// Arithmetic Logic Unit (ALU)
module ALU(
    input [31:0] ra, rb, imm, pc, // Operands A, B, Immediate, and Current PC
    input [4:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg taken_branch, is_jal, is_jalr,
    output [4:0] DMem_addr,
    output reg [31:0] alu_out
);
    // [Opcode and function parameters remain identical to the original code]
    parameter   OP_LUI = 5'b01101, OP_AUIPC = 5'b00101, OP_JAL_JALR = 5'b11011, OP_JALR = 3'b000,
                OP_BRANCH = 5'b11000, OP_LOAD = 5'b00000, OP_STORE = 5'b01000, OP_OPIMM = 5'b00100, OP_OP = 5'b01100,
                FUNC_BEQ = 3'b000, FUNC_BNE = 3'b001, FUNC_BLT = 3'b100, FUNC_BGE = 3'b101, FUNC_BLTU = 3'b110, FUNC_BGEU = 3'b111,
                FUNC_LB = 3'b000, FUNC_LH = 3'b001, FUNC_LW = 3'b010, FUNC_LBU = 3'b100, FUNC_LHU = 3'b101,
                FUNC_SB = 3'b000, FUNC_SH = 3'b001, FUNC_SW = 3'b010, FUNC_ADDI = 3'b000, FUNC_SLTI = 3'b010, FUNC_SLTIU = 3'b011,
                FUNC_XORI = 3'b100, FUNC_ORI = 3'b110, FUNC_ANDI = 3'b111, FUNC_SLLI = 3'b001, FUNC_SRLI_SRAI = 3'b101, FUNC_SRLI = 1'b0, FUNC_SRAI = 1'b1,
                ALU_OP_ADD_SUB = 3'b000, ALU_OP_ADD = 1'b0, ALU_OP_SUB = 1'b1, ALU_OP_SLL = 3'b001, ALU_OP_SLT = 3'b010, ALU_OP_SLTU = 3'b011,
                ALU_OP_XOR = 3'b100, ALU_OP_SRL_SRA = 3'b101, ALU_OP_SRL = 1'b0, ALU_OP_SRA = 1'b1, ALU_OP_OR = 3'b110, ALU_OP_AND = 3'b111;

    reg [31:0] r_temp, sltu_rslt, sltiu_rslt;
    reg [63:0] srai_rslt, sra_rslt, sext_ra;

    always @(*) begin
        // Assign default values to prevent unintended latches
        taken_branch = 1'b0; is_jal = 1'b0; is_jalr = 1'b0; alu_out = 32'b0;
        
        r_temp = (r_temp !== 32'bx) ? r_temp : (ra + imm);
        sltu_rslt  = {{31{1'b0}}, ra < rb};     // Unsigned comparison
        sltiu_rslt = {{31{1'b0}}, ra < imm};    // Unsigned comparison with Immediate
        sext_ra    = {{32{ra[31]}}, ra[31:0]};  // Sign-extension for arithmetic right shift
        srai_rslt  = sext_ra >> imm[4:0];       // Arithmetic right shift with Immediate
        sra_rslt   = sext_ra >> rb[4:0];        // Arithmetic right shift with register
        
        case(opcode)
            OP_LUI:   alu_out = {imm[31:12], 12'b0}; // Load Upper Immediate
            OP_AUIPC: alu_out = pc + {imm[31:12], 12'b0}; // Add Upper Immediate to PC
            OP_JAL_JALR: 
                case(funct3)
                    OP_JALR: is_jalr = 1'b1;
                    default: is_jal = 1'b1;
                endcase
            OP_BRANCH: // Branch instructions
                case(funct3)
                    FUNC_BEQ:  taken_branch = (ra == rb) ? 1'b1 : 1'b0;
                    FUNC_BNE:  taken_branch = (ra !== rb) ? 1'b1 : 1'b0;
                    FUNC_BLT:  taken_branch = ((ra < rb) ^ (ra[31] !== rb[31])) ? 1'b1 : 1'b0;
                    FUNC_BGE:  taken_branch = ((ra >= rb) ^ (ra[31] !== rb[31])) ? 1'b1 : 1'b0;
                    FUNC_BLTU: taken_branch = (ra < rb) ? 1'b1 : 1'b0;
                    FUNC_BGEU: taken_branch = (ra >= rb) ? 1'b1 : 1'b0;
                endcase
            OP_LOAD: // Load instructions
                case(funct3)
                    FUNC_LB:  alu_out = {{24{r_temp[7]}}, r_temp[7:0]};
                    FUNC_LH:  alu_out = {{16{r_temp[15]}}, r_temp[15:0]};
                    FUNC_LW:  alu_out = {r_temp[31:0]};
                    FUNC_LBU: alu_out = {{24{1'b0}}, r_temp[7:0]};
                    FUNC_LHU: alu_out = {{16{1'b0}}, r_temp[15:0]};
                endcase
            OP_STORE: // Store instructions
                case(funct3)
                    FUNC_SB: r_temp[7:0] = rb[7:0];
                    FUNC_SH: r_temp[15:0] = rb[15:0];
                    FUNC_SW: r_temp[31:0] = rb[31:0];
                endcase
            OP_OPIMM: // Arithmetic/Logic with Immediate
                case(funct3)
                    FUNC_ADDI: alu_out = ra + imm;
                    FUNC_SLTI: alu_out = (ra[31] == imm[31]) ? sltu_rslt : {{31{1'b0}}, ra[31]};
                    FUNC_SLTIU: alu_out = sltiu_rslt;
                    FUNC_XORI: alu_out = ra ^ imm;
                    FUNC_ORI:  alu_out = ra | imm;
                    FUNC_ANDI: alu_out = ra & imm;
                    FUNC_SLLI: alu_out = ra << imm[5:0];
                    FUNC_SRLI_SRAI: 
                        case(funct7[5])
                            FUNC_SRLI: alu_out = ra >> imm[5:0]; // Logical shift right
                            FUNC_SRAI: alu_out = srai_rslt[31:0]; // Arithmetic shift right
                        endcase
                endcase
            OP_OP: // Arithmetic/Logic between Registers
                case(funct3)
                    ALU_OP_ADD_SUB: 
                        case(funct7[5])
                            ALU_OP_ADD: alu_out = ra + rb;
                            ALU_OP_SUB: alu_out = ra - rb;
                        endcase
                    ALU_OP_SLL:  alu_out = ra << rb;
                    ALU_OP_SLT:  alu_out = (ra[31] == rb[31]) ? sltu_rslt : {{31{1'b0}}, ra[31]};
                    ALU_OP_SLTU: alu_out = sltu_rslt;
                    ALU_OP_XOR:  alu_out = ra ^ rb;
                    ALU_OP_SRL_SRA:
                        case(funct7[5])
                            ALU_OP_SRL: alu_out = ra >> rb;
                            ALU_OP_SRA: alu_out = sra_rslt[31:0];
                        endcase
                    ALU_OP_OR:  alu_out = ra | rb;
                    ALU_OP_AND: alu_out = ra & rb;
                endcase
        endcase
    end
    
    // Calculate Data Memory access address (DMem_addr), dropping the last 2 bits for word alignment
    assign DMem_addr = alu_out[6:2];
endmodule