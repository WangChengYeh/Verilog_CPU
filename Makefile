all:
   # Build DUT only and use C++ testbench without Verilog delays
   verilator --cc cpu_5stage.v --trace --exe sim_main.cpp
