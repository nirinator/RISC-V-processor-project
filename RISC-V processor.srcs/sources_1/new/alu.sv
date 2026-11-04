import riscv_pkg::*;

module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  alu_op_t     alu_op,
    output logic [31:0] result,
    output logic        zero
);

    always_comb begin
        case (alu_op)
            ALU_ADD:  result = a + b;
            ALU_SUB:  result = a - b;
            ALU_SLL:  result = a << b[4:0]; // ???? ????? ?????? ?-5 ????? ???????
            ALU_SLT:  result = 32'($signed(a) < $signed(b)); // ?????? ?? ????
            ALU_SLTU: result = 32'(a < b); // ?????? ??? ????
            ALU_XOR:  result = a ^ b;
            ALU_SRL:  result = a >> b[4:0];
            ALU_SRA:  result = $signed(a) >>> b[4:0]; // ???? ????? ????? ????
            ALU_OR:   result = a | b;
            ALU_AND:  result = a & b;
            default:  result = 32'b0;
        endcase
    end

    // ??? zero ???? ???? ?????? ??? 0 
    assign zero = (result == 32'b0);

endmodule