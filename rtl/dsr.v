`default_nettype none

//Data Store Replication (DSR) Module
//misnomer from previous implementation,
//this module shifts the data to align with the byte offset within the word
//ex if storing a byte at offset 1, it will be shifted left by 8 bits within the 32-bit word
//for half-word at offset 1, it will be shifted left by 16 bits within the 32-bit word
module dsr (
    input wire [31:0] i_rs2,            //data to be stored
    input wire [2:0] i_funct3,          //determines the type of store
    output reg [31:0] o_wdata           //replicated data to be masked(inside dmem module) then written to memory
);

always @(*) begin
    case (i_funct3)
        3'b000: o_wdata = {4{i_rs2[7:0]}};   // SB
        3'b001: o_wdata = {2{i_rs2[15:0]}};  // SH
        3'b010: o_wdata = i_rs2;             // SW
        default: o_wdata = 32'b0;
    endcase
end
    
endmodule

`default_nettype wire