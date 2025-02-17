## Generated SDC file "coincidence.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.0.0 Build 614 04/24/2018 SJ Lite Edition"

## DATE    "Sat May 22 22:31:22 2021"

##
## DEVICE  "EP4CE22F17C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk50in} -period 20.000 -waveform { 0.000 10.000 } [get_ports {clk50in}]
create_clock -name {clk50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {clk50}]
create_clock -name {scanclk} -period 100.000 -waveform { 0.000 50.000 } [get_registers {processor:instpro|scanclk}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {clk50inpll} -source [get_pins {inst2pll|altpll_component|auto_generated|pll1|inclk[1]}] -duty_cycle 50/1 -multiply_by 1 -master_clock {clk50in} [get_pins {inst2pll|altpll_component|auto_generated|pll1|clk[0]}] -add
create_generated_clock -name {clk50pll} -source [get_pins {inst2pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 1 -master_clock {clk50} [get_pins {inst2pll|altpll_component|auto_generated|pll1|clk[0]}] -add
create_generated_clock -name {clkadcinpll} -source [get_pins {inst2pll|altpll_component|auto_generated|pll1|inclk[1]}] -duty_cycle 50/1 -multiply_by 5 -divide_by 2 -master_clock {clk50in} [get_pins {inst2pll|altpll_component|auto_generated|pll1|clk[1]}] -add
create_generated_clock -name {clkadcpll} -source [get_pins {inst2pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 5 -divide_by 2 -master_clock {clk50} [get_pins {inst2pll|altpll_component|auto_generated|pll1|clk[1]}] -add


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty

#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -logically_exclusive -group {clk50pll clkadcpll} -group {clk50inpll clkadcinpll}

#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_keepers {processor:instpro|scanclk}] -to [get_keepers {processor:instpro|scanclk}]

#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

