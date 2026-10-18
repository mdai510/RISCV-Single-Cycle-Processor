`default_nettype none

//Data Store Replication (DSR) Module
//this module replicates the appropriate byte/half-word across the whole 32-bit word for store operations
//ex if storing a byte, it will be replicated 4 times to fill the 32-bit word
//for half-word, it will be replicated 2 times
module dsr (
    input wire [31:0] i_rs2,            //data to be stored
    input wire [1:0] i_byte_offset,     //byte offset within the word
    input wire [2:0] i_funct3,          //determines the type of store
    output reg [31:0] o_wdata           //replicated data to be masked(inside dmem module) then written to memory
);
reg [31:0] aligned_data;

always @(*) begin
    case (i_byte_offset)
        2'd0: aligned_data = i_rs2;
        2'd1: aligned_data = {i_rs2[23:0], 8'b0};
        2'd2: aligned_data = {i_rs2[15:0], 16'b0};
        2'd3: aligned_data = {i_rs2[7:0], 24'b0};
        default: aligned_data = 32'bx;
    endcase

    case(i_funct3)
            3'd0, 3'd1, 3'd2: o_wdata = aligned_data; // sb/sh/sw
            default: o_wdata = 32'b0;
    endcase
end
    
endmodule

`default_nettype wire