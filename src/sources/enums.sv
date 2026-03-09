
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



`endif // __ENUMS_SV__