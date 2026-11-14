#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <iomanip>

using namespace std;

int main() {
    uint32_t regs[32] = { 0 };      // virtual registers
    uint32_t memory[64] = { 0 };    // virtual RAM
    vector<uint32_t> inst_mem;

    // In this section of code we open the file, read it line by line and store in the the inst_mem vector, later we would loop on it.
    ifstream infile("program.hex");
    if (!infile) {
        cerr << "Error: Could not open program.hex" << endl;
        return 1;
    }
    string line;
    while (infile >> line) {
        inst_mem.push_back(stoul(line, nullptr, 16));
    }
    infile.close();

    // 2. every command is 4 bits, meaning 4 bytes, so going to the next line means jumping by 4.
    uint32_t pc = 0;
    while (pc / 4 < inst_mem.size()) {
        uint32_t inst = inst_mem[pc / 4];
        uint32_t next_pc = pc + 4;


        uint32_t opcode = inst & 0x7F;
        uint32_t rd = (inst >> 7) & 0x1F;
        uint32_t rs1 = (inst >> 15) & 0x1F;
        uint32_t rs2 = (inst >> 20) & 0x1F;
        uint32_t funct3 = (inst >> 12) & 0x7;
        uint32_t funct7 = (inst >> 25) & 0x7F;
        bool funct7_5 = (inst >> 30) & 0x1;


        if (opcode == 0x13){ // I-Type 
            int32_t imm = (int32_t)inst >> 20; // sign extention
            uint32_t shamt = rs2;              // storing the shift

            switch (funct3) {
            case 0: regs[rd] = regs[rs1] + imm; break;                     // ADDI
            case 1: regs[rd] = regs[rs1] << shamt; break;                  // SLLI
            case 2: regs[rd] = ((int32_t)regs[rs1] < imm) ? 1 : 0; break;  // SLTI
            case 3: regs[rd] = (regs[rs1] < (uint32_t)imm) ? 1 : 0; break; // SLTIU
            case 4: regs[rd] = regs[rs1] ^ imm; break;                     // XORI
            case 5:
                if (funct7_5)
                    regs[rd] = (int32_t)regs[rs1] >> shamt;                // SRAI
                else
                    regs[rd] = regs[rs1] >> shamt;                         // SRLI
                break;
            case 6: regs[rd] = regs[rs1] | imm; break;                     // ORI
            case 7: regs[rd] = regs[rs1] & imm; break;                     // ANDI
            }

        }
        else if (opcode == 0x33) { // R-Type (
            uint32_t shamt = regs[rs2] & 0x1F;

            switch (funct3) {
            case 0:
                if (funct7_5) regs[rd] = regs[rs1] - regs[rs2];            // SUB
                else          regs[rd] = regs[rs1] + regs[rs2];            // ADD
                break;
            case 1: regs[rd] = regs[rs1] << shamt; break;                  // SLL
            case 2: regs[rd] = ((int32_t)regs[rs1] < (int32_t)regs[rs2]) ? 1 : 0; break; // SLT
            case 3: regs[rd] = (regs[rs1] < regs[rs2]) ? 1 : 0; break;     // SLTU
            case 4: regs[rd] = regs[rs1] ^ regs[rs2]; break;               // XOR
            case 5:
                if (funct7_5)
                    regs[rd] = (int32_t)regs[rs1] >> shamt;                // SRA
                else
                    regs[rd] = regs[rs1] >> shamt;                         // SRL
                break;
            case 6: regs[rd] = regs[rs1] | regs[rs2]; break;               // OR
            case 7: regs[rd] = regs[rs1] & regs[rs2]; break;               // AND
            }

        }
        else if (opcode == 0x03) { // S-Type Load (LW)
            int32_t imm = (int32_t)inst >> 20;
            if (funct3 == 2) { // LW
                uint32_t addr = regs[rs1] + imm;
                regs[rd] = memory[addr / 4];
            }

        }
        else if (opcode == 0x23) { // S-Type Store (SW)
            int32_t imm = ((inst >> 25) << 5) | ((inst >> 7) & 0x1F);
            if (imm & (1 << 11)) imm |= 0xFFFFF000; // הרחבת סימן

            if (funct3 == 2) { // SW
                uint32_t addr = regs[rs1] + imm;
                memory[addr / 4] = regs[rs2];
            }

        }
    }
    else if (opcode == 0x63) { // B-Type (BEQ)
        int32_t imm = 0;
        //In RISC-V, the imm integer is broken into two bits sections, so its extraction is more complicated
        imm |= ((inst >> 31) & 0x1) << 12;
        imm |= ((inst >> 7) & 0x1) << 11;
        imm |= ((inst >> 25) & 0x3F) << 5;
        imm |= ((inst >> 8) & 0xF) << 1;

        // sign extention (in case we want to jump back)
        if (imm & (1 << 12)) imm |= 0xFFFFE000;

        if (regs[rs1] == regs[rs2]) {
            next_pc = pc + imm; 
        }
    }

        regs[0] = 0; // חוק ברזל ב-RISC-V: רגיסטר 0 תמיד מאופס
        pc = next_pc;
    }

    // storing the output (the registers) in expected_regs.hex
    ofstream outfile("expected_regs.hex");
    for (int i = 0; i < 32; i++) {
        outfile << setfill('0') << setw(8) << hex << regs[i] << "\n";
    }
    outfile.close();

    cout << "C++ Golden model updated" << endl;
    return 0;
}