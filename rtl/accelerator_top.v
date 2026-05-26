`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/18/2026 08:03:25 PM
// Design Name: 
// Module Name: accelerator_top
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



module accelerator_top #(
    parameter SYS_N = 16,
    parameter DATA_WIDTH = 8,
    parameter PSUM_WIDTH = 32
)(
    input  wire        clk_i,
    input  wire        rst_ni,
    
    // Cổng điều khiển từ CPU (thêm bank_sel)
    input  wire        start_i,
    input  wire        dma_bank_i, // 0: Ping, 1: Pong cho DMA
    input  wire        agu_bank_i, // 0: Ping, 1: Pong cho AGU
    input  wire [15:0] dim_m_i,
    input  wire [15:0] dim_k_i,
    input  wire [15:0] dim_n_i,
    output wire        done_o,

    // Cổng DMA
    input  wire        dma_we_a_i,
    input  wire [8:0]  dma_addr_a_i,
    input  wire [(SYS_N*DATA_WIDTH)-1:0] dma_data_a_i,

    input  wire        dma_we_b_i,
    input  wire [8:0]  dma_addr_b_i,
    input  wire [(SYS_N*DATA_WIDTH)-1:0] dma_data_b_i,

    input  wire        dma_re_c_i,
    input  wire [8:0]  dma_addr_c_i,
    output wire [(SYS_N*PSUM_WIDTH)-1:0] dma_data_c_o
);

    // =========================================
    // NỐI DÂY NỘI BỘ
    // =========================================
    wire [31:0] agu_brama_addr_w, agu_bramb_addr_w, agu_bramc_wr_addr_w;
    wire        agu_brama_en_w, agu_bramb_en_w, agu_bramc_wr_en_w, agu_bramc_wr_we_w;
    wire [(SYS_N*PSUM_WIDTH)-1:0] agu_bramc_wr_din_w;
    wire [(SYS_N*DATA_WIDTH)-1:0] brama_dout_w, bramb_dout_w;
    wire [(SYS_N*PSUM_WIDTH)-1:0] bramc_dout_a_w;

    // =========================================
    // BRAM A (Ping-Pong: 512 dòng, 10-bit addr)
    // =========================================
    tdp_bram #(.DATA_WIDTH(128), .ADDR_WIDTH(10), .RAM_DEPTH(512)) BRAM_A (
        .clk_a(clk_i), .en_a(dma_we_a_i), .we_a(dma_we_a_i),
        .addr_a({dma_bank_i, dma_addr_a_i}), 
        .din_a(dma_data_a_i), .dout_a(),
        .clk_b(clk_i), .en_b(agu_brama_en_w), .we_b(1'b0),
        .addr_b({agu_bank_i, agu_brama_addr_w[8:0]}), .din_b(128'd0), .dout_b(brama_dout_w)
    );

    // =========================================
    // BRAM B (Ping-Pong: 512 dòng)
    // =========================================
    tdp_bram #(.DATA_WIDTH(128), .ADDR_WIDTH(10), .RAM_DEPTH(512)) BRAM_B (
        .clk_a(clk_i), .en_a(dma_we_b_i), .we_a(dma_we_b_i),
        .addr_a({dma_bank_i, dma_addr_b_i}),
        .din_a(dma_data_b_i), .dout_a(),
        .clk_b(clk_i), .en_b(agu_bramb_en_w), .we_b(1'b0),
        .addr_b({agu_bank_i, agu_bramb_addr_w[8:0]}), .din_b(128'd0), .dout_b(bramb_dout_w)
    );

    // =========================================
    // BRAM C (Ping-Pong: 512 dòng)
    // =========================================
    tdp_bram #(.DATA_WIDTH(512), .ADDR_WIDTH(10), .RAM_DEPTH(512)) BRAM_C (
        // Port A: DMA đọc kết quả / AGU đọc psum cũ
        .clk_a(clk_i), .en_a(dma_re_c_i | 1'b1), .we_a(1'b0),
        .addr_a({dma_bank_i, dma_addr_c_i}), 
        .din_a(512'd0), .dout_a(dma_data_c_o),
        
        // Port B: AGU ghi psum mới
        .clk_b(clk_i), .en_b(agu_bramc_wr_en_w), .we_b(agu_bramc_wr_we_w),
        .addr_b({agu_bank_i, agu_bramc_wr_addr_w[8:0]}), .din_b(agu_bramc_wr_din_w), .dout_b()
    );

    // =========================================
    // TILING AGU & PE GRID
    // =========================================
    tiling_agu #(.SYS_N(SYS_N)) agu_inst (
        .clk_i(clk_i), .rst_ni(rst_ni), .start_i(start_i),
        .dim_m_i(dim_m_i), .dim_k_i(dim_k_i), .dim_n_i(dim_n_i),
        .done_o(done_o),
        
        .brama_addr_o(agu_brama_addr_w), .brama_en_o(agu_brama_en_w), .brama_dout_i(brama_dout_w),
        .bramb_addr_o(agu_bramb_addr_w), .bramb_en_o(agu_bramb_en_w), .bramb_dout_i(bramb_dout_w),
        .bramc_rd_addr_o(), .bramc_rd_en_o(), .bramc_rd_dout_i(bramc_dout_a_w),
        .bramc_wr_addr_o(agu_bramc_wr_addr_w), .bramc_wr_en_o(agu_bramc_wr_en_w), 
        .bramc_wr_we_o(agu_bramc_wr_we_w), .bramc_wr_din_o(agu_bramc_wr_din_w)
    );

endmodule