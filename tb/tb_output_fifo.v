`timescale 1ns / 1ps

module tb_output_fifo();

    // -------------------------------------------------------------------------
    // 1. Signal Declarations
    // -------------------------------------------------------------------------
    reg          wr_clk_i;
    reg          rst_i;      
    
    reg          wr_en_i;
    reg  [511:0] din_i;
    wire         full_o;

    reg          rd_clk_i;
    reg          rd_en_i;
    wire         empty_o;
    wire [511:0] dout_o;

    integer t, c;
    integer current_row;
 
    // -------------------------------------------------------------------------
    // 2. DUT Instantiation
    // -------------------------------------------------------------------------
    output_fifo dut (
        .wr_clk_i (wr_clk_i),
        .rst_i    (rst_i),
        .wr_en_i  (wr_en_i),
        .din_i    (din_i),
        .full_o   (full_o),
        .rd_clk_i (rd_clk_i),
        .rd_en_i  (rd_en_i),
        .empty_o  (empty_o),
        .dout_o   (dout_o)
    );

    // -------------------------------------------------------------------------
    // 3. Clocks
    // -------------------------------------------------------------------------
    initial begin
        wr_clk_i = 0;
        forever #5 wr_clk_i = ~wr_clk_i;
    end

    initial begin
        rd_clk_i = 0;
        #3; 
        forever #3.75 rd_clk_i = ~rd_clk_i;
    end

    // -------------------------------------------------------------------------
    // 4. Main Test Sequence
    // -------------------------------------------------------------------------
    initial begin
        // A. Reset Phase
        rst_i   = 1; 
        wr_en_i = 0;
        din_i   = 512'd0;
        rd_en_i = 0;

        #100;
        rst_i = 0;
        #2000; // Wait for XPM Async FIFO to settle

        $display("==================================================");
        $display("[%0t] WR DOMAIN: Injecting data (Col 0 first, Col 15 last)...", $time);
        
        // Increased loop to 30 to give the 15-cycle pipeline time to fill and output data
        for (t = 0; t < 30; t = t + 1) begin
            din_i = 512'd0;
            
            for (c = 10; c <= 15; c = c + 1) begin
                
                // FIXED MATH: Column 0 arrives at t=0. Column 15 arrives at t=15.
                current_row = t - c; 
                
                if (current_row >= 0) begin
                    din_i[c*32 +: 32] = {current_row[15:0], c[15:0]};
                end else begin
                    din_i[c*32 +: 32] = 32'hFFFF_FFFF; 
                end
            end
            
            // Row 0 is only fully assembled when the slowest column (Col 15) 
            // finally produces its data at t=15. So we wait until t>=15 to write!
            if (t >= 15) wr_en_i = 1;
            else         wr_en_i = 0;
            
            @(posedge wr_clk_i);
        end
        
        wr_en_i = 0;
        din_i   = 512'd0;

        // C. CDC Wait Time
        $display("[%0t] Waiting for XPM FIFO cross-clock domain sync...", $time);
        #500;

        // D. Read Domain Check
        $display("==================================================");
        $display("[%0t] RD DOMAIN: Checking flattened output...", $time);
        
        wait(empty_o == 1'b0);
        @(posedge rd_clk_i);

        while (!empty_o) begin
            // XPM FWFT Mode: Data is already waiting on dout_o
            $display("   [READ %0t] Col 10: %04x_%04x | Col 11: %04x_%04x | Col 12: %04x_%04x | Col 13: %04x_%04x | Col 14: %04x_%04x | Col 15: %04x_%04x", 
                     $time, 
                     dout_o[10*32 + 31 : 10*32 + 16], dout_o[10*32 + 15 : 10*32],
                     dout_o[11*32 + 31 : 11*32 + 16], dout_o[11*32 + 15 : 11*32],
                     dout_o[12*32 + 31 : 12*32 + 16], dout_o[12*32 + 15 : 12*32],
                     dout_o[13*32 + 31 : 13*32 + 16], dout_o[13*32 + 15 : 13*32],
                     dout_o[14*32 + 31 : 14*32 + 16], dout_o[14*32 + 15 : 14*32],
                     dout_o[15*32 + 31 : 15*32 + 16], dout_o[15*32 + 15 : 15*32]
            );
            
            // Pulse Read Enable to advance the FIFO to the next word
            rd_en_i = 1;
            @(posedge rd_clk_i);
            rd_en_i = 0; 
            
            #1; // Safe delay for simulation to update empty_o
        end

        $display("==================================================");
        $display("[%0t] Simulation Complete.", $time);
        $finish;
    end

endmodule