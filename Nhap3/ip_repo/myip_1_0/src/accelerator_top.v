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
    
    // Cổng điều khiển từ CPU
    input  wire        start_i,
    input  wire        dma_bank_i, // 0: Ping, 1: Pong cho DMA
    input  wire        agu_bank_i, // 0: Ping, 1: Pong cho AGU
    input  wire [15:0] dim_m_i,
    input  wire [15:0] dim_k_i,
    input  wire [15:0] dim_n_i,
    output wire        done_o,

    // Cổng DMA Nạp BRAM A
    input  wire        dma_we_a_i,
    input  wire [8:0]  dma_addr_a_i,
    input  wire [(SYS_N*DATA_WIDTH)-1:0] dma_data_a_i,

    // Cổng DMA Nạp BRAM B
    input  wire        dma_we_b_i,
    input  wire [8:0]  dma_addr_b_i,
    input  wire [(SYS_N*DATA_WIDTH)-1:0] dma_data_b_i,

    // Cổng DMA Hút BRAM C
    input  wire        dma_re_c_i,
    input  wire [8:0]  dma_addr_c_i,
    output wire [(SYS_N*PSUM_WIDTH)-1:0] dma_data_c_o
);

    // =========================================
    // DÂY KẾT NỐI NỘI BỘ
    // =========================================
    wire [31:0] agu_brama_addr_w, agu_bramb_addr_w;
    wire        agu_brama_en_w, agu_bramb_en_w;
    wire [(SYS_N*DATA_WIDTH)-1:0] brama_dout_w, bramb_dout_w;

    wire [31:0] agu_bramc_rd_addr_w, agu_bramc_wr_addr_w;
    wire        agu_bramc_rd_en_w, agu_bramc_wr_en_w, agu_bramc_wr_we_w;
    wire [(SYS_N*PSUM_WIDTH)-1:0] agu_bramc_wr_din_w;
    wire [(SYS_N*PSUM_WIDTH)-1:0] bramc_rd_dout_w;

    // =========================================
    // BRAM A (Ma trận Input - Ping-Pong 1024 dòng)
    // =========================================
    tdp_bram #(.DATA_WIDTH(128), .ADDR_WIDTH(10), .RAM_DEPTH(1024)) BRAM_A (
        .clk_a(clk_i), .en_a(dma_we_a_i), .we_a(dma_we_a_i),
        .addr_a({dma_bank_i, dma_addr_a_i}), 
        .din_a(dma_data_a_i), .dout_a(),
        
        .clk_b(clk_i), .en_b(agu_brama_en_w), .we_b(1'b0),
        .addr_b({agu_bank_i, agu_brama_addr_w[8:0]}), 
        .din_b(128'd0), .dout_b(brama_dout_w)
    );

    // =========================================
    // BRAM B (Ma trận Trọng số - Ping-Pong 1024 dòng)
    // =========================================
    tdp_bram #(.DATA_WIDTH(128), .ADDR_WIDTH(10), .RAM_DEPTH(1024)) BRAM_B (
        .clk_a(clk_i), .en_a(dma_we_b_i), .we_a(dma_we_b_i),
        .addr_a({dma_bank_i, dma_addr_b_i}),
        .din_a(dma_data_b_i), .dout_a(),
        
        .clk_b(clk_i), .en_b(agu_bramb_en_w), .we_b(1'b0),
        .addr_b({agu_bank_i, agu_bramb_addr_w[8:0]}), 
        .din_b(128'd0), .dout_b(bramb_dout_w)
    );

    // =========================================
    // BRAM C (Ma trận Kết quả - TÁCH VẬT LÝ CHO PING-PONG)
    // =========================================
    wire [8:0] agu_c_rd_addr = agu_bramc_rd_addr_w[8:0];
    wire [8:0] agu_c_wr_addr = agu_bramc_wr_addr_w[8:0];

    // --- Khối PING (Bank 0) ---
    // Port A: Cấp cho DMA nếu dma_bank = 0, Cấp cho AGU đọc nếu agu_bank = 0
    wire        ping_en_a   = (dma_bank_i == 1'b0) ? (dma_re_c_i | 1'b1) : 
                              (agu_bank_i == 1'b0) ? agu_bramc_rd_en_w : 1'b0;
    wire [8:0]  ping_addr_a = (dma_bank_i == 1'b0) ? dma_addr_c_i : 
                              (agu_bank_i == 1'b0) ? agu_c_rd_addr : 9'd0;
    wire [(SYS_N*PSUM_WIDTH)-1:0] ping_dout_a;

    // Port B: Dành riêng cho AGU ghi (nếu agu_bank = 0)
    wire        ping_en_b   = (agu_bank_i == 1'b0) ? agu_bramc_wr_en_w : 1'b0;
    wire        ping_we_b   = (agu_bank_i == 1'b0) ? agu_bramc_wr_we_w : 1'b0;

    tdp_bram #(.DATA_WIDTH(512), .ADDR_WIDTH(9), .RAM_DEPTH(512)) BRAM_C_PING (
        .clk_a(clk_i), .en_a(ping_en_a), .we_a(1'b0), .addr_a(ping_addr_a), 
        .din_a(512'd0), .dout_a(ping_dout_a),
        
        .clk_b(clk_i), .en_b(ping_en_b), .we_b(ping_we_b), .addr_b(agu_c_wr_addr), 
        .din_b(agu_bramc_wr_din_w), .dout_b()
    );

    // --- Khối PONG (Bank 1) ---
    // Port A: Cấp cho DMA nếu dma_bank = 1, Cấp cho AGU đọc nếu agu_bank = 1
    wire        pong_en_a   = (dma_bank_i == 1'b1) ? (dma_re_c_i | 1'b1) : 
                              (agu_bank_i == 1'b1) ? agu_bramc_rd_en_w : 1'b0;
    wire [8:0]  pong_addr_a = (dma_bank_i == 1'b1) ? dma_addr_c_i : 
                              (agu_bank_i == 1'b1) ? agu_c_rd_addr : 9'd0;
    wire [(SYS_N*PSUM_WIDTH)-1:0] pong_dout_a;

    // Port B: Dành riêng cho AGU ghi (nếu agu_bank = 1)
    wire        pong_en_b   = (agu_bank_i == 1'b1) ? agu_bramc_wr_en_w : 1'b0;
    wire        pong_we_b   = (agu_bank_i == 1'b1) ? agu_bramc_wr_we_w : 1'b0;

    tdp_bram #(.DATA_WIDTH(512), .ADDR_WIDTH(9), .RAM_DEPTH(512)) BRAM_C_PONG (
        .clk_a(clk_i), .en_a(pong_en_a), .we_a(1'b0), .addr_a(pong_addr_a), 
        .din_a(512'd0), .dout_a(pong_dout_a),
        
        .clk_b(clk_i), .en_b(pong_en_b), .we_b(pong_we_b), .addr_b(agu_c_wr_addr), 
        .din_b(agu_bramc_wr_din_w), .dout_b()
    );

    // --- ĐIỀU HƯỚNG DỮ LIỆU ĐẦU RA ---
    // Trả Psum cũ về cho AGU dựa trên Bank mà AGU đang làm việc
    assign bramc_rd_dout_w = (agu_bank_i == 1'b0) ? ping_dout_a : pong_dout_a;
    
    // Đẩy kết quả ra cho DMA hút dựa trên Bank mà DMA đang chỉ định
    assign dma_data_c_o    = (dma_bank_i == 1'b0) ? ping_dout_a : pong_dout_a;

    // =========================================
    // TILING AGU & PE GRID
    // =========================================
    tiling_agu #(.SYS_N(SYS_N)) agu_inst (
        .clk_i(clk_i), .rst_ni(rst_ni), .start_i(start_i),
        .dim_m_i(dim_m_i), .dim_k_i(dim_k_i), .dim_n_i(dim_n_i),
        .done_o(done_o),
        
        .brama_addr_o(agu_brama_addr_w), .brama_en_o(agu_brama_en_w), .brama_dout_i(brama_dout_w),
        .bramb_addr_o(agu_bramb_addr_w), .bramb_en_o(agu_bramb_en_w), .bramb_dout_i(bramb_dout_w),
        
        .bramc_rd_addr_o(agu_bramc_rd_addr_w), .bramc_rd_en_o(agu_bramc_rd_en_w), .bramc_rd_dout_i(bramc_rd_dout_w),
        
        .bramc_wr_addr_o(agu_bramc_wr_addr_w), .bramc_wr_en_o(agu_bramc_wr_en_w), 
        .bramc_wr_we_o(agu_bramc_wr_we_w), .bramc_wr_din_o(agu_bramc_wr_din_w)
    );

endmodule