//this module has a small RAM memory, and through this module the processor either reads data from the memory or writes to it

module data_mem (
    input  logic        clk,
    input  logic        mem_write,   
    input  logic        mem_read,    
    input  logic [31:0] addr,        // the adress where the data should be stored in the memory
    input  logic [31:0] write_data,  
    
    output logic [31:0] read_data    
);

    logic [31:0] memory [0:63];

    always_ff @(posedge clk) begin
        if (mem_write) begin
            memory[addr[31:2]] <= write_data;
        end
    end

    assign read_data = (mem_read) ? memory[addr[31:2]] : 32'b0;

endmodule