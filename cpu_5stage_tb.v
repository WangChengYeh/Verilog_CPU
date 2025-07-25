module cpu_5stage_tb(
  input clk,
  input reset
);
  // Instantiate the 5‐stage CPU
  CPU_5Stage UUT (
    .clk(clk),
    .reset(reset)
  );

  // clk and reset driven by C++ Verilator harness

  // Memory and register initialization
  initial begin
    // 2) 初始化 register file
    UUT.regfile[1] = 32'd10;
    UUT.regfile[2] = 32'd5;
    UUT.regfile[5] = 32'd0;

    // 3) 初始化 data memory: 地址 4 (dmem[1]) 放 100
    UUT.dmem[1] = 32'd100;

    // 4) 載入指令到 imem
    // ADD  R3, R1, R2
    UUT.imem[0] = 32'b000000_00001_00010_00011_00000_000000;
    // CMP  R4, R1, R2
    UUT.imem[1] = 32'b000001_00001_00010_00100_00000_000000;
    // LOAD R6, 4(R5)
    UUT.imem[2] = {6'b100011, 5'd5, 5'd6, 16'd4};
    // STORE R6, 8(R5)
    UUT.imem[3] = {6'b101011, 5'd5, 5'd6, 16'd8};
    // JUMP offset=1  (跳到 imem[5])
    UUT.imem[4] = {6'b000010, 26'd1};

  end

  // Waveform dump
  initial begin
    $dumpfile("cpu_5stage.vcd");
    $dumpvars(0, cpu_5stage_tb);
  end

endmodule
