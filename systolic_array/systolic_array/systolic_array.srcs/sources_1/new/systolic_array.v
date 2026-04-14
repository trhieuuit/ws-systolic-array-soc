`timescale 1ns / 1ps

module systolic_array(
        input wire      clk_i,
        input wire      rst_n,
        input wire      start_i,
        input wire      loadw_i,
        output wire     done_o,
        
        // AXI DMA Clock (Often different from clk_i)
        input  wire         dma_clk_i,
        
        // DMA -> Weight FIFO Interface
        input  wire         wff_wr_en_i,
        input  wire [127:0] wff_din_i,
        output wire         wff_full_o,
        
        // DMA -> Input FIFO Interface
        input  wire         inff_wr_en_i,
        input  wire [127:0] inff_din_i,
        output wire         inff_full_o,
        
        // Output FIFO -> DMA Interface
        input  wire         outff_rd_en_i,
        output wire [511:0] outff_dout_o,
        output wire         outff_empty_o
    );

    wire pe_en_w;
    wire wff_rd_w, inff_rd_w, outff_wr_w;
    wire rst_i = ~rst_n;

//////////////////////////////////////////////////////////////////////////////////
//                                  Controller                                  //
//////////////////////////////////////////////////////////////////////////////////\
    wire pe_loadw_w;
    controller ctrl(
        .clk_i (clk_i),
        .rst_n  (rst_n),          
        .loadw_i (loadw_i),          // Load weight signal
        .start_i (start_i),        // Start execution + output collection
        
        .in_ff_rd_o (inff_rd_w),       // Input FIFO read (only applies to the first FIFO, latter ones are mapped to shift register)
        .w_ff_rd_o (wff_rd_w),      // Weight FIFO read (applies to all FIFO)
        .out_ff_wr_o (outff_wr_w),    // Output FIFO write (only applies to the first FIFO, latter ones are mapped to shift register)
        .pe_loadw_o (pe_loadw_w),
        .pe_en_o      (pe_en_w),        // PE enable signal
        .done_o (done_o)
    );
   
//////////////////////////////////////////////////////////////////////////////////
//                                 Weight FIFO                                  //
//////////////////////////////////////////////////////////////////////////////////
    wire [127:0] wff_dout_w;
    weight_fifo weight_ff(
        // Write Domain (from AXI DMA)
        .wr_clk_i   (dma_clk_i),
        .rst_i      (rst_i),          // FIXED: Connected reset
        .wr_en_i    (wff_wr_en_i),    // FIXED: Routed to top
        .din_i      (wff_din_i),      // FIXED: Routed to top
        .full_o     (wff_full_o),     // FIXED: Routed to top
    
        // Read Domain (to Systolic Array)
        .rd_clk_i   (clk_i),
        .rd_en_i    (wff_rd_w),
        .empty_o    (),               // Can leave empty if controller manages timing
        .dout_o     (wff_dout_w)
    );
    
//////////////////////////////////////////////////////////////////////////////////
//                                  Input FIFO                                  //
//////////////////////////////////////////////////////////////////////////////////   
    wire [127:0] inff_dout_w;
    input_fifo input_ff(
        // Write Domain (from AXI DMA)
        .wr_clk_i   (dma_clk_i),
        .rst_i      (rst_i),          // FIXED: Connected reset
        .wr_en_i    (inff_wr_en_i),   // FIXED: Routed to top
        .din_i      (inff_din_i),     // FIXED: Routed to top
        .full_o     (inff_full_o),    // FIXED: Routed to top
    
        // Read Domain (to Systolic Array)
        .rd_clk_i   (clk_i),
        .rd_en_i    (inff_rd_w),
        .empty_o    (),
        .dout_o     (inff_dout_w)
    );

//////////////////////////////////////////////////////////////////////////////////
//                                 Output FIFO                                  //
//////////////////////////////////////////////////////////////////////////////////   
    wire [511:0] outff_din_w;
    output_fifo output_ff(
        // Write Domain (from Systolic Array)
        .wr_clk_i   (clk_i),          // FIXED: Array writes to this FIFO
        .rst_i      (rst_i),          // FIXED: Connected reset
        .wr_en_i    (outff_wr_w),
        .din_i      (outff_din_w),
        .full_o     (),               // Array assumes DMA empties it fast enough
    
        // Read Domain (to AXI DMA)
        .rd_clk_i   (dma_clk_i),      // FIXED: DMA reads from this FIFO
        .rd_en_i    (outff_rd_en_i),  // FIXED: Routed to top
        .empty_o    (outff_empty_o),  // FIXED: Routed to top
        .dout_o     (outff_dout_o)    // FIXED: Routed to top
    );
   
    
//////////////////////////////////////////////////////////////////////////////////
//                                 16x16 PE grid                                //
//////////////////////////////////////////////////////////////////////////////////
    pe_grid pe_grid (
         .clk_i   (clk_i),
        .rst_n    (rst_n),
        .loadw_i  (pe_loadw_w),
        .en_i     (pe_en_w),
        .weight_i (wff_dout_w),
        .input_i  (inff_dout_w),
        .output_o (outff_din_w) 
    );
    
    
    
    

 endmodule