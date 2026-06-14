`timescale 1ns / 1ps

// =============================================================================
//  Self-Checking Testbench cho tiling_agu
//
//  Layout BRAM khớp với tilling_agu.v + pe_grid.v:
//
//  BRAM A: addr = row_a * (K/SYS_N) + k_tile
//          bit[r*DW +: DW] = A[row_a][k_tile*SYS_N + r]   (pe_grid hàng r)
//
//  BRAM B: addr = row_b * (N/SYS_N) + n_tile
//          bit[c*DW +: DW] = B[row_b][n_tile*SYS_N + c]   (pe_grid cột c)
//
//  BRAM C: addr = row_c * (N/SYS_N) + n_tile
//          bit[c*PW +: PW] = C[row_c][n_tile*SYS_N + c]   (output cột c)
// =============================================================================

module tb_tiling_agu_sc();

    // =========================================================================
    // PARAMETERS
    // =========================================================================
    parameter SYS_N      = 16;
    parameter DATA_WIDTH = 8;
    parameter PSUM_WIDTH = 32;

    parameter DIM_M = 64;
    parameter DIM_K = 64;
    parameter DIM_N = 64;

    localparam TIMEOUT_CYC = 200_000; // số cycle tối đa

    // =========================================================================
    // TÍN HIỆU
    // =========================================================================
    reg  clk_r, rst_n_r, start_r;
    reg  [15:0] dim_m_r, dim_k_r, dim_n_r;
    wire done_w;

    wire [31:0]                   brama_addr_w;
    wire                          brama_en_w;
    wire [(SYS_N*DATA_WIDTH)-1:0] brama_dout_w;

    wire [31:0]                   bramb_addr_w;
    wire                          bramb_en_w;
    wire [(SYS_N*DATA_WIDTH)-1:0] bramb_dout_w;

    wire [31:0]                    bramc_addr_w;
    wire                           bramc_en_w;
    wire                           bramc_we_w;
    wire [(SYS_N*PSUM_WIDTH)-1:0]  bramc_din_w;
    wire [(SYS_N*PSUM_WIDTH)-1:0]  bramc_dout_w;

wire [31:0]                    bramc_rd_addr_w;
    wire                           bramc_rd_en_w;
    wire [(SYS_N*PSUM_WIDTH)-1:0]  bramc_rd_dout_w;

    wire [31:0]                    bramc_wr_addr_w;
    wire                           bramc_wr_en_w;
    wire                           bramc_wr_we_w;
    wire [(SYS_N*PSUM_WIDTH)-1:0]  bramc_wr_din_w;
    // =========================================================================
    // BRAM ẢO
    // =========================================================================
    reg [(SYS_N*DATA_WIDTH)-1:0]  BRAM_A_r [0:4095];
    reg [(SYS_N*DATA_WIDTH)-1:0]  BRAM_B_r [0:4095];
    reg [(SYS_N*PSUM_WIDTH)-1:0]  BRAM_C_r [0:4095];

//    assign brama_dout_w = brama_en_w ? BRAM_A_r[brama_addr_w] : 0;
//    assign bramb_dout_w = bramb_en_w ? BRAM_B_r[bramb_addr_w] : 0;
    
    // THAY BẰNG KHỐI SAU (Mô phỏng BRAM trễ 1 nhịp):
    reg [(SYS_N*DATA_WIDTH)-1:0] brama_dout_reg;
    reg [(SYS_N*DATA_WIDTH)-1:0] bramb_dout_reg;

    always @(posedge clk_r) begin
        if (brama_en_w) brama_dout_reg <= BRAM_A_r[brama_addr_w];
        if (bramb_en_w) bramb_dout_reg <= BRAM_B_r[bramb_addr_w];
    end

    assign brama_dout_w = brama_dout_reg;
    assign bramb_dout_w = bramb_dout_reg;
    
    reg [(SYS_N*PSUM_WIDTH)-1:0] bramc_dout_reg;
    always @(posedge clk_r) begin
        if (bramc_rd_en_w) bramc_dout_reg <= BRAM_C_r[bramc_rd_addr_w];
    end
    assign bramc_rd_dout_w = bramc_dout_reg;

    // BRAM C - Port B: GHI
    always @(posedge clk_r) begin
        if (bramc_wr_en_w && bramc_wr_we_w)
            BRAM_C_r[bramc_wr_addr_w] <= bramc_wr_din_w;
    end

    always @(posedge clk_r)
        if (bramc_en_w && bramc_we_w)
            BRAM_C_r[bramc_addr_w] <= bramc_din_w;

    // =========================================================================
    // DUT
    // =========================================================================
    tiling_agu #(
        .SYS_N(SYS_N), .DATA_WIDTH(DATA_WIDTH), .PSUM_WIDTH(PSUM_WIDTH)
    ) dut (
        .clk_i(clk_r), .rst_ni(rst_n_r), .start_i(start_r),
        .dim_m_i(dim_m_r), .dim_k_i(dim_k_r), .dim_n_i(dim_n_r),
        .done_o(done_w),
        
        .brama_addr_o(brama_addr_w), .brama_en_o(brama_en_w), .brama_dout_i(brama_dout_w),
        .bramb_addr_o(bramb_addr_w), .bramb_en_o(bramb_en_w), .bramb_dout_i(bramb_dout_w),
        
        // Giao tiếp BRAM C mới
        .bramc_rd_addr_o(bramc_rd_addr_w), .bramc_rd_en_o(bramc_rd_en_w), .bramc_rd_dout_i(bramc_rd_dout_w),
        .bramc_wr_addr_o(bramc_wr_addr_w), .bramc_wr_en_o(bramc_wr_en_w), .bramc_wr_we_o(bramc_wr_we_w), .bramc_wr_din_o(bramc_wr_din_w)
    );

    // =========================================================================
    // CLOCK
    // =========================================================================
    initial begin clk_r = 0; forever #5 clk_r = ~clk_r; end

    // =========================================================================
    // GOLDEN MODEL & BRAM PACKING
    // =========================================================================
    integer A_flat [0:DIM_M*DIM_K-1];
    integer B_flat [0:DIM_K*DIM_N-1];
    integer C_gold [0:DIM_M*DIM_N-1];
    integer ii, jj, kk;

    task build_golden;
    integer s, row_a, k_tile, row_b, n_tile, r, addr_a, addr_b;
    begin
        // --- Tạo dữ liệu: A[i][k]=i+1, B[k][j]=j+1 => C[i][j]=K*(i+1)*(j+1) ---
        for (ii = 0; ii < DIM_M; ii = ii + 1)
            for (kk = 0; kk < DIM_K; kk = kk + 1)
                A_flat[ii*DIM_K + kk] = $random % 128;

        for (kk = 0; kk < DIM_K; kk = kk + 1)
            for (jj = 0; jj < DIM_N; jj = jj + 1)
                B_flat[kk*DIM_N + jj] = $random % 128;

        // --- Golden C = A x B ---
        for (ii = 0; ii < DIM_M; ii = ii + 1)
            for (jj = 0; jj < DIM_N; jj = jj + 1) begin
                s = 0;
                for (kk = 0; kk < DIM_K; kk = kk + 1)
                    s = s + A_flat[ii*DIM_K + kk] * B_flat[kk*DIM_N + jj];
                C_gold[ii*DIM_N + jj] = s;
            end

        // --- Pack BRAM A ---
        // addr = row_a*(K/SYS_N) + k_tile
        // bit[r*DW +: DW] = A[row_a][k_tile*SYS_N + r]
        // Vì pe_grid: input_pe_w[r][0] = input_i[r*DW +: DW]
        //   => hàng r của array nhận bit r => bit r = phần tử thứ r trong tile K
        for (ii = 0; ii < 4096; ii = ii + 1) BRAM_A_r[ii] = 0;
        for (row_a = 0; row_a < DIM_M; row_a = row_a + 1)
            for (k_tile = 0; k_tile < DIM_K/SYS_N; k_tile = k_tile + 1) begin
                addr_a = row_a*(DIM_K/SYS_N) + k_tile;
                for (r = 0; r < SYS_N; r = r + 1)
                    BRAM_A_r[addr_a][r*DATA_WIDTH +: DATA_WIDTH]
                        = A_flat[row_a*DIM_K + k_tile*SYS_N + r];
            end

        // --- Pack BRAM B ---
        // addr = row_b*(N/SYS_N) + n_tile
        // bit[c*DW +: DW] = B[row_b][n_tile*SYS_N + c]
        // Vì pe_grid: weight_pe_w[0][c] = weight_i[c*DW +: DW]
        //   => cột c của array nhận bit c => bit c = phần tử cột c trong tile N
        for (ii = 0; ii < 4096; ii = ii + 1) BRAM_B_r[ii] = 0;
        for (row_b = 0; row_b < DIM_K; row_b = row_b + 1)
            for (n_tile = 0; n_tile < DIM_N/SYS_N; n_tile = n_tile + 1) begin
                addr_b = row_b*(DIM_N/SYS_N) + n_tile;
                for (r = 0; r < SYS_N; r = r + 1)
                    BRAM_B_r[addr_b][r*DATA_WIDTH +: DATA_WIDTH]
                        = B_flat[row_b*DIM_N + n_tile*SYS_N + r];
            end

        // --- Xóa BRAM C ---
        for (ii = 0; ii < 4096; ii = ii + 1) BRAM_C_r[ii] = 0;

        // --- In để xác minh ---
        $display("\n--- MATRIX A (%0dx%0d) ---", DIM_M, DIM_K);
        for (ii = 0; ii < DIM_M; ii = ii + 1) begin
            $write("  Row %0d: ", ii);
            for (kk = 0; kk < DIM_K; kk = kk + 1) $write("%3d ", A_flat[ii*DIM_K+kk]);
            $display("");
        end
        $display("\n--- MATRIX B (%0dx%0d) ---", DIM_K, DIM_N);
        for (kk = 0; kk < DIM_K; kk = kk + 1) begin
            $write("  Row %0d: ", kk);
            for (jj = 0; jj < DIM_N; jj = jj + 1) $write("%3d ", B_flat[kk*DIM_N+jj]);
            $display("");
        end
        $display("\n--- EXPECTED C = A x B ---");
        for (ii = 0; ii < DIM_M; ii = ii + 1) begin
            $write("  Row %0d: ", ii);
            for (jj = 0; jj < DIM_N; jj = jj + 1) $write("%5d ", C_gold[ii*DIM_N+jj]);
            $display("");
        end
    end
    endtask

    // =========================================================================
    // SELF-CHECK
    // =========================================================================
    integer errors;

    task check_results;
    integer row_c, n_tile, c, addr_c, hw_val, gold_val, col_abs;
    begin
        errors = 0;
        $display("\n--- MATRIX C (Hardware output) ---");
        for (row_c = 0; row_c < DIM_M; row_c = row_c + 1) begin
            $write("  Row %0d: ", row_c);
            for (n_tile = 0; n_tile < DIM_N/SYS_N; n_tile = n_tile + 1) begin
                addr_c = row_c*(DIM_N/SYS_N) + n_tile;
                for (c = 0; c < SYS_N; c = c + 1)
                    $write("%5d ", $signed(BRAM_C_r[addr_c][c*PSUM_WIDTH +: PSUM_WIDTH]));
            end
            $display("");
        end

        $display("\n==================================================");
        $display("  SELF-CHECK");
        $display("==================================================");
        for (row_c = 0; row_c < DIM_M; row_c = row_c + 1)
            for (n_tile = 0; n_tile < DIM_N/SYS_N; n_tile = n_tile + 1) begin
                addr_c = row_c*(DIM_N/SYS_N) + n_tile;
                for (c = 0; c < SYS_N; c = c + 1) begin
                    col_abs  = n_tile*SYS_N + c;
                    hw_val   = $signed(BRAM_C_r[addr_c][c*PSUM_WIDTH +: PSUM_WIDTH]);
                    gold_val = C_gold[row_c*DIM_N + col_abs];
                    if (hw_val !== gold_val) begin
                        $display("  [FAIL] C[%0d][%0d]  Expected=%0d  Got=%0d",
                                 row_c, col_abs, gold_val, hw_val);
                        errors = errors + 1;
                    end
                end
            end

        $display("--------------------------------------------------");
        if (errors == 0)
            $display("  KET QUA: PASS - Tat ca %0d phan tu dung!", DIM_M*DIM_N);
        else
            $display("  KET QUA: FAIL - Co %0d loi!", errors);
        $display("==================================================\n");
    end
    endtask

    // =========================================================================
    // MAIN
    // =========================================================================
    integer timeout_cnt;

    initial begin
        rst_n_r = 0; start_r = 0;
        dim_m_r = DIM_M; dim_k_r = DIM_K; dim_n_r = DIM_N;

        $display("==================================================");
        $display("  TB SELF-CHECK: TILING AGU  M=%0d K=%0d N=%0d  SYS_N=%0d",
                 DIM_M, DIM_K, DIM_N, SYS_N);
        $display("==================================================");

        build_golden();

        #100; rst_n_r = 1;
        #2000;

        @(posedge clk_r); start_r = 1;
        @(posedge clk_r); start_r = 0;

        $display("[%0t ns] Bat dau tinh toan...", $time);

        // Chờ done với timeout (Verilog-2001)
        timeout_cnt = 0;
        while (done_w !== 1'b1) begin
            @(posedge clk_r);
            timeout_cnt = timeout_cnt + 1;
            if (timeout_cnt >= TIMEOUT_CYC) begin
                $display("[%0t ns] *** TIMEOUT! done_w khong len. ***", $time);
                $finish;
            end
        end

        $display("[%0t ns] done_w = 1 - Hoan tat!", $time);
        #50;

        check_results();

        #100; $finish;
    end

endmodule