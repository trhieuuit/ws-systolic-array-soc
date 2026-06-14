`timescale 1ns / 1ps

module tiling_agu #(
    parameter SYS_N = 16,
    parameter DATA_WIDTH = 8,
    parameter PSUM_WIDTH = 32
)(
    input  wire clk_i,
    input  wire rst_ni,
    input  wire start_i,
    
    input  wire [15:0] dim_m_i,
    input  wire [15:0] dim_k_i,
    input  wire [15:0] dim_n_i,
    output wire        done_o,
    
    output wire [31:0]                     brama_addr_o,
    output wire                            brama_en_o,
    input  wire [(SYS_N*DATA_WIDTH)-1:0]   brama_dout_i,
    
    output wire [31:0]                     bramb_addr_o,
    output wire                            bramb_en_o,
    input  wire [(SYS_N*DATA_WIDTH)-1:0]   bramb_dout_i,
  
    // ==========================================
    // BRAM C - PORT A (READ ONLY)
    // ==========================================
    output wire [31:0]                     bramc_rd_addr_o,
    output wire                            bramc_rd_en_o,
    input  wire [(SYS_N*PSUM_WIDTH)-1:0]   bramc_rd_dout_i,
    
    // ==========================================
    // BRAM C - PORT B (WRITE ONLY)
    // ==========================================
    output wire [31:0]                     bramc_wr_addr_o,
    output wire                            bramc_wr_en_o,
    output wire                            bramc_wr_we_o,
    output wire [(SYS_N*PSUM_WIDTH)-1:0]   bramc_wr_din_o
);

    localparam IDLE_S       = 3'd0;
    localparam FETCH_W_S    = 3'd1; 
    localparam WAIT_LOADW_S = 3'd2; 
    localparam FETCH_IN_S   = 3'd3; 
    localparam WAIT_MAC_S   = 3'd4; 
    localparam ACCUM_C_S    = 3'd5; 
    localparam UPDATE_CNT_S = 3'd6; 
    localparam WAIT_DONE_S  = 3'd7; 
    
    reg [2:0] state_r, next_state_r;
    
    reg start_d;
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) start_d <= 0;
        else start_d <= start_i;
    end
    wire start_pulse = start_i && !start_d;
    
    reg [15:0] m_cnt_r, k_cnt_r, n_cnt_r;
    reg [4:0]  row_idx_r; 
    
    wire sys_done_w;
    wire sys_wff_full_w, sys_inff_full_w, sys_outff_empty_w;
    wire [(SYS_N*PSUM_WIDTH)-1:0] sys_outff_dout_w;
    
    reg sys_start_r;
    reg sys_loadw_r;

    wire sys_outff_rd_en_w = (state_r == ACCUM_C_S)  && !sys_outff_empty_w;

    // ==========================================
    // PIPELINE REGISTERS (BRAM C LATENCY SYNCHRONIZATION)
    // ==========================================
    // STAGE 1 (d1): Fetch FIFO data, output BRAM Read Address
    reg        sys_outff_rd_en_d1;
    reg [4:0]  row_idx_d1;
    reg [15:0] k_cnt_d1, m_cnt_d1, n_cnt_d1;
    reg [(SYS_N*PSUM_WIDTH)-1:0] sys_outff_dout_d1;
    
    // NEW: 1-cycle delay register for FIFO Write command
    reg        sys_wff_wr_en_d1;  
    reg        sys_inff_wr_en_d1;
    
    // STAGE 2 (d2): Receive BRAM data, output BRAM Write Address
    reg        sys_outff_rd_en_d2;
    reg [31:0] bramc_wr_addr_d2;
    reg [15:0] k_cnt_d2;
    reg [(SYS_N*PSUM_WIDTH)-1:0] sys_outff_dout_d2;
    
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            sys_outff_rd_en_d1 <= 0;
            row_idx_d1 <= 0; k_cnt_d1 <= 0; m_cnt_d1 <= 0; n_cnt_d1 <= 0;
            sys_outff_dout_d1 <= 0;
            
            sys_wff_wr_en_d1  <= 0;
            sys_inff_wr_en_d1 <= 0;
            
            
            sys_outff_rd_en_d2 <= 0;
            bramc_wr_addr_d2   <= 0;
            k_cnt_d2           <= 0;
        end else begin
            // --- Update Stage 1 ---
            sys_outff_rd_en_d1 <= sys_outff_rd_en_w;
            row_idx_d1         <= row_idx_r;
            k_cnt_d1           <= k_cnt_r;
            m_cnt_d1           <= m_cnt_r;
            n_cnt_d1           <= n_cnt_r;
            
            sys_wff_wr_en_d1  <= bramb_en_o;
            sys_inff_wr_en_d1 <= brama_en_o;
            
            if (sys_outff_rd_en_w) begin
                sys_outff_dout_d1 <= sys_outff_dout_w;
            end
            
            // --- Update Stage 2 ---
            sys_outff_rd_en_d2 <= sys_outff_rd_en_d1;
            // WRITE address at cycle d2 is the READ address saved from cycle d1
            bramc_wr_addr_d2   <= bramc_rd_addr_o; 
            k_cnt_d2           <= k_cnt_d1;
            sys_outff_dout_d2  <= sys_outff_dout_d1;
        end
    end

    // ==========================================
    // INSTANTIATE SYSTOLIC ARRAY CORE
    // ==========================================
    systolic_array #(
        .N(SYS_N),
        .DATA_WIDTH(DATA_WIDTH),
        .PSUM_WIDTH(PSUM_WIDTH)
    ) sys_core (
        .clk_i          (clk_i),
        .rst_n          (rst_ni),
        .start_i        (sys_start_r),
        .loadw_i        (sys_loadw_r),
        .done_o         (sys_done_w),
        
        .dma_clk_i      (clk_i),
        
        .wff_wr_en_i    (sys_wff_wr_en_d1),
        .wff_din_i      (bramb_dout_i),    
        .wff_full_o     (sys_wff_full_w),
        
        .inff_wr_en_i   (sys_inff_wr_en_d1),
        .inff_din_i     (brama_dout_i),     
        .inff_full_o    (sys_inff_full_w),
        
        .outff_rd_en_i  (sys_outff_rd_en_w), 
        .outff_dout_o   (sys_outff_dout_w),
        .outff_empty_o  (sys_outff_empty_w)
    );

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) state_r <= IDLE_S;
        else          state_r <= next_state_r;
    end

    /// ==========================================
    // FSM LOGIC
    // ==========================================
    always @(*) begin
        next_state_r = state_r; 
        case (state_r)
            IDLE_S:       if (start_pulse) next_state_r = FETCH_W_S; // Use start_pulse instead of start_i
            FETCH_W_S:    if (bramb_en_o  && row_idx_r == SYS_N - 1) next_state_r = WAIT_LOADW_S;
            WAIT_LOADW_S: if (sys_done_w) next_state_r = FETCH_IN_S;
            FETCH_IN_S:   if (brama_en_o && row_idx_r == SYS_N - 1) next_state_r = WAIT_MAC_S;
            WAIT_MAC_S:   if (sys_done_w) next_state_r = ACCUM_C_S;
            ACCUM_C_S:    if (sys_outff_rd_en_w && row_idx_r == SYS_N - 1) next_state_r = UPDATE_CNT_S;
            UPDATE_CNT_S: begin
                if (m_cnt_r >= dim_m_i - SYS_N && n_cnt_r >= dim_n_i - SYS_N && k_cnt_r >= dim_k_i - SYS_N)
                    next_state_r = WAIT_DONE_S; // Move to wait pipeline flush instead of returning to IDLE
                else
                    next_state_r = FETCH_W_S;
            end
            WAIT_DONE_S: next_state_r = IDLE_S; // Stay here for 1 Clock cycle to allow d2 to finish BRAM write before returning to IDLE
            default: next_state_r = IDLE_S;
        endcase
    end

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            m_cnt_r <= 0; k_cnt_r <= 0; n_cnt_r <= 0; row_idx_r <= 0;
            sys_start_r <= 0; sys_loadw_r <= 0; 
        end else begin
            sys_start_r <= 0; sys_loadw_r <= 0; 

            case (state_r)
                IDLE_S: begin
                    m_cnt_r <= 0; k_cnt_r <= 0; n_cnt_r <= 0; row_idx_r <= 0;
                end
                FETCH_W_S: begin
                    if (bramb_en_o) begin
                        if (row_idx_r == SYS_N - 1) begin
                            sys_loadw_r <= 1; 
                            row_idx_r <= 0;
                        end else row_idx_r <= row_idx_r + 1;
                    end
                end
                WAIT_LOADW_S: row_idx_r <= 0; 
                FETCH_IN_S: begin
                    if (brama_en_o) begin
                        if (row_idx_r == SYS_N - 1) begin
                            sys_start_r <= 1; 
                            row_idx_r <= 0;
                        end else row_idx_r <= row_idx_r + 1;
                    end
                end
                WAIT_MAC_S: row_idx_r <= 0;
                ACCUM_C_S: begin
                    if (sys_outff_rd_en_w) begin
                        if (row_idx_r == SYS_N - 1) row_idx_r <= 0;
                        else row_idx_r <= row_idx_r + 1;
                    end
                end
                UPDATE_CNT_S: begin
                    if (k_cnt_r < dim_k_i - SYS_N) k_cnt_r <= k_cnt_r + SYS_N;
                    else begin
                        k_cnt_r <= 0;
                        if (n_cnt_r < dim_n_i - SYS_N) n_cnt_r <= n_cnt_r + SYS_N;
                        else begin
                            n_cnt_r <= 0;
                            if (m_cnt_r < dim_m_i - SYS_N) m_cnt_r <= m_cnt_r + SYS_N;
                        end
                    end
                end
            endcase
        end
    end

    // ==========================================
    // BRAM A & B ADDRESSING (Cast to 32-bit to prevent overflow)
    // ==========================================
    assign brama_en_o   = (state_r == FETCH_IN_S) && !sys_inff_full_w;
    
    // Cast m_cnt_r and k_cnt_r to 32-bit before multiplication.
    // Using >> 4 is equivalent to dividing by 16 (SYS_N)
    assign brama_addr_o = ({16'd0, m_cnt_r} + {27'd0, row_idx_r}) * ({16'd0, dim_k_i} >> 4) 
                        + ({16'd0, k_cnt_r} >> 4);

    assign bramb_en_o   = (state_r == FETCH_W_S) && !sys_wff_full_w;
    assign bramb_addr_o = ({16'd0, k_cnt_r} + {27'd0, row_idx_r}) * ({16'd0, dim_n_i} >> 4) 
                        + ({16'd0, n_cnt_r} >> 4);

    // ==========================================
    // BRAM C - PORT A (READ ONLY - CYCLE d1)
    // ==========================================
    assign bramc_rd_en_o   = sys_outff_rd_en_d1;
    assign bramc_rd_addr_o = ({16'd0, m_cnt_d1} + {27'd0, row_idx_d1}) * ({16'd0, dim_n_i} >> 4) 
                           + ({16'd0, n_cnt_d1} >> 4);
                           
    // ==========================================
    // BRAM C - PORT B (WRITE ONLY - CYCLE d2)
    // ==========================================
    assign bramc_wr_en_o   = sys_outff_rd_en_d2;
    assign bramc_wr_we_o   = sys_outff_rd_en_d2;
    assign bramc_wr_addr_o = bramc_wr_addr_d2;

    // OVERFLOW-SAFE ADDER RUNNING AT CYCLE d2
    genvar i_gen;
    generate
        for (i_gen = 0; i_gen < SYS_N; i_gen = i_gen + 1) begin : gen_mac_adders
            // Get new Psum from d1 register
            wire [PSUM_WIDTH-1:0] psum_new = sys_outff_dout_d2[i_gen*PSUM_WIDTH +: PSUM_WIDTH];
            // Get old Psum just fetched from BRAM at cycle d2
            wire [PSUM_WIDTH-1:0] psum_old = bramc_rd_dout_i[i_gen*PSUM_WIDTH +: PSUM_WIDTH];
            
            assign bramc_wr_din_o[i_gen*PSUM_WIDTH +: PSUM_WIDTH] = (k_cnt_d2 == 0) ? psum_new : (psum_new + psum_old);
        end
    endgenerate

    reg done_r;
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) done_r <= 0;
        else if (state_r == WAIT_DONE_S)
            done_r <= 1; // Set flag when BRAM C WRITE IS COMPLETE
        else if (start_i == 0)
            done_r <= 0; // ONLY CLEAR FLAG when Linux CPU finishes reading and asserts start_i to 0
    end
    assign done_o = done_r;

endmodule