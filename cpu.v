module cpu (
    input clk,
    input reset
);
    // 五階段：IF, ID, EX, MEM, WB
    // 這裡僅示意各階段暫存器與基本流程
    reg [31:0] pc;
    reg [31:0] instr_if, instr_id, instr_ex, instr_mem, instr_wb;
    reg [31:0] regfile [0:31];
    reg [31:0] alu_out_ex, alu_out_mem, alu_out_wb;
    reg [31:0] mem_data_mem, mem_data_wb;

    // 指令記憶體與資料記憶體
    reg [31:0] imem [0:255];
    reg [31:0] dmem [0:255];

    // IF 階段
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 0;
            instr_if <= 0;
        end else begin
            instr_if <= imem[pc[9:2]];
            pc <= pc + 4;
        end
    end

    // ID 階段
    always @(posedge clk) begin
        instr_id <= instr_if;
        // ...解碼與暫存...
    end

    // EX 階段
    always @(posedge clk) begin
        instr_ex <= instr_id;
        // ...ALU 運算...
    end

    // MEM 階段
    always @(posedge clk) begin
        instr_mem <= instr_ex;
        // ...存取記憶體...
    end

    // WB 階段
    always @(posedge clk) begin
        instr_wb <= instr_mem;
        // ...寫回暫存器...
    end
endmodule