`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2026 05:47:47 PM
// Design Name: 
// Module Name: pe_grid
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


module pe_grid(
    input wire          clk_i,
    input wire          rst_n,
    input wire          loadw_i,
    input wire          en_i,
    input wire  [127:0] weight_i,
    input wire  [127:0] input_i,
    output wire [511:0] output_o
);

     // horizontal_wires[row][column]
    wire signed [7:0]  input_pe_w [0:15][0:16]; 
    
    // vertical_wires[row][column]
    wire signed [7:0]  weight_pe_w [0:16][0:15];
    wire signed [31:0] psum_pe_w   [0:16][0:15]; 
   
    genvar r, c;
    generate
        // 1. INPUT ASSIGN (Rows)
        for (r = 0; r < 16; r = r + 1) begin : INPUT_ASSIGN
            assign input_pe_w[r][0] = input_i[r*8 + 7 : r*8];
        end
        
        // 2. WEIGHT ASSIGN (Columns) 
        for (c = 0; c < 16; c = c + 1) begin : WEIGHT_ASSIGN
            assign weight_pe_w[0][c] = weight_i[c*8 + 7 : c*8];
        end
        
        // 3. OUTPUT ASSIGN (Columns) 
        for (c = 0; c < 16; c = c + 1) begin : OUTPUT_ASSIGN
            assign output_o[c*32 + 31 : c*32] = psum_pe_w[16][c];
        end
    endgenerate
    
    generate
        for (r = 0; r < 16; r = r + 1) begin : PE_ROW
            if (r == 0) begin : TOP_ROW_INIT
                for (c = 0; c < 16; c = c + 1) begin : ZERO_COL
                    assign psum_pe_w[0][c] = 32'sd0;
                end
            end 
            
            for (c = 0; c < 16; c = c + 1) begin  : PE_COL
                // Instantiate the PE
                pe u_pe (
                    .clk_i(clk_i),
                    .rst_n(rst_n),
                    .loadw_i(loadw_i),
                    .en_i(en_i), 
                    
                    .weight_i (weight_pe_w [r][c]),
                    .weight_o (weight_pe_w [r+1][c]),    
                    
                    .input_i(input_pe_w[r][c]),      // Grab wire from the left
                    .input_o(input_pe_w[r][c+1]),   // Push to wire on the right
                    
                    .psum_i(psum_pe_w[r][c]),      // Grab wire from above
                    .psum_o(psum_pe_w[r+1][c])     // Push to wire below
                );
            end
        end
    endgenerate
endmodule
