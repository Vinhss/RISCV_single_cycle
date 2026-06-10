`timescale 1ns / 1ps

module tb_alu();

    reg [31:0] ra, rb, imm, pc;
    reg [4:0]  opcode;
    reg [2:0]  funct3;
    reg [6:0]  funct7;
    
    wire taken_branch, is_jal, is_jalr;
    wire [4:0] DMem_addr;
    wire [31:0] alu_out;

    parameter OP_OPIMM = 5'b00100, OP_OP = 5'b01100, OP_BRANCH = 5'b11000;
    
    parameter FUNC_ADD_SUB = 3'b000, FUNC_SLT = 3'b010, FUNC_SLTU = 3'b011;
    parameter FUNC_XOR = 3'b100, FUNC_OR = 3'b110, FUNC_AND = 3'b111;
    parameter FUNC_SLL = 3'b001, FUNC_SRL_SRA = 3'b101;
    
    parameter FUNC_BEQ = 3'b000, FUNC_BNE = 3'b001, FUNC_BLT = 3'b100, FUNC_BGE = 3'b101;

    ALU uut (
        .ra(ra), .rb(rb), .imm(imm), .pc(pc),
        .opcode(opcode), .funct3(funct3), .funct7(funct7),
        .taken_branch(taken_branch), .is_jal(is_jal), .is_jalr(is_jalr),
        .DMem_addr(DMem_addr), .alu_out(alu_out)
    );

    initial begin
        ra = 0; rb = 0; imm = 0; pc = 0;
        opcode = 0; funct3 = 0; funct7 = 0;
        #10;

        $display("===============================================================");
        $display("STARTING ALU TEST");
        $display("===============================================================");

        // --- Scenario 1: Arithmetic Operations (ADD / SUB) ---
        $display("\n--- Scenario 1: Addition and Subtraction ---");
        ra = 32'd15; rb = 32'd10; opcode = OP_OP; funct3 = FUNC_ADD_SUB; 
        
        // Test Addition
        funct7 = 7'b0000000; 
        #10 $display("ADD:  %d + %d \t\t= %d \t(Expected: 25)", ra, rb, alu_out);
        
        // Test Subtraction
        funct7 = 7'b0100000; 
        #10 $display("SUB:  %d - %d \t\t= %d \t(Expected: 5)", ra, rb, alu_out);

        // --- Scenario 2: Logical Operations (AND / OR) ---
        $display("\n--- Scenario 2: Logical Operations (Hex) ---");
        ra = 32'hFFFF0000; rb = 32'h00FF00FF; opcode = OP_OP; funct7 = 7'b0000000;
        
        // Test Logical AND
        funct3 = FUNC_AND;
        #10 $display("AND:  %h & %h \t= %h \t(Expected: 00ff0000)", ra, rb, alu_out);
        
        // Test Logical OR
        funct3 = FUNC_OR;
        #10 $display("OR :  %h | %h \t= %h \t(Expected: ffff00ff)", ra, rb, alu_out);

        // --- Scenario 3: Shift Operations (Corner Cases for SLL / SRL / SRA) ---
        $display("\n--- Scenario 3: Shift Operations (Corner Cases) ---");
        ra = 32'hF0000000; // MSB is 1 (Negative number)
        rb = 32'd4;        // Shift by 4 bits
        opcode = OP_OP;
        
        // Test Shift Left Logical
        funct3 = FUNC_SLL; funct7 = 7'b0000000; 
        #10 $display("SLL : %h << %d \t= %h \t(Expected: 00000000)", ra, rb, alu_out);
        
        // Test Shift Right Logical (Does not preserve sign)
        funct3 = FUNC_SRL_SRA; funct7 = 7'b0000000; 
        #10 $display("SRL : %h >> %d (Logic)\t= %h \t(Expected: 0f000000)", ra, rb, alu_out);
        
        // Test Shift Right Arithmetic (Preserves sign)
        funct3 = FUNC_SRL_SRA; funct7 = 7'b0100000; 
        #10 $display("SRA : %h >> %d (Arith)\t= %h \t(Expected: ff000000)", ra, rb, alu_out);

        // --- Scenario 4: Set Less Than Comparisons (Signed & Unsigned) ---
        $display("\n--- Scenario 4: SLT vs SLTU Comparison ---");
        ra = 32'hFFFFFFFF; // -1 (Signed) or 4,294,967,295 (Unsigned)
        rb = 32'd1;        // 1
        opcode = OP_OP; funct7 = 7'b0000000;
        
        // Test Set Less Than (Signed: -1 < 1 is True)
        funct3 = FUNC_SLT; 
        #10 $display("SLT : %d < %d (Signed)\t= %d \t(Expected: 1)", $signed(ra), $signed(rb), alu_out);
        
        // Test Set Less Than Unsigned (Unsigned: 4,294,967,295 < 1 is False)
        // Fixed the display format issue by using %u for unsigned decimal
        funct3 = FUNC_SLTU; 
      	#10 $display("SLTU: %h < %h (Unsigned)= %d \t(Expected: 0)", ra, rb, alu_out);

        // --- Scenario 5: Branch Conditions ---
        $display("\n--- Scenario 5: Check for Branches ---");
        opcode = OP_BRANCH; ra = 32'd50; rb = 32'd50;
        
        // Test Branch if Equal
        funct3 = FUNC_BEQ; 
        #10 $display("BEQ : %d == %d \t\t-> taken_branch = %b (Expected: 1)", ra, rb, taken_branch);
        
        // Test Branch if Greater Than or Equal
        ra = 32'd20; rb = 32'd50;
        funct3 = FUNC_BGE; 
        #10 $display("BGE : %d >= %d \t\t-> taken_branch = %b (Expected: 0)", ra, rb, taken_branch);

        $display("===============================================================");
        $display("ALU TEST COMPLETE");
        $display("===============================================================");
        $finish;
    end
    initial begin
            $dumpfile("alu_wave.vcd");
            $dumpvars(0, tb_alu);
        end
endmodule