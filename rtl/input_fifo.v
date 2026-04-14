`timescale 1ns / 1ps

module input_fifo (
    // Write Domain (e.g., from AXI DMA)
    input  wire         wr_clk_i,
    input  wire         rst_i,      // Active high reset for XPM
    input  wire         wr_en_i,
    input  wire [127:0] din_i,
    output wire         full_o,

    // Read Domain (e.g., to Systolic Array)
    input  wire         rd_clk_i,
    input  wire         rd_en_i,
    
    output wire         empty_o,
    output wire [127:0] dout_o
);
    parameter ROW = 16, COL = 16;

//////////////////////////////////////////////////////////////////////////////////
//                             Input FIFO declaration                           //
//////////////////////////////////////////////////////////////////////////////////
    wire [127:0] fifo_dout_w;
    xpm_fifo_async #(
        .FIFO_MEMORY_TYPE("block"),    // Force synthesis into BRAM
        .WRITE_DATA_WIDTH(128),        // 128-bit input
        .READ_DATA_WIDTH(128),         // 128-bit output
        .FIFO_WRITE_DEPTH(256),        // Depth of 256 words
        .READ_MODE("fwft"),            // First-Word-Fall-Through
        .FIFO_READ_LATENCY(0),             
        .CDC_SYNC_STAGES(2),           // Safe cross-clock domain synchronization
        .USE_ADV_FEATURES("0000")      // Disable advanced counters to save resources
    ) xpm_fifo_inst (
        .wr_clk(wr_clk_i),
        .rd_clk(rd_clk_i),
        .rst(rst_i),
        .wr_en(wr_en_i),
        .din(din_i),
        .rd_en(rd_en_i),
        .dout(fifo_dout_w),
        .full(full_o),
        .empty(empty_o),
        
        // Unused advanced ports tied off
        .sleep(1'b0),
        .injectsbiterr(1'b0),
        .injectdbiterr(1'b0)
    );
    
//////////////////////////////////////////////////////////////////////////////////
//               Split read data: 128 bit -> 8b data x 16 width                 //
//////////////////////////////////////////////////////////////////////////////////    
    
    wire [7:0] fifo_split_data_w [0:15];
    genvar r, c, d;
    generate
        for (r = 0; r < 16; r = r + 1) begin: IN_FIFO_SPLIT_DATA
            assign fifo_split_data_w[r] = fifo_dout_w[r*8 + 7 : r*8];
        end
    endgenerate
    
    
//////////////////////////////////////////////////////////////////////////////////
//                      Chained delay register (INPUT FIFO)                     //
//////////////////////////////////////////////////////////////////////////////////
    
    // We need a 2D array of registers to act as our delay pipelines
    reg [7:0]   inff_delay_r [0:15][0:15]; 
    wire [7:0]  pe_input_data_w [0:15]; // The final, properly staggered data
    
    
    generate
        for (r = 0; r < 16; r = r + 1) begin : INPUT_DELAY_CHAIN
            
            if (r == 0) begin
                // Row 0 goes straight through, no delay needed!
                assign pe_input_data_w[0] = fifo_split_data_w[0];
                
            end else begin
                // Create a shift register chain for row 'r' that is 'r' stages deep
                
                // First stage catches the raw unpacked data
                always @(posedge rd_clk_i) begin
                    inff_delay_r[r][0] <= fifo_split_data_w[r]; 
                end
                
                // Middle stages (if any) daisy-chain together
                for (d = 1; d < r; d = d + 1) begin : SKEW_STAGE
                    always @(posedge rd_clk_i) begin
                        inff_delay_r[r][d] <= inff_delay_r[r][d-1];
                    end
                end
                
                // The final output of this row's chain goes to the systolic array
                assign pe_input_data_w[r] = inff_delay_r[r][r-1];
            end
        end
    endgenerate
  
//////////////////////////////////////////////////////////////////////////////////
//               Merge read data: 8b data x 16 width  -> 128 bit                //
//////////////////////////////////////////////////////////////////////////////////     
    generate
        for (r = 0; r < 16; r = r + 1) begin: IN_FIFO_MERGE_DATA
            assign dout_o[r*8 + 7 : r*8] = pe_input_data_w[r];
        end
    endgenerate

endmodule