`timescale 1ns / 1ps

module tb_controller();

    // -------------------------------------------------------------------------
    // 1. Signal Declarations
    // -------------------------------------------------------------------------
    reg  clk_i;
    reg  rst_n;
    reg  loadw_i;
    reg  start_i;
    
    wire in_ff_rd_o;
    wire w_ff_rd_o;
    wire out_ff_wr_o;
    wire pe_loadw_o;
    wire pe_en_o;
    wire done_o;

    // -------------------------------------------------------------------------
    // 2. DUT Instantiation
    // -------------------------------------------------------------------------
    controller dut (
        .clk_i       (clk_i),
        .rst_n       (rst_n),
        .loadw_i     (loadw_i),
        .start_i     (start_i),
        .in_ff_rd_o  (in_ff_rd_o),
        .w_ff_rd_o   (w_ff_rd_o),
        .out_ff_wr_o (out_ff_wr_o),
        .pe_loadw_o  (pe_loadw_o),
        .pe_en_o     (pe_en_o),
        .done_o      (done_o)
    );

    // -------------------------------------------------------------------------
    // 3. Clock Generation (100 MHz / 10ns period)
    // -------------------------------------------------------------------------
    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i;
    end

    // -------------------------------------------------------------------------
    // 4. Main Stimulus
    // -------------------------------------------------------------------------
    initial begin
        // Initialize Inputs
        rst_n   = 0;
        loadw_i = 0;
        start_i = 0;

        // Apply Reset
        $display("[%0t] Asserting Reset...", $time);
        #25;
        rst_n = 1;
        $display("[%0t] Reset Released. System IDLE.", $time);
        #20;

        // ---------------------------------------------------------
        // PHASE 1: Load Weights
        // ---------------------------------------------------------
        $display("[%0t] Pulsing loadw_i...", $time);
        @(posedge clk_i);
        loadw_i = 1;
        @(posedge clk_i);
        loadw_i = 0;
        
        // Let it run for the 16 cycles
        // Expected: w_ff_rd_o and pe_loadw_o should be HIGH
        #200; 
        $display("[%0t] Weight load should be complete. Back to IDLE.", $time);
        
        #50; // Pause a few cycles before starting

        // ---------------------------------------------------------
        // PHASE 2: Start Array Computation
        // ---------------------------------------------------------
        $display("[%0t] Pulsing start_i...", $time);
        @(posedge clk_i);
        start_i = 1;
        @(posedge clk_i);
        start_i = 0;

        // The FSM should now chain through:
        // 1. LOAD_INPUT (16 cycles)
        // 2. WAIT (15 cycles)
        // 3. RESULT_COLLECT (16 cycles)

        // Wait for the done_o signal to pulse
        wait(done_o == 1'b1);
        $display("[%0t] SUCCESS! done_o signal received.", $time);

        // Wait a few cycles to ensure it transitions back to IDLE cleanly
        #50;
        $display("[%0t] Simulation Complete.", $time);
        $finish;
    end

    // -------------------------------------------------------------------------
    // 5. Safety Timeout (In case of FSM deadlock)
    // -------------------------------------------------------------------------
    initial begin
        #2000;
        $display("[%0t] ERROR: Simulation timed out. Check FSM transitions!", $time);
        $finish;
    end

endmodule