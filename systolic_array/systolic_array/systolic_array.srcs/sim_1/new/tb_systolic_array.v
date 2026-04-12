`timescale 1ns / 1ps

module tb_systolic_array();

    // -------------------------------------------------------------------------
    // 1. Signal Declarations
    // -------------------------------------------------------------------------
    reg          clk_i;
    reg          rst_n;
    reg          start_i;
    reg          loadw_i;
    wire         done_o;
    
    reg          dma_clk_i;
    
    reg          wff_wr_en_i;
    reg  [127:0] wff_din_i;
    wire         wff_full_o;
    
    reg          inff_wr_en_i;
    reg  [127:0] inff_din_i;
    wire         inff_full_o;
    
    reg          outff_rd_en_i;
    wire [511:0] outff_dout_o;
    wire         outff_empty_o;

    integer i, j;

    // -------------------------------------------------------------------------
    // 2. DUT Instantiation
    // -------------------------------------------------------------------------
    systolic_array dut (
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
    // 3. Clocks
    // -------------------------------------------------------------------------
    // 100 MHz System Clock
    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i;
    end

    // 100 MHz DMA Clock (Phase shifted to test Cross-Clock Domain CDC safely)
    initial begin
        dma_clk_i = 0;
        #2; 
        forever #5 dma_clk_i = ~dma_clk_i;
    end

    // -------------------------------------------------------------------------
    // 4. Main Test Sequence
    // -------------------------------------------------------------------------
    initial begin
        // A. Init
        rst_n         = 0;
        start_i       = 0;
        loadw_i       = 0;
        wff_wr_en_i   = 0;
        wff_din_i     = 128'd0;
        inff_wr_en_i  = 0;
        inff_din_i    = 128'd0;
        outff_rd_en_i = 0;

        $display("==================================================");
        $display("[%0t] Resetting System...", $time);
        #100;
        rst_n = 1;
        
        // FIX: Wait for Async FIFO to clear its 'rst_busy' flags!
        // 10 cycles (#100) is not enough. We give it 200 cycles here.
        #2000; 

        // B. Load Weights into XPM FIFO (From DMA)
        $display("[%0t] DMA: Streaming Weights to FIFO...", $time);

        // B. Load Weights into XPM FIFO (From DMA)
        $display("[%0t] DMA: Streaming Weights to FIFO...", $time);
        @(posedge dma_clk_i);
        for (i = 0; i < 16; i = i + 1) begin
            wff_wr_en_i = 1;
            // Encode exactly where this weight belongs: Upper Nibble = Row, Lower = Col
            for (j = 0; j < 16; j = j + 1) begin
                wff_din_i[j*8 +: 8] = i; 
            end
            @(posedge dma_clk_i);
        end
        wff_wr_en_i = 0;

        // Wait for XPM Async FIFO pointers to cross the clock domain (CDC Delay)
        #100;

        // C. Controller triggers Weight Load into PE Grid
        $display("[%0t] CTRL: Pulsing loadw_i. Watch the PE grid swallow the weights!", $time);
        @(posedge clk_i);
        loadw_i = 1;
        @(posedge clk_i);
        loadw_i = 0;

        // Wait for weight loading state to finish
        #300; 

        // D. Load Inputs into XPM FIFO (From DMA)
        $display("[%0t] DMA: Streaming Inputs to FIFO...", $time);
        @(posedge dma_clk_i);
        for (i = 0; i < 16; i = i + 1) begin
            inff_wr_en_i = 1;
            // Encode Inputs: Upper Nibble = Row + A (to distinguish from weights), Lower = Col
            for (j = 0; j < 16; j = j + 1) begin
                inff_din_i[j*8 +: 8] = 1; 
            end
            @(posedge dma_clk_i);
        end
        inff_wr_en_i = 0;

        // Wait for XPM CDC 
        #100;

        // E. Controller triggers Computation
        $display("[%0t] CTRL: Pulsing start_i. Computation Begins!", $time);
        @(posedge clk_i);
        start_i = 1;
        @(posedge clk_i);
        start_i = 0;

        // F. Wait for computation to complete
        wait (done_o == 1'b1);
        $display("[%0t] CTRL: done_o received! Array finished.", $time);
        #50;

        // G. Read Out Results
        $display("==================================================");
        $display("[%0t] DMA: Reading Computed Partial Sums from Output FIFO:", $time);
        @(posedge dma_clk_i);
        i = 0;
        
        while (!outff_empty_o) begin
            // FWFT FIFO: Data is valid BEFORE we pulse the read enable!
            $display("   -> Row %0d Output [Col 15 Data]: %h | [Col 0 Data]: %h", 
                     i, outff_dout_o[511:480], outff_dout_o[31:0]);
            
            // Pulse Read Enable
            outff_rd_en_i = 1;
            @(posedge dma_clk_i);
            outff_rd_en_i = 0;
            
            // Wait 1 timestep to allow the empty_o flag to safely update 
            // before the while loop evaluates it again
            #1; 
            
            i = i + 1;
        end
        outff_rd_en_i = 0;

        $display("[%0t] Simulation Complete.", $time);
        $finish;
    end
    
    
    
    // -------------------------------------------------------------------------
    // 5. Console Snooping (Peek into the Controller and PE Inputs)
    // -------------------------------------------------------------------------
    // This will print every time the controller reads a new row from the FIFOs
    always @(posedge clk_i) begin
        if (dut.wff_rd_w) begin
            $display("   [PE SNOOP %0t] Controller sending Weight Row to PE: %h", $time, dut.wff_dout_w);
        end
        if (dut.inff_rd_w) begin
            $display("   [PE SNOOP %0t] Controller sending Input Row to PE:  %h", $time, dut.inff_dout_w);
        end
    end


endmodule