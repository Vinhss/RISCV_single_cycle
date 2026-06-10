// Instruction Decoder: Extracts bit fields from the RISC-V instruction
module Decoder(
    input clk,
    input [31:0] instr,
    output [4:0] rs1, rs2, rd, opcode,
    output [2:0] funct3,
    output [6:0] funct7,
    output reg [31:0] imm
);
    // Standard RISC-V opcode definitions
    parameter OP_LUI = 5'b01101, OP_AUIPC = 5'b00101, OP_JAL = 5'b11011, OP_JALR = 5'b11001,
              OP_BRANCH = 5'b11000, OP_STORE = 5'b01000, OP_LOAD = 5'b00000;

    // Extract basic fields directly from machine code
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign opcode = instr[6:2];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];
    assign rd = instr[11:7];

    // Sign-extension for Immediate value based on instruction format
    always @(*) begin
        case(opcode)
            OP_LUI, OP_AUIPC: imm = {instr[31:12], {12{1'b0}}}; // U-type
            OP_JAL: imm = {{11{instr[31]}}, instr[19:12], {2{instr[20]}}, instr[30:21], 1'b0}; // J-type
            OP_BRANCH: imm = {{19{instr[31]}}, {2{instr[7]}}, instr[30:25], instr[11:8], 1'b0}; // B-type
            OP_STORE: imm = {{21{instr[31]}}, instr[30:25], instr[11:8], instr[7]}; // S-type
            OP_JALR: imm = {{21{instr[31]}}, instr[30:20]}; // I-type (JALR specific)
            default: imm = {{21{instr[31]}}, instr[30:20]}; // Standard I-type
        endcase
    end
endmodule 