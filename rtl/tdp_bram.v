`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/18/2026 08:04:41 PM
// Design Name: 
// Module Name: tdp_bram
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

module tdp_bram #(
    parameter DATA_WIDTH = 128,  // Độ rộng dữ liệu
    parameter ADDR_WIDTH = 9,    // Độ rộng địa chỉ
    parameter RAM_DEPTH  = 512   // Chiều sâu (Số dòng)
)(
    // ================= PORT A =================
    input  wire                   clk_a,
    input  wire                   en_a,
    input  wire                   we_a,
    input  wire [ADDR_WIDTH-1:0]  addr_a,
    input  wire [DATA_WIDTH-1:0]  din_a,
    output reg  [DATA_WIDTH-1:0]  dout_a,

    // ================= PORT B =================
    input  wire                   clk_b,
    input  wire                   en_b,
    input  wire                   we_b,
    input  wire [ADDR_WIDTH-1:0]  addr_b,
    input  wire [DATA_WIDTH-1:0]  din_b,
    output reg  [DATA_WIDTH-1:0]  dout_b
);

    // Thuộc tính ép Vivado sử dụng Block RAM (BRAM) thay vì LUTRAM
    (* ram_style = "block" *) reg [DATA_WIDTH-1:0] ram_memory [0:RAM_DEPTH-1];

    // Xử lý Cổng A
    always @(posedge clk_a) begin
        if (en_a) begin
            if (we_a) begin
                ram_memory[addr_a] <= din_a;
            end
            // Hành vi chuẩn của BRAM: Data xuất hiện sau 1 nhịp clock
            dout_a <= ram_memory[addr_a]; 
        end
    end

    // Xử lý Cổng B
    always @(posedge clk_b) begin
        if (en_b) begin
            if (we_b) begin
                ram_memory[addr_b] <= din_b;
            end
            dout_b <= ram_memory[addr_b];
        end
    end

endmodule