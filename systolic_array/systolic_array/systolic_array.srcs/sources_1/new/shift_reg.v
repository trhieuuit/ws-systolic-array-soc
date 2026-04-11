`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2026 02:57:16 PM
// Design Name: 
// Module Name: shift_reg
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


module shift_reg(
    input wire         clk_i,
    input wire         rst_n,
    input wire         en_i,
    input wire         in_i,       
    output reg  [14:0] out_o
    );
    
    always @(posedge clk_i or rst_n) begin
        if (rst_n) begin
            out_o <= 15'b0;
        end else if (en_i) begin
            out_o <= {out_o[13:0], in_i};
        end 
    end 

endmodule
