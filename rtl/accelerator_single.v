`timescale 1ns / 1ps
//==========================================================//
//                    Accelerator Top Level                 //
//==========================================================//
// Single Buffer Version

module accelerator_single #(
    parameter SYS_N      = 16,
    parameter DATA_WIDTH = 8,
    parameter PSUM_WIDTH = 32
)(
    // Global Ports
    input  wire                 clk_i,
    input  wire                 rst_ni,

    // Control Interface (Connected to ARM CPU via AXI-Lite)
    input  wire                 start_i,
    input  wire [15:0]          dim_m_i,
    input  wire [15:0]          dim_k_i,
    input  wire [15:0]          dim_n_i,
    output wire                 done_o,

    // DMA Interface for BRAM A (Input Matrix)
    input  wire                 dma_we_a_i,
    input  wire [8:0]           dma_addr_a_i,
    input  wire [127:0]         dma_data_a_i,

    // DMA Interface for BRAM B (Weight Matrix)
    input  wire                 dma_we_b_i,
    input  wire [8:0]           dma_addr_b_i,
    input  wire [127:0]         dma_data_b_i,

    // DMA Interface for BRAM C (Result Matrix)
    input  wire                 dma_re_c_i,
    input  wire [8:0]           dma_addr_c_i,
    output wire [511:0]         dma_data_c_o
);

//==========================================================//
//                    Wire Declaration                      //
//==========================================================//

    // Interconnect Wires between Tiling AGU and BRAMs
    wire [31:0]  agu_brama_addr_w;
    wire         agu_brama_en_w;
    wire [127:0] brama_dout_w;

    wire [31:0]  agu_bramb_addr_w;
    wire         agu_bramb_en_w;
    wire [127:0] bramb_dout_w;

    wire [31:0]  agu_bramc_rd_addr_w;
    wire         agu_bramc_rd_en_w;
    wire [511:0] bramc_rd_dout_w;

    wire [31:0]  agu_bramc_wr_addr_w;
    wire         agu_bramc_wr_en_w;
    wire         agu_bramc_wr_we_w;
    wire [511:0] agu_bramc_wr_din_w;

    wire         sys_done_w;
    assign done_o = sys_done_w;

//==========================================================//
//               BRAM A (Input Matrix Buffer)               //
//==========================================================//
    // Depth 256 is sufficient for 64x64 Tiling Single Buffer
    tdp_bram #(
        .DATA_WIDTH(128), .ADDR_WIDTH(9), .RAM_DEPTH(256)
    ) BRAM_A (
        // Port A: DMA Write
        .clk_a   (clk_i), 
        .en_a    (dma_we_a_i), 
        .we_a    (dma_we_a_i),
        .addr_a  (dma_addr_a_i), 
        .din_a   (dma_data_a_i), 
        .dout_a  (),
        
        // Port B: AGU Read to PE Core
        .clk_b   (clk_i), 
        .en_b    (agu_brama_en_w), 
        .we_b    (1'b0),
        .addr_b  (agu_brama_addr_w[8:0]), 
        .din_b   (128'd0), 
        .dout_b  (brama_dout_w)
    );

//==========================================================//
//               BRAM B (Weight Matrix Buffer)              //
//==========================================================//
    // Depth 256
    tdp_bram #(
        .DATA_WIDTH(128), .ADDR_WIDTH(9), .RAM_DEPTH(256)
    ) BRAM_B (
        // Port A: DMA Write
        .clk_a   (clk_i), 
        .en_a    (dma_we_b_i), 
        .we_a    (dma_we_b_i),
        .addr_a  (dma_addr_b_i), 
        .din_a   (dma_data_b_i), 
        .dout_a  (),
        
        // Port B: AGU Read to PE Core
        .clk_b   (clk_i), 
        .en_b    (agu_bramb_en_w), 
        .we_b    (1'b0),
        .addr_b  (agu_bramb_addr_w[8:0]), 
        .din_b   (128'd0), 
        .dout_b  (bramb_dout_w)
    );

//==========================================================//
//           BRAM C Port A Multiplexer (DMA vs AGU)         //
//==========================================================//

    // If computation is done (sys_done_w == 1), yield Port A to DMA
    wire         mux_bramc_en_a   = sys_done_w ? dma_re_c_i   : agu_bramc_rd_en_w;
    wire [8:0]   mux_bramc_addr_a = sys_done_w ? dma_addr_c_i : agu_bramc_rd_addr_w[8:0];
    wire [511:0] bramc_dout_a_w;

    // Data read from BRAM C branches to both AGU and DMA.
    // DMA only processes valid data when it has address control (sys_done_w == 1).
    assign bramc_rd_dout_w = bramc_dout_a_w; // Feedback to AGU
    assign dma_data_c_o    = bramc_dout_a_w; // Output to DMA

//==========================================================//
//               BRAM C (Result Matrix Buffer)              //
//==========================================================//
    // Psum is 32-bit - Total width 512-bit
    tdp_bram #(
        .DATA_WIDTH(512), .ADDR_WIDTH(9), .RAM_DEPTH(256)
    ) BRAM_C (
        // Port A: SHARED (AGU reads old Psum / DMA harvests final results)
        .clk_a   (clk_i), 
        .en_a    (mux_bramc_en_a), 
        .we_a    (1'b0), // Read-only for both AGU and DMA on this port
        .addr_a  (mux_bramc_addr_a), 
        .din_a   (512'd0), 
        .dout_a  (bramc_dout_a_w),
        
        // Port B: AGU DEDICATED (AGU writes new Psum)
        .clk_b   (clk_i), 
        .en_b    (agu_bramc_wr_en_w), 
        .we_b    (agu_bramc_wr_we_w),
        .addr_b  (agu_bramc_wr_addr_w[8:0]), 
        .din_b   (agu_bramc_wr_din_w), 
        .dout_b  ()      // No read required from Port B
    );

//==========================================================//
//                  Tiling AGU & PE Grid                    //
//==========================================================//

    tiling_agu #(
        .SYS_N(SYS_N),
        .DATA_WIDTH(DATA_WIDTH),
        .PSUM_WIDTH(PSUM_WIDTH)
    ) agu_inst (
        .clk_i           (clk_i),
        .rst_ni          (rst_ni),
        .start_i         (start_i),
        
        .dim_m_i         (dim_m_i),
        .dim_k_i         (dim_k_i),
        .dim_n_i         (dim_n_i),
        .done_o          (sys_done_w),
        
        // BRAM A Interface
        .brama_addr_o    (agu_brama_addr_w),
        .brama_en_o      (agu_brama_en_w),
        .brama_dout_i    (brama_dout_w),
        
        // BRAM B Interface
        .bramb_addr_o    (agu_bramb_addr_w),
        .bramb_en_o      (agu_bramb_en_w),
        .bramb_dout_i    (bramb_dout_w),
        
        // BRAM C Interface (Read)
        .bramc_rd_addr_o (agu_bramc_rd_addr_w),
        .bramc_rd_en_o   (agu_bramc_rd_en_w),
        .bramc_rd_dout_i (bramc_rd_dout_w),
        
        // BRAM C Interface (Write)
        .bramc_wr_addr_o (agu_bramc_wr_addr_w),
        .bramc_wr_en_o   (agu_bramc_wr_en_w),
        .bramc_wr_we_o   (agu_bramc_wr_we_w),
        .bramc_wr_din_o  (agu_bramc_wr_din_w)
    );

endmodule