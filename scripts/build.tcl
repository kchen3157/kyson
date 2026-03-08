######## SET DESIGN SOURCES HERE (ONE PER FILE) ########
read_verilog -sv "src/sources/top.sv"

######## SET CONSTRAINTS HERE ########
read_xdc "src/constrs/Nexys-Video-Master.xdc"

######## SET PART HERE ########
synth_design -top "top" -part "xc7a200tsbg484-1"

# place and route
opt_design
place_design
route_design

report_utilization -file utilizationReport.txt

######## SET FINAL BITSTREAM OUTPUT HERE ########
write_bitstream -force "build/proj.bit"
