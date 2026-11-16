//this code initializes all the modules that we wrote, and connects the wires between them

import riscv_pkg::*;

module riscv_core (
    input  logic        clk,
    input  logic        rst_n,       
    input  logic [31:0] instr,       
    input  logic [31:0] read_data,   
    
    output logic [31:0] pc,          
    output logic [31:0] alu_out,     
    output logic [31:0] write_data,  
    output logic        mem_write,   
    output logic        mem_read     
);


    logic [31:0] pc_next, pc_plus_4, pc_target;
    logic [31:0] imm;
    logic [31:0] rd1, rd2;
    logic [31:0] alu_b;       // ???? ????? ?????? ?? ????? ?' ?? ?-ALU
    logic [31:0] result;      // ???? ????? ???? ???? ?????????
    logic        zero;
    

    logic       reg_write, alu_src, branch;
    logic [1:0] result_src;
    alu_op_t    alu_op;

//we either go back to the beginning of the commands if reset is on or go to the next line every clock cycle
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) pc <= 32'b0;
        else        pc <= pc_next;
    end

//there are 2 cases for which command line is the next: either the next in order, or the destination in a branch command
//we calculate both cases, and choose the right one depending on whether branch=1 and if zero=1 meaning the result of the substraction condition in the OP_BRANCH command was correct
    assign pc_plus_4 = pc + 4;
    assign pc_target = pc + imm;
    assign pc_next   = (branch && zero) ? pc_target : pc_plus_4; 


//we initialize all the modules
    control_unit u_cu (
        .opcode     (opcode_t'(instr[6:0])),
        .funct3     (instr[14:12]),
        .funct7_5   (instr[30]),
        .reg_write  (reg_write),
        .alu_src    (alu_src),
        .mem_write  (mem_write),
        .mem_read   (mem_read),
        .branch     (branch),
        .result_src (result_src),
        .alu_op     (alu_op)
    );


    reg_file u_rf (
        .clk (clk),
        .rst_n (rst_n),
        .we  (reg_write),
        .rs1 (instr[19:15]),
        .rs2 (instr[24:20]),
        .rd  (instr[11:7]),
        .wd  (result),       
        .rd1 (rd1),
        .rd2 (rd2)
    );


    imm_gen u_imm_gen (
        .instr (instr),
        .imm   (imm)
    );

    //alu_src decides whether the second input of the alu is the second register or the extracted integer
    assign alu_b = (alu_src == 1'b1) ? imm : rd2;


    alu u_alu (
        .a      (rd1),
        .b      (alu_b),     
        .alu_op (alu_op),
        .result (alu_out),
        .zero   (zero)
    );

    //from register 2 we get the data to store (from register 1 we get the adress where to store it)
    assign write_data = rd2;

//here we dictate which data would be the output: the alu output/the data read
    always_comb begin
        case (result_src)
            2'b00: result = alu_out;     // ?????? ????? ??-ALU
            2'b01: result = read_data;   // ????? ?????? ??-RAM
            default: result = 32'b0;
        endcase
    end

endmodule