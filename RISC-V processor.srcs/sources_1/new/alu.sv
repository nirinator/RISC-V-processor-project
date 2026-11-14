import riscv_pkg::*;

//the alu has two data inputs a,b, an alu_op input dictating which alu operation to execute
//a result output, and a zero output which returns zero when the result is zero, it would be usefull for certain commands
module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  alu_op_t     alu_op,
    output logic [31:0] result,
    output logic        zero
);

//the combinational logic and the main part of the alu, it makes a mathematical/logical operation on a and b given a certain alu_op
    always_comb begin
        case (alu_op)
            ALU_ADD:  result = a + b;
            ALU_SUB:  result = a - b;
            ALU_SLL:  result = a << b[4:0]; 
            ALU_SLT:  result = 32'($signed(a) < $signed(b)); 
            ALU_SLTU: result = 32'(a < b);
            ALU_XOR:  result = a ^ b;
            ALU_SRL:  result = a >> b[4:0];
            ALU_SRA:  result = $signed(a) >>> b[4:0]; 
            ALU_OR:   result = a | b;
            ALU_AND:  result = a & b;
            default:  result = 32'b0;
        endcase
    end

    
    assign zero = (result == 32'b0);

endmodule