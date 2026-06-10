`timescale 1ns / 1ps

module tb_Decoder_Control();

    reg clk;
    reg [31:0] instruction;
    wire [4:0]  rs1, rs2, rd, opcode;
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire [31:0] imm;
    wire rd_valid, rs1_valid, rs2_valid, is_s_instr, is_load;

    Decoder uut_decoder (
        .clk(clk),
        .instr(instruction),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .opcode(opcode), .funct3(funct3), .funct7(funct7),
        .imm(imm)
    );

    Control uut_control (
        .instruction(instruction),
        .rd_valid(rd_valid),
        .rs1_valid(rs1_valid),
        .rs2_valid(rs2_valid),
        .is_s_instr(is_s_instr),
        .is_load(is_load)
    );


    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //  Test Scenarios
    initial begin
        instruction = 0;
        #10;

        $display("===============================================================");
        $display("STARTING DECODER & CONTROL TEST");
        $display("===============================================================");

        // --- Scenario 1: R-Type Instruction (add $t3, $t0, $t1) ---
        $display("\n--- Scenario 1: R-Type (ADD) ---");
        instruction = 32'h00628e33; // Binary: 00000000_0110_00101_000_11100_0110011
        #10;
        $display("Instr: %h", instruction);
        $display("DECODER -> opcode: %h, rd: %d, rs1: %d, rs2: %d", opcode, rd, rs1, rs2);
        $display("CONTROL -> rd_valid: %b, rs1_valid: %b, rs2_valid: %b (Expected: 1, 1, 1)", rd_valid, rs1_valid, rs2_valid);

        // --- Scenario 2: I-Type Instruction (lb $a1, 0($a0)) ---
        $display("\n--- Scenario 2: I-Type (LOAD BYTE) ---");
        instruction = 32'h00050583; // Binary: 000000000000_01010_000_01011_0000011
        #10;
        $display("Instr: %h", instruction);
        $display("DECODER -> opcode: %h, rd: %d, rs1: %d, imm: %d", opcode, rd, rs1, $signed(imm));
        $display("CONTROL -> is_load: %b (Expected: 1), rd_valid: %b, rs2_valid: %b (Expected: 1, 0)", is_load, rd_valid, rs2_valid);

        // --- Scenario 3: S-Type Instruction (sb $t3, 0($a0)) ---
        $display("\n--- Scenario 3: S-Type (STORE BYTE) ---");
        instruction = 32'h01c50023; // Binary: 0000000_11100_01010_000_00000_0100011
        #10;
        $display("Instr: %h", instruction);
        $display("DECODER -> opcode: %h, rs1: %d, rs2: %d, imm: %d", opcode, rs1, rs2, $signed(imm));
        $display("CONTROL -> is_s_instr: %b (Expected: 1), rd_valid: %b (Expected: 0)", is_s_instr, rd_valid);

        // --- Scenario 4: B-Type Instruction (beq $t2, $t3, 0) ---
        $display("\n--- Scenario 4: B-Type (BRANCH EQUAL) ---");
        instruction = 32'h01c38063; // Binary: 0000000_11100_00111_000_00000_1100011
        #10;
        $display("Instr: %h", instruction);
        $display("DECODER -> opcode: %h, rs1: %d, rs2: %d, imm: %d", opcode, rs1, rs2, $signed(imm));
        $display("CONTROL -> rd_valid: %b (Expected: 0), rs1_valid: %b, rs2_valid: %b", rd_valid, rs1_valid, rs2_valid);

        // --- Scenario 5: J-Type Instruction (jal $s0, 8) ---
        $display("\n--- Scenario 5: J-Type (JUMP AND LINK) ---");
        instruction = 32'h0080046f; // Binary: 00000000100_000000000_01000_1101111
        #10;
        $display("Instr: %h", instruction);
        $display("DECODER -> opcode: %h, rd: %d, imm: %d", opcode, rd, $signed(imm));
        $display("CONTROL -> rd_valid: %b (Expected: 1), rs1_valid: %b (Expected: 0)", rd_valid, rs1_valid);

        $display("===============================================================");
        $display("DECODER & CONTROL TEST COMPLETE");
        $display("===============================================================");
        $finish;
    end
    initial begin
            $dumpfile("alu_wave.vcd");
            $dumpvars(0, tb_Decoder_Control);
        end
endmodule