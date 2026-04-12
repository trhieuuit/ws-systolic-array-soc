`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2026 02:38:25 PM
// Design Name: 
// Module Name: tb_pe
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

module tb_pe();

    // 1. Declare Testbench Signals
    reg               clk_i;
    reg               rst_n;
    reg signed [7:0]  input_i;
    reg               loadw_i;
    reg               en_i;
    reg signed [7:0]  weight_i;
    reg signed [31:0] psum_i;

    wire signed [7:0] input_o;
    wire signed [31:0] psum_o;

    // 2. Instantiate the Unit Under Test (UUT)
    pe uut (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .input_i(input_i),
        .loadw_i(loadw_i),
        .en_i(en_i),
        .weight_i(weight_i),
        .psum_i(psum_i),
        .input_o(input_o),
        .psum_o(psum_o)
    );

    // 3. Clock Generation (100 MHz -> 10ns period)
    always #5 clk_i = ~clk_i;

    // 4. Stimulus Block
    initial begin
        // Initialize all signals to 0
        clk_i    = 0;
        rst_n    = 0;
        input_i  = 0;
        loadw_i   = 0;
        en_i     = 0;
        weight_i = 0;
        psum_i   = 0;


        // Set up console monitoring to watch the values change
        $monitor("Time=%0t | rst_n=%b load=%b en=%b | w_in=%0d | in_i=%0d psum_i=%0d | out_o=%0d psum_o=%0d", 
                 $time, rst_n, loadw_i, en_i, weight_i, input_i, psum_i, input_o, psum_o);
        
        // --- RESET PHASE ---
        #15 rst_n = 1; // Release reset after 15ns

        // --- PHASE 1: Load Weight ---
        // Wait for the next rising edge, then assert load and provide a weight
        @(negedge clk_i);
        loadw_i   = 1;
        weight_i = 8'sd5;    // We will lock in a weight of 5
        
        // Wait one clock cycle for it to register, then de-assert load
        // Drive stimulus on the falling edge!
        @(negedge clk_i);
        loadw_i = 0;
        en_i   = 1;
        input_i = 8'sd2; 
        psum_i  = 32'sd0;
        
        @(negedge clk_i);
        input_i = -8'sd3;  
        psum_i  = 32'sd10; 
        
        @(negedge clk_i);
        input_i = 8'sd0;  
        psum_i  = -32'sd5;

        #20;
        $display("Simulation Complete.");
        $finish;
    end

endmodule
