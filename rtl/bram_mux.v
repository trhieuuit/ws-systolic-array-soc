`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/12/2026 08:23:56 AM
// Design Name: 
// Module Name: bram_mux
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



module bram_mux #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 512,
    // Số lượng bit Write Enable = DATA_WIDTH / 8 (Mỗi bit quản lý 1 byte)
    parameter WE_WIDTH   = 64 
)(
    // Tín hiệu chọn luồng (Từ AXI GPIO)
    // 0 = CPU dùng Port A (Có thể Đọc/Ghi)
    // 1 = AGU dùng Port A (Chỉ Đọc)
    input  wire                  sel_agu_i, 
    
    // ==========================================
    // PORT 1: Giao tiếp với Zynq CPU (Từ AXI BRAM Controller)
    // ==========================================
    input  wire [ADDR_WIDTH-1:0] cpu_addr_i,
    input  wire                  cpu_en_i,
    input  wire [WE_WIDTH-1:0]   cpu_we_i,
    input  wire [DATA_WIDTH-1:0] cpu_din_i,
    output wire [DATA_WIDTH-1:0] cpu_dout_o,
    
    // ==========================================
    // PORT 2: Giao tiếp với IP tiling_agu (AGU Read Port)
    // ==========================================
    input  wire [ADDR_WIDTH-1:0] agu_addr_i,
    input  wire                  agu_en_i,
    output wire [DATA_WIDTH-1:0] agu_dout_o,
    
    // ==========================================
    // MASTER PORT: Nối vào Port A của BRAM C
    // ==========================================
    output wire [ADDR_WIDTH-1:0] bram_addr_o,
    output wire                  bram_en_o,
    output wire [WE_WIDTH-1:0]   bram_we_o,
    output wire [DATA_WIDTH-1:0] bram_din_o,
    input  wire [DATA_WIDTH-1:0] bram_dout_i
);

    // MẠCH CHUYỂN KÊNH (COMBINATIONAL LOGIC)
    
    // 1. Phân luồng tín hiệu đi VÀO BRAM
    assign bram_addr_o = sel_agu_i ? agu_addr_i         : cpu_addr_i;
    assign bram_en_o   = sel_agu_i ? agu_en_i           : cpu_en_i;
    
    // AGU chỉ dùng cổng này để ĐỌC, nên khi sel_agu_i = 1, ép WE và DIN về 0
    assign bram_we_o   = sel_agu_i ? {WE_WIDTH{1'b0}}   : cpu_we_i; 
    assign bram_din_o  = sel_agu_i ? {DATA_WIDTH{1'b0}} : cpu_din_i;
    
    // 2. Phân luồng tín hiệu trả TỪ BRAM ra ngoài
    // Dữ liệu đọc ra cứ phát song song cho cả 2 bên, ai đang có quyền thì bên đó tự lấy dùng
    assign agu_dout_o  = bram_dout_i;
    assign cpu_dout_o  = bram_dout_i;

endmodule