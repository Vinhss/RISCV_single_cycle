// Program Counter: Manages the current instruction address
module Program_Counter (
    input clk, reset, taken_br, is_jal, is_jalr,
    input [31:0] imm, rs1_data, PC_in,
    output reg [31:0] PC_out
);
    // Synchronous PC update
    always @(posedge clk or posedge reset) begin
        if(reset)
            PC_out <= 32'b0; // Reset address to 0
        else if(taken_br == 1'b1 || is_jal == 1'b1)
            PC_out <= PC_in + imm; // Conditional Branch or JAL: PC = PC + Immediate
        else if(is_jalr == 1'b1)
            PC_out <= rs1_data + imm; // JALR jump: PC = rs1 + Immediate
        else
            PC_out <= PC_in; // Normal operation: PC = PC + 4 (from external adder)
    end
endmodule 