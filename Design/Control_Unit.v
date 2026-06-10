// Control Unit: Generates read/write enable flags based on the opcode
module Control_Unit(
    input [31:0] instruction,
    output rd_valid, rs1_valid, rs2_valid, is_s_instr, is_load
);
    wire is_u_instr, is_b_instr, is_j_instr, is_r_instr, is_i_instr, empty_rd;

    // Classify instruction based on opcode (bits 6:2)
    assign empty_rd = (instruction[11:7] == 5'b00000) ? 1'b1 : 1'b0;
    assign is_load = (instruction[6:2] == 5'b00000) ? 1'b1 : 1'b0;
    assign is_u_instr = ((instruction[6:2] == 5'b00101) || (instruction[6:2] == 5'b01101)) ? 1'b1 : 1'b0;
    assign is_b_instr = (instruction[6:2] == 5'b11000) ? 1'b1 : 1'b0;
    assign is_s_instr = (instruction[6:2] == 5'b01000) ? 1'b1 : 1'b0;
    assign is_j_instr = (instruction[6:2] == 5'b11011) ? 1'b1 : 1'b0;
    
    assign is_r_instr = ((instruction[6:2] == 5'b01000) || (instruction[6:2] == 5'b01001) || (instruction[6:2] == 5'b01010) || 
                         (instruction[6:2] == 5'b01011) || (instruction[6:2] == 5'b01100) || (instruction[6:2] == 5'b01101) || 
                         (instruction[6:2] == 5'b01110) || (instruction[6:2] == 5'b01111) || (instruction[6:2] == 5'b10100)) ? 1'b1 : 1'b0;
                         
    assign is_i_instr = ((instruction[6:2] == 5'b00000) || (instruction[6:2] == 5'b00001) || 
                         (instruction[6:2] == 5'b00100) || (instruction[6:2] == 5'b00110) || (instruction[6:2] == 5'b11001)) ? 1'b1 : 1'b0;

    // Assign validation flags for participating registers
    assign rd_valid = ~(is_s_instr | is_b_instr | empty_rd);  
    assign rs1_valid = ~(is_u_instr | is_j_instr);             
    assign rs2_valid = (is_r_instr | is_s_instr | is_b_instr); 
endmodule 