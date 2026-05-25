
`timescale 1 ns / 1 ps

	module myip #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 5,

		// Parameters of Axi Slave Bus Interface S00_AXIS
		parameter integer C_S00_AXIS_TDATA_WIDTH	= 128,

		// Parameters of Axi Slave Bus Interface S01_AXIS
		parameter integer C_S01_AXIS_TDATA_WIDTH	= 128,

		// Parameters of Axi Master Bus Interface M00_AXIS
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 512,
		parameter integer C_M00_AXIS_START_COUNT	= 32
	)
	(
		// Users to add ports here
        
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready,

		// Ports of Axi Slave Bus Interface S00_AXIS
		input wire  s00_axis_aclk,
		input wire  s00_axis_aresetn,
		output wire  s00_axis_tready,
		input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
		input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
		input wire  s00_axis_tlast,
		input wire  s00_axis_tvalid,

		// Ports of Axi Slave Bus Interface S01_AXIS
		input wire  s01_axis_aclk,
		input wire  s01_axis_aresetn,
		output wire  s01_axis_tready,
		input wire [C_S01_AXIS_TDATA_WIDTH-1 : 0] s01_axis_tdata,
		input wire [(C_S01_AXIS_TDATA_WIDTH/8)-1 : 0] s01_axis_tstrb,
		input wire  s01_axis_tlast,
		input wire  s01_axis_tvalid,

		// Ports of Axi Master Bus Interface M00_AXIS
		input wire  m00_axis_aclk,
		input wire  m00_axis_aresetn,
		output wire  m00_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
		output wire  m00_axis_tlast,
		input wire  m00_axis_tready
	);
// Instantiation of Axi Bus Interface S00_AXI

	wire        done_w;           // Cờ báo hiệu tính xong từ accelerator
	wire [31:0] start_reg_w;
    wire [31:0] dim1_reg_w;
    wire [31:0] dim2_reg_w;
    wire dma_bank_w; 
    wire agu_bank_w;
	myip_slave_lite_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) myip_slave_lite_v1_0_S00_AXI_inst (
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready),
		
		.start_reg_out (start_reg_w),
        .dim1_reg_out  (dim1_reg_w),
        .dim2_reg_out  (dim2_reg_w),
        .done_flag_in  (done_w),
        .dma_bank_out(dma_bank_w),
        .agu_bank_out(agu_bank_w)
        
	);


	// Add user logic here

    
    // =========================================================================
    // USER LOGIC - KẾT NỐI TRỰC TIẾP AXI-STREAM VÀO ACCELERATOR_TOP
    // =========================================================================

    // Đồng bộ hóa Clock và Reset (Giả sử hệ thống dùng chung 1 Clock từ AXI-Lite)
    wire sys_clk   = s00_axi_aclk;
    wire sys_reset = s00_axi_aresetn;

    // ---------------------------------------------------------
    // 1. KÊNH NẠP MA TRẬN A (S00_AXIS -> BRAM A)
    // ---------------------------------------------------------
    reg [8:0] addr_a_cnt;
    always @(posedge sys_clk) begin
        if (!sys_reset) begin
            addr_a_cnt <= 0;
        end else begin
            // Tự động tăng địa chỉ khi có tín hiệu bắt tay thành công
            if (s00_axis_tvalid && s00_axis_tready) begin
                if (s00_axis_tlast) addr_a_cnt <= 0; // Reset khi nhận gói cuối
                else                addr_a_cnt <= addr_a_cnt + 1;
            end
        end
    end
    
    wire dma_we_a_w = (s00_axis_tvalid && s00_axis_tready);
    
    // IP luôn sẵn sàng nhận dữ liệu nếu chưa bị Reset
    assign s00_axis_tready = 1'b1; 


    // ---------------------------------------------------------
    // 2. KÊNH NẠP MA TRẬN B (S01_AXIS -> BRAM B)
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
    // 3. KÊNH XUẤT MA TRẬN C (BRAM C -> M00_AXIS)
    // ---------------------------------------------------------
    wire [511:0] dma_data_c_w; 
    
    // SỬA Ở ĐÂY: Tính tổng số gói tin cần gửi dựa trên M và N
    // Dịch phải 4 (>> 4) tương đương với chia cho 16
    wire [15:0] total_transfers = (dim1_reg_w[15:0] * dim2_reg_w[15:0]) >> 4; 
    
    reg [1:0]  out_state;
    reg [15:0] addr_c_cnt; // SỬA Ở ĐÂY: Nâng cấp lên 16-bit để đếm được ma trận lớn

    reg done_w_d;
    always @(posedge sys_clk) begin
        if (!sys_reset) done_w_d <= 1'b0;
        else done_w_d <= done_w;
    end
    wire done_rising_edge = (done_w && !done_w_d);

    always @(posedge sys_clk) begin
        if (!sys_reset) begin
            out_state  <= 0;
            addr_c_cnt <= 0;
        end else begin
            case (out_state)
                2'd0: begin 
                    if (done_rising_edge) begin
                        out_state  <= 2'd1;
                        addr_c_cnt <= 0;
                    end
                end
                2'd1: begin 
                    out_state <= 2'd2;
                end
                2'd2: begin 
                    if (m00_axis_tready) begin
                        // SỬA Ở ĐÂY: Đếm đến (tổng số gói tin - 1)
                        if (addr_c_cnt == total_transfers - 1) begin
                            addr_c_cnt <= 0;
                            out_state  <= 2'd0; // Xong toàn bộ, về nghỉ
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
    // SỬA Ở ĐÂY: Bật cờ TLAST ở gói tin cuối cùng thực sự
    assign m00_axis_tlast  = (out_state == 2'd2) && (addr_c_cnt == total_transfers - 1);
    assign m00_axis_tstrb  = 64'hFFFFFFFF_FFFFFFFF; 

    wire dma_re_c_w = 1'b1; 
    wire [8:0] dma_addr_c_w = addr_c_cnt[8:0]; // Cắt lấy 9-bit đưa vào accelerator
    
    // ---------------------------------------------------------
    // 4. INSTANTIATE ACCELERATOR_TOP
    // ---------------------------------------------------------
    accelerator_top #(
        .SYS_N(16),
        .DATA_WIDTH(8),
        .PSUM_WIDTH(32)
    ) my_accel_inst (
        .clk_i        (sys_clk),
        .rst_ni       (sys_reset),

        // --- Cổng Điều khiển nối vào các thanh ghi AXI-Lite (slv_reg) ---
        // slv_reg0, slv_reg1, slv_reg2 là các thanh ghi do Vivado tự sinh ra
        .start_i      (start_reg_w[0]),               // Lấy bit 0 của thanh ghi 0
        .dim_m_i      (dim1_reg_w[15:0]),            // Nửa dưới thanh ghi 1
        .dim_k_i      (dim1_reg_w[31:16]),           // Nửa trên thanh ghi 1
        .dim_n_i      (dim2_reg_w[15:0]),            // Nửa dưới thanh ghi 2
        .done_o       (done_w),                    // Xuất ra cờ done_w để dùng bên trên
        .dma_bank_i(dma_bank_w),
        .agu_bank_i(agu_bank_w),
        // --- Giao tiếp Nạp Ma trận A ---
        .dma_we_a_i   (dma_we_a_w),
        .dma_addr_a_i (addr_a_cnt),
        .dma_data_a_i (s00_axis_tdata),

        // --- Giao tiếp Nạp Ma trận B ---
        .dma_we_b_i   (dma_we_b_w),
        .dma_addr_b_i (addr_b_cnt),
        .dma_data_b_i (s01_axis_tdata),

        // --- Giao tiếp Xuất Ma trận C ---
        .dma_re_c_i   (dma_re_c_w),
        .dma_addr_c_i (dma_addr_c_w),
        .dma_data_c_o (dma_data_c_w)
    );

    // =========================================================================
	// User logic ends

	endmodule
