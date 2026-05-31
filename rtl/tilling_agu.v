`timescale 1ns / 1ps

//==========================================================//
//                    Tiling AGU                            //
//==========================================================//
module tiling_agu #(
    parameter SYS_N      = 16,
    parameter DATA_WIDTH = 8,
    parameter PSUM_WIDTH = 32
)(
    input  wire                          clk_i,
    input  wire                          rst_ni,
    input  wire                          start_i,
    
    input  wire [15:0]                   dim_m_i,
    input  wire [15:0]                   dim_k_i,
    input  wire [15:0]                   dim_n_i,
    output wire                          done_o,
    
    // BRAM A Interface (Read)
    output wire [31:0]                   brama_addr_o,
    output wire                          brama_en_o,
    input  wire [(SYS_N*DATA_WIDTH)-1:0] brama_dout_i,
    
    // BRAM B Interface (Read)
    output wire [31:0]                   bramb_addr_o,
    output wire                          bramb_en_o,
    input  wire [(SYS_N*DATA_WIDTH)-1:0] bramb_dout_i,
    
    // BRAM C Interface - Port A (Read Only)
    output wire [31:0]                   bramc_rd_addr_o,
    output wire                          bramc_rd_en_o,
    input  wire [(SYS_N*PSUM_WIDTH)-1:0] bramc_rd_dout_i,
    
    // BRAM C Interface - Port B (Write Only)
    output wire [31:0]                   bramc_wr_addr_o,
    output wire                          bramc_wr_en_o,
    output wire                          bramc_wr_we_o,
    output wire [(SYS_N*PSUM_WIDTH)-1:0] bramc_wr_din_o
);

//==========================================================//
//                Parameter & Register Declaration          //
//==========================================================//

    localparam IDLE_S       = 3'd0;
    localparam FETCH_W_S    = 3'd1; 
    localparam WAIT_LOADW_S = 3'd2; 
    localparam FETCH_IN_S   = 3'd3; 
    localparam WAIT_MAC_S   = 3'd4; 
    localparam ACCUM_C_S    = 3'd5; 
    localparam UPDATE_CNT_S = 3'd6; 
    localparam WAIT_DONE_S  = 3'd7; 
    
    reg [2:0]  state_r, next_state_r;
    
    reg [15:0] m_cnt_r, k_cnt_r, n_cnt_r;
    reg [4:0]  row_idx_r; 
    
    reg        sys_start_r;
    reg        sys_loadw_r;
    reg        done_r;

//==========================================================//
//                    Wire Declaration                      //
//==========================================================//

    wire sys_done_w;
    wire sys_wff_full_w, sys_inff_full_w, sys_outff_empty_w;
    wire [(SYS_N*PSUM_WIDTH)-1:0] sys_outff_dout_w;
    
    wire sys_outff_rd_en_w = (state_r == ACCUM_C_S) && !sys_outff_empty_w;

//==========================================================//
//       Pipeline Registers (BRAM C Latency Sync)           //
//==========================================================//

    // Stage 1 (d1): Fetch FIFO data, output BRAM Read Address
    reg                          sys_outff_rd_en_d1;
    reg [4:0]                    row_idx_d1;
    reg [15:0]                   k_cnt_d1, m_cnt_d1, n_cnt_d1;
    reg [(SYS_N*PSUM_WIDTH)-1:0] sys_outff_dout_d1;
    
    // 1-cycle delay registers for FIFO write enables
    reg                          sys_wff_wr_en_d1;  
    reg                          sys_inff_wr_en_d1;
    
    // Stage 2 (d2): Receive BRAM data, output BRAM Write Address
    reg                          sys_outff_rd_en_d2;
    reg [31:0]                   bramc_wr_addr_d2;
    reg [15:0]                   k_cnt_d2;
    reg [(SYS_N*PSUM_WIDTH)-1:0] sys_outff_dout_d2;
    
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            sys_outff_rd_en_d1 <= 0;
            row_idx_d1         <= 0; 
            k_cnt_d1           <= 0; 
            m_cnt_d1           <= 0; 
            n_cnt_d1           <= 0;
            sys_outff_dout_d1  <= 0;
            
            sys_wff_wr_en_d1   <= 0;
            sys_inff_wr_en_d1  <= 0;
            
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
            
            sys_wff_wr_en_d1   <= bramb_en_o;
            sys_inff_wr_en_d1  <= brama_en_o;
            
            if (sys_outff_rd_en_w) begin
                sys_outff_dout_d1 <= sys_outff_dout_w;
            end
            
            // --- Update Stage 2 ---
            sys_outff_rd_en_d2 <= sys_outff_rd_en_d1;
            // Write address at d2 is the read address saved from d1
            bramc_wr_addr_d2   <= bramc_rd_addr_o; 
            k_cnt_d2           <= k_cnt_d1;
            sys_outff_dout_d2  <= sys_outff_dout_d1;
        end
    end

//==========================================================//
//               Systolic Array Core Instance               //
//==========================================================//

    systolic_array #(
        .N(SYS_N),
        .DATA_WIDTH(DATA_WIDTH),
        .PSUM_WIDTH(PSUM_WIDTH)
    ) sys_core (
        .clk_i         (clk_i),
        .rst_n         (rst_ni),
        .start_i       (sys_start_r),
        .loadw_i       (sys_loadw_r),
        .done_o        (sys_done_w),
        
        .dma_clk_i     (clk_i),
        
        .wff_wr_en_i   (sys_wff_wr_en_d1),
        .wff_din_i     (bramb_dout_i),    
        .wff_full_o    (sys_wff_full_w),
        
        .inff_wr_en_i  (sys_inff_wr_en_d1),
        .inff_din_i    (brama_dout_i),      
        .inff_full_o   (sys_inff_full_w),
        
        .outff_rd_en_i (sys_outff_rd_en_w), 
        .outff_dout_o  (sys_outff_dout_w),
        .outff_empty_o (sys_outff_empty_w)
    );

//==========================================================//
//                       FSM Logic                          //
//==========================================================//

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) state_r <= IDLE_S;
        else         state_r <= next_state_r;
    end

    always @(*) begin
        next_state_r = state_r; 
        case (state_r)
            IDLE_S:       if (start_i) next_state_r = FETCH_W_S;
            FETCH_W_S:    if (bramb_en_o  && row_idx_r == SYS_N - 1) next_state_r = WAIT_LOADW_S;
            WAIT_LOADW_S: if (sys_done_w) next_state_r = FETCH_IN_S;
            FETCH_IN_S:   if (brama_en_o && row_idx_r == SYS_N - 1) next_state_r = WAIT_MAC_S;
            WAIT_MAC_S:   if (sys_done_w) next_state_r = ACCUM_C_S;
            ACCUM_C_S:    if (sys_outff_rd_en_w && row_idx_r == SYS_N - 1) next_state_r = UPDATE_CNT_S;
            UPDATE_CNT_S: begin
                // Condition 1: All loops maxed out -> We are done!
                if (m_cnt_r >= dim_m_i - SYS_N && n_cnt_r >= dim_n_i - SYS_N && k_cnt_r >= dim_k_i - SYS_N) begin
                    next_state_r = IDLE_S;
                end
                // Condition 2: The M loop just finished -> K or N is about to change.
                else if (m_cnt_r >= dim_m_i - SYS_N) begin
                    next_state_r = FETCH_W_S; // Fetch a brand new Weight tile
                end
                // Condition 3: We are still inside the M loop.
                else begin
                    next_state_r = FETCH_IN_S; // Weight is stationary. Skip FETCH_W_S entirely.
                end
            end
            default: next_state_r = IDLE_S;
        endcase
    end

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            m_cnt_r     <= 0; 
            k_cnt_r     <= 0; 
            n_cnt_r     <= 0; 
            row_idx_r   <= 0;
            sys_start_r <= 0; 
            sys_loadw_r <= 0; 
        end else begin
            sys_start_r <= 0; 
            sys_loadw_r <= 0; 

            case (state_r)
                IDLE_S: begin
                    m_cnt_r   <= 0; 
                    k_cnt_r   <= 0; 
                    n_cnt_r   <= 0; 
                    row_idx_r <= 0;
                end
                FETCH_W_S: begin
                    if (bramb_en_o) begin
                        if (row_idx_r == SYS_N - 1) begin
                            sys_loadw_r <= 1; 
                            row_idx_r   <= 0;
                        end else begin
                            row_idx_r <= row_idx_r + 1;
                        end
                    end
                end
                WAIT_LOADW_S: row_idx_r <= 0; 
                FETCH_IN_S: begin
                    if (brama_en_o) begin
                        if (row_idx_r == SYS_N - 1) begin
                            sys_start_r <= 1; 
                            row_idx_r   <= 0;
                        end else begin
                            row_idx_r <= row_idx_r + 1;
                        end
                    end
                end
                WAIT_MAC_S: row_idx_r <= 0;
                ACCUM_C_S: begin
                    if (sys_outff_rd_en_w) begin
                        if (row_idx_r == SYS_N - 1) row_idx_r <= 0;
                        else                        row_idx_r <= row_idx_r + 1;
                    end
                end
                UPDATE_CNT_S: begin
                    // INNER LOOP: M Dimension (Traverse down the input rows)
                    if (m_cnt_r < dim_m_i - SYS_N) begin
                        m_cnt_r <= m_cnt_r + SYS_N;
                    end
                    // MIDDLE LOOP: K Dimension (Move right across input, down across weight)
                    else begin
                        m_cnt_r <= 0;
                        if (k_cnt_r < dim_k_i - SYS_N) begin
                            k_cnt_r <= k_cnt_r + SYS_N;
                        end
                        // OUTER LOOP: N Dimension (Move right across the weight matrix)
                        else begin
                            k_cnt_r <= 0;
                            if (n_cnt_r < dim_n_i - SYS_N) begin
                                n_cnt_r <= n_cnt_r + SYS_N;
                            end
                            else begin
                                n_cnt_r <= 0; // Matrix multiplication is complete
                            end
                        end
                    end
                end
            endcase
        end
    end

//==========================================================//
//                  BRAM Address Generation                 //
//==========================================================//

    assign brama_en_o = (state_r == FETCH_IN_S) && !sys_inff_full_w;
    
    // Cast to 32-bit to prevent overflow. Right shift by 4 is equivalent to division by 16 (SYS_N).
    assign brama_addr_o = ({16'd0, m_cnt_r} + {27'd0, row_idx_r}) * ({16'd0, dim_k_i} >> 4) 
                        + ({16'd0, k_cnt_r} >> 4);

    assign bramb_en_o   = (state_r == FETCH_W_S) && !sys_wff_full_w;
    
    assign bramb_addr_o = ({16'd0, k_cnt_r} + {27'd0, row_idx_r}) * ({16'd0, dim_n_i} >> 4) 
                        + ({16'd0, n_cnt_r} >> 4);

    // BRAM C - Port A (Read - Stage d1)
    assign bramc_rd_en_o   = sys_outff_rd_en_d1;
    assign bramc_rd_addr_o = ({16'd0, m_cnt_d1} + {27'd0, row_idx_d1}) * ({16'd0, dim_n_i} >> 4) 
                           + ({16'd0, n_cnt_d1} >> 4);
                           
    // BRAM C - Port B (Write - Stage d2)
    assign bramc_wr_en_o   = sys_outff_rd_en_d2;
    assign bramc_wr_we_o   = sys_outff_rd_en_d2;
    assign bramc_wr_addr_o = bramc_wr_addr_d2;

//==========================================================//
//                  Accumulation Logic (d2)                 //
//==========================================================//

    genvar i_gen;
    generate
        for (i_gen = 0; i_gen < SYS_N; i_gen = i_gen + 1) begin : gen_mac_adders
            // New Psum from d1 register
            wire [PSUM_WIDTH-1:0] psum_new = sys_outff_dout_d2[i_gen*PSUM_WIDTH +: PSUM_WIDTH];
            // Old Psum read from BRAM at d2
            wire [PSUM_WIDTH-1:0] psum_old = bramc_rd_dout_i[i_gen*PSUM_WIDTH +: PSUM_WIDTH];
            
            assign bramc_wr_din_o[i_gen*PSUM_WIDTH +: PSUM_WIDTH] = (k_cnt_d2 == 0) ? psum_new : (psum_new + psum_old);
        end
    endgenerate

//==========================================================//
//                       Done Logic                         //
//==========================================================//

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) done_r <= 0;
        else if (state_r == UPDATE_CNT_S &&
                 m_cnt_r >= dim_m_i - SYS_N &&
                 n_cnt_r >= dim_n_i - SYS_N &&
                 k_cnt_r >= dim_k_i - SYS_N)
            done_r <= 1;
        else if (start_i)
            done_r <= 0;
    end
    
    assign done_o = done_r;

endmodule