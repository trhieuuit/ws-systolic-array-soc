`timescale 1ns / 1ps

module pe#(
    parameter DATA_WIDTH = 8,
    parameter  PSUM_WIDTH = 32
)(
    input  wire               clk_i,
    input  wire               rst_n,
    input  wire               loadw_i,     // Load weight signal
    input  wire               en_i,        // Activate PE
    input  wire signed [DATA_WIDTH-1:0]  input_i,     // Cascaded input (from the left) 
    input  wire signed [DATA_WIDTH-1:0]  weight_i,   
    input  wire signed [PSUM_WIDTH-1:0] psum_i,      // Previous partial sum (from the top)
    
    output reg signed [DATA_WIDTH-1:0]   weight_o,    // Pass weight down to the bottom
    output reg  signed [DATA_WIDTH-1:0]  input_o,     // Pass input to the right
    output wire signed [PSUM_WIDTH-1:0] psum_o       // Output partial sum (downward)
);
    // Register declaration
    reg signed [PSUM_WIDTH-1:0] psum_r;
    
    // Combinational output
    wire signed [(2*DATA_WIDTH)-1:0] mul = input_i * weight_o;
    assign psum_o = psum_r +  mul;
  
  always @(posedge clk_i or negedge rst_n) begin
        if (!rst_n) begin
            weight_o <= {DATA_WIDTH{1'b0}};
        end else if (loadw_i) begin
            weight_o <= weight_i;
        end
    end
  
    always @(posedge clk_i or negedge rst_n) begin
        if (!rst_n) begin
            input_o  <= {DATA_WIDTH{1'b0}};
            psum_r   <= {DATA_WIDTH{1'b0}};
        end else if (en_i) begin
            psum_r  <= psum_i; 
            input_o <= input_i;
        end
    end
            
endmodule
