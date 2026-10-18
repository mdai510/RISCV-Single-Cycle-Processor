`default_nettype none

//ALU module
module alu (
    // Major operation selection.
    // 3'b000: addition/subtraction if `i_sub` asserted
    // 3'b001: shift left logical
    // 3'b010: both 010 and 011 support set less than signed or unsigned based on `i_unsigned`
    // 3'b011: 
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
    reg [31:0] result_r;
    reg [31:0] sub_r;
    reg eq_r;
    reg slt_r;

    assign o_result = result_r;
    assign o_eq = eq_r;
    assign o_slt = slt_r;

    always @* begin
        eq_r = i_op1 == i_op2;
        sub_r = i_op1 - i_op2;
        slt_r = i_unsigned ? (i_op1 < i_op2) : ((i_op1[31] != i_op2[31]) ? i_op1[31] : sub_r[31]);
        result_r = 32'b0;

        case (i_opsel)
            3'd0: begin // addition/subtraction if `i_sub` asserted
                result_r = i_sub ? (i_op1 - i_op2) : (i_op1 + i_op2);
            end
            3'd1: begin // shift left logical
                result_r = i_op1;
                result_r = (i_op2[4]) ? {result_r[15:0], 16'b0} : result_r;
                result_r = (i_op2[3]) ? {result_r[23:0], 8'b0} : result_r;
                result_r = (i_op2[2]) ? {result_r[27:0], 4'b0} : result_r;
                result_r = (i_op2[1]) ? {result_r[29:0], 2'b0} : result_r;
                result_r = (i_op2[0]) ? {result_r[30:0], 1'b0} : result_r;
            end
            3'd2, 3'd3: begin // set less than/unsigned if `i_unsigned` asserted
                result_r = {31'b0, slt_r};
            end
            3'd4: begin // exclusive or
                result_r = i_op1 ^ i_op2;
            end
            3'd5: begin // shift right logical/arithmetic if `i_arith` asserted
                result_r = i_op1;
                result_r = i_op2[4] ? (i_arith ? {{16{i_op1[31]}}, result_r[31:16]} : {16'b0, result_r[31:16]}) : result_r;
                result_r = i_op2[3] ? (i_arith ? {{8{i_op1[31]}},  result_r[31:8]}  : {8'b0,  result_r[31:8]})  : result_r;
                result_r = i_op2[2] ? (i_arith ? {{4{i_op1[31]}},  result_r[31:4]}  : {4'b0,  result_r[31:4]})  : result_r;
                result_r = i_op2[1] ? (i_arith ? {{2{i_op1[31]}},  result_r[31:2]}  : {2'b0,  result_r[31:2]})  : result_r;
                result_r = i_op2[0] ? (i_arith ? {{1{i_op1[31]}},  result_r[31:1]}  : {1'b0,  result_r[31:1]})  : result_r;
            end
            3'd6: begin // or
                result_r = i_op1 | i_op2;
            end
            3'd7: begin // and
                result_r = i_op1 & i_op2;
            end
            default: begin
                result_r = 32'b0;
            end
        endcase
    end
endmodule

`default_nettype wire
