module alu (
    input [2:0] opcode,
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] result,
    output reg cmp_flag
);
    always @(*) begin
        case (opcode)
            `OPCODE_ADD: result = a + b;
            `OPCODE_CMP: cmp_flag = (a == b);
            default: result = 0;
        endcase
    end
endmodule