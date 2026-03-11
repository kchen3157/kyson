
`ifndef __ENUMS_SV__
`define __ENUMS_SV__


// ALU Operations
`define     ALU_OP_ADD      4'b0001
`define     ALU_OP_AND      4'b0010
`define     ALU_OP_SLT      4'b0011
`define     ALU_OP_SLTU     4'b0100
`define     ALU_OP_SLL      4'b0101
`define     ALU_OP_SRL      4'b0110
`define     ALU_OP_SRA      4'b0111
`define     ALU_OP_OR       4'b1000
`define     ALU_OP_XOR      4'b1001
`define     ALU_OP_SUB      4'b1010

// ALU Control Op
`define     ALU_CTL_LS          2'b00
`define     ALU_CTL_BRANCH      2'b01
`define     ALU_CTL_OP          2'b10
`define     ALU_CTL_OP_IMM      2'b11

// ALU 1st Operand Source
`define     ALU_SRC1_RS1        2'b00   // Set rs1 as ALU's first operand
`define     ALU_SRC1_FWEX_RS1   2'b01   // Forward result from the execute stage
`define     ALU_SRC1_FWMEM_RS1  2'b10   // Forward result from the memory stage
`define     ALU_SRC1_PC         2'b11   // Set PC as ALU's first operand

// ALU 2nd Operand Source
`define     ALU_SRC2_RS2        2'b00   // Set rs2 as ALU's second operand
`define     ALU_SRC2_IMM        2'b01   // Set immediate as ALU's second operand
`define     ALU_SRC2_FWEX_RS2   2'b10   // Forward result from the execute stage
`define     ALU_SRC2_FWMEM_RS2  2'b11   // Forward result from the memory stage

// Register rd Write Source
`define     REG_RD_WRITE_ALU    3'b000 // Write ALU result back to rd
`define     REG_RD_WRITE_MEM    3'b001 // Write memory read result back to rd
`define     REG_RD_WRITE_UI     3'b010 // Write upper immediate back to rd
`define     REG_RD_WRITE_PC_P4  3'b011 // Write PC + 4 back to rd
`define     REG_RD_WRITE_PC_IMM 3'b100 // Write PC + UI back to rd

// Jump types
`define     JUMP_NONE       2'b00
`define     JUMP_JAL        2'b01
`define     JUMP_JALR       2'b10

// Instruction OPCodes
`define     OPCODE_LOAD     7'b0000011 // lb/h/w/bu/hu
`define     OPCODE_MISCMEM  7'b0001111 // fence
`define     OPCODE_OP_IMM   7'b0010011 // addi,slli,...,andi
`define     OPCODE_AUIPC    7'b0010111 // auipc
`define     OPCODE_STORE    7'b0100011 // sb/h/w
`define     OPCODE_OP       7'b0110011 // add,sub,sll,...,and
`define     OPCODE_LUI      7'b0110111 // lui
`define     OPCODE_BRANCH   7'b1100011 // beq,bne,...,bgeu
`define     OPCODE_JALR     7'b1100111 // jalr
`define     OPCODE_JAL      7'b1101111 // jal
`define     OPCODE_SYSTEM   7'b1110011 // ecall,ebreak

// Instruction FUNCT3s
`define     FUNCT3_LB       3'b000
`define     FUNCT3_LH       3'b001
`define     FUNCT3_LW       3'b010

`define     FUNCT3_LBU      3'b100
`define     FUNCT3_LHU      3'b101

`define     FUNCT3_FENCE    3'b000
`define     FUNCT3_FENCEI   3'b001
`define     FUNCT3_ADDI     3'b000
`define     FUNCT3_SLLI     3'b001
`define     FUNCT3_SLTI     3'b010
`define     FUNCT3_SLTIU    3'b011
`define     FUNCT3_XORI     3'b100
`define     FUNCT3_SRLI_SRAI 3'b101
`define     FUNCT3_ORI      3'b110
`define     FUNCT3_ANDI     3'b111
`define     FUNCT3_AUIPC    3'b000

`define     FUNCT3_SB       3'b000
`define     FUNCT3_SH       3'b001
`define     FUNCT3_SW       3'b010

`define     FUNCT3_ADD_SUB  3'b000
`define     FUNCT3_SLL      3'b001
`define     FUNCT3_SLT      3'b010
`define     FUNCT3_SLTU     3'b011
`define     FUNCT3_XOR      3'b100
`define     FUNCT3_SRL_SRA  3'b101
`define     FUNCT3_OR       3'b110
`define     FUNCT3_AND      3'b111
`define     FUNCT3_LUI      3'b000

`define     FUNCT3_BEQ      3'b000
`define     FUNCT3_BNE      3'b001
`define     FUNCT3_BLT      3'b100
`define     FUNCT3_BGE      3'b101
`define     FUNCT3_BLTU     3'b110
`define     FUNCT3_BGEU     3'b111
`define     FUNCT3_JALR     3'b000
`define     FUNCT3_JAL      3'b000
`define     FUNCT3_ECALL    3'b000
`define     FUNCT3_EBREAK   3'b000
`define     FUNCT3_CSRRW    3'b001
`define     FUNCT3_CSRRS    3'b010
`define     FUNCT3_CSRRC    3'b011
`define     FUNCT3_CSRRWI   3'b101
`define     FUNCT3_CSRRSI   3'b110
`define     FUNCT3_CSRRCI   3'b111

// Instruction FUNCT7s/IMM (nonzero)
`define     FUNCT7_SRAI     7'b0100000
`define     FUNCT7_SUB      7'b0100000
`define     FUNCT7_SRA      7'b0100000
`define     FUNCT7_EBREAK   12'h001



`endif // __ENUMS_SV__