`default_nettype none

// The arithmetic logic unit (ALU) is responsible for performing the core
// calculations of the processor. It takes two 32-bit operands and outputs
// a 32 bit result based on the selection operation - addition, comparison,
// shift, or logical operation. This ALU is a purely combinational block, so
// you should not attempt to add any registers or pipeline it.
module alu (
    // NOTE: Both 3'b010 and 3'b011 are used for set less than operations and
    // your implementation should output the same result for both codes. The
    // reason for this will become clear in project 3.
    //
    // Major operation selection.
    // 3'b000: addition/subtraction if `i_sub` asserted
    // 3'b001: shift left logical
    // 3'b010,
    // 3'b011: set less than/unsigned if `i_unsigned` asserted
    // 3'b100: exclusive or
    // 3'b101: shift right logical/arithmetic if `i_arith` asserted
    // 3'b110: or
    // 3'b111: and
    input  wire [ 2:0] i_opsel,
    // When asserted, addition operations should subtract instead.
    // This is only used for `i_opsel == 3'b000` (addition/subtraction).
    input  wire        i_sub,
    // When asserted, comparison operations should be treated as unsigned.
    // This is used for branch comparisons and set less than unsigned. For
    // b ranch operations, the ALU result is not used, only the comparison
    // results.
    input  wire        i_unsigned,
    // When asserted, right shifts should be treated as arithmetic instead of
    // logical. This is only used for `i_opsel == 3'b101` (shift right).
    input  wire        i_arith,
    // First 32-bit input operand.
    input  wire [31:0] i_op1,
    // Second 32-bit input operand.
    input  wire [31:0] i_op2,
    // 32-bit output result. Any carry out should be ignored.
    output wire [31:0] o_result,
    // Equality result. This is used externally to determine if a branch
    // should be taken.
    output wire        o_eq,
    // Set less than result. This is used externally to determine if a branch
    // should be taken.
    output wire        o_slt
);
    // TODO: Fill in your implementation here.

    //Compare unsigned values directly. For signed values, the sign bit has
    //priority; values with equal signs can be compared by their lower bits.
    wire slt_unsigned = i_op1 < i_op2;
    wire slt_signed = (i_op1[31] != i_op2[31]) ? i_op1[31]==1'b1 : i_op1[30:0] < i_op2[30:0]; //if signs differ, sign bit determines result; if op1 is 1, it is negative and less than op2

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
