 // Top module datapath: Instantiates and connects all internal components
module CPU_Core_Main(
    input clk, reset,
    output [31:0] W_PC_in, W_rd_data1, W_rd_data2, W_imm, // Output signals for debugging
  	output [4:0] W_rs1, W_rs2, W_rd,
    output [31:0] W_PC_out, W_alu_out, W_instruction // Output signals for debugging
  
);
    // Declare internal routing wires between blocks
    wire [31:0] W_addr, W_result_write_rf, W_ld_data;
    wire [6:0] W_funct7;
    wire [4:0] W_opcode, W_DMem_addr;
    wire [2:0] W_funct3;
    wire taken_br, is_jal, is_jalr, W_rd_valid, W_rs1_valid, W_rs2_valid, W_is_s_instr, W_is_load;

    // 1. Auto-increment PC by 4 (32-bit/4-byte instruction structure)
    adder32Bit C3(.clk(clk), .reset(reset), .input1(W_PC_in), .input2(32'd4), .out(W_PC_out));

    // 2. Program Counter Management Block
    Program_Counter C1(.clk(clk), .reset(reset), .taken_br(taken_br), .is_jal(is_jal), .is_jalr(is_jalr), 
                       .imm(W_imm), .rs1_data(W_rd_data1), .PC_in(W_PC_out), .PC_out(W_PC_in));
  
    // 3. Instruction Memory: Provides the instruction code based on PC
    Instruction_Memory C4(.read_address(W_PC_out), .read_data(W_instruction), .reset(reset));

    // 4. Decoder Block: Fetches instruction and unpacks parameters
    Decoder C5(.clk(clk), .instr(W_instruction), .rs1(W_rs1), .rs2(W_rs2), .rd(W_rd), 
               .opcode(W_opcode), .funct3(W_funct3), .funct7(W_funct7), .imm(W_imm));

    // 5. Control Block: Generates control flags from opcode
    Control_Unit C6(.instruction(W_instruction), .rd_valid(W_rd_valid), .rs1_valid(W_rs1_valid), .rs2_valid(W_rs2_valid), 
               .is_s_instr(W_is_s_instr), .is_load(W_is_load));

    // 6. Register File
    Register_File C7(.clk(clk), .wr_en(W_rd_valid), .wr_addr(W_rd), .wr_data(W_result_write_rf), 
                     .rd_en1(W_rs1_valid), .rd_addr1(W_rs1), .rd_data1(W_rd_data1), 
                     .rd_en2(W_rs2_valid), .rd_addr2(W_rs2), .rd_data2(W_rd_data2));

    // 7. ALU Block: Computation and branching logic
    ALU C8(.ra(W_rd_data1), .rb(W_rd_data2), .imm(W_imm), .pc(W_PC_in), .opcode(W_opcode), 
           .funct3(W_funct3), .funct7(W_funct7), .taken_branch(taken_br), .is_jal(is_jal), 
           .is_jalr(is_jalr), .DMem_addr(W_DMem_addr), .alu_out(W_alu_out));

    // 8. Data Memory Block: Load/Store data operations
    Data_Memory C9(.clk(clk), .addr(W_DMem_addr), .wr_en(W_is_s_instr), .wr_data(W_rd_data2), 
                   .rd_en(W_is_load), .rd_data(W_ld_data));
    
    // 9. Multiplexer (Mux): Decides whether to write back ALU output or Data Memory data to Register File
    mux_32_bit C10(.in0(W_alu_out), .in1(W_ld_data), .mux_out(W_result_write_rf), .select(W_is_load));

endmodule