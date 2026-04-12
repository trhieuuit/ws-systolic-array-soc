`timescale 1ns / 1ps

module controller(
    input wire      clk_i,
    input wire      rst_n,          
    input wire      loadw_i,        // Load weight signal
    input wire      start_i,        // Start execution + output collection
    
    output reg      in_ff_rd_o,     // Input FIFO read (only applies to the first FIFO, latter ones are mapped to shift register)
    output reg      w_ff_rd_o,      // Weight FIFO read (applies to all FIFO)
    output reg      out_ff_wr_o,    // Output FIFO write (only applies to the first FIFO, latter ones are mapped to shift register)
    output reg      pe_loadw_o,      // PE load signal
    output reg      pe_en_o,         // PE execution enable signal
    output reg      done_o
);
    // State declaration
    localparam IDLE = 3'b000, LOAD_WEIGHT = 3'b001, LOAD_INPUT = 3'b011, WAIT = 3'b010,  RESULT_COLLECT = 3'b100;
    
    // Register declaration
    reg [2:0] current_state_r;
    reg [2:0] next_state_r;
    reg [3:0] counter_r;
    
//////////////////////////////////////////////////////////////////////////////////
//                            Next State Generation                             //
//////////////////////////////////////////////////////////////////////////////////
// LOAD_WEIGHT, EXECUTE and RESULT_COLLECT last for 16 cycles

    always @(*) begin
        case (current_state_r)
            IDLE: next_state_r = loadw_i ? LOAD_WEIGHT : (start_i ? LOAD_INPUT : IDLE);
            LOAD_WEIGHT: next_state_r = (counter_r == 4'd15) ? IDLE : LOAD_WEIGHT; 
            LOAD_INPUT: next_state_r = (counter_r == 4'd15) ? WAIT : LOAD_INPUT;
            WAIT: next_state_r = (counter_r == 4'd14) ? RESULT_COLLECT : WAIT;
            RESULT_COLLECT: next_state_r = (counter_r == 4'd15) ? IDLE : RESULT_COLLECT;
            default: next_state_r = IDLE;
        endcase
    end

//////////////////////////////////////////////////////////////////////////////////
//                                   Current State                              //
//////////////////////////////////////////////////////////////////////////////////
    always @(posedge clk_i or negedge rst_n) begin
        if (!rst_n) begin
            counter_r <= 0;
            current_state_r <= IDLE;
        end else begin
            current_state_r <= next_state_r;
            if (current_state_r == next_state_r) 
                counter_r <= counter_r + 1;
            else 
                 counter_r <= 0;
        end
    end
    
//////////////////////////////////////////////////////////////////////////////////
//                               Output Generation                              //
//////////////////////////////////////////////////////////////////////////////////
// IDLE:           Do nothing
// LOAD_WEIGHT:    Activate PE weight load and rd on Weight FIFO 
// EXECUTE:        Activate PE calculation and rd on Input FIFO
// RESULT_COLLECT: Activate wr on Output FIFO

    always @(*) begin
        in_ff_rd_o  = 0;
        w_ff_rd_o   = 0;
        out_ff_wr_o = 0;
        pe_en_o     = 0;
        pe_loadw_o   = 0;
        case (current_state_r)
            LOAD_WEIGHT: begin
                w_ff_rd_o  = 1;
                pe_loadw_o  = 1;
                end
            LOAD_INPUT: begin
                in_ff_rd_o = 1;
                pe_en_o    = 1;
                end 
            WAIT: begin
                pe_en_o    = 1;
                end
            RESULT_COLLECT: begin
                out_ff_wr_o = 1;
                pe_en_o     = 1;
                end
            default: begin 
                in_ff_rd_o  = 0;
                w_ff_rd_o   = 0;
                out_ff_wr_o = 0;
                pe_en_o     = 0;
            end
        endcase
    end
    
//////////////////////////////////////////////////////////////////////////////////
//                                 Done logic                                   //
//////////////////////////////////////////////////////////////////////////////////    
     always @(posedge clk_i or negedge rst_n) begin
        if (!rst_n) begin
            done_o <= 0;
        end else begin
            if (!done_o)
                done_o <= (current_state_r == RESULT_COLLECT) && (counter_r == 4'd15);
        end
    end

endmodule
