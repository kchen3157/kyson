# Vivado simulation script for riscv_test_tb (single test).
#
# Usage (from repo root):
#   ./test.sh riscv_test
#
# To change the test being run, set HEX_FILE below.

######## SET TEST HEX FILE HERE ########
set HEX_FILE "tests/build/rv32ui-p-add.hex"

######## FIXED SETTINGS ########
set MODULE_UNDER_TEST "riscv_test"
set SIM_TIME          "10ms"     ;# riscv-tests are short; 10 ms is generous

set WAVEFORM_DIR "waveforms"
set TIMESTAMP    [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]
file mkdir ${WAVEFORM_DIR}

create_project temp_proj_${MODULE_UNDER_TEST}_tb \
    ./temp_proj_${MODULE_UNDER_TEST}_tb -force
set_property target_language Verilog [current_project]
set_property part xc7a200tsbg484-1   [current_project]

add_files -fileset sim_1     "src/sims/${MODULE_UNDER_TEST}_tb.sv"
add_files -fileset sources_1 "src/sources/"

set_property top     ${MODULE_UNDER_TEST}_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib          [get_filesets sim_1]

# Pass the hex file to the testbench via plusarg
set_property -name {xsim.simulate.xsim.more_options} \
    -value "-testplusarg HEX=${HEX_FILE}" \
    -objects [get_filesets sim_1]

launch_simulation

open_vcd ../${WAVEFORM_DIR}/${TIMESTAMP}_${MODULE_UNDER_TEST}_tb.vcd
log_vcd /${MODULE_UNDER_TEST}_tb/*

restart
run ${SIM_TIME}

close_vcd
