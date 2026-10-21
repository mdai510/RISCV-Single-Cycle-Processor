// Your data port is split by address. Anything with bit 31 set is a
// peripheral; everything else is memory:
//
//      o_dmem_addr[31] == 0   ->  dmem     (your program's data and stack)
//      o_dmem_addr[31] == 1   ->  mmio     (switches, buttons, LEDs, displays)
//
// Both memories read combinationally, because that is what your hart's
// interface requires. Neither is a block RAM -- a block RAM's read port is
// registered and could not return data in the same cycle. Look for that in the
// Quartus fitter report.
//
// =============================================================================

`default_nettype none

// Top-level module for the system-on-chip core, connecting the hart to
// instruction and data memories, as well as board inputs and outputs.
// The data memory is split into regular memory and memory-mapped I/O
// based on the most significant bit of the address.
//
// Data port is split by address. Anything with bit 31 set is a
// peripheral; everything else is memory:
//
//      o_dmem_addr[31] == 0   ->  dmem     (program's data and stack)
//      o_dmem_addr[31] == 1   ->  mmio     (switches, buttons, LEDs, displays)
//
// Both memories read combinationally, because that is what hart's
// interface requires. Neither is a block RAM -- a block RAM's read port is
// registered and could not return data in the same cycle. 
// (in Quartus fitter report, there will not be any M10K blocks)
module soc_core #(
    parameter IMEM_WORDS = 1024,                // 4 KB
    parameter DMEM_WORDS = 1024,                // 4 KB
    parameter INIT_FILE  = "program.mem"
) (
    input  wire        i_clk,                   // CPU clock (already divided)
    input  wire        i_rst,                   // synchronous, active high

    // raw board inputs
    input  wire [ 9:0] i_sw,
    input  wire [ 3:0] i_key_n,                 // active low, as the board wires them

    // outputs toward the board
    output wire [ 9:0] o_ledr,
    output wire [23:0] o_hex_val,
    output wire [ 5:0] o_hex_en,

    // retire interface, forwarded so the board can show halts and traps
    output wire        o_retire_valid,
    output wire        o_retire_halt,
    output wire        o_retire_trap,
    output wire [31:0] o_retire_pc,
    output wire [31:0] o_retire_inst
);
    // ------------------------------------------------------------ hart wires
    // These are already declared for you. Connect your hart to them below.
    wire [31:0] imem_raddr, imem_rdata;
    wire [31:0] dmem_addr, dmem_wdata, dmem_rdata;
    wire        dmem_ren, dmem_wen;
    wire [ 3:0] dmem_mask;

    // Retire signals the board does not use, but your hart still drives.
    wire [ 4:0] retire_rs1_raddr, retire_rs2_raddr, retire_rd_waddr;
    wire [31:0] retire_rs1_rdata, retire_rs2_rdata, retire_rd_wdata;
    wire [31:0] retire_next_pc;

    // ----------------------------------------------------------------- split
    wire is_mmio = dmem_addr[31];

    wire        mem_ren  = dmem_ren  & ~is_mmio;
    wire        mem_wen  = dmem_wen  & ~is_mmio;
    wire        mmio_ren = dmem_ren  &  is_mmio;
    wire        mmio_wen = dmem_wen  &  is_mmio;

    wire [31:0] mem_rdata, mmio_rdata;

    assign dmem_rdata = is_mmio ? mmio_rdata : mem_rdata;

    //connect hart to memories and board interfaces
    hart #(
        .RESET_ADDR (32'h0)                     // programs start at address 0
    ) u_hart (
        .i_clk(i_clk), .i_rst (i_rst),
        .o_imem_raddr       (imem_raddr),
        .i_imem_rdata       (imem_rdata),

        .o_dmem_addr        (dmem_addr),
        .o_dmem_ren         (dmem_ren),
        .o_dmem_wen         (dmem_wen),
        .o_dmem_wdata       (dmem_wdata),
        .o_dmem_mask        (dmem_mask),
        .i_dmem_rdata       (dmem_rdata),

        .o_retire_valid     (o_retire_valid),
        .o_retire_inst      (o_retire_inst),
        .o_retire_trap      (o_retire_trap),
        .o_retire_halt      (o_retire_halt),
        .o_retire_rs1_raddr (retire_rs1_raddr),
        .o_retire_rs1_rdata (retire_rs1_rdata),
        .o_retire_rs2_raddr (retire_rs2_raddr),
        .o_retire_rs2_rdata (retire_rs2_rdata),
        .o_retire_rd_waddr  (retire_rd_waddr),
        .o_retire_rd_wdata  (retire_rd_wdata),
        .o_retire_pc        (o_retire_pc),
        .o_retire_next_pc   (retire_next_pc)
    );

    // ------------------------------------------------------------- memories
    imem #(
        .WORDS     (IMEM_WORDS),
        .INIT_FILE (INIT_FILE)
    ) u_imem (
        .i_raddr (imem_raddr),
        .o_rdata (imem_rdata)
    );

    dmem #(
        .WORDS     (DMEM_WORDS),
        .INIT_FILE (INIT_FILE)
    ) u_dmem (
        .i_clk   (i_clk),
        .i_addr  (dmem_addr),
        .i_ren   (mem_ren),
        .i_wen   (mem_wen),
        .i_wdata (dmem_wdata),
        .i_mask  (dmem_mask),
        .o_rdata (mem_rdata)
    );

    // ----------------------------------------------------------- peripherals
    mmio u_mmio (
        .i_clk       (i_clk),
        .i_rst       (i_rst),

        .i_addr      (dmem_addr),
        .i_ren       (mmio_ren),
        .i_wen       (mmio_wen),
        .i_wdata     (dmem_wdata),
        .o_rdata     (mmio_rdata),

        .i_sw_raw    (i_sw),
        .i_key_raw_n (i_key_n),

        .i_retire    (o_retire_valid),

        .o_ledr      (o_ledr),
        .o_hex_val   (o_hex_val),
        .o_hex_en    (o_hex_en)
    );

endmodule

`default_nettype wire
