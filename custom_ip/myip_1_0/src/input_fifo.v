`timescale 1ns / 1ps

module input_fifo #(
    parameter N = 16,
    parameter DATA_WIDTH = 8,
    parameter  PSUM_WIDTH = 32
)(
    // Write Domain (e.g., from AXI DMA)
    input  wire         wr_clk_i,
    input  wire         rst_i,      // Active high reset for XPM
    input  wire         pe_en_i,
    input  wire         wr_en_i,
    input  wire [DATA_WIDTH*N-1:0] din_i,
    output wire         full_o,

    // Read Domain (e.g., to Systolic Array)
    input  wire         rd_clk_i,
    input  wire         rd_en_i,
    
    output wire         empty_o,
    output wire [DATA_WIDTH*N-1:0] dout_o
);
    parameter ROW = N, COL = N;

//////////////////////////////////////////////////////////////////////////////////
//                             Input FIFO declaration                           //
//////////////////////////////////////////////////////////////////////////////////
    wire [DATA_WIDTH*N-1:0] fifo_dout_w;
    xpm_fifo_async #(
        .FIFO_MEMORY_TYPE("block"),    // Force synthesis into BRAM
        .WRITE_DATA_WIDTH(DATA_WIDTH * N),        // 128-bit input
        .READ_DATA_WIDTH(DATA_WIDTH * N),         // 128-bit output
        .FIFO_WRITE_DEPTH(256),        // Depth of 256 words
        .READ_MODE("fwft"),            // First-Word-Fall-Through
        .FIFO_READ_LATENCY(0),             
        .CDC_SYNC_STAGES(2),           // Safe cross-clock domain synchronization
        .USE_ADV_FEATURES("0000")      // Disable advanced counters to save resources
    ) xpm_fifo_inst (
        .wr_clk(wr_clk_i),
        .rd_clk(rd_clk_i),
        .rst(rst_i),
        .wr_en(wr_en_i),
        .din(din_i),
        .rd_en(rd_en_i),
        .dout(fifo_dout_w),
        .full(full_o),
        .empty(empty_o),
        
        // Unused advanced ports tied off
        .sleep(1'b0),
        .injectsbiterr(1'b0),
        .injectdbiterr(1'b0)
    );
    
//////////////////////////////////////////////////////////////////////////////////
//               Split read data: 128 bit -> 8b data x 16 width                 //
//////////////////////////////////////////////////////////////////////////////////    
    
    wire [DATA_WIDTH-1:0] fifo_split_data_w [0:N-1];
    genvar r, c, d;
    generate
        for (r = 0; r < N; r = r + 1) begin: IN_FIFO_SPLIT_DATA
            assign fifo_split_data_w[r] = fifo_dout_w[(r+1)*DATA_WIDTH-1 : r*DATA_WIDTH];
        end
    endgenerate
    
    
//////////////////////////////////////////////////////////////////////////////////
//                     Chained delay register (INPUT FIFO)                      //
//////////////////////////////////////////////////////////////////////////////////
    
    reg [DATA_WIDTH-1:0]   inff_delay_r [0:N-1][0:N-1]; 
    wire [DATA_WIDTH-1:0]  pe_input_data_w [0:N-1];
    
 //   genvar r, d;
    generate
        for (r = 0; r < N; r = r + 1) begin : INPUT_DELAY_CHAIN
            
            localparam D_STAGES = N - 1 - r;
            
            if (D_STAGES == 0) begin
                 // Direct path: Use multiplexer to inject zero when read stops
                assign pe_input_data_w[r] = rd_en_i ? fifo_split_data_w[r] : {DATA_WIDTH{1'b0}};
                
            end else begin
                always @(posedge rd_clk_i or posedge rst_i) begin
                    if (rst_i) begin
                        inff_delay_r[r][0] <= {DATA_WIDTH{1'b0}}; 
                    end else if (pe_en_i) begin                   
                        if (rd_en_i)
                            inff_delay_r[r][0] <= fifo_split_data_w[r]; 
                        else
                            inff_delay_r[r][0] <= {DATA_WIDTH{1'b0}};
                    end
                end
                

                for (d = 1; d < D_STAGES; d = d + 1) begin : SKEW_STAGE
                    always @(posedge rd_clk_i or posedge rst_i) begin
                        if (rst_i) begin
                            inff_delay_r[r][d] <= {DATA_WIDTH{1'b0}};
                        end else if (pe_en_i) begin
                            inff_delay_r[r][d] <= inff_delay_r[r][d-1];
                        end
                    end
                end
                
                assign pe_input_data_w[r] = inff_delay_r[r][D_STAGES-1];
            end
        end
    endgenerate
//////////////////////////////////////////////////////////////////////////////////
//               Merge read data: 8b data x 16 width  -> 128 bit                //
//////////////////////////////////////////////////////////////////////////////////     
    generate
        for (r = 0; r < N; r = r + 1) begin: IN_FIFO_MERGE_DATA
            assign dout_o[(r+1)*DATA_WIDTH-1 : r*DATA_WIDTH] = pe_input_data_w[r];
        end
    endgenerate

endmodule