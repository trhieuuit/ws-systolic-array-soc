`timescale 1ns / 1ps
//==========================================================//
//                    Accelerator Top Level                 //
//==========================================================//
// This module integrates the Tiling AGU with a Physical 
// Ping-Pong BRAM subsystem for Input, Weight, and Output.

module accelerator_top #(
    parameter SYS_N      = 16,
    parameter DATA_WIDTH = 8,
    parameter PSUM_WIDTH = 32
)(
    // Global Ports
    input  wire                          clk_i,
    input  wire                          rst_ni,
    
    // Control Interface (from CPU)
    input  wire                          start_i,
    input  wire                          dma_bank_i, // 0: Ping, 1: Pong for DMA
    input  wire                          agu_bank_i, // 0: Ping, 1: Pong for AGU
    input  wire [15:0]                   dim_m_i,
    input  wire [15:0]                   dim_k_i,
    input  wire [15:0]                   dim_n_i,
    output wire                          done_o,

    // DMA Interface for BRAM A (Input Matrix)
    input  wire                          dma_we_a_i,
    input  wire [8:0]                    dma_addr_a_i,
    input  wire [(SYS_N*DATA_WIDTH)-1:0] dma_data_a_i,

    // DMA Interface for BRAM B (Weight Matrix)
    input  wire                          dma_we_b_i,
    input  wire [8:0]                    dma_addr_b_i,
    input  wire [(SYS_N*DATA_WIDTH)-1:0] dma_data_b_i,

    // DMA Interface for BRAM C (Result Matrix)
    input  wire                          dma_re_c_i,
    input  wire [8:0]                    dma_addr_c_i,
    output wire [(SYS_N*PSUM_WIDTH)-1:0] dma_data_c_o
);

//==========================================================//
//                    Wire Declaration                      //
//==========================================================//

    // AGU to BRAM A & B Wires
    wire [31:0]                   agu_brama_addr_w, agu_bramb_addr_w;
    wire                          agu_brama_en_w,   agu_bramb_en_w;
    wire [(SYS_N*DATA_WIDTH)-1:0] brama_dout_w,     bramb_dout_w;

    // AGU to BRAM C Wires
    wire [31:0]                   agu_bramc_rd_addr_w, agu_bramc_wr_addr_w;
    wire                          agu_bramc_rd_en_w,   agu_bramc_wr_en_w, agu_bramc_wr_we_w;
    wire [(SYS_N*PSUM_WIDTH)-1:0] agu_bramc_wr_din_w;
    wire [(SYS_N*PSUM_WIDTH)-1:0] bramc_rd_dout_w;

//==========================================================//
//           BRAM A & B (Ping-Pong via Address Offset)      //
//==========================================================//

    // BRAM A (Input Matrix - 1024 Depth)
    tdp_bram #(.DATA_WIDTH(128), .ADDR_WIDTH(10), .RAM_DEPTH(1024)) BRAM_A (
        .clk_a   (clk_i), 
        .en_a    (dma_we_a_i), 
        .we_a    (dma_we_a_i),
        .addr_a  ({dma_bank_i, dma_addr_a_i}), 
        .din_a   (dma_data_a_i), 
        .dout_a  (),
        
        .clk_b   (clk_i), 
        .en_b    (agu_brama_en_w), 
        .we_b    (1'b0),
        .addr_b  ({agu_bank_i, agu_brama_addr_w[8:0]}), 
        .din_b   (128'd0), 
        .dout_b  (brama_dout_w)
    );

    // BRAM B (Weight Matrix - 1024 Depth)
    tdp_bram #(.DATA_WIDTH(128), .ADDR_WIDTH(10), .RAM_DEPTH(1024)) BRAM_B (
        .clk_a   (clk_i), 
        .en_a    (dma_we_b_i), 
        .we_a    (dma_we_b_i),
        .addr_a  ({dma_bank_i, dma_addr_b_i}),
        .din_a   (dma_data_b_i), 
        .dout_a  (),
        
        .clk_b   (clk_i), 
        .en_b    (agu_bramb_en_w), 
        .we_b    (1'b0),
        .addr_b  ({agu_bank_i, agu_bramb_addr_w[8:0]}), 
        .din_b   (128'd0), 
        .dout_b  (bramb_dout_w)
    );

//==========================================================//
//             BRAM C (Physical Ping-Pong Design)           //
//==========================================================//

    wire [8:0] agu_c_rd_addr = agu_bramc_rd_addr_w[8:0];
    wire [8:0] agu_c_wr_addr = agu_bramc_wr_addr_w[8:0];

    // --- Bank PING (0) ---
    // Port A: Granted to DMA if dma_bank = 0, or to AGU for reading if agu_bank = 0
    wire                          ping_en_a   = (dma_bank_i == 1'b0) ? (dma_re_c_i | 1'b1) : 
                                                (agu_bank_i == 1'b0) ? agu_bramc_rd_en_w   : 1'b0;
    wire [8:0]                    ping_addr_a = (dma_bank_i == 1'b0) ? dma_addr_c_i        : 
                                                (agu_bank_i == 1'b0) ? agu_c_rd_addr       : 9'd0;
    wire [(SYS_N*PSUM_WIDTH)-1:0] ping_dout_a;

    // Port B: Dedicated to AGU for writing (if agu_bank = 0)
    wire                          ping_en_b   = (agu_bank_i == 1'b0) ? agu_bramc_wr_en_w   : 1'b0;
    wire                          ping_we_b   = (agu_bank_i == 1'b0) ? agu_bramc_wr_we_w   : 1'b0;

    tdp_bram #(.DATA_WIDTH(512), .ADDR_WIDTH(9), .RAM_DEPTH(512)) BRAM_C_PING (
        .clk_a   (clk_i), 
        .en_a    (ping_en_a), 
        .we_a    (1'b0), 
        .addr_a  (ping_addr_a), 
        .din_a   (512'd0), 
        .dout_a  (ping_dout_a),
        
        .clk_b   (clk_i), 
        .en_b    (ping_en_b), 
        .we_b    (ping_we_b), 
        .addr_b  (agu_c_wr_addr), 
        .din_b   (agu_bramc_wr_din_w), 
        .dout_b  ()
    );

    // --- Bank PONG (1) ---
    // Port A: Granted to DMA if dma_bank = 1, or to AGU for reading if agu_bank = 1
    wire                          pong_en_a   = (dma_bank_i == 1'b1) ? (dma_re_c_i | 1'b1) : 
                                                (agu_bank_i == 1'b1) ? agu_bramc_rd_en_w   : 1'b0;
    wire [8:0]                    pong_addr_a = (dma_bank_i == 1'b1) ? dma_addr_c_i        : 
                                                (agu_bank_i == 1'b1) ? agu_c_rd_addr       : 9'd0;
    wire [(SYS_N*PSUM_WIDTH)-1:0] pong_dout_a;

    // Port B: Dedicated to AGU for writing (if agu_bank = 1)
    wire                          pong_en_b   = (agu_bank_i == 1'b1) ? agu_bramc_wr_en_w   : 1'b0;
    wire                          pong_we_b   = (agu_bank_i == 1'b1) ? agu_bramc_wr_we_w   : 1'b0;

    tdp_bram #(.DATA_WIDTH(512), .ADDR_WIDTH(9), .RAM_DEPTH(512)) BRAM_C_PONG (
        .clk_a   (clk_i), 
        .en_a    (pong_en_a), 
        .we_a    (1'b0), 
        .addr_a  (pong_addr_a), 
        .din_a   (512'd0), 
        .dout_a  (pong_dout_a),
        
        .clk_b   (clk_i), 
        .en_b    (pong_en_b), 
        .we_b    (pong_we_b), 
        .addr_b  (agu_c_wr_addr), 
        .din_b   (agu_bramc_wr_din_w), 
        .dout_b  ()
    );

//==========================================================//
//                  Output Data Steering                    //
//==========================================================//

    // Return old Psum to AGU based on current AGU bank
    assign bramc_rd_dout_w = (agu_bank_i == 1'b0) ? ping_dout_a : pong_dout_a;
    
    // Output result for DMA extraction based on current DMA bank
    assign dma_data_c_o    = (dma_bank_i == 1'b0) ? ping_dout_a : pong_dout_a;

//==========================================================//
//                  Tiling AGU & PE Grid                    //
//==========================================================//

    tiling_agu #(.SYS_N(SYS_N)) agu_inst (
        .clk_i           (clk_i), 
        .rst_ni          (rst_ni), 
        .start_i         (start_i),
        .dim_m_i         (dim_m_i), 
        .dim_k_i         (dim_k_i), 
        .dim_n_i         (dim_n_i),
        .done_o          (done_o),
        
        .brama_addr_o    (agu_brama_addr_w), 
        .brama_en_o      (agu_brama_en_w), 
        .brama_dout_i    (brama_dout_w),
        
        .bramb_addr_o    (agu_bramb_addr_w), 
        .bramb_en_o      (agu_bramb_en_w), 
        .bramb_dout_i    (bramb_dout_w),
        
        .bramc_rd_addr_o (agu_bramc_rd_addr_w), 
        .bramc_rd_en_o   (agu_bramc_rd_en_w), 
        .bramc_rd_dout_i (bramc_rd_dout_w),
        
        .bramc_wr_addr_o (agu_bramc_wr_addr_w), 
        .bramc_wr_en_o   (agu_bramc_wr_en_w), 
        .bramc_wr_we_o   (agu_bramc_wr_we_w), 
        .bramc_wr_din_o  (agu_bramc_wr_din_w)
    );

endmodule