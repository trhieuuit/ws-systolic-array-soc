`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2026 03:52:28 PM
// Design Name: 
// Module Name: weight_fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module weight_fifo(
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

    
//////////////////////////////////////////////////////////////////////////////////
//                             Weight FIFO declaration                          //
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
        .dout(dout_o),
        .full(full_o),
        .empty(empty_o),
        
        // Unused advanced ports tied off
        .sleep(1'b0),
        .injectsbiterr(1'b0),
        .injectdbiterr(1'b0)
    );
endmodule
