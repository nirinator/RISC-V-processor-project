//the control unit tells what signal should be sent through which wires for every type of command
//opcode dictates which type of command we need, funct3 and funct7_5 dictate which alu command we need
import riscv_pkg::*;

module control_unit (
    input  opcode_t    opcode,     
    input  logic [2:0] funct3,     
    input  logic       funct7_5,   


    output logic       reg_write,  
    output logic       alu_src,    
    output logic       mem_write,  
    output logic       mem_read,   
    output logic       branch,     
    output logic [1:0] result_src, // what returns to the register? 00=alu output, 01= the memory, 10=PC+4 (jump a row)
    

    output alu_op_t    alu_op
);

    always_comb begin
//reset all the output signals
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        mem_write  = 1'b0;
        mem_read   = 1'b0;
        branch     = 1'b0;
        result_src = 2'b00;
        alu_op     = ALU_ADD; 


        case (opcode)
            
            // R-command
            OP_REG: begin
            //reg_write=1 means we need to store the output in the memory
            //alu_src=0 means the alu gets its second input from the second register (it can also get it from the extracted integer)
                reg_write  = 1'b1;  
                alu_src    = 1'b0;  

                case (funct3)
                    3'b000: alu_op = (funct7_5) ? ALU_SUB : ALU_ADD;
                    3'b001: alu_op = ALU_SLL;
                    3'b010: alu_op = ALU_SLT;
                    3'b011: alu_op = ALU_SLTU;
                    3'b100: alu_op = ALU_XOR;
                    3'b101: alu_op = (funct7_5) ? ALU_SRA : ALU_SRL;
                    3'b110: alu_op = ALU_OR;
                    3'b111: alu_op = ALU_AND;
                endcase
            end

            //I-command
            OP_IMM: begin
            //reg_write=1 means we need to store the output in the memory
            //alu_src=1 means the alu gets its second input from the extracted integer
                reg_write  = 1'b1;
                alu_src    = 1'b1; 
                case (funct3)
                    3'b000: alu_op = ALU_ADD;
                    3'b001: alu_op = ALU_SLL;
                    3'b010: alu_op = ALU_SLT;
                    3'b011: alu_op = ALU_SLTU;
                    3'b100: alu_op = ALU_XOR;
                    3'b101: alu_op = (funct7_5) ? ALU_SRA : ALU_SRL;
                    3'b110: alu_op = ALU_OR;
                    3'b111: alu_op = ALU_AND;
                endcase
            end

            //reg_write=1 means we need to store the output in the memory
            //alu_src=1 means the alu gets its second input from the extracted integer
            //mem_read=1 means reading is authorized
            //result_src=01 means the data writen in the register would come from the memory
            //the alu command here is addition since it adds numbers (the register number and what exact bit in it) to reach the precise adress 
            OP_LOAD: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1; 
                mem_read   = 1'b1; 
                result_src = 2'b01; 
                alu_op     = ALU_ADD;
            end

            //mem_write=1 means writing to the memory is permitted
            //alu_src=1 and alu_op=alu_add for the same reason as in OP_LOAD
            OP_STORE: begin
                mem_write  = 1'b1; 
                alu_src    = 1'b1; 
                alu_op     = ALU_ADD;
            end

            //branch=1 permits branching, alu_op=ALU_SUB is ised to check whether the two values in the registers are equal (so that a condition is met
            //the adress to where to jump is calculated in the riscv_core.sv code
            OP_BRANCH: begin
                branch     = 1'b1; 
                alu_op     = ALU_SUB; 
            end
            
            
        endcase
    end
endmodule