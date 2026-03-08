#!/bin/bash
vivado -mode batch -nolog -nojournal -source ./scripts/tb/${1}_tb.tcl

rm -rf ./temp_proj_${1}_tb/ ./xvlog.pb
