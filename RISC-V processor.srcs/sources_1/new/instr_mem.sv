//it receives an adress in the input command list (pc) and returns its content

module instr_mem (
    input  logic [31:0] pc,       
    output logic [31:0] instr     
);


    logic [31:0] memory [0:63];

//memory now would contain the input file
    initial begin
        $readmemh("program.hex", memory);
    end

//begin from bit 2 and not 0, since the processor jumps every 4 bits 
    assign instr = memory[pc[31:2]]; 

endmodule