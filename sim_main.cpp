#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vcpu_5stage_tb.h"

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    // Trace configuration
    Verilated::traceEverOn(true);
    Vcpu_5stage_tb* top = new Vcpu_5stage_tb;
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("cpu_5stage.vcd");

    // Initialize signals
    top->clk = 0;
    top->reset = 1;
    top->eval();
    tfp->dump(0);

    // Release reset after one cycle
    top->clk = 1;
    top->eval();
    tfp->dump(1);
    top->reset = 0;

    // Memory and instruction initialization now handled by Verilog TB
    // Initial waveform dump after reset release
    top->eval(); tfp->dump(2);

    // Run for N clock cycles
    const int MAX_CYCLES = 100;
    for (int cyc = 0; cyc < MAX_CYCLES; ++cyc) {
        // Rising edge
        top->clk = 0;
        top->eval();
        tfp->dump(2*cyc + 2);
        // Falling edge
        top->clk = 1;
        top->eval();
        tfp->dump(2*cyc + 3);
    }

    // Final values printout (optional user logic can be added in Verilog testbench)
    tfp->close();
    delete top;
    delete tfp;
    return 0;
}
