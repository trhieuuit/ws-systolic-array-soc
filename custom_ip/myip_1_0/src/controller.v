`timescale 1ns / 1ps
//==========================================================//
//              Controller (Systolic Array)                 //
//==========================================================//
// This module controls the input for Input, Weight, Output FIFO
// and the PE grids in Systolic Array

module controller #(
    parameter N = 16
)(
    input  wire                 clk_i,
    input  wire                 rst_n,          
    
    // Tiling AGU control flags
    input  wire                 loadw_i,        
    input  wire                 start_i,        
    
    // FIFO Status Flags
    input  wire                 w_ff_empty_i,   // Weight FIFO empty flag
    input  wire                 in_ff_empty_i,  // Input FIFO empty flag
    input  wire                 out_ff_full_i,  // Output FIFO full flag

    output reg                  in_ff_rd_o,     
    output reg                  w_ff_rd_o,      
    output reg                  out_ff_wr_o,    
    output reg                  pe_loadw_o,     
    output reg                  pe_en_o,         
    output reg                  done_o
);

//==========================================================//
//                Parameter & Register Declaration          //
//==========================================================//

    localparam IDLE           = 3'b000;
    localparam LOAD_WEIGHT    = 3'b001;
    localparam LOAD_INPUT     = 3'b011;
    localparam WAIT           = 3'b010;
    localparam RESULT_COLLECT = 3'b100;
    
    reg [2:0]           current_state_r;
    reg [2:0]           next_state_r;
    reg [$clog2(N)-1:0] counter_r;

//==========================================================//
//                    Wire Declaration                      //
//==========================================================//

    // Valid signals: Proceed only in correct state AND when FIFO is ready
    wire w_valid_w = (current_state_r == LOAD_WEIGHT)    && !w_ff_empty_i;
    wire i_valid_w = (current_state_r == LOAD_INPUT)     && !in_ff_empty_i;
    wire o_valid_w = (current_state_r == RESULT_COLLECT) && !out_ff_full_i;
    wire wait_w    = (current_state_r == WAIT);

//==========================================================//
//                    Next State Generation                 //
//==========================================================//

    always @(*) begin
        case (current_state_r)
            IDLE:           next_state_r = loadw_i ? LOAD_WEIGHT : (start_i ? LOAD_INPUT : IDLE);
            
            // State transition occurs only when N cycles are counted AND the final operation is valid
            LOAD_WEIGHT:    next_state_r = (counter_r == N-1 && w_valid_w) ? IDLE : LOAD_WEIGHT; 
            LOAD_INPUT:     next_state_r = (counter_r == N-1 && i_valid_w) ? WAIT : LOAD_INPUT;
            WAIT:           next_state_r = (counter_r == N-3)              ? RESULT_COLLECT : WAIT;
            RESULT_COLLECT: next_state_r = (counter_r == N-1 && o_valid_w) ? IDLE : RESULT_COLLECT;
            
            default:        next_state_r = IDLE;
        endcase
    end

//==========================================================//
//            Current State & Counter (Stall Mechanism)     //
//==========================================================//

    always @(posedge clk_i or negedge rst_n) begin
        if (!rst_n) begin
            counter_r       <= 0;
            current_state_r <= IDLE;
        end else begin
            current_state_r <= next_state_r;
            
            if (current_state_r != next_state_r) begin
                counter_r <= 0; // Reset counter on state transition
            end else if (w_valid_w || i_valid_w || o_valid_w || wait_w) begin
                counter_r <= counter_r + 1; // Increment counter only when data successfully flows
            end
        end
    end
    
//==========================================================//
//                    Output Generation                     //
//==========================================================//

    always @(*) begin
        // Bind outputs directly to valid flags
        in_ff_rd_o  = i_valid_w;
        w_ff_rd_o   = w_valid_w;
        out_ff_wr_o = o_valid_w;
        pe_loadw_o  = w_valid_w;
        
        // PE array is enabled when receiving new input, waiting, or outputting results
        pe_en_o     = i_valid_w || wait_w || o_valid_w;
    end
    
//==========================================================//
//                        Done Logic                        //
//==========================================================//    

    always @(posedge clk_i or negedge rst_n) begin
        if (!rst_n) begin
            done_o <= 0;
        end else begin
            // Generate a 1-cycle pulse (Assert Done for either Weight Load OR Compute completion)
            done_o <= ((current_state_r == RESULT_COLLECT && o_valid_w) || 
                       (current_state_r == LOAD_WEIGHT    && w_valid_w)) 
                      && (counter_r == N-1);
        end
    end

endmodule