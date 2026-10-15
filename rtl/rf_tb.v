module rf_tb();
    reg         i_clk;
    reg         i_rst;
    reg  [4:0]  i_rs1_raddr;
    wire [31:0] o_rs1_rdata;
    reg  [4:0]  i_rs2_raddr;
    wire [31:0] o_rs2_rdata;
    reg         i_rd_wen;
    reg  [4:0]  i_rd_waddr;
    reg  [31:0] i_rd_wdata;
    wire [31:0] o_rs1_rdata_bypass;
    wire [31:0] o_rs2_rdata_bypass;

    rf #(.BYPASS_EN(0)) dut (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_rs1_raddr(i_rs1_raddr),
        .o_rs1_rdata(o_rs1_rdata),
        .i_rs2_raddr(i_rs2_raddr),
        .o_rs2_rdata(o_rs2_rdata),
        .i_rd_wen(i_rd_wen),
        .i_rd_waddr(i_rd_waddr),
        .i_rd_wdata(i_rd_wdata)
    );

    rf #(.BYPASS_EN(1)) dut_bypass (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_rs1_raddr(i_rs1_raddr),
        .o_rs1_rdata(o_rs1_rdata_bypass),
        .i_rs2_raddr(i_rs2_raddr),
        .o_rs2_rdata(o_rs2_rdata_bypass),
        .i_rd_wen(i_rd_wen),
        .i_rd_waddr(i_rd_waddr),
        .i_rd_wdata(i_rd_wdata)
    );

    initial begin
        i_clk = 0;
    end

    always #5 i_clk = ~i_clk;

    initial begin
        i_rst = 1;
        i_rs1_raddr = 0;
        i_rs2_raddr = 0;
        i_rd_wen = 0;
        i_rd_waddr = 0;
        i_rd_wdata = 0;
        repeat (2) @(posedge i_clk);
        @(negedge i_clk);
        i_rst = 0;

        //test reads are 0 from reset registers
        if(o_rs1_rdata != 32'h0) begin
            $display("Read rs1 failed after reset: expected 0x0, got 0x%h", o_rs1_rdata);
        end else begin
            $display("Test passed after reset: got 0x%h", o_rs1_rdata);
        end
        if(o_rs2_rdata != 32'h0) begin
            $display("Read rs2 failed after reset: expected 0x0, got 0x%h", o_rs2_rdata);
        end else begin
            $display("Test passed after reset: got 0x%h", o_rs2_rdata);
        end

        // Test writing to and reading from the register file
        //write to register 1
        i_rs1_raddr = 5'd1;
        i_rd_wen = 1;
        i_rd_waddr = 5'd1;
        i_rd_wdata = 32'h12345678;
        #1;
        if(o_rs1_rdata != 32'h0) begin
            $display("Bypass-off failed before clock: expected 0x0, got 0x%h", o_rs1_rdata);
        end else begin
            $display("Bypass-off passed before clock: got 0x%h", o_rs1_rdata);
        end
        if(o_rs1_rdata_bypass != 32'h12345678) begin
            $display("Bypass-on failed before clock: expected 0x12345678, got 0x%h", o_rs1_rdata_bypass);
        end else begin
            $display("Bypass-on passed before clock: got 0x%h", o_rs1_rdata_bypass);
        end
        @(posedge i_clk);
        i_rd_wen = 0;
        #1;
        if(o_rs1_rdata != 32'h12345678) begin
            $display("Read rs1 failed: expected 0x12345678, got 0x%h", o_rs1_rdata);
        end else begin
            $display("Test passed: got 0x%h", o_rs1_rdata);
        end

        @(posedge i_clk);
        #1;

        //write to register 31
        i_rd_wen = 1;
        i_rd_waddr = 5'd31;
        i_rd_wdata = 32'h87654321;
        @(posedge i_clk);
        #1;
        i_rd_wen = 0;
        i_rs1_raddr = 5'd31;
        #1;
        if(o_rs1_rdata != 32'h87654321) begin
            $display("Read rs1 failed: expected 0x87654321, got 0x%h", o_rs1_rdata);
        end else begin
            $display("Test passed: got 0x%h", o_rs1_rdata);
        end

        @(posedge i_clk);
        #1;

        //write to register 0 (should always read as 0)
        i_rd_wen = 1;
        i_rd_waddr = 5'd0;
        i_rd_wdata = 32'hFFFFFFFF;
        @(posedge i_clk);
        #1;
        i_rd_wen = 0;
        i_rs1_raddr = 5'd0;
        #1;
        if(o_rs1_rdata != 32'h0) begin
            $display("Read rs1 failed: expected 0x0, got 0x%h", o_rs1_rdata);
        end else begin
            $display("Test passed: got 0x%h", o_rs1_rdata);
        end

        @(posedge i_clk);
        #1;

        //read from register 0 to verify it still returns 0
        i_rs1_raddr = 5'd0;
        #1;
        if(o_rs1_rdata != 32'h0) begin
            $display("Read rs1 failed: expected 0x0, got 0x%h", o_rs1_rdata);
        end else begin
            $display("Test passed: got 0x%h", o_rs1_rdata);
        end

        $display("All tests completed.");
        $stop;
    end

endmodule