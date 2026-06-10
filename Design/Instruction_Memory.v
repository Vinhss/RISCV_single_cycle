// Instruction Memory: Contains the pre-loaded program
module Instruction_Memory (
    input reset,
    input [31:0] read_address,
    output [31:0] read_data
);
    reg [31:0] Imemory [63:0]; // 64-word memory (32-bit per word)
    integer k;
    
    // Asynchronous read based on PC (word-aligned address)
    assign read_data = Imemory[read_address];

    // Initialize the program when reset is triggered
    always @(posedge reset) begin
        for (k=0; k<64; k=k+1) begin  
            Imemory[k] = 32'b0; // Clear memory
        end
        // Pre-loaded machine code instructions
        Imemory[0]  = 32'b00000000_0110_00101_000_11100_01100_11; // add $t3 $t0 $t1
        Imemory[4]  = 32'b0000000_11100_00111_000_00000_11000_11; // beq $t2 $t3 0
        Imemory[8]  = 32'b00000000100_000000000_01000_11011_11;   // jal $s0 8
        Imemory[12] = 32'b000000001110_00110_000_01000_11001_11;  // jalr $s0 14($t1)
        Imemory[16] = 32'b0000000_11100_01010_000_00000_01000_11; // sb $t3 0($a0)
        Imemory[20] = 32'b000000000000_01010_000_01011_00000_11;  // lb $a1 0($a0)
        Imemory[24] = 32'b00000000000000000000_01000_11011_11;    // jal $s0 0
    end
endmodule 