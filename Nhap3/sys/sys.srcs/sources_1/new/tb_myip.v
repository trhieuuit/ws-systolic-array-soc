`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2026 02:56:19 PM
// Design Name: 
// Module Name: tb_myip
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module tb_myip();

    // -------------------------------------------------------------
    // 1. KHAI BÁO TÍN HIỆU GIẢ LẬP
    // -------------------------------------------------------------
    reg clk;
    reg rst_n;

    // Tín hiệu AXI-Lite (Giả lập CPU)
    reg [3:0]  awaddr;
    reg        awvalid;
    wire       awready;
    reg [31:0] wdata;
    reg        wvalid;
    wire       wready;
    wire [1:0] bresp;
    wire       bvalid;
    reg        bready;

    // Các tín hiệu AXI-Lite còn lại (không xài tới trong test này thì gán 0)
    reg [3:0]  araddr = 0;
    reg        arvalid = 0;
    wire       arready;
    wire [31:0] rdata;
    wire [1:0] rresp;
    wire       rvalid;
    reg        rready = 1;

    // Tín hiệu AXI-Stream (Giả lập DMA Bơm A)
    wire       s00_tready;
    reg [127:0] s00_tdata;
    reg        s00_tlast;
    reg        s00_tvalid;

    // Tín hiệu AXI-Stream (Giả lập DMA Bơm B)
    wire       s01_tready;
    reg [127:0] s01_tdata;
    reg        s01_tlast;
    reg        s01_tvalid;

    // Tín hiệu AXI-Stream (Giả lập DMA Hút C)
    wire       m00_tvalid;
    wire [511:0] m00_tdata;
    wire       m00_tlast;
    reg        m00_tready; // Ta sẽ điều khiển chân này để test chống nghẽn

    // -------------------------------------------------------------
    // 2. KẾT NỐI VÀO KHỐI MYIP CỦA BẠN (Device Under Test)
    // -------------------------------------------------------------
    myip #(
        .C_S00_AXI_DATA_WIDTH(32), .C_S00_AXI_ADDR_WIDTH(4),
        .C_S00_AXIS_TDATA_WIDTH(128), .C_S01_AXIS_TDATA_WIDTH(128), .C_M00_AXIS_TDATA_WIDTH(512)
    ) DUT (
        .s00_axi_aclk(clk), .s00_axi_aresetn(rst_n),
        .s00_axi_awaddr(awaddr), .s00_axi_awprot(3'b000), .s00_axi_awvalid(awvalid), .s00_axi_awready(awready),
        .s00_axi_wdata(wdata), .s00_axi_wstrb(4'hF), .s00_axi_wvalid(wvalid), .s00_axi_wready(wready),
        .s00_axi_bresp(bresp), .s00_axi_bvalid(bvalid), .s00_axi_bready(bready),
        .s00_axi_araddr(araddr), .s00_axi_arprot(3'b000), .s00_axi_arvalid(arvalid), .s00_axi_arready(arready),
        .s00_axi_rdata(rdata), .s00_axi_rresp(rresp), .s00_axi_rvalid(rvalid), .s00_axi_rready(rready),

        .s00_axis_aclk(clk), .s00_axis_aresetn(rst_n),
        .s00_axis_tready(s00_tready), .s00_axis_tdata(s00_tdata), .s00_axis_tstrb(16'hFFFF), .s00_axis_tlast(s00_tlast), .s00_axis_tvalid(s00_tvalid),

        .s01_axis_aclk(clk), .s01_axis_aresetn(rst_n),
        .s01_axis_tready(s01_tready), .s01_axis_tdata(s01_tdata), .s01_axis_tstrb(16'hFFFF), .s01_axis_tlast(s01_tlast), .s01_axis_tvalid(s01_tvalid),

        .m00_axis_aclk(clk), .m00_axis_aresetn(rst_n),
        .m00_axis_tvalid(m00_tvalid), .m00_axis_tdata(m00_tdata), .m00_axis_tstrb(), .m00_axis_tlast(m00_tlast), .m00_axis_tready(m00_tready)
    );

    // -------------------------------------------------------------
    // 3. TẠO XUNG CLOCK (100MHz)
    // -------------------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Đảo trạng thái mỗi 5ns -> Chu kỳ 10ns = 100MHz
    end

    // -------------------------------------------------------------
    // 4. TASK GIẢ LẬP CPU GHI AXI-LITE
    // -------------------------------------------------------------
    task write_axi_lite(input [3:0] addr, input [31:0] data);
    begin
        @(posedge clk);
        awaddr  = addr;
        wdata   = data;
        awvalid = 1;
        wvalid  = 1;
        bready  = 1;
        // Chờ mạch báo ready
        wait(awready && wready);
        @(posedge clk);
        awvalid = 0;
        wvalid  = 0;
        wait(bvalid);
        @(posedge clk);
        bready  = 0;
    end
    endtask

    // -------------------------------------------------------------
    // 5. KỊCH BẢN CHẠY CHÍNH (MAIN TEST)
    // -------------------------------------------------------------
    integer i;

    initial begin
        // Khởi tạo ngõ vào
        rst_n = 0;
        awvalid = 0; wvalid = 0; bready = 0;
        s00_tvalid = 0; s00_tdata = 0; s00_tlast = 0;
        s01_tvalid = 0; s01_tdata = 0; s01_tlast = 0;
        m00_tready = 1; // DMA luôn mở cửa hút C

        // Reset hệ thống
        #50 rst_n = 1;
        #50;

        $display("--- BAT DAU MO PHONG ---");

        // BƯỚC 1: CPU Cấu hình Kích thước (M=16, K=16, N=16)
        // REG1 = {K, M} = {16, 16} = 32'h00100010
        write_axi_lite(4'h4, 32'h00100010); 
        // REG2 = {N} = 16 = 32'h00000010
        write_axi_lite(4'h8, 32'h00000010); 
        $display("1. Da nap Kich thuoc M, K, N");

        // BƯỚC 2: CPU Bật cờ START
        write_axi_lite(4'h0, 32'h00000001);
        $display("2. Da bat co START");

        // BƯỚC 3: DMA Bơm Ma trận A và B (Chạy song song)
        @(posedge clk);
        $display("3. Dang bom Data A va B vao mach...");
        
        // Vì bus rộng 128-bit (16 byte), ta chỉ cần bơm 16 nhịp là đủ ma trận 16x16
        for(i = 0; i < 16; i = i + 1) begin
            s00_tvalid = 1;
            s01_tvalid = 1;
            // Cho A toàn số 1, B toàn số 2 để dễ check
            s00_tdata  = 128'h01010101_01010101_01010101_01010101; 
            s01_tdata  = 128'h02020202_02020202_02020202_02020202;
            
            s00_tlast  = (i == 15) ? 1 : 0;
            s01_tlast  = (i == 15) ? 1 : 0;

            @(posedge clk);
            while(!s00_tready || !s01_tready) @(posedge clk); // Chờ nếu mạch bận
        end
        s00_tvalid = 0; s00_tlast = 0;
        s01_tvalid = 0; s01_tlast = 0;
        $display("4. Bơm xong Data! Dang cho mach tinh toan...");

        // BƯỚC 4: Chờ cờ TVALID và TLAST của kênh C đẩy ra
        wait(m00_tvalid);
        $display("5. Phat hien mach dang tra ve Ma tran C!");
        
        // TEST ÁP LỰC CHỐNG NGHẼN DMA: Nhấp nhả chân TREADY
        // Để xem mạch Verilog của bạn có đứng im giữ data không
        #30 m00_tready = 0; $display("=> Gia lap DMA bi nghen (TREADY = 0)");
        #50 m00_tready = 1; $display("=> DMA mo cua lai (TREADY = 1)");

        wait(m00_tlast);
        @(posedge clk);
        
        $display("--- THANH CONG! MACH DA TINH XONG VA XUAT DU DATA ---");
        #100 $finish; // Kết thúc mô phỏng
    end

endmodule
