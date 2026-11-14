//this moduleinitiatesd riscv_core.sv, and also the reading and writing modules (instr_mem, data_mem)
//it only had inputs, it needs no output since it just receives all the inputs and plugs them into the modules

module riscv_top (
    input logic clk,
    input logic rst_n
);


    logic [31:0] pc;
    logic [31:0] instr;
    logic [31:0] data_addr;
    logic [31:0] write_data;
    logic [31:0] read_data;
    logic        mem_write;
    logic        mem_read;


    riscv_core u_core (
        .clk        (clk),
        .rst_n      (rst_n),
        .instr      (instr),       // ????? ?????? ??-ROM
        .read_data  (read_data),   // ?????? ??????? ??-RAM
        
        .pc         (pc),          // ?????? ?????? ?-ROM
        .alu_out    (data_addr),   // ?????? ?????? ?-RAM
        .write_data (write_data),  // ????? ????? ?-RAM
        .mem_write  (mem_write),
        .mem_read   (mem_read)
    );


    instr_mem u_imem (
        .pc         (pc),          
        .instr      (instr)        
    );


    data_mem u_dmem (
        .clk        (clk),
        .mem_write  (mem_write),
        .mem_read   (mem_read),
        .addr       (data_addr),  
        .write_data (write_data),
        .read_data  (read_data)    
    );

endmodule