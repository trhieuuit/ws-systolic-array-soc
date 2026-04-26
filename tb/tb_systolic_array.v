`timescale 1ns / 1ps

module tb_systolic_array();

    // -------------------------------------------------------------------------
    // 1. Parameter Configuration
    // -------------------------------------------------------------------------
    parameter N = 4;
    parameter DATA_WIDTH = 8;
    parameter PSUM_WIDTH = 32;

    // -------------------------------------------------------------------------
    // 2. Signal Declarations
    // -------------------------------------------------------------------------
    reg          clk_i;
    reg          rst_n;
    reg          start_i;
    reg          loadw_i;
    wire         done_o;
    
    reg          dma_clk_i;
    
    reg          wff_wr_en_i;
    reg  [(N*DATA_WIDTH)-1:0] wff_din_i;
    wire         wff_full_o;
    
    reg          inff_wr_en_i;
    reg  [(N*DATA_WIDTH)-1:0] inff_din_i;
    wire         inff_full_o;
    
    reg          outff_rd_en_i;
    wire [(N*PSUM_WIDTH)-1:0] outff_dout_o;
    wire         outff_empty_o;

    wire rst_high_w = ~rst_n;
    // -------------------------------------------------------------------------
    // 3. Golden Model Matrices for Self-Checking
    // -------------------------------------------------------------------------
    reg signed [DATA_WIDTH-1:0] A_mat [0:N-1][0:N-1];  // Input Matrix
    reg signed [DATA_WIDTH-1:0] B_mat [0:N-1][0:N-1];  // Weight Matrix
    reg signed [PSUM_WIDTH-1:0] C_gold [0:N-1][0:N-1]; // Expected Output Matrix
    reg signed [PSUM_WIDTH-1:0] C_act  [0:N-1][0:N-1]; // Actual Output from Hardware
    
    integer i, j, k;
    integer error_count = 0;

    // -------------------------------------------------------------------------
    // 4. DUT Instantiation
    // -------------------------------------------------------------------------
    systolic_array #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH),
        .PSUM_WIDTH(PSUM_WIDTH)
    ) dut (
        .clk_i         (clk_i),
        .rst_n         (rst_n),
        .start_i       (start_i),
        .loadw_i       (loadw_i),
        .done_o        (done_o),
        
        .dma_clk_i     (dma_clk_i),
        
        .wff_wr_en_i   (wff_wr_en_i),
        .wff_din_i     (wff_din_i),
        .wff_full_o    (wff_full_o),
        
        .inff_wr_en_i  (inff_wr_en_i),
        .inff_din_i    (inff_din_i),
        .inff_full_o   (inff_full_o),
        
        .outff_rd_en_i (outff_rd_en_i),
        .outff_dout_o  (outff_dout_o),
        .outff_empty_o (outff_empty_o)
    );

    // -------------------------------------------------------------------------
    // 5. Clock Generation
    // -------------------------------------------------------------------------
    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i;
    end

    initial begin
        dma_clk_i = 0;
        #2; 
        forever #5 dma_clk_i = ~dma_clk_i;
    end

    // -------------------------------------------------------------------------
    // 6. TASKS: Golden Model Generation and Calculation
    // -------------------------------------------------------------------------
    task generate_and_calc_golden();
    begin
        // Generate random numbers for Input (A) and Weight (B)
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                A_mat[i][j] = $urandom_range(1, 10); // Range 1-5 for readable output
                B_mat[i][j] = $urandom_range(1, 10); 
            end
        end
        
        // Calculate expected Result: C = A * B
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                C_gold[i][j] = 0;
                for (k = 0; k < N; k = k + 1) begin
                    C_gold[i][j] = C_gold[i][j] + (A_mat[i][k] * B_mat[k][j]);
                end
            end
        end
        
        // Print matrices to console for reference
        $display("\n--- MATRIX A (INPUTS) ---");
        for (i = 0; i < N; i = i + 1) begin
            $write("Row %0d: ", i);
            for (j = 0; j < N; j = j + 1) $write("%4d ", A_mat[i][j]);
            $display("");
        end
        
        $display("\n--- MATRIX B (WEIGHTS) ---");
        for (i = 0; i < N; i = i + 1) begin
            $write("Row %0d: ", i);
            for (j = 0; j < N; j = j + 1) $write("%4d ", B_mat[i][j]);
            $display("");
        end
        
        $display("\n--- EXPECTED MATRIX C (GOLDEN) ---");
        for (i = 0; i < N; i = i + 1) begin
            $write("Row %0d: ", i);
            for (j = 0; j < N; j = j + 1) $write("%4d ", C_gold[i][j]);
            $display("");
        end
        $display("----------------------------------\n");
    end
    endtask

    // -------------------------------------------------------------------------
    // 7. MAIN TEST SEQUENCE
    // -------------------------------------------------------------------------
    initial begin
        // Initialize signals
        rst_n         = 0;
        start_i       = 0;
        loadw_i       = 0;
        wff_wr_en_i   = 0;
        wff_din_i     = 0;
        inff_wr_en_i  = 0;
        inff_din_i    = 0;
        outff_rd_en_i = 0;

        $display("==================================================");
        $display("   STARTING SYSTOLIC ARRAY SELF-CHECKING TB (N=%0d)", N);
        $display("==================================================");
        
        // Generate test vectors and golden result
        generate_and_calc_golden();

        // A. System Reset
        #100; rst_n = 1;
        #2000; // Wait for XPM Async FIFO cross-clock domain logic to settle

        // B. Stream Weights into FIFO 
        // Note: Weights must be pushed from Row N-1 down to 0 to align correctly in the PE grid
        $display("[%0t] Pushing Weights...", $time);
        @(posedge dma_clk_i);
        for (i = N-1; i >= 0; i = i - 1) begin
            wff_wr_en_i = 1;
            for (j = 0; j < N; j = j + 1) begin
                wff_din_i[j*DATA_WIDTH +: DATA_WIDTH] = B_mat[i][j]; 
            end
            @(posedge dma_clk_i);
        end
        wff_wr_en_i = 0;
        #100;

        // C. Trigger Weight Load
        @(posedge clk_i); loadw_i = 1;
        @(posedge clk_i); loadw_i = 0;
        
        // Wait for weights to shift down the grid
        #(N * 20); 

        // D. Stream Inputs into FIFO
        // Inputs are pushed normally from Row 0 to N-1
        $display("[%0t] Pushing Inputs...", $time);
        @(posedge dma_clk_i);
        for (i = 0; i < N; i = i + 1) begin
            inff_wr_en_i = 1;
            for (j = 0; j < N; j = j + 1) begin
                inff_din_i[j*DATA_WIDTH +: DATA_WIDTH] = A_mat[i][j]; 
            end
            @(posedge dma_clk_i);
        end
        inff_wr_en_i = 0;
        #100;

        // E. Trigger Computation
        $display("[%0t] Starting Computation...", $time);
        @(posedge clk_i); start_i = 1;
        @(posedge clk_i); start_i = 0;

        // F. Wait for hardware to assert done flag
        wait (done_o == 1'b1);
        $display("[%0t] Hardware Computation Done!", $time);
        #50;

        // G. Read Out Results and VERIFY AGAINST GOLDEN MODEL
        $display("\n================ CHECKING RESULTS ================");
        @(posedge dma_clk_i);
        i = 0;
        
        while (!outff_empty_o && i < N) begin
            outff_rd_en_i = 1;
            
            // Extract the flat data bus into a matrix format
            for (j = 0; j < N; j = j + 1) begin
                C_act[i][j] = outff_dout_o[j*PSUM_WIDTH +: PSUM_WIDTH];
                
                // COMPARE HARDWARE RESULT WITH GOLDEN MODEL
                if (C_act[i][j] !== C_gold[i][j]) begin
                    $display("[FAIL] Row %0d, Col %0d | Expected: %0d | Hardware: %0d", i, j, C_gold[i][j], C_act[i][j]);
                    error_count = error_count + 1;
                end
            end
            
            // Print the hardware output row to the console
            $write("HW Output Row %0d: ", i);
            for (j = 0; j < N; j = j + 1) $write("%4d ", C_act[i][j]);
            $display("");
            
            @(posedge dma_clk_i);
            outff_rd_en_i = 0;
            #1; // Allow empty flag to update
            i = i + 1;
        end

        // -------------------------------------------------------------------------
        // 8. FINAL VERIFICATION VERDICT
        // -------------------------------------------------------------------------
        $display("\n==================================================");
        if (error_count == 0) begin
            $display("   TEST PASSED 100%%! ZERO ERRORS FOUND.");
        end else begin
            $display("   TEST FAILED! FOUND %0d ERRORS.", error_count);
        end
        $display("==================================================");
        
        $finish;
    end

endmodule