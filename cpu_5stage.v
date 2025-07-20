// 5‐stage pipeline CPU 支援 LOAD, STORE, ADD, CMP, JUMP
module CPU_5Stage(
  input         clk,
  input         reset
);

  // ----- Instruction Memory (IMEM) -----
  reg [31:0] imem [0:255];
  // ----- Data Memory (DMEM) -----
  reg [31:0] dmem [0:255];
  // ----- Register File -----
  reg [31:0] regfile [0:31];

  // ---- IF stage ----
  reg [31:0] pc;
  wire [31:0] pc_plus4 = pc + 4;
  wire [31:0] if_inst = imem[pc[9:2]];

  // IF/ID pipeline register
  reg [31:0] if_id_pc, if_id_inst;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      if_id_pc   <= 0;
      if_id_inst <= 0;
      pc         <= 0;
    end else begin
      if_id_pc   <= pc_plus4;
      if_id_inst <= if_inst;
      pc <= next_pc;
    end
  end

  // ---- ID stage ----
  wire [5:0] opcode = if_id_inst[31:26];
  wire [4:0] rs     = if_id_inst[25:21];
  wire [4:0] rt     = if_id_inst[20:16];
  wire [4:0] rd     = if_id_inst[15:11];
  wire [15:0] imm16 = if_id_inst[15:0];
  wire [31:0] imm_se = {{16{imm16[15]}}, imm16};

  wire [31:0] reg_rs = regfile[rs];
  wire [31:0] reg_rt = regfile[rt];

  // control signals
  reg        id_reg_write, id_mem_write, id_mem_read, id_mem_to_reg, id_alu_src, id_jump;
  reg [2:0]  id_alu_op;
  always @(*) begin
    // default
    {id_reg_write, id_mem_write, id_mem_read, id_mem_to_reg, id_alu_src, id_jump, id_alu_op} = 0;
    case (opcode)
      6'b100011: begin // LOAD
        id_reg_write = 1; id_mem_read = 1; id_mem_to_reg = 1; id_alu_src = 1; id_alu_op = 3'b010;
      end
      6'b101011: begin // STORE
        id_mem_write = 1; id_alu_src = 1; id_alu_op = 3'b010;
      end
      6'b000000: begin // ADD
        id_reg_write = 1; id_alu_op = 3'b010;
      end
      6'b000001: begin // CMP  (rs<rt ? Rd=1 : Rd=0)
        id_reg_write = 1; id_alu_op = 3'b110;
      end
      6'b000010: begin // JUMP
        id_jump = 1;
      end
    endcase
  end

  // ID/EX pipeline register
  reg [31:0] id_ex_pc4, id_ex_reg_rs, id_ex_reg_rt, id_ex_imm;
  reg [4:0]  id_ex_rs, id_ex_rt, id_ex_rd;
  reg        id_ex_reg_write, id_ex_mem_write, id_ex_mem_read, id_ex_mem_to_reg, id_ex_alu_src, id_ex_jump;
  reg [2:0]  id_ex_alu_op;
  always @(posedge clk) begin
    id_ex_pc4        <= if_id_pc;
    id_ex_reg_rs     <= reg_rs;
    id_ex_reg_rt     <= reg_rt;
    id_ex_imm        <= imm_se;
    id_ex_rs         <= rs;
    id_ex_rt         <= rt;
    id_ex_rd         <= rd;
    id_ex_reg_write  <= id_reg_write;
    id_ex_mem_write  <= id_mem_write;
    id_ex_mem_read   <= id_mem_read;
    id_ex_mem_to_reg <= id_mem_to_reg;
    id_ex_alu_src    <= id_alu_src;
    id_ex_jump       <= id_jump;
    id_ex_alu_op     <= id_alu_op;
  end

  // ---- EX stage ----
  wire [31:0] ex_alu_in2 = id_ex_alu_src ? id_ex_imm : id_ex_reg_rt;
  reg  [31:0] ex_alu_res;
  reg         ex_zero;
  reg  [31:0] ex_target;
  // simple ALU
  always @(*) begin
    case (id_ex_alu_op)
      3'b010: ex_alu_res = id_ex_reg_rs + ex_alu_in2;
      3'b110: ex_alu_res = (id_ex_reg_rs < ex_alu_in2) ? 32'd1 : 32'd0;
      default: ex_alu_res = 0;
    endcase
    ex_zero = (ex_alu_res == 0);
    ex_target = id_ex_pc4 + (id_ex_imm << 2);
  end

  // EX/MEM pipeline register
  reg [31:0] ex_mem_alu_res, ex_mem_reg_rt;
  reg [4:0]  ex_mem_rd;
  reg        ex_mem_reg_write, ex_mem_mem_write, ex_mem_mem_read, ex_mem_mem_to_reg, ex_mem_jump;
  reg [31:0] ex_mem_target;
  always @(posedge clk) begin
    ex_mem_alu_res    <= ex_alu_res;
    ex_mem_reg_rt     <= id_ex_reg_rt;
    ex_mem_rd         <= id_ex_rd;
    ex_mem_reg_write  <= id_ex_reg_write;
    ex_mem_mem_write  <= id_ex_mem_write;
    ex_mem_mem_read   <= id_ex_mem_read;
    ex_mem_mem_to_reg <= id_ex_mem_to_reg;
    ex_mem_jump       <= id_ex_jump;
    ex_mem_target     <= ex_target;
  end

  // next PC logic (只考慮 JUMP)
  wire [31:0] next_pc = ex_mem_jump ? ex_mem_target : pc_plus4;

  // ---- MEM stage ----
  reg [31:0] mem_wb_alu_res, mem_wb_mem_data;
  reg [4:0]  mem_wb_rd;
  reg        mem_wb_reg_write, mem_wb_mem_to_reg;
  always @(posedge clk) begin
    // memory access
    if (ex_mem_mem_read)  mem_wb_mem_data <= dmem[ex_mem_alu_res[9:2]];
    if (ex_mem_mem_write) dmem[ex_mem_alu_res[9:2]] <= ex_mem_reg_rt;
    // pass registers
    mem_wb_alu_res   <= ex_mem_alu_res;
    mem_wb_rd        <= ex_mem_rd;
    mem_wb_reg_write <= ex_mem_reg_write;
    mem_wb_mem_to_reg<= ex_mem_mem_to_reg;
  end

  // ---- WB stage ----
  always @(posedge clk) begin
    if (mem_wb_reg_write) begin
      regfile[mem_wb_rd] <= mem_wb_mem_to_reg ? mem_wb_mem_data : mem_wb_alu_res;
    end
  end

endmodule
