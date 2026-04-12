`timescale 1ns / 1ps

module tb_pe_grid();

    // -------------------------------------------------------------------------
    // 1. Signal Declarations
    // -------------------------------------------------------------------------
    reg          clk_i;
    reg          rst_n;
    reg          loadw_i;
    reg          en_i;
    reg  [127:0] weight_i;
    reg  [127:0] input_i;
    wire [511:0] output_o;

    integer i, j;

    // -------------------------------------------------------------------------
    // 2. DUT Instantiation
    // -------------------------------------------------------------------------
    pe_grid dut (
        .clk_i    (clk_i),
        .rst_n    (rst_n),
        .loadw_i  (loadw_i),
        .en_i     (en_i),
        .weight_i (weight_i),
        .input_i  (input_i),
        .output_o (output_o)
    );

    // -------------------------------------------------------------------------
    // 3. Clock Generation (100 MHz)
    // -------------------------------------------------------------------------
    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i;
    end

    // -------------------------------------------------------------------------
    // 4. Main Test Sequence
    // -------------------------------------------------------------------------
    initial begin
        // A. Initialize
        rst_n    = 0;
        loadw_i  = 0;
        en_i     = 0;
        weight_i = 128'd0;
        input_i  = 128'd0;

        $display("==================================================");
        $display("[%0t] Asserting Reset...", $time);
        #50;
        rst_n = 1;
        #50;

        // B. Load Weights (Weight Stationary)
        // We load them in reverse (Row 15 first, Row 0 last) so that as they 
        // cascade down the grid, Row 0 ends up at the very top of the 16x16 array.
        $display("[%0t] Loading Weights (Hex Coordinates)...", $time);
        @(posedge clk_i);
        loadw_i = 1;
        
        for (i = 15; i >= 0; i = i - 1) begin
            // Pack 16 columns of weights for the current row
            for (j = 0; j < 16; j = j + 1) begin
                weight_i[j*8 +: 8] = i; // Upper nibble = Row, Lower = Col
            end
            @(posedge clk_i);
        end
        
        loadw_i = 0; // Stop loading weights
        weight_i = 128'd0; // Clear the bus just to be clean
        $display("[%0t] Weights successfully loaded into PE registers.", $time);
        #20;

        // C. Feed Inputs and Compute
        // We feed 1s into the inputs. Because (Weight * 1 = Weight), the output
        // partial sums will be an exact replica of the weight coordinates!
        $display("[%0t] Starting Computation...", $time);
        @(posedge clk_i);
        en_i = 1;

        // Run the grid for 48 cycles (enough time for the first inputs to reach 
        // the bottom right corner and fully flush out)
        for (i = 0; i < 48; i = i + 1) begin
            // Feed a solid wall of 1s to the left side of the grid
            for (j = 0; j < 16; j = j + 1) begin
                input_i[j*8 +: 8] = 8'h01; 
            end
            @(posedge clk_i);
        end
        
        en_i = 0;
        input_i = 128'd0;

        $display("[%0t] Simulation Complete.", $time);
        #100;
        $finish;
    end
    

    // -------------------------------------------------------------------------
    // 5. Console Output Monitor
    // -------------------------------------------------------------------------
    // Watch the bottom row of the grid. Because of systolic skewing, Col 0 will 
    // spit out valid data first, followed by Col 1, etc.
    always @(posedge clk_i) begin
        if (en_i && output_o[31:0] != 0) begin
            $display("   [GRID OUTPUT %0t] Col 0 Psum: %h | Col 1 Psum: %h | Col 2 Psum: %h", 
                     $time, output_o[31:0], output_o[63:32], output_o[95:64]);
        end
    end

endmodule