`default_nettype none

//Immediate Generator (IMM) Module
//Extracts and sign-extends the immediate value from the instruction based on its format
module imm (
    input  wire [31:0] i_inst,  // instruction word from which to extract the immediate
    //One-hot encoded instruction format:
    // [0] R-type
    // [1] I-type
    // [2] S-type
    // [3] B-type
    // [4] U-type
    // [5] J-type
    input  wire [ 5:0] i_format,
    output wire [31:0] o_immediate  // sign-extended immediate based on instruction format
);
    // Immediate generation logic based on instruction format
    wire [31:0] imm_r = {{32{1'bx}}};
    wire [31:0] imm_i = {{21{i_inst[31]}}, i_inst[30:20]};
    wire [31:0] imm_s = {{21{i_inst[31]}}, i_inst[30:25], i_inst[11:7]};
    wire [31:0] imm_b = {{20{i_inst[31]}}, i_inst[7], i_inst[30:25], i_inst[11:8], 1'b0};
    wire [31:0] imm_u = {i_inst[31:12], 12'b0};
    wire [31:0] imm_j = {{12{i_inst[31]}}, // sign extension
                        i_inst[19:12],
                        i_inst[20],       
                        i_inst[30:25],
                        i_inst[24:21],
                        1'b0
                        };

    assign o_immediate = i_format[0] ? imm_r :
                         i_format[1] ? imm_i :
                         i_format[2] ? imm_s :
                         i_format[3] ? imm_b :
                         i_format[4] ? imm_u :
                         i_format[5] ? imm_j :
                         32'b0;
endmodule

`default_nettype wire
