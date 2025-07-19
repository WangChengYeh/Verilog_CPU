`timescale 1ns/1ps
`include "instruction.vh"

module cpu_tb;
    reg clk;
    reg reset;

    // 實例化 CPU
    cpu uut (
        .clk(clk),
        .reset(reset)
    );

    // 時鐘產生
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 測試流程
    initial begin
        $display("Start CPU Testbench");
        reset = 1;
        #10;
        reset = 0;

        // 可在此初始化指令記憶體內容
        // 例如: uut.imem[0] = {`OPCODE_ADD, ...};
        //      uut.imem[1] = {`OPCODE_LOAD, ...};
        //      uut.imem[2] = {`OPCODE_STORE, ...};
        //      uut.imem[3] = {`OPCODE_CMP, ...};
        //      uut.imem[4] = {`OPCODE_JUMP, ...};

        // 執行一段時間
        #100;

        $display("Finish CPU Testbench");
        $finish;
    end
endmodule