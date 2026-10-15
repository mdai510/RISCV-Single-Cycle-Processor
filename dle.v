`default_nettype none

//Data Load Extend (DLE) Module
//Since data memory returns 32-bit words,
//this module extracts & extends the appropriate byte or half-word based on the instruction type
module dle (
    input wire [31:0] i_rdata,              //data read from memory
    input wire [1:0] i_byte_offset,         //the least significant 2 bits of the mem address to select the byte within the 32-bit word
    input wire [2:0] i_funct3,              //determines the type of load
    output reg [31:0] o_ldata
);
    reg [7:0] b;        //byte extracted from word
    reg [15:0] h;       //half-word extracted from word

    always @(*) begin
        //select byte/half-word based on byte offset
        case (i_byte_offset)
            2'd0: b = i_rdata[7:0];
            2'd1: b = i_rdata[15:8];
            2'd2: b = i_rdata[23:16];
            default: b = i_rdata[31:24];
        endcase
        h = i_byte_offset[1] ? i_rdata[31:16] : i_rdata[15:0];

        //output based on load type
        case (i_funct3)
            3'b000: o_ldata = {{24{b[7]}}, b}; // lb
            3'b001: o_ldata = {{16{h[15]}}, h}; // lh
            3'b010: o_ldata = i_rdata; // lw
            3'b100: o_ldata = {24'b0, b}; // lbu
            3'b101: o_ldata = {16'b0, h}; // lhu
            default: o_ldata = 32'b0;
        endcase
     end
endmodule

`default_nettype wire