`timescale 1ns / 1ps

module systolic_array(
        input wire      clk_i,
        input wire      rst_n,
        input wire      start_i,
        input wire      loadweight_i,
        output wire     done_o
    );

    wire pe_en_w;
    wire  w_ff_rd_w, in_ff_rd_w, out_ff_wr_w;


    controller ctrl(
        .clk_i (clk_i),
        .rst_n  (rst_n),          
        .loadweight_i (loadweight_i),   // Load weight signal
        .start_i (start_i),        // Start execution + output collection
        
        .in_ff_rd_o (in_ff_rd_w),       // Input FIFO read (only applies to the first FIFO, latter ones are mapped to shift register)
        .w_ff_rd_o (w_ff_rd_w),      // Weight FIFO read (applies to all FIFO)
        .out_ff_wr_o (out_ff_wr_w),    // Output FIFO write (only applies to the first FIFO, latter ones are mapped to shift register)
        .pe_en_o      (pe_en_w)        // PE enable signal
);
   
    

    
    // horizontal_wires[row][column]
    wire [7:0]  input_w [0:15][0:16]; 
    
    
    // vertical_wires[row][column]
    wire [7:0]  weight_w [0:16][0:15];
    wire [31:0] psum_w   [0:16][0:15]; 
    
    genvar r, c, d;
    generate
        for (c = 0; c < 16; c = c + 1) begin : INIT_PSUM_ROW
            assign psum_w[0][c] = 0;
        end
    endgenerate
    
    
    
    generate
        for (r = 0; r < 16; r = r + 1) begin  
            for (c = 0; c < 16; c = c + 1) begin  
                
                // Instantiate the PE
                pe u_pe (
                    .clk_i(clk_i),
                    .rst_n(rst_n),
                    

                    .en_i(pe_en_w), 
                    
                    .weight_i (weight_w [r][c]),
                    .weight_o (weight_w [r+1][c]),    
                    
                    .in_i(input_w[r][c]),      // Grab wire from the left
                    .out_o(input_w[r][c+1]),   // Push to wire on the right
                    
                    .psum_i(psum_w[r][c]),      // Grab wire from above
                    .psum_o(psum_w[r+1][c])     // Push to wire below
                );
                
            end
        end
    endgenerate
    
    // We need a 2D array of registers to act as our delay pipelines
    reg [7:0]   delay_regs [0:15][0:15]; 
    wire [7:0]  pe_in_data [0:15]; // The final, properly staggered data
    wire [31:0] pe_out_data [0:15];
    
    wire [7:0] inff_data [0:15];
    wire [7:0] outff_data [0:15];
    
    generate
        for (r = 0; r < 16; r = r + 1) begin : SKEW_ROW
            
            if (r == 0) begin
                // Row 0 goes straight through, no delay needed!
                assign pe_in_data[0] = inff_data[0];
                
            end else begin
                // Create a shift register chain for row 'r' that is 'r' stages deep
                
                // First stage catches the raw unpacked data
                always @(posedge clk_i) begin
                    delay_regs[r][0] <= inff_data[r]; 
                end
                
                // Middle stages (if any) daisy-chain together
                for (d = 1; d < r; d = d + 1) begin : SKEW_STAGE
                    always @(posedge clk_i) begin
                        delay_regs[r][d] <= delay_regs[r][d-1];
                    end
                end
                
                // The final output of this row's chain goes to the systolic array
                assign pe_in_data[r] = delay_regs[r][r-1];
            end
            
        end
    endgenerate
 endmodule