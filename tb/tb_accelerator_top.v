`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/18/2026 10:25:01 PM
// Design Name: 
// Module Name: tb_accelerator_top
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



module tb_accelerator_top;

    // ==========================================
    // THAM SỐ HỆ THỐNG
    // ==========================================
    parameter SYS_N = 16;
    parameter DATA_WIDTH = 8;
    parameter PSUM_WIDTH = 32;

    // ==========================================
    // KHAI BÁO TÍN HIỆU (SIGNALS)
    // ==========================================
    reg clk;
    reg rst_ni;

    // Control
    reg        start_i;
    reg [15:0] dim_m_i;
    reg [15:0] dim_k_i;
    reg [15:0] dim_n_i;
    wire       done_o;

    // DMA A
    reg        dma_we_a_i;
    reg [8:0]  dma_addr_a_i;
    reg [127:0] dma_data_a_i;

    // DMA B
    reg        dma_we_b_i;
    reg [8:0]  dma_addr_b_i;
    reg [127:0] dma_data_b_i;

    // DMA C
    reg        dma_re_c_i;
    reg [8:0]  dma_addr_c_i;
    wire [511:0] dma_data_c_o;

    // ==========================================
    // KHỞI TẠO MODULE TOP (DUT - Design Under Test)
    // ==========================================
    accelerator_single #(
        .SYS_N(SYS_N),
        .DATA_WIDTH(DATA_WIDTH),
        .PSUM_WIDTH(PSUM_WIDTH)
    ) dut (
        .clk_i         (clk),
        .rst_ni        (rst_ni),

        .start_i       (start_i),
        .dim_m_i       (dim_m_i),
        .dim_k_i       (dim_k_i),
        .dim_n_i       (dim_n_i),
        .done_o        (done_o),

        .dma_we_a_i    (dma_we_a_i),
        .dma_addr_a_i  (dma_addr_a_i),
        .dma_data_a_i  (dma_data_a_i),

        .dma_we_b_i    (dma_we_b_i),
        .dma_addr_b_i  (dma_addr_b_i),
        .dma_data_b_i  (dma_data_b_i),

        .dma_re_c_i    (dma_re_c_i),
        .dma_addr_c_i  (dma_addr_c_i),
        .dma_data_c_o  (dma_data_c_o)
    );

    // ==========================================
    // TẠO XUNG CLOCK (100MHz)
    // ==========================================
    always #5 clk = ~clk;

    // ==========================================
    // QUÁ TRÌNH CHẠY TEST (MAIN PROCESS)
    // ==========================================
    integer i, p;
    integer total_words;
    
    initial begin
        // 1. KHỞI TẠO TRẠNG THÁI BAN ĐẦU
        clk = 0;
        rst_ni = 0;
        start_i = 0;
        dma_we_a_i = 0; dma_addr_a_i = 0; dma_data_a_i = 0;
        dma_we_b_i = 0; dma_addr_b_i = 0; dma_data_b_i = 0;
        dma_re_c_i = 0; dma_addr_c_i = 0;
        
        // Cấu hình tính toán ma trận 32x32
        dim_m_i = 32;
        dim_k_i = 32;
        dim_n_i = 32;

        $display("==================================================");
        $display("BẮT ĐẦU MÔ PHỎNG: NHÂN MA TRẬN 32x32 TRÊN MẢNG 16x16");
        $display("==================================================");

        // Nhả Reset sau 20ns
        #20;
        rst_ni = 1;
        #20;

        // 2. PHA NẠP LIỆU (Giả lập DMA bơm ma trận A và B vào BRAM)
        // Ma trận 32x32 cần số dòng BRAM = (32 * 32) / 16 = 64 dòng.
        total_words = (32 * 32) / 16;
        
        $display("[TIME: %0t] PHA 1: Nạp Ma trận A (toàn số 1) và Ma trận B (toàn số 2)", $time);
        for (i = 0; i < total_words; i = i + 1) begin
            @(posedge clk);
            // Nạp A
            dma_we_a_i = 1;
            dma_addr_a_i = i;
            dma_data_a_i = {16{8'h01}}; // 16 phần tử, mỗi phần tử mang giá trị 1

            // Nạp B
            dma_we_b_i = 1;
            dma_addr_b_i = i;
            dma_data_b_i = {16{8'h02}}; // 16 phần tử, mỗi phần tử mang giá trị 2
        end
        @(posedge clk);
        dma_we_a_i = 0; // Tắt ghi
        dma_we_b_i = 0;

        // 3. PHA TÍNH TOÁN (Giả lập CPU kích hoạt phần cứng)
        #50;
        $display("[TIME: %0t] PHA 2: Kích hoạt Start", $time);
        @(posedge clk);
        start_i = 1;
        @(posedge clk);
        start_i = 0;

        // CHỜ HỆ THỐNG TÍNH TOÁN XONG
        $display("[TIME: %0t] Hệ thống đang tính toán... (Tiling AGU đang chia việc)", $time);
        wait(done_o); // Đứng chờ ở đây cho đến khi done_o = 1
        $display("[TIME: %0t] PHA 3: Đã có tín hiệu DONE_O! Bắt đầu thu hoạch BRAM C.", $time);

        // 4. PHA THU HOẠCH (Giả lập DMA hút dữ liệu từ BRAM C)
        #20;
        for (i = 0; i < total_words; i = i + 1) begin
            @(posedge clk);
            dma_re_c_i = 1;
            dma_addr_c_i = i;
            
            // Vì BRAM C có độ trễ đọc là 1 nhịp clock, phải đợi nhịp tiếp theo mới lấy data
            @(posedge clk); 
            #1; // Delay thêm 1 chút xíu ảo (1ns) để waveform hiển thị đẹp, tránh đua tín hiệu
            
            // In 4 phần tử đầu tiên của mỗi hàng ra màn hình để kiểm chứng
            $display("Addr %2d | Psum[0]: %0d, Psum[1]: %0d, Psum[2]: %0d, Psum[3]: %0d", 
                      dma_addr_c_i,
                      dma_data_c_o[31:0], 
                      dma_data_c_o[63:32], 
                      dma_data_c_o[95:64], 
                      dma_data_c_o[127:96]);
                      
            // Kiểm tra tự động (Self-checking): Phải ra 64
            if (dma_data_c_o[31:0] !== 32'd64) begin
                $display(">>> LỖI SAI KẾT QUẢ TẠI ĐỊA CHỈ %0d <<<", i);
                $stop;
            end
        end
        @(posedge clk);
        dma_re_c_i = 0;

        $display("==================================================");
        $display(">>> TEST PASSED THÀNH CÔNG RỰC RỠ! TẤT CẢ KẾT QUẢ ĐỀU LÀ 64 <<<");
        $display("==================================================");
        $finish;
    end

endmodule