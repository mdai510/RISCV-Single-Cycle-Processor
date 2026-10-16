module imm_tb();
    reg [31:0] i_inst;
    reg [5:0] i_format;
    wire [31:0] o_imm;

    //instantiate the imm module here
    imm dut (
        .i_inst(i_inst),
        .i_format(i_format),
        .o_immediate(o_imm)
    );

    initial begin
        //test R type instruction
        i_inst = 32'hF0F0F0F0;
        i_format = 6'b000001; // R type format
        #10; // wait for 10 time units to observe the output
        if (o_imm !== 32'hx) // R type instructions should produce x (don't care)
            $error("R type instruction failed, o_imm should be 32'hx, but got %h", o_imm);

        //test I type instruction
        i_inst = 32'h8F100000; // bit 31 is 1, bits 30-25 are 000111, bits 24-21 are 1000, bit 20 is 1 
        i_format = 6'b000010; // I type format
        #10; // wait for 10 time units to observe the output
        if (o_imm != 32'hFFFFF8F1)
            $error("I type instruction failed, o_imm should be 32'hFFFFF8F1, but got %h", o_imm);

        //test S type instruction
        i_inst = 32'h8E000F80; // bit 31 is 1, bits 30-25 are 000111, bits 11-8 are 1111, bit 7 is 1
        i_format = 6'b000100; // S type format
        #10; // wait for 10 time units to observe the output
        if (o_imm != 32'hFFFFF8FF)
            $error("S type instruction failed, o_imm should be 32'hFFFFF8FF, but got %h", o_imm);

        //test B type instruction
        i_inst = 32'h8E000F80; // bit 31 is 1, bits 30-25 are 000111, bits 11-8 are 1111, bit 7 is 1
        i_format = 6'b001000; // B type format
        #10; // wait for 10 time units to observe the output
        if (o_imm != 32'hFFFFF8FE)
            $error("B type instruction failed, o_imm should be 32'hFFFFF8FE, but got %h", o_imm);

        //test U type instruction
        i_inst = 32'h8F8F8FFF; //imm is 0x8F8F8
        i_format = 6'b010000; // U type format
        #10; // wait for 10 time units to observe the output
        if (o_imm != 32'h8F8F8000)
            $error("U type instruction failed, o_imm should be 32'h8F8F8000, but got %h", o_imm);

        //test J type instruction
        i_inst = 32'h8F8F8FFF; //imm is 0x8F8F8
        i_format = 6'b100000; // J type format
        #10; // wait for 10 time units to observe the output
        if (o_imm != 32'hFFFF80F8)
            $error("J type instruction failed, o_imm should be 32'hFFFF80F8, but got %h", o_imm);

        $display("All tests passed");
        $stop;
    end

endmodule
