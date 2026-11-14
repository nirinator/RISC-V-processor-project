# RISC-V 32-bit Processor - Part A

## 📌 Project Overview
This project is a simplified implementation of a **RISC-V 32-bit processor** written in **SystemVerilog**. The core is designed from scratch, focusing on a clear understanding of hardware architecture, specifically the strict separation between the **Datapath** and the **Control Unit**. 

The current stage encompasses the complete RTL hardware design, which has been successfully verified via RTL Analysis. 

## 🏗️ Architecture & Specifications
*   **ISA:** RISC-V 32-bit (RV32I subset).
*   **Execution Model:** Single-Cycle.
*   **Memory Architecture:** Harvard Architecture (physically separated Instruction Memory and Data Memory).
*   **Modularity:** Fully modular design integrating an ALU, Register File, Immediate Generator, and Control Unit into a unified Top Core (`riscv_core`).

## ⚙️ Supported Instruction Set
To keep the logic streamlined and focused on core functionality, the processor supports a targeted subset of the RV32I base integer instruction set:
*   **R-Type:** `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND`
*   **I-Type:** Immediate arithmetic operations (`ADDI`, etc.)
*   **Load/Store:** `LW`, `SW`
*   **Branch:** `BEQ`, `BNE` (and other conditional branches)

## 🧩 Hardware Modules Breakdown
1.  **`riscv_core` (Top Module):** The main Datapath orchestrating the flow of data between all internal modules.
2.  **`control_unit`:** The "brain" of the processor. It evaluates the 7-bit `opcode` (along with `funct3` and `funct7`) and outputs binary control signals (flags) to direct the Datapath. It performs no calculations.
3.  **`alu` (Arithmetic Logic Unit):** Handles all mathematical and logical operations, as well as address calculations for memory access.
4.  **`reg_file`:** A 32x32-bit fast register file with two asynchronous read ports and one synchronous write port.
5.  **`imm_gen`:** Extracts and extends immediate values from the 32-bit instruction dynamically based on the opcode.
6.  **`instr_mem` (ROM):** Read-only memory storing the executable program.
7.  **`data_mem` (RAM):** Read/Write memory for storing variables and program data.

## 🧠 Key Design Decisions & Optimizations
*   **Datapath vs. Control Separation:** All 32-bit arithmetic (including branch target calculation `pc + imm`) is strictly hardwired in the Datapath. The Control Unit is solely responsible for asserting control flags (e.g., `branch`, `mem_write`).
*   **Word-Aligned Memory Access:** While the RISC-V ISA is byte-addressed (PC increments by 4), our memory arrays are word-indexed. This is elegantly resolved in hardware by truncating the two least significant bits of the address (`addr[31:2]`), acting as a hardware-level division by 4.
*   **Hardwired STORE Logic:** Following the RISC-V standard, the data to be stored in RAM always originates from `rs2`. Therefore, the `rd2` output from the Register File is hardwired directly to the `write_data` input of the Data Memory, relying on the `mem_write` flag to gate the operation.

## 🚀 Current Status & Next Steps
*   [x] Datapath implementation
*   [x] Control Unit design
*   [x] Sub-modules integration
*   [x] RTL Analysis & Schematic verification
*   [ ] **Next Phase:** Writing the SystemVerilog Testbench and loading a `.hex` program to simulate and verify the processor's execution in Modelsim/Vivado.
