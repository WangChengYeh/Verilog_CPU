module cpu_5stage_tb;
  reg clk, reset;
  // Instantiate the 5‐stage CPU
  CPU_5Stage UUT (
    .clk(clk),
    .reset(reset)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // Test sequence
  initial begin
    // 1) Reset
    reset = 1;
    // 等待 1 個時鐘週期
    @(posedge clk);
    reset = 0;

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

    // 5) 讓 CPU 執行足夠週期
    // 等待 20 個時鐘週期
    repeat (20) @(posedge clk);

    // 6) 列印檢查結果
    $display("R3 = %0d (expect 15)", UUT.regfile[3]);
    $display("R4 = %0d (expect 1)",  UUT.regfile[4]);
    $display("R6 = %0d (expect 100)",UUT.regfile[6]);
    $display("DMEM[2] = %0d (expect 100)", UUT.dmem[2]);

    $finish;
  end

  // Waveform dump
  initial begin
    $dumpfile("cpu_5stage.vcd");
    $dumpvars(0, cpu_5stage_tb);
  end

endmodule
