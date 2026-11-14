import riscv_pkg::*;

//some commands store an integer (for example, to which line to jump)
//this section of code extracts the integer outof the command. it receives an an input instr
//it checks the LS 7 bits for the opcode to identify the type of command
//and given the command, it extracts the integers value out of the correct buts 
//in RISC-V different commands store the integer in a different way
//for the case of the commands that dont involve an integer (for example, substraction), the integer returned is 0
module imm_gen (
    input  logic [31:0] instr,
    output logic [31:0] imm
);

    opcode_t opcode;
    
    
    assign opcode = opcode_t'(instr[6:0]);

    always_comb begin
        case (opcode)
            // I-Type (ADDI, LW)
            OP_IMM, OP_LOAD: 
                imm = { {20{instr[31]}}, instr[31:20] };
                
            // S-Type (SW, SB)
            OP_STORE: 
                imm = { {20{instr[31]}}, instr[31:25], instr[11:7] };
                
            // B-Type (BEQ, BNE)
            OP_BRANCH: 
                imm = { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0 };
                
            // U-Type (LUI, AUIPC)
            OP_LUI, OP_AUIPC: 
                imm = { instr[31:12], 12'b0 };
                
 
                
            
            default: 
                imm = 32'b0;
        endcase
    end

endmodule