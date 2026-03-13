# Kyson

A pipelined RV32I core implemented in SystemVerilog.

## Running Tests

Tests use the [riscv-tests](https://github.com/riscv-software-src/riscv-tests) ISA test suite and are simulated with Vivado xsim.

### Prerequisites

- Vivado (for `xvlog`, `xelab`, `xsim`)
- `riscv64-unknown-elf-*` binutils
- `cpp`, `python3`

### 1. Build the test binaries

Only needed once, or after modifying test sources:

```bash
make -f tests/Makefile
```

Outputs land in `tests/build/` as `rv32ui-p-<test>.hex`.

### 2. Compile and elaborate the simulator using ivado xsim

Required after modifying any `.sv` source file:

```bash
rm -rf xsim.dir
xvlog -sv src/sources/enums.sv src/sources/alu.sv src/sources/alu_ctl.sv \
          src/sources/imm_gen.sv src/sources/regs.sv src/sources/hazard_det.sv \
          src/sources/core_ctl.sv src/sources/core.sv src/sims/riscv_test_tb.sv
xelab -top riscv_test_tb -snapshot riscv_test_tb
```

### 3. Run tests

Single test:

```bash
xsim riscv_test_tb --runall --testplusarg "HEX=tests/build/rv32ui-p-add.hex"
```

All tests:

```bash
for hex in tests/build/rv32ui-p-*.hex; do
    xsim riscv_test_tb --runall --testplusarg "HEX=$hex" 2>&1 | grep -E "^PASS|^FAIL|^TIMEOUT"
done
```

### Output format

```
PASS  tests/build/rv32ui-p-add.hex
FAIL  tests/build/rv32ui-p-foo.hex  (tohost=0x00000005, failing_testnum=2)
TIMEOUT  tests/build/rv32ui-p-bar.hex  (100000 cycles, no tohost write)
```
