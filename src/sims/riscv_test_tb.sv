`timescale 1 ns/10 ps

// Testbench for running riscv-tests ISA tests against the kyson pipeline core.
//
// Memory model
// ------------
// A single 32 KB unified memory (MEM_WORDS × 32-bit words) backs both the
// instruction and data ports.  The ELF is linked with:
//   .text  @ 0x0000  (instructions)
//   .data  @ 0x4000  (tohost is the first word here)
//
// Pass/fail protocol
// ------------------
//   tohost == 1                    → PASS
//   tohost == (testnum << 1) | 1   → FAIL (testnum is the failing test number)
//
// Running with iverilog
// ---------------------
//   iverilog -g2012 -o sim src/sims/riscv_test_tb.sv src/sources/*.sv
//   vvp sim +HEX=tests/build/rv32ui-p-add.hex
//
// Running with Vivado xsim
// -------------------------
//   (see tests/run_tests.sh and scripts/tb/riscv_test_tb.tcl)

module riscv_test_tb;

    // -----------------------------------------------------------------------
    // Parameters
    // -----------------------------------------------------------------------
    localparam CLK_PERIOD  = 10;          // ns → 100 MHz
    localparam MEM_WORDS   = 8192;        // 32 KB  (must be ≥ TOHOST_ADDR/4 + 1)
    localparam TOHOST_ADDR = 32'h0000_4000;
    localparam MAX_CYCLES  = 100_000;

    // -----------------------------------------------------------------------
    // DUT IO
    // -----------------------------------------------------------------------
    logic        i_clk, i_rst;
    logic [31:0] o_imem_addr;
    logic [31:0] i_imem_data;
    logic [31:0] o_dmem_addr;
    logic [31:0] o_dmem_write_data;
    logic [31:0] i_dmem_read_data;
    logic        o_dmem_write_en;
    logic [3:0]  o_dmem_byte_en;
    logic        o_dmem_read_en;

    // -----------------------------------------------------------------------
    // Clock
    // -----------------------------------------------------------------------
    initial i_clk = 1'b0;
    always #(CLK_PERIOD / 2) i_clk = ~i_clk;

    // -----------------------------------------------------------------------
    // DUT
    // -----------------------------------------------------------------------
    core dut_core (.*);

    // -----------------------------------------------------------------------
    // Unified 32 KB memory
    // -----------------------------------------------------------------------
    logic [31:0] mem [0:MEM_WORDS-1];

    // Instruction fetch
    assign i_imem_data      = mem[o_imem_addr[14:2]];

    // Data read
    assign i_dmem_read_data = mem[o_dmem_addr[14:2]];

    // Data write with byte enables
    always_ff @(posedge i_clk)
        if (o_dmem_write_en) begin
            if (o_dmem_byte_en[0]) mem[o_dmem_addr[14:2]][7:0]   <= o_dmem_write_data[7:0];
            if (o_dmem_byte_en[1]) mem[o_dmem_addr[14:2]][15:8]  <= o_dmem_write_data[15:8];
            if (o_dmem_byte_en[2]) mem[o_dmem_addr[14:2]][23:16] <= o_dmem_write_data[23:16];
            if (o_dmem_byte_en[3]) mem[o_dmem_addr[14:2]][31:24] <= o_dmem_write_data[31:24];
        end

    // -----------------------------------------------------------------------
    // Cycle counter and tohost monitor
    // -----------------------------------------------------------------------
    string  hex_file;
    integer cycle_count;

    always_ff @(posedge i_clk, posedge i_rst) begin
        if (i_rst) begin
            cycle_count <= 0;
        end else begin
            cycle_count <= cycle_count + 1;

            // DEBUG: print every cycle for first 15, then writes only
            if (cycle_count < 15)
                $display("DBG cycle=%0d pc=0x%08x wen=%b addr=0x%08x data=0x%08x",
                         cycle_count, o_imem_addr, o_dmem_write_en, o_dmem_addr, o_dmem_write_data);
            else if (o_dmem_write_en)
                $display("DBG WRITE cycle=%0d addr=0x%08x data=0x%08x",
                         cycle_count, o_dmem_addr, o_dmem_write_data);

            if (o_dmem_write_en && o_dmem_addr == TOHOST_ADDR) begin
                if (o_dmem_write_data == 32'h1) begin
                    $display("PASS  %s", hex_file);
                    $finish;
                end else begin
                    $display("FAIL  %s  (tohost=0x%08x, failing_testnum=%0d)",
                             hex_file,
                             o_dmem_write_data,
                             o_dmem_write_data >> 1);
                    $finish;
                end
            end

            if (cycle_count >= MAX_CYCLES) begin
                $display("TIMEOUT  %s  (%0d cycles, no tohost write)",
                         hex_file, MAX_CYCLES);
                $finish;
            end
        end
    end

    // -----------------------------------------------------------------------
    // Initialisation
    // -----------------------------------------------------------------------
    initial begin
        // Hex file via +HEX=<path> plusarg; fall back to a default so the
        // testbench compiles without argument in the Vivado project browser.
        if (!$value$plusargs("HEX=%s", hex_file))
            hex_file = "tests/build/rv32ui-p-add.hex";

        foreach (mem[i]) mem[i] = 32'h0;
        $readmemh(hex_file, mem);

        i_rst = 1'b1;
        repeat(4) @(posedge i_clk);
        i_rst = 1'b0;
    end

endmodule
