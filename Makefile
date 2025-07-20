all:
	verilator --cc cpu_5stage_tb.v cpu_5stage.v --trace --exe sim_main.cpp
	cd obj_dir ; make -f Vcpu_5stage_tb.mk
