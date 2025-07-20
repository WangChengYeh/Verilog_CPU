#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vcpu_5stage.h"

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    // Trace configuration
    Verilated::traceEverOn(true);
    Vcpu_5stage* top = new Vcpu_5stage;
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

    // Initialize register file
    top->regfile[1] = 0x0000000A; // 10 decimal
    top->regfile[2] = 0x00000005; // 5 decimal
    top->regfile[5] = 0x00000000; // 0 decimal
    // Initialize data memory: dmem[1] = 100
    top->dmem[1] = 0x00000064; // 100 decimal
    // Load instructions into imem
    top->imem[0] = 0x00223000; // 000000_00001_00010_00011_00000_000000
    top->imem[1] = 0x04222000; // 000001_00001_00010_00100_00000_000000
    top->imem[2] = 0x8CA60004; // LOAD R6, 4(R5)
    top->imem[3] = 0xACA60008; // STORE R6, 8(R5)
    top->imem[4] = 0x08000001; // JUMP offset=1
    // Dump after initialization
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
