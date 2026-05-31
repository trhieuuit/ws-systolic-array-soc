`timescale 1ns / 1ps
//==========================================================//
//                Systolic Array Top Module                 //
//==========================================================//
// This module wires Input, Weight, Output FIFO, Controller 
// and PE grids together

module systolic_array #(
    parameter N          = 16,
    parameter DATA_WIDTH = 8,
    parameter PSUM_WIDTH = 32
)(
    // Global Ports
    input  wire                      clk_i,
    input  wire                      rst_n,
    input  wire                      start_i,
    input  wire                      loadw_i,
    output wire                      done_o,
    
    // DMA Clock
    input  wire                      dma_clk_i, 
    
    // Weight FIFO (WFF) Interface
    input  wire                      wff_wr_en_i,
    input  wire [(N*DATA_WIDTH)-1:0] wff_din_i,
    output wire                      wff_full_o,
    
    // Input FIFO (INFF) Interface
    input  wire                      inff_wr_en_i,
    input  wire [(N*DATA_WIDTH)-1:0] inff_din_i,
    output wire                      inff_full_o,
    
    // Output FIFO (OUTFF) Interface
    input  wire                      outff_rd_en_i,
    output wire [(N*PSUM_WIDTH)-1:0] outff_dout_o,
    output wire                      outff_empty_o
);

//==========================================================//
//                    Wire Declaration                      //
//==========================================================//
    
    wire rst_i = ~rst_n;

    // Controller wires
    wire pe_en_w;
    wire pe_loadw_w;
    wire wff_rd_w;
    wire inff_rd_w;
    wire outff_wr_w;

    // FIFO status monitoring wires
    wire wff_empty_w;
    wire inff_empty_w;
    wire outff_full_w;
    
    // Interconnect wires between FIFOs and PE Grid
    wire [(N*DATA_WIDTH)-1:0] wff_dout_w;
    wire [(N*DATA_WIDTH)-1:0] inff_dout_w;
    wire [(N*PSUM_WIDTH)-1:0] outff_din_w;

//==========================================================//
//                      Controller                          //
//==========================================================//

    controller #(
        .N(N)
    ) ctrl (
        .clk_i         (clk_i),
        .rst_n         (rst_n),          
        .loadw_i       (loadw_i),          
        .start_i       (start_i),        
        
        // FIFO status inputs
        .w_ff_empty_i  (wff_empty_w),
        .in_ff_empty_i (inff_empty_w),
        .out_ff_full_i (outff_full_w),

        // Control signal outputs
        .in_ff_rd_o    (inff_rd_w),        
        .w_ff_rd_o     (wff_rd_w),      
        .out_ff_wr_o   (outff_wr_w),    
        .pe_loadw_o    (pe_loadw_w),
        .pe_en_o       (pe_en_w),        
        .done_o        (done_o)
    );

//==========================================================//
//                      Weight FIFO                         //
//==========================================================//

    weight_fifo #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH)
    ) weight_ff (
        .wr_clk_i (dma_clk_i),
        .rst_i    (rst_i),          
        .wr_en_i  (wff_wr_en_i),    
        .din_i    (wff_din_i),      
        .full_o   (wff_full_o),     
    
        .rd_clk_i (clk_i),
        .rd_en_i  (wff_rd_w),
        .empty_o  (wff_empty_w), 
        .dout_o   (wff_dout_w)
    );

//==========================================================//
//                      Input FIFO                          //
//==========================================================//   

    input_fifo #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH)
    ) input_ff (
        .wr_clk_i (dma_clk_i),
        .rst_i    (rst_i),          
        .wr_en_i  (inff_wr_en_i),   
        .pe_en_i  (pe_en_w),
        .din_i    (inff_din_i),     
        .full_o   (inff_full_o),    
    
        .rd_clk_i (clk_i),
        .rd_en_i  (inff_rd_w),
        .empty_o  (inff_empty_w), 
        .dout_o   (inff_dout_w)
    );

//==========================================================//
//                      Output FIFO                         //
//==========================================================//   

    output_fifo #(
        .N(N),
        .PSUM_WIDTH(PSUM_WIDTH)
    ) output_ff (
        .wr_clk_i (clk_i),          
        .rst_i    (rst_i),          
        .wr_en_i  (outff_wr_w),
        .din_i    (outff_din_w),
        .full_o   (outff_full_w), 
    
        .rd_clk_i (dma_clk_i),      
        .rd_en_i  (outff_rd_en_i),  
        .empty_o  (outff_empty_o),  
        .dout_o   (outff_dout_o)    
    );

//==========================================================//
//                     16x16 PE Grid                        //
//==========================================================//

    pe_grid #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH),
        .PSUM_WIDTH(PSUM_WIDTH)
    ) pe_grid_inst (
        .clk_i    (clk_i),
        .rst_n    (rst_n),
        .loadw_i  (pe_loadw_w),
        .en_i     (pe_en_w),
        .weight_i (wff_dout_w),
        .input_i  (inff_dout_w),
        .output_o (outff_din_w) 
    );

endmodule