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


`timescale 1ns / 1ps

module accelerator_top #(
    parameter SYS_N = 16,
    parameter DATA_WIDTH = 8,
    parameter PSUM_WIDTH = 32
)(
    input  wire        clk_i,
    input  wire        rst_ni,

    // ==========================================
    // CỔNG ĐIỀU KHIỂN (Nối với CPU ARM qua AXI-Lite)
    // ==========================================
    input  wire        start_i,
    input  wire [15:0] dim_m_i,
    input  wire [15:0] dim_k_i,
    input  wire [15:0] dim_n_i,
    output wire        done_o,

    // ==========================================
    // CỔNG DMA NẠP BRAM A (Ma trận Input)
    // ==========================================
    input  wire        dma_we_a_i,
    input  wire [8:0]  dma_addr_a_i,
    input  wire [127:0] dma_data_a_i,

    // ==========================================
    // CỔNG DMA NẠP BRAM B (Ma trận Trọng số)
    // ==========================================
    input  wire        dma_we_b_i,
    input  wire [8:0]  dma_addr_b_i,
    input  wire [127:0] dma_data_b_i,

    // ==========================================
    // CỔNG DMA HÚT BRAM C (Ma trận Kết quả)
    // ==========================================
    input  wire        dma_re_c_i,
    input  wire [8:0]  dma_addr_c_i,
    output wire [511:0] dma_data_c_o
);

    // ==========================================
    // DÂY KẾT NỐI GIỮA TILING AGU VÀ BRAMs
    // ==========================================
    wire [31:0] agu_brama_addr_w;
    wire        agu_brama_en_w;
    wire [127:0] brama_dout_w;

    wire [31:0] agu_bramb_addr_w;
    wire        agu_bramb_en_w;
    wire [127:0] bramb_dout_w;

    wire [31:0] agu_bramc_rd_addr_w;
    wire        agu_bramc_rd_en_w;
    wire [511:0] bramc_rd_dout_w;

    wire [31:0] agu_bramc_wr_addr_w;
    wire        agu_bramc_wr_en_w;
    wire        agu_bramc_wr_we_w;
    wire [511:0] agu_bramc_wr_din_w;

    wire sys_done_w;
    assign done_o = sys_done_w;

    // ==========================================
    // BRAM A (Chiều sâu 256 đủ cho Tiling 64x64 Single Buffer)
    // ==========================================
    tdp_bram #(
        .DATA_WIDTH(128), .ADDR_WIDTH(9), .RAM_DEPTH(256)
    ) BRAM_A (
        // Port A: Dành cho DMA Nạp vào
        .clk_a(clk_i), .en_a(dma_we_a_i), .we_a(dma_we_a_i),
        .addr_a(dma_addr_a_i), .din_a(dma_data_a_i), .dout_a(),
        
        // Port B: Dành cho AGU Đọc ra Lõi PE
        .clk_b(clk_i), .en_b(agu_brama_en_w), .we_b(1'b0),
        .addr_b(agu_brama_addr_w[8:0]), .din_b(128'd0), 
        .dout_b(brama_dout_w)
    );

    // ==========================================
    // BRAM B (Chiều sâu 256)
    // ==========================================
    tdp_bram #(
        .DATA_WIDTH(128), .ADDR_WIDTH(9), .RAM_DEPTH(256)
    ) BRAM_B (
        // Port A: Dành cho DMA Nạp vào
        .clk_a(clk_i), .en_a(dma_we_b_i), .we_a(dma_we_b_i),
        .addr_a(dma_addr_b_i), .din_a(dma_data_b_i), .dout_a(),
        
        // Port B: Dành cho AGU Đọc ra Lõi PE
        .clk_b(clk_i), .en_b(agu_bramb_en_w), .we_b(1'b0),
        .addr_b(agu_bramb_addr_w[8:0]), .din_b(128'd0), 
        .dout_b(bramb_dout_w)
    );

    // ==========================================
    // MUX CHIẾM QUYỀN ĐIỀU KHIỂN BRAM C (PORT A)
    // ==========================================
    // Nếu hệ thống chạy xong (sys_done_w == 1), nhường quyền Port A cho DMA
    wire        mux_bramc_en_a   = sys_done_w ? dma_re_c_i   : agu_bramc_rd_en_w;
    wire [8:0]  mux_bramc_addr_a = sys_done_w ? dma_addr_c_i : agu_bramc_rd_addr_w[8:0];
    wire [511:0] bramc_dout_a_w;

    // Dữ liệu đọc ra từ BRAM C tách làm 2 đường cho AGU và DMA
    // DMA chỉ đọc được dữ liệu đúng khi nó được cấp quyền cấp địa chỉ
    assign bramc_rd_dout_w = bramc_dout_a_w; // Đưa ngược lại AGU
    assign dma_data_c_o    = bramc_dout_a_w; // Đưa ra ngoài cho DMA hút

    // ==========================================
    // BRAM C (Ma trận Psum 32-bit - Rộng 512-bit)
    // ==========================================
    tdp_bram #(
        .DATA_WIDTH(512), .ADDR_WIDTH(9), .RAM_DEPTH(256)
    ) BRAM_C (
        // Port A: DÙNG CHUNG (AGU đọc Psum cũ / DMA hút kết quả về)
        .clk_a(clk_i), 
        .en_a(mux_bramc_en_a), 
        .we_a(1'b0), // Cả AGU và DMA đều chỉ đọc ở Port này
        .addr_a(mux_bramc_addr_a), 
        .din_a(512'd0), 
        .dout_a(bramc_dout_a_w),
        
        // Port B: DÀNH RIÊNG CHO AGU (AGU ghi Psum mới vào)
        .clk_b(clk_i), 
        .en_b(agu_bramc_wr_en_w), 
        .we_b(agu_bramc_wr_we_w),
        .addr_b(agu_bramc_wr_addr_w[8:0]), 
        .din_b(agu_bramc_wr_din_w), 
        .dout_b() // Không cần đọc từ Port B
    );

    // ==========================================
    // KHỐI QUẢN LÝ VÀ ĐIỀU KHIỂN (TILING AGU + PE GRID)
    // ==========================================
    tiling_agu #(
        .SYS_N(SYS_N),
        .DATA_WIDTH(DATA_WIDTH),
        .PSUM_WIDTH(PSUM_WIDTH)
    ) agu_inst (
        .clk_i           (clk_i),
        .rst_ni          (rst_ni),
        .start_i         (start_i),
        
        .dim_m_i         (dim_m_i),
        .dim_k_i         (dim_k_i),
        .dim_n_i         (dim_n_i),
        .done_o          (sys_done_w),
        
        .brama_addr_o    (agu_brama_addr_w),
        .brama_en_o      (agu_brama_en_w),
        .brama_dout_i    (brama_dout_w),
        
        .bramb_addr_o    (agu_bramb_addr_w),
        .bramb_en_o      (agu_bramb_en_w),
        .bramb_dout_i    (bramb_dout_w),
        
        .bramc_rd_addr_o (agu_bramc_rd_addr_w),
        .bramc_rd_en_o   (agu_bramc_rd_en_w),
        .bramc_rd_dout_i (bramc_rd_dout_w),
        
        .bramc_wr_addr_o (agu_bramc_wr_addr_w),
        .bramc_wr_en_o   (agu_bramc_wr_en_w),
        .bramc_wr_we_o   (agu_bramc_wr_we_w),
        .bramc_wr_din_o  (agu_bramc_wr_din_w)
    );

endmodule