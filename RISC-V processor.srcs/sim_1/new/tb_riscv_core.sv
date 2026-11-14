`timescale 1ns / 1ps

module tb_riscv_core;

    logic clk;
    logic rst;

   
    logic [31:0] expected_regs [0:31];
    int errors = 0;

    riscv_top uut (
        .clk(clk),
        .rst_n(rst)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 0;

        #20;
        rst = 1;

        #100;

//We use readmemh to read the file expected_regs.hex and store its values in the expected_regs memory.
        $readmemh("expected_regs.hex", expected_regs);
        
        $display("Starting Self-Checking Verification...");
        
        //This loop checks every register, it compares its content to the expected content from the C++ verificztion code.
        for (int i = 0; i < 32; i++) begin
            if (uut.u_core.u_rf.registers[i] !== expected_regs[i]) begin
                $display("ERROR at x%0d! Expected: %h, Got: %h", i, expected_regs[i], uut.u_core.u_rf.registers[i]);
                errors=1;
            end
        end

        if (errors == 0) begin
            $display("Verification passed successfully");
        end else begin
            $display("Verification failed");
        end
        #10;
        $finish;
    end

endmodule