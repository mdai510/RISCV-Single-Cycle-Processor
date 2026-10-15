`default_nettype none

//ALU module
module alu (
    // Major operation selection.
    // 3'b000: addition/subtraction if `i_sub` asserted
    // 3'b001: shift left logical
    // 3'b010: set less than (signed)
    // 3'b011: set less than/unsigned if `i_unsigned` asserted
    // 3'b100: exclusive or
    // 3'b101: shift right logical/arithmetic if `i_arith` asserted
    // 3'b110: or
    // 3'b111: and
    input  wire [ 2:0] i_opsel,
    input  wire        i_sub,       //when asserted, add operations should subtract (only used in `i_opsel == 3'b000`)
    input  wire        i_unsigned,  //when asserted, comparison operations should be treated as unsigned
    input  wire        i_arith,     //when asserted, right shifts should be treated as arithmetic instead of logical
    //operands
    input  wire [31:0] i_op1,
    input  wire [31:0] i_op2,
    output wire [31:0] o_result,    //output result; any carry out should be ignored
    output wire        o_eq,        //equality result; used externally to determine if a branch should be taken.
    output wire        o_slt        //set less than result; used externally to determine if a branch should be taken.
);
    //comparison logic
    wire slt_unsigned = i_op1 < i_op2;
    wire slt_signed = (i_op1[31] != i_op2[31]) ? i_op1[31]==1'b1 : i_op1[30:0] < i_op2[30:0];

    //Shifter logic without using variable shift operators
    //Each stage shifts the input by a power of two based on the corresponding bit in the shift amount.
    //Left shift
    wire [31:0] sll_1  = i_op2[0] ? {i_op1[30:0], 1'b0} : i_op1;
    wire [31:0] sll_2  = i_op2[1] ? {sll_1[29:0], 2'b0} : sll_1;
    wire [31:0] sll_4  = i_op2[2] ? {sll_2[27:0], 4'b0} : sll_2;
    wire [31:0] sll_8  = i_op2[3] ? {sll_4[23:0], 8'b0} : sll_4;
    wire [31:0] sll_16 = i_op2[4] ? {sll_8[15:0], 16'b0} : sll_8;

    //Right logical shift
    wire [31:0] srl_1  = i_op2[0] ? {1'b0, i_op1[31:1]} : i_op1;
    wire [31:0] srl_2  = i_op2[1] ? {2'b0, srl_1[31:2]} : srl_1;
    wire [31:0] srl_4  = i_op2[2] ? {4'b0, srl_2[31:4]} : srl_2;
    wire [31:0] srl_8  = i_op2[3] ? {8'b0, srl_4[31:8]} : srl_4;
    wire [31:0] srl_16 = i_op2[4] ? {16'b0, srl_8[31:16]} : srl_8;

    //Right arithmetic shift
    wire [31:0] sra_1  = i_op2[0] ? {{1{i_op1[31]}}, i_op1[31:1]} : i_op1;
    wire [31:0] sra_2  = i_op2[1] ? {{2{sra_1[31]}}, sra_1[31:2]} : sra_1;
    wire [31:0] sra_4  = i_op2[2] ? {{4{sra_2[31]}}, sra_2[31:4]} : sra_2;
    wire [31:0] sra_8  = i_op2[3] ? {{8{sra_4[31]}}, sra_4[31:8]} : sra_4;
    wire [31:0] sra_16 = i_op2[4] ? {{16{sra_8[31]}}, sra_8[31:16]} : sra_8;

    //assign equality and less than outputs
    assign o_eq = (i_op1 == i_op2);
    assign o_slt = i_unsigned ? slt_unsigned : slt_signed;

    //result assignment based on operation select and other control signals
    assign o_result = 
        (i_opsel == 3'b000) ? (i_sub ? i_op1 - i_op2 : i_op1 + i_op2) :
        (i_opsel == 3'b001) ? sll_16 :
        (i_opsel == 3'b010 || i_opsel == 3'b011) ?
        (i_unsigned ? {31'b0, slt_unsigned} : {31'b0, slt_signed}) :
        (i_opsel == 3'b100) ? i_op1 ^ i_op2 :
        (i_opsel == 3'b101) ? (i_arith ? sra_16 : srl_16) :
        (i_opsel == 3'b110) ? i_op1 | i_op2 :
        (i_opsel == 3'b111) ? i_op1 & i_op2 :
        32'h0;
endmodule

`default_nettype wire
