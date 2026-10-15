`default_nettype none

//Data Store Replication (DSR) Module
//this module replicates the appropriate byte/half-word across the whole 32-bit word for store operations
//ex if storing a byte, it will be replicated 4 times to fill the 32-bit word
//for half-word, it will be replicated 2 times
module dsr (
    input wire [31:0] i_rs2,        // data to be stored
    input wire [2:0] i_funct3,      // determines the type of store
    output reg [31:0] o_wdata       // replicated data to be masked(inside dmem module) then written to memory
);

always @(*) begin
    case(i_funct3)
            3'd0: o_wdata = {4{i_rs2[7:0]}}; // sb
            3'd1: o_wdata = {2{i_rs2[15:0]}}; // sh
            3'd2: o_wdata = i_rs2; // sw
            default: o_wdata = 32'b0;
    endcase
end
    
endmodule

`default_nettype wire