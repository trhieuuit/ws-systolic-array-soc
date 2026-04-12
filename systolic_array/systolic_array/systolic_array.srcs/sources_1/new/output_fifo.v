`timescale 1ns / 1ps

module output_fifo (
    input  wire         wr_clk_i,
    input  wire         rst_i,      // Active high reset for XPM
    
    // Write Domain (e.g., from PE)
    input  wire         wr_en_i,
    input  wire [511:0] din_i,
    output wire         full_o,

    // Read Domain (e.g., to DMA)
    input  wire         rd_clk_i,
    input  wire         rd_en_i,
    output wire         empty_o,
    output wire [511:0] dout_o
);


    
//////////////////////////////////////////////////////////////////////////////////
//               Split read data: 512 bit -> 32b data x 16 width                 //
//////////////////////////////////////////////////////////////////////////////////    
    wire [31:0] fifo_split_data_w [0:15]; 
    genvar r, c, d;
    
    generate
        for (c = 0; c < 16; c = c + 1) begin: IN_FIFO_SPLIT_DATA
            assign fifo_split_data_w[c] = din_i[c*32 + 31 : c*32];
        end
    endgenerate
    
    
//////////////////////////////////////////////////////////////////////////////////
//                      Chained delay register (OUTPUT FIFO)                    //
//////////////////////////////////////////////////////////////////////////////////
    
    // We need a 2D array of registers to act as our delay pipelines
    reg  signed [31:0]   outff_delay_r [0:15][0:15]; 
    wire signed [31:0]  fifo_input_data_w [0:15]; // The final, properly staggered data
    
    
    generate
        for (c = 0; c < 16; c = c + 1) begin : OUTPUT_DELAY_CHAIN
            
            if (c == 15) begin
                // Column 15 arrives last, so it goes straight through, no delay needed!
                assign fifo_input_data_w[c] = fifo_split_data_w[c]; 
                
            end else begin
                // Columns 0 through 14 arrive early and must wait in a shift register.
                // Col 0 waits 15 cycles. Col 14 waits 1 cycle.
                
                // First stage catches the raw unpacked data from the PE grid
                always @(posedge wr_clk_i) begin
                    outff_delay_r[0][c] <= fifo_split_data_w[c]; 
                end
                
                // Middle stages (if any) daisy-chain together
                for (d = 1; d < 15; d = d + 1) begin : SKEW_STAGE
                    
                    always @(posedge wr_clk_i) begin
                       outff_delay_r[d][c] <= outff_delay_r[d-1][c];
                    end
                    
                end
                
                // The final output of this column's chain goes to the FIFO write data
                // If c = 0, last index is 14 (14 - 0). Delay = 15 cycles.
                // If c = 14, last index is 0 (14 - 14). Delay = 1 cycle.
                assign fifo_input_data_w[c] = outff_delay_r[14 - c][c];
            end
            
        end
    endgenerate

//////////////////////////////////////////////////////////////////////////////////
//               Merge read data: 8b data x 16 width  -> 128 bit                //
//////////////////////////////////////////////////////////////////////////////////  
    wire [511:0] fifo_din_w;   
    generate
        for (c = 0; c < 16; c = c + 1) begin: OUT_FIFO_MERGE_DATA
            assign  fifo_din_w[c*32 + 31 : c*32] = fifo_input_data_w[c];
        end
    endgenerate
    

//////////////////////////////////////////////////////////////////////////////////
//                             Output FIFO declaration                          //
//////////////////////////////////////////////////////////////////////////////////
   
    xpm_fifo_async #(
        .FIFO_MEMORY_TYPE("block"),    // Force synthesis into BRAM
        .WRITE_DATA_WIDTH(512),        // 128-bit input
        .READ_DATA_WIDTH(512),         // 128-bit output
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
        .din(fifo_din_w),
        .rd_en(rd_en_i),
        .dout(dout_o),
        .full(full_o),
        .empty(empty_o),
        
        // Unused advanced ports tied off
        .sleep(1'b0),
        .injectsbiterr(1'b0),
        .injectdbiterr(1'b0)
    );
  

endmodule