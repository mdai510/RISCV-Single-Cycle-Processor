`default_nettype none


//Register File (RF) Module
//Implements a 32x32 bit register file with two asynchronous read ports and one synchronous write port.
//The register file supports optional write-to-read bypassing controlled by the BYPASS_EN parameter.
//Register x0 is hardwired to zero and writes to it are ignored.
module rf #(
    // When this parameter is set to 1, "RF bypass" mode is enabled. This
    // allows data at the write port to be observed at the read ports
    // immediately without having to wait for the next clock edge. 
    // This will be used in a pipelined core, but not this single-cycle processor
    parameter BYPASS_EN = 0
) (
    input  wire        i_clk,
    input  wire        i_rst,       //synchronous active-high reset
    //read register port 1
    input  wire [ 4:0] i_rs1_raddr,
    output wire [31:0] o_rs1_rdata,
    //read register read port 2
    input  wire [ 4:0] i_rs2_raddr,
    output wire [31:0] o_rs2_rdata,
    //synchronous write port; when wen is asserted, wdata is written to waddr at the next clock edge
    input  wire        i_rd_wen,
    input  wire [ 4:0] i_rd_waddr,
    input  wire [31:0] i_rd_wdata
);
    //register file storage
    reg [31:0] rf_reg [0:31];

    //comb read logic with optional write-to-read bypass
    assign o_rs1_rdata = (i_rs1_raddr == 5'b0) ? 32'b0 :
                         (BYPASS_EN && i_rd_wen && i_rd_waddr != 5'b0 &&
                          i_rs1_raddr == i_rd_waddr) ? i_rd_wdata :
                         rf_reg[i_rs1_raddr];
    assign o_rs2_rdata = (i_rs2_raddr == 5'b0) ? 32'b0 :
                         (BYPASS_EN && i_rd_wen && i_rd_waddr != 5'b0 &&
                          i_rs2_raddr == i_rd_waddr) ? i_rd_wdata :
                         rf_reg[i_rs2_raddr];

    //synchronous write logic
    always @(posedge i_clk) begin
        if (i_rst) begin
            rf_reg[0]  <= 32'b0;
            rf_reg[1]  <= 32'b0;
            rf_reg[2]  <= 32'b0;
            rf_reg[3]  <= 32'b0;
            rf_reg[4]  <= 32'b0;
            rf_reg[5]  <= 32'b0;
            rf_reg[6]  <= 32'b0;
            rf_reg[7]  <= 32'b0;
            rf_reg[8]  <= 32'b0;
            rf_reg[9]  <= 32'b0;
            rf_reg[10] <= 32'b0;
            rf_reg[11] <= 32'b0;
            rf_reg[12] <= 32'b0;
            rf_reg[13] <= 32'b0;
            rf_reg[14] <= 32'b0;
            rf_reg[15] <= 32'b0;
            rf_reg[16] <= 32'b0;
            rf_reg[17] <= 32'b0;
            rf_reg[18] <= 32'b0;
            rf_reg[19] <= 32'b0;
            rf_reg[20] <= 32'b0;
            rf_reg[21] <= 32'b0;
            rf_reg[22] <= 32'b0;
            rf_reg[23] <= 32'b0;
            rf_reg[24] <= 32'b0;
            rf_reg[25] <= 32'b0;
            rf_reg[26] <= 32'b0;
            rf_reg[27] <= 32'b0;
            rf_reg[28] <= 32'b0;
            rf_reg[29] <= 32'b0;
            rf_reg[30] <= 32'b0;
            rf_reg[31] <= 32'b0;
        end else if (i_rd_wen && i_rd_waddr != 5'b0) begin //if write enable and addr is not zero
            rf_reg[i_rd_waddr] <= i_rd_wdata;
        end
    end

endmodule

`default_nettype wire
