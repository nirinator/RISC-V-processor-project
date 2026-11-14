//this is a fast memory module, it receives write enable, 2 source registers, 
//destination register, data to write, and 2 outputs for the data from the source registers.
//reading data is immidiate, however writing data depends on the clock cycle, in order not to change data while it is being used.

module reg_file (
    input  logic        clk,
    input  logic        we,    // Write Enable
    input  logic [4:0]  rs1,   // Source register 
    input  logic [4:0]  rs2,   // Source register 
    input  logic [4:0]  rd,    // Destination register 
    input  logic [31:0] wd,    // Write Data 
    output logic [31:0] rd1,   // Read Data 1 
    output logic [31:0] rd2    // Read Data 2 
);

//here we create 32 registers of 32 bits, this is the fast memory's storage.
//We reset them all to zeros
    logic [31:0] registers [31:0];
    
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
    end

 //here we check whther both writing is enabled and the destination registewr is valid
 //if so, we copy the writing data into the register dictated by rd.
    always_ff @(posedge clk) begin
        if (we && rd != 5'b00000) begin
            registers[rd] <= wd;
        end
    end

// here we read the data from both source registers and store them 
    assign rd1 = (rs1 == 5'b00000) ? 32'b0 : registers[rs1];
    assign rd2 = (rs2 == 5'b00000) ? 32'b0 : registers[rs2];

endmodule
