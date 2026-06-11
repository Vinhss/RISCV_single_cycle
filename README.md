# RISCV_single_cycle
## 1. Introduction to RISCV
RISC-V (Reduced Instruction Set Computing - Five) is an open source instruction set architecture (ISA) designed to be simple, modular, and extensible. It was originally developed at the University of California, Berkeley, and has attracted much attention in both academia and industry due to its open and flexible nature. Unlike proprietary ISAs, RISC-V is freely available, allowing anyone to design, implement, and customize a processor without paying licensing fees.

This project focuses on researching and designing hardware at the register transfer level (RTL) and implementing a 32-bit microprocessor core based on the open-source **RISC-V (RV32I)** instruction set architecture. The microprocessor is designed using a **Single-Cycle** model and is optimized for synthesis on an FPGA platform.
>**Key Features:** This design optimizes control flow latency, ensuring continuous and stable branch/jump address computation and data memory access.

<img width="975" height="607" alt="image" src="https://github.com/user-attachments/assets/4d467ea2-e2f1-4c68-9278-13ea35e205d2" />


## 2. Hardware Design Overview

The system is programmed entirely in **Verilog**, divided into a clear hierarchical structure to isolate errors and facilitate easy debugging.

### Hierarchy Architecture
- **`CPU_Core` (Top Module FPGA):** The physical interface block. Integrates a multiplexer (MUX) and a 7-segment LED decoder (Hex to 7-Segment) to directly map internal signals (PC, ALU Output, Register Data) to the FPGA board's I/O (Switches, Keys, LEDs), enabling real-time visual debugging.
- **`CPU_Core_Main` (Datapath & Control):** The heart of the microprocessor, comprising synchronously connected component modules:
- **Instruction & Data Memory:** Instruction memory (ROM) and data memory (RAM).
- **Register File:** A collection of 32 32-bit general-purpose registers.
- **Decoder & Control Unit:** The "brain" that decomposes 32-bit machine code, performs instantaneous interpolation (Sign-extension), and generates control signals.
- **ALU (Arithmetic Logic Unit):** Handles mathematical, logical, and branch condition processing.

<img width="880" height="671" alt="image" src="https://github.com/user-attachments/assets/85ecbd88-a206-40d1-b0d3-0e47cb0b69b3" />

## 3. Test Environment & Verification

To ensure the CPU core operates flawlessly, the project employs a systematic Hardware Verification method, from Unit Tests for each critical module to Integration Tests for the entire system.
### Test Scenarios
1. **Unit Test - ALU (`tb_alu.v`):** Exhaustive testing of algebraic and bitwise operations, and especially Corner Cases such as sign-preserving arithmetic right shift (`SRA`), signed/unsigned comparisons (`SLT`/`SLTU`).
2. **Unit Test - Decoder & Control (`tb_Decoder_Control.v`):** Input raw machine code and force the system to correctly cut opcodes, and accurately enable flags for reading/writing RAM and Register Files.
3. **Integration Test - Datapath (`tb_CPU_Core_Main.v`):** Allows the CPU to run freely through a real Assembly sequence consisting of R-Type operands, memory instructions (Load/Store), and jump instructions (Branch/JAL).

### Some Simulation Results
The simulation was performed on **EDA Playground(https://www.edaplayground.com/)** using the **EPWave** tool. 
#### ALU Block Testbench Results

<img width="824" height="764" alt="image" src="https://github.com/user-attachments/assets/ed09307e-1bb0-4ae5-8fe9-de9d0a14d60c" />

<img width="975" height="130" alt="image" src="https://github.com/user-attachments/assets/11a155cf-be70-4f8d-8325-2b9c3b2d5f36" />

#### Decoder and Control unit Block Testbench Results

<img width="584" height="573" alt="image" src="https://github.com/user-attachments/assets/a50527e7-4cb5-4a39-a495-4ced2973c9f9" />

<img width="1830" height="203" alt="image" src="https://github.com/user-attachments/assets/b71e9de9-f15a-4137-87f1-a8b83d742398" />

#### System-Wide Datapath Flow Testbench Results

<img width="1706" height="379" alt="image" src="https://github.com/user-attachments/assets/cc8af884-aaa6-4e6f-912a-59a2786bf487" />

<img width="518" height="402" alt="image" src="https://github.com/user-attachments/assets/3aacfff9-6b4b-4795-a120-09366748496b" />

** Key Signals Analysis:**

To demonstrate the stability and correctness of the verification environment, critical datapath signals are closely monitored at every rising edge of the clock (`clk`):

* **`W_PC_in` & `W_instruction` (Fetch Path):** The program counter and its corresponding 32-bit machine code. The synchronous transitions of these signals confirm that the Instruction Fetch stage operates smoothly without any timing lags.
* **`W_opcode` & `W_imm` (Decode Path):** Specific bit fields extracted from the raw instruction. The `W_imm` signal displays the correctly sign-extended immediate value ready to be fed into the execution stage.
* **`W_is_load` & `W_is_s_instr` (Memory Control):** Control flags for Data Memory access. The fact that these signals assert to `1` independently only during `lb` (Load) or `sb` (Store) instructions proves that the Control Unit successfully identifies and steers memory-bound operations.
* **`W_rd_valid` (Write-Back Protection):** The write-enable flag for the Register File. This signal automatically drops to `0` during branch (`beq`) or store (`sb`) instructions, effectively protecting the register file from data corruption caused by invalid write-backs.
