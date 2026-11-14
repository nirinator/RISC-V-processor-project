# RISC-V 32-bit Processor - Part A

## Project Overview
This project is a simplified implementation of a **RISC-V 32-bit processor** written in **SystemVerilog**. My main goal was to gain a hands-on understanding of hardware architecture, specifically focusing on the interaction between the **Datapath** and the **Control Unit**. 

The current stage encompasses the complete RTL hardware design, which has been successfully verified via RTL Analysis. 

## Architecture & Specifications
*   **ISA:** RISC-V 32-bit (RV32I subset).
*   **Execution Model:** Single-Cycle.
*   **Modularity:** Modular design integrating an ALU, Register File, Immediate Generator, and Control Unit into a unified top core.

## Supported Instruction Set
To keep the design focused on core functionality, I implemented a subset of the RV32I base instructions:
*   **R-Type:** `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND`
*   **I-Type:** Immediate arithmetic operations (`ADDI`, etc.)
*   **Load/Store:** `LW`, `SW`
*   **Branch:** `BEQ`, `BNE` 

## Hardware Modules Breakdown
Here is a quick look at the main modules I wrote:
1.  **`riscv_core` (Top Module):** The main datapath that connects all internal modules and handles the physical data flow.
2.  **`control_unit`:** The "brain" of the processor. It evaluates the 7-bit `opcode` (along with `funct3` and `funct7`) and outputs binary control signals (flags) to direct the Datapath. It performs no calculations.
3.  **`alu` (Arithmetic Logic Unit):** Performs mathematical and logical operations, as well as address calculations for memory access.
4.  **`reg_file`:** A 32x32-bit fast register file with two asynchronous read ports and one synchronous write port.
5.  **`imm_gen`:** Extracts and extends immediate values from the 32-bit instruction dynamically based on the opcode.
6.  **`instr_mem` (ROM):** Read-only memory storing the executable program.
7.  **`data_mem` (RAM):** Read/Write memory for variables and program data.

## Things I Learned & Design Choices
*   **Datapath vs. Control Separation:** It was important to realize that all 32-bit arithmetic (including calculating the branch target `pc + imm`) should happen continuously in the Datapath. The Control Unit is only responsible for flipping flags (e.g., `branch`, `mem_write`).
*   **Word-Aligned Memory Access:** While the RISC-V PC increments by 4 (byte-addressed), my memory arrays are word-indexed. I resolved this hardware constraint by ignoring the two least significant bits of the address (`addr[31:2]`), which effectively divides the address by 4.
*   **Hardwired STORE Logic:** Following the RISC-V standard, data to be stored in RAM always comes from `rs2`. Therefore, I hardwired the `rd2` output directly to the RAM's `write_data` input. The RAM only accepts the data when the `mem_write` flag is high.
