#!/bin/bash
# run_tests.sh – build and run all riscv-tests ISA tests against the
#                kyson RV32I pipeline core.
#
# Usage (from repo root):
#   ./tests/run_tests.sh [test_glob]
#
# Examples:
#   ./tests/run_tests.sh                   # run every test
#   ./tests/run_tests.sh rv32ui-p-add      # run a single test by name
#   ./tests/run_tests.sh "rv32ui-p-b*"     # run tests matching a glob
#
# Simulator preference (first found wins):
#   1. iverilog / vvp  (fast, no licence needed – install with: apt install iverilog)
#   2. Vivado xvlog / xelab / xsim

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$REPO/tests/build"
GLOB="${1:-rv32ui-p-*}"

# -----------------------------------------------------------------------
# 1. Build all test hex files
# -----------------------------------------------------------------------
echo "=== Building tests ==="
make -f "$REPO/tests/Makefile" --no-print-directory

# -----------------------------------------------------------------------
# 2. Select simulator and compile design (once)
# -----------------------------------------------------------------------
echo ""
echo "=== Compiling simulator ==="

if command -v iverilog &>/dev/null; then
    SIM_TOOL="iverilog"
    SIM_BIN="$BUILD_DIR/riscv_test_sim"

    iverilog -g2012 \
        -I "$REPO/src/sources" \
        -o "$SIM_BIN" \
        "$REPO/src/sims/riscv_test_tb.sv" \
        "$REPO/src/sources/"*.sv
    echo "  iverilog → $SIM_BIN"

    run_sim() {   # arg: hex_path
        vvp "$SIM_BIN" "+HEX=$1" 2>&1 | tr -d '\r'
    }

else
    # Vivado xvlog / xelab / xsim
    XVLOG=$(find /tools /opt /usr -name xvlog -type f 2>/dev/null | head -1)
    XELAB=$(find /tools /opt /usr -name xelab -type f 2>/dev/null | head -1)
    XSIM=$(find /tools /opt /usr -name  xsim  -type f 2>/dev/null | head -1)

    if [[ -z "$XVLOG" ]]; then
        echo "ERROR: neither iverilog nor Vivado xvlog found."
        echo "  Install iverilog (apt install iverilog) or source a Vivado settings script."
        exit 1
    fi

    SIM_TOOL="xsim"
    SIM_DIR="$BUILD_DIR/xsim_work"
    mkdir -p "$SIM_DIR"

    pushd "$SIM_DIR" >/dev/null
    # Compile
    "$XVLOG" --sv -log /dev/null \
        -i "$REPO/src/sources" \
        "$REPO/src/sims/riscv_test_tb.sv" \
        "$REPO/src/sources/"*.sv
    # Elaborate
    "$XELAB" -log /dev/null \
        -debug off \
        riscv_test_tb \
        -s riscv_test_snapshot
    popd >/dev/null
    echo "  xelab snapshot → $SIM_DIR/riscv_test_snapshot"

    run_sim() {   # arg: hex_path
        pushd "$SIM_DIR" >/dev/null
        "$XSIM" riscv_test_snapshot \
            --testplusarg "HEX=$1" \
            --runall \
            --log /dev/null 2>&1 | tr -d '\r'
        popd >/dev/null
    }
fi

# -----------------------------------------------------------------------
# 3. Run each matching test
# -----------------------------------------------------------------------
echo ""
echo "=== Running tests (simulator: $SIM_TOOL) ==="

PASS=0
FAIL=0
TIMEOUT=0
FAIL_NAMES=()

for hex in "$BUILD_DIR"/$GLOB.hex; do
    [ -f "$hex" ] || continue

    name=$(basename "$hex" .hex)
    result=$(run_sim "$hex")

    if echo "$result" | grep -q "^PASS"; then
        echo "  PASS     $name"
        PASS=$((PASS + 1))
    elif echo "$result" | grep -q "^TIMEOUT"; then
        echo "  TIMEOUT  $name"
        TIMEOUT=$((TIMEOUT + 1))
        FAIL_NAMES+=("TIMEOUT : $name")
    elif echo "$result" | grep -q "^FAIL"; then
        echo "  $(echo "$result" | grep '^FAIL')"
        FAIL=$((FAIL + 1))
        FAIL_NAMES+=("FAIL    : $name")
    else
        echo "  UNKNOWN  $name  ($result)"
        FAIL=$((FAIL + 1))
        FAIL_NAMES+=("UNKNOWN : $name")
    fi
done

# -----------------------------------------------------------------------
# 4. Summary
# -----------------------------------------------------------------------
TOTAL=$((PASS + FAIL + TIMEOUT))
echo ""
echo "=== Results: $PASS / $TOTAL passed  ($FAIL failed, $TIMEOUT timeout) ==="

if [ ${#FAIL_NAMES[@]} -gt 0 ]; then
    echo ""
    echo "Failed / timed-out:"
    for n in "${FAIL_NAMES[@]}"; do
        echo "  $n"
    done
    exit 1
fi
