`timescale 1ns / 1ps

module controller#(
    parameter N = 16
)(
    input wire      clk_i,
    input wire      rst_n,          
    input wire      loadw_i,        
    input wire      start_i,        
    
    // THÊM MỚI: Các tín hiệu giám sát trạng thái FIFO
    input wire      w_ff_empty_i,   // Cờ Weight FIFO trống
    input wire      in_ff_empty_i,  // Cờ Input FIFO trống
    input wire      out_ff_full_i,  // Cờ Output FIFO đầy

    output reg      in_ff_rd_o,     
    output reg      w_ff_rd_o,      
    output reg      out_ff_wr_o,    
    output reg      pe_loadw_o,      
    output reg      pe_en_o,         
    output reg      done_o
);
    localparam IDLE = 3'b000, LOAD_WEIGHT = 3'b001, LOAD_INPUT = 3'b011, WAIT = 3'b010,  RESULT_COLLECT = 3'b100;
    
    reg [2:0] current_state_r;
    reg [2:0] next_state_r;
    reg [$clog2(N)-1:0] counter_r;

//////////////////////////////////////////////////////////////////////////////////
//                          Điều kiện Hợp lệ (Valid Signals)                    //
//////////////////////////////////////////////////////////////////////////////////
    // Chỉ thao tác khi đang ở đúng State VÀ FIFO tương ứng đã sẵn sàng
    wire w_valid_w = (current_state_r == LOAD_WEIGHT)    && !w_ff_empty_i;
    wire i_valid_w = (current_state_r == LOAD_INPUT)     && !in_ff_empty_i;
    wire o_valid_w = (current_state_r == RESULT_COLLECT) && !out_ff_full_i;
    wire wait_w    = (current_state_r == WAIT);

//////////////////////////////////////////////////////////////////////////////////
//                            Next State Generation                             //
//////////////////////////////////////////////////////////////////////////////////
    always @(*) begin
        case (current_state_r)
            IDLE: next_state_r = loadw_i ? LOAD_WEIGHT : (start_i ? LOAD_INPUT : IDLE);
            // Chỉ chuyển State khi đã đếm đủ N VÀ thao tác cuối cùng hợp lệ
            LOAD_WEIGHT:    next_state_r = (counter_r == N-1 && w_valid_w) ? IDLE : LOAD_WEIGHT; 
            LOAD_INPUT:     next_state_r = (counter_r == N-1 && i_valid_w) ? WAIT : LOAD_INPUT;
            WAIT:           next_state_r = (counter_r == N-3) ? RESULT_COLLECT : WAIT;
            RESULT_COLLECT: next_state_r = (counter_r == N-1 && o_valid_w) ? IDLE : RESULT_COLLECT;
            default: next_state_r = IDLE;
        endcase
    end

//////////////////////////////////////////////////////////////////////////////////
//                   Current State & Counter (Với cơ chế Stall)                 //
//////////////////////////////////////////////////////////////////////////////////
    always @(posedge clk_i or negedge rst_n) begin
        if (!rst_n) begin
            counter_r <= 0;
            current_state_r <= IDLE;
        end else begin
            current_state_r <= next_state_r;
            
            if (current_state_r != next_state_r) begin
                counter_r <= 0; // Reset khi chuyển State
            end else if (w_valid_w || i_valid_w || o_valid_w || wait_w) begin
                counter_r <= counter_r + 1; // Chỉ tăng biến đếm khi dữ liệu chảy thành công!
            end
        end
    end
    
//////////////////////////////////////////////////////////////////////////////////
//                               Output Generation                              //
//////////////////////////////////////////////////////////////////////////////////
    always @(*) begin
        // Gắn trực tiếp ngõ ra vào các cờ Hợp lệ (Valid)
        in_ff_rd_o  = i_valid_w;
        w_ff_rd_o   = w_valid_w;
        out_ff_wr_o = o_valid_w;
        pe_loadw_o  = w_valid_w;
        
        // Mảng PE chỉ chạy (en=1) khi có Input mới, hoặc đang chờ (WAIT), hoặc đang xuất kết quả
        pe_en_o     = i_valid_w || wait_w || o_valid_w;
    end
    
//////////////////////////////////////////////////////////////////////////////////
//                                 Done logic                                   //
//////////////////////////////////////////////////////////////////////////////////    
    always @(posedge clk_i or negedge rst_n) begin
        if (!rst_n) begin
            done_o <= 0;
        end else begin
            // TẠO XUNG 1 NHỊP (Báo Done cho CẢ 2 TRƯỜNG HỢP: Xong Weight HOẶC Xong Tính toán)
            done_o <= ((current_state_r == RESULT_COLLECT && o_valid_w) || 
                       (current_state_r == LOAD_WEIGHT && w_valid_w)) 
                      && (counter_r == N-1);
        end
    end

endmodule