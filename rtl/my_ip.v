`timescale 1 ns / 1 ps
//==========================================================//
//                    AXI IP Wrapper                        //
//==========================================================//
// This module wraps the accelerator_top with AXI-Lite for 
// control and AXI-Stream for Matrix A, Matrix B, and Output C data.

module myip #
(
    // Parameters of Axi Slave Bus Interface S00_AXI
    parameter integer C_S00_AXI_DATA_WIDTH   = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH   = 4,

    // Parameters of Axi Slave Bus Interface S00_AXIS
    parameter integer C_S00_AXIS_TDATA_WIDTH = 128,

    // Parameters of Axi Slave Bus Interface S01_AXIS
    parameter integer C_S01_AXIS_TDATA_WIDTH = 128,

    // Parameters of Axi Master Bus Interface M00_AXIS
    parameter integer C_M00_AXIS_TDATA_WIDTH = 512,
    parameter integer C_M00_AXIS_START_COUNT = 32
)
(
    // Ports of Axi Slave Bus Interface S00_AXI
    input  wire                                  s00_axi_aclk,
    input  wire                                  s00_axi_aresetn,
    input  wire [C_S00_AXI_ADDR_WIDTH-1 : 0]     s00_axi_awaddr,
    input  wire [2 : 0]                          s00_axi_awprot,
    input  wire                                  s00_axi_awvalid,
    output wire                                  s00_axi_awready,
    input  wire [C_S00_AXI_DATA_WIDTH-1 : 0]     s00_axi_wdata,
    input  wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
    input  wire                                  s00_axi_wvalid,
    output wire                                  s00_axi_wready,
    output wire [1 : 0]                          s00_axi_bresp,
    output wire                                  s00_axi_bvalid,
    input  wire                                  s00_axi_bready,
    input  wire [C_S00_AXI_ADDR_WIDTH-1 : 0]     s00_axi_araddr,
    input  wire [2 : 0]                          s00_axi_arprot,
    input  wire                                  s00_axi_arvalid,
    output wire                                  s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1 : 0]     s00_axi_rdata,
    output wire [1 : 0]                          s00_axi_rresp,
    output wire                                  s00_axi_rvalid,
    input  wire                                  s00_axi_rready,

    // Ports of Axi Slave Bus Interface S00_AXIS
    input  wire                                  s00_axis_aclk,
    input  wire                                  s00_axis_aresetn,
    output wire                                  s00_axis_tready,
    input  wire [C_S00_AXIS_TDATA_WIDTH-1 : 0]   s00_axis_tdata,
    input  wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
    input  wire                                  s00_axis_tlast,
    input  wire                                  s00_axis_tvalid,

    // Ports of Axi Slave Bus Interface S01_AXIS
    input  wire                                  s01_axis_aclk,
    input  wire                                  s01_axis_aresetn,
    output wire                                  s01_axis_tready,
    input  wire [C_S01_AXIS_TDATA_WIDTH-1 : 0]   s01_axis_tdata,
    input  wire [(C_S01_AXIS_TDATA_WIDTH/8)-1 : 0] s01_axis_tstrb,
    input  wire                                  s01_axis_tlast,
    input  wire                                  s01_axis_tvalid,

    // Ports of Axi Master Bus Interface M00_AXIS
    input  wire                                  m00_axis_aclk,
    input  wire                                  m00_axis_aresetn,
    output wire                                  m00_axis_tvalid,
    output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0]   m00_axis_tdata,
    output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
    output wire                                  m00_axis_tlast,
    input  wire                                  m00_axis_tready
);

//==========================================================//
//                AXI-Lite Slave Instantiation              //
//==========================================================//

    wire        done_w;           // Computation completion flag from accelerator
    wire [31:0] start_reg_w;
    wire [31:0] dim1_reg_w;
    wire [31:0] dim2_reg_w;
    wire        dma_bank_w; 
    wire        agu_bank_w;

    myip_slave_lite_v1_0_S00_AXI #( 
        .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
    ) myip_slave_lite_v1_0_S00_AXI_inst (
        .S_AXI_ACLK    (s00_axi_aclk),
        .S_AXI_ARESETN (s00_axi_aresetn),
        .S_AXI_AWADDR  (s00_axi_awaddr),
        .S_AXI_AWPROT  (s00_axi_awprot),
        .S_AXI_AWVALID (s00_axi_awvalid),
        .S_AXI_AWREADY (s00_axi_awready),
        .S_AXI_WDATA   (s00_axi_wdata),
        .S_AXI_WSTRB   (s00_axi_wstrb),
        .S_AXI_WVALID  (s00_axi_wvalid),
        .S_AXI_WREADY  (s00_axi_wready),
        .S_AXI_BRESP   (s00_axi_bresp),
        .S_AXI_BVALID  (s00_axi_bvalid),
        .S_AXI_BREADY  (s00_axi_bready),
        .S_AXI_ARADDR  (s00_axi_araddr),
        .S_AXI_ARPROT  (s00_axi_arprot),
        .S_AXI_ARVALID (s00_axi_arvalid),
        .S_AXI_ARREADY (s00_axi_arready),
        .S_AXI_RDATA   (s00_axi_rdata),
        .S_AXI_RRESP   (s00_axi_rresp),
        .S_AXI_RVALID  (s00_axi_rvalid),
        .S_AXI_RREADY  (s00_axi_rready),
        
        .start_reg_out (start_reg_w),
        .dim1_reg_out  (dim1_reg_w),
        .dim2_reg_out  (dim2_reg_w),
        .done_flag_in  (done_w),
        .dma_bank_out  (dma_bank_w),
        .agu_bank_out  (agu_bank_w)
    );

//==========================================================//
//          USER LOGIC - STREAMING & ACCELERATOR            //
//==========================================================//

    // Clock and Reset Synchronization (Assuming unified clock domain)
    wire sys_clk   = s00_axi_aclk;
    wire sys_reset = s00_axi_aresetn;

    // ---------------------------------------------------------
    // 1. MATRIX A CHANNEL (S00_AXIS -> BRAM A)
    // ---------------------------------------------------------
    reg [8:0] addr_a_cnt;
    always @(posedge sys_clk) begin
        if (!sys_reset) begin
            addr_a_cnt <= 0;
        end else begin
            // Automatically increment address upon successful handshake
            if (s00_axis_tvalid && s00_axis_tready) begin
                if (s00_axis_tlast) addr_a_cnt <= 0; // Reset upon receiving last packet
                else                addr_a_cnt <= addr_a_cnt + 1;
            end
        end
    end
    
    wire dma_we_a_w = (s00_axis_tvalid && s00_axis_tready);
    
    // IP is always ready to receive data as long as it isn't in reset
    assign s00_axis_tready = 1'b1; 

    // ---------------------------------------------------------
    // 2. MATRIX B CHANNEL (S01_AXIS -> BRAM B)
    // ---------------------------------------------------------
    reg [8:0] addr_b_cnt;
    always @(posedge sys_clk) begin
        if (!sys_reset) begin
            addr_b_cnt <= 0;
        end else begin
            if (s01_axis_tvalid && s01_axis_tready) begin
                if (s01_axis_tlast) addr_b_cnt <= 0;
                else                addr_b_cnt <= addr_b_cnt + 1;
            end
        end
    end
    
    wire dma_we_b_w = (s01_axis_tvalid && s01_axis_tready);
    assign s01_axis_tready = 1'b1;

    // ---------------------------------------------------------
    // 3. MATRIX C CHANNEL (BRAM C -> M00_AXIS)
    // ---------------------------------------------------------
    wire [511:0] dma_data_c_w; 
    
    // Calculate total packets based on M and N dimensions
    // Right shift by 4 (>> 4) is equivalent to dividing by 16 (SYS_N)
    wire [15:0] total_transfers = (dim1_reg_w[15:0] * dim2_reg_w[15:0]) >> 4; 
    
    reg [1:0]  out_state;
    reg [15:0] addr_c_cnt; // Upgraded to 16-bit to count large matrices
    
    // =========================================================
    // SAFETY MECHANISM: AVOID RACE CONDITIONS IN PING-PONG
    // =========================================================
    // Only ready to transmit when computation is complete AND CPU confirms banks are aligned
    wire safe_to_send = done_w && (dma_bank_w == agu_bank_w);

    reg safe_to_send_d;
    always @(posedge sys_clk) begin
        if (!sys_reset) safe_to_send_d <= 1'b0;
        else            safe_to_send_d <= safe_to_send;
    end
    
    // Generate pulse to trigger data transmission
    wire trigger_tx_pulse = (safe_to_send && !safe_to_send_d);

    always @(posedge sys_clk) begin
        if (!sys_reset) begin
            out_state  <= 0;
            addr_c_cnt <= 0;
        end else begin
            case (out_state)
                2'd0: begin 
                    // Wait for the safe pulse instead of simple done_w
                    if (trigger_tx_pulse) begin
                        out_state  <= 2'd1;
                        addr_c_cnt <= 0;
                    end
                end
                2'd1: begin 
                    out_state <= 2'd2;
                end
                2'd2: begin 
                    if (m00_axis_tready) begin
                        // Count up to (total packets - 1)
                        if (addr_c_cnt == total_transfers - 1) begin
                            addr_c_cnt <= 0;
                            out_state  <= 2'd0; // Transmission complete, return to idle
                        end else begin
                            addr_c_cnt <= addr_c_cnt + 1;
                            out_state  <= 2'd1; 
                        end
                    end
                end
            endcase
        end
    end

    assign m00_axis_tvalid = (out_state == 2'd2);
    assign m00_axis_tdata  = dma_data_c_w;
    
    // Assert TLAST strictly on the final packet
    assign m00_axis_tlast  = (out_state == 2'd2) && (addr_c_cnt == total_transfers - 1);
    assign m00_axis_tstrb  = 64'hFFFFFFFF_FFFFFFFF; 

    wire       dma_re_c_w   = 1'b1; 
    wire [8:0] dma_addr_c_w = addr_c_cnt[8:0]; // Slice 9 LSBs for accelerator BRAM address
    
//==========================================================//
//                Accelerator Top Instantiation             //
//==========================================================//

    accelerator_ping_pong #(
        .SYS_N(16),
        .DATA_WIDTH(8),
        .PSUM_WIDTH(32)
    ) my_accel_inst (
        .clk_i             (sys_clk),
        .rst_ni            (sys_reset),

        // --- Control Ports (Connected to Vivado slv_reg) ---
        .start_i           (start_reg_w[0]),       // Bit 0 of reg 0
        .dim_m_i           (dim1_reg_w[15:0]),     // Lower half of reg 1
        .dim_k_i           (dim1_reg_w[31:16]),    // Upper half of reg 1
        .dim_n_i           (dim2_reg_w[15:0]),     // Lower half of reg 2
        .done_o            (done_w),               // Output to upper logic
        .dma_bank_i        (dma_bank_w),
        .agu_bank_i        (agu_bank_w),
        
        // --- DMA Matrix A Interface ---
        .dma_we_a_i        (dma_we_a_w),
        .dma_addr_a_i      (addr_a_cnt),
        .dma_data_a_i      (s00_axis_tdata),

        // --- DMA Matrix B Interface ---
        .dma_we_b_i        (dma_we_b_w),
        .dma_addr_b_i      (addr_b_cnt),
        .dma_data_b_i      (s01_axis_tdata),

        // --- DMA Matrix C Interface ---
        .dma_re_c_i        (dma_re_c_w),
        .dma_addr_c_i      (dma_addr_c_w),
        .dma_data_c_o      (dma_data_c_w)
    );

endmodule