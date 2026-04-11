`timescale 1ns / 1ps

module controller(
    input wire      clk_i,
    input wire      rst_n,          
    input wire      loadweight_i,   // Load weight signal
    input wire      start_i,        // Start execution + output collection
    
    output reg      in_ff_rd_o,     // Input FIFO read (only applies to the first FIFO, latter ones are mapped to shift register)
    output reg      w_ff_rd_o,      // Weight FIFO read (applies to all FIFO)
    output reg      out_ff_wr_o,    // Output FIFO write (only applies to the first FIFO, latter ones are mapped to shift register)
    output reg      pe_en_o         // PE enable signal
);
    // State declaration
    localparam IDLE = 2'b00, LOAD_WEIGHT = 2'b01, EXECUTE = 2'b11, RESULT_COLLECT = 2'b10;
    
    // Register declaration
    reg [1:0] current_state_r;
    reg [1:0] next_state_r;
    reg [3:0] counter_r;
    
//////////////////////////////////////////////////////////////////////////////////
//                            Next State Generation                             //
//////////////////////////////////////////////////////////////////////////////////
// LOAD_WEIGHT, EXECUTE and RESULT_COLLECT last for 16 cycles

    always @(*) begin
        case (current_state_r)
            IDLE: next_state_r = loadweight_i ? LOAD_WEIGHT : (start_i ? EXECUTE : IDLE);
            LOAD_WEIGHT: next_state_r = (counter_r == 4'd15) ? IDLE : LOAD_WEIGHT; 
            EXECUTE: next_state_r = (counter_r == 4'd15) ? RESULT_COLLECT : EXECUTE;
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
// LOAD_WEIGHT:    Activate rd on Weight FIFO 
// EXECUTE:        Activate PE calculation and rd on Input FIFO
// RESULT_COLLECT: Activate wr on Output FIFO

    always @(*) begin
        in_ff_rd_o  = 0;
        w_ff_rd_o   = 0;
        out_ff_wr_o = 0;
        pe_en_o     = 0;
        case (current_state_r)
            LOAD_WEIGHT: 
                w_ff_rd_o  = 1;
            EXECUTE: begin
                in_ff_rd_o = 1;
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
    
endmodule
