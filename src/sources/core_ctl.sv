`timescale 1 ns/10 ps

`include "enums.sv"

module core_ctl
    (
        input   logic [31:0] i_inst,

        // Consumed @ EX
        output  logic [1:0] o_aluctl_op, // alu operation (ALU_CTL_XXX)
        output  logic o_alu_src1, // ALU input A: rs1 (0) or PC (1)
        output  logic o_alu_src2, // ALU input B: rs2 (0) or immediate (1)

        output  logic [1:0] o_jump, // type of jump
        output  logic o_branch, // this is a branch type instruction

        // Consumed @ MEM
        output  logic o_mem_read_en, // whether to read data memory
        output  logic o_mem_write_en, // whether to write to data memory

        // Consumed @ WB
        output  logic o_reg_write_en, // whether to write to register
        output  logic [2:0] o_reg_write_src // what to write to rd (REG_RD_WRITE_XXX)
        
    );

    logic [6:0] w_opcode;
    assign w_opcode = i_inst[6:0];

    always_comb
    begin
        o_branch = 1'b0;
        o_mem_read_en = 1'b0;
        o_reg_write_src = `REG_RD_WRITE_ALU;
        o_aluctl_op = `ALU_CTL_LS;
        o_mem_write_en = 1'b0;
        o_alu_src1 = `ALU_SRC1_RS1;
        o_alu_src2 = `ALU_SRC2_RS2;
        o_reg_write_en = 1'b0;
        o_jump = `JUMP_NONE;
        case (w_opcode)
            `OPCODE_LOAD:
            begin
                o_mem_read_en = 1'b1;
                o_reg_write_src = `REG_RD_WRITE_MEM;
                o_alu_src2 = `ALU_SRC2_IMM;
                o_reg_write_en = 1'b1;
            end
            `OPCODE_MISCMEM:
            begin
                
            end
            `OPCODE_OP_IMM:
            begin
                o_aluctl_op = `ALU_CTL_OP_IMM;
                o_alu_src2 = `ALU_SRC2_IMM;
                o_reg_write_en = 1'b1;
            end
            `OPCODE_AUIPC: 
            begin
                o_reg_write_en = 1'b1;
                o_reg_write_src = `REG_RD_WRITE_PC_IMM;
                o_alu_src1 = `ALU_SRC1_PC;
            end
            `OPCODE_STORE: 
            begin
                o_mem_write_en = 1'b1;
                o_alu_src2 = `ALU_SRC2_IMM;
            end 
            `OPCODE_OP:  
            begin
                o_aluctl_op = `ALU_CTL_OP;
                o_reg_write_en = 1'b1;
            end   
            `OPCODE_LUI:
            begin
                o_reg_write_en = 1'b1;
                o_reg_write_src = `REG_RD_WRITE_UI;
            end
            `OPCODE_BRANCH: 
            begin
                o_branch = 1'b1;
                o_aluctl_op = `ALU_CTL_BRANCH;
            end
            `OPCODE_JALR:
            begin
                o_reg_write_en = 1'b1;
                o_reg_write_src = `REG_RD_WRITE_PC_P4;
                o_alu_src2 = `ALU_SRC2_IMM;
                o_jump = `JUMP_JALR;
            end  
            `OPCODE_JAL:
            begin
                o_reg_write_en = 1'b1;
                o_reg_write_src = `REG_RD_WRITE_PC_P4;
                o_jump = `JUMP_JAL;
            end  
            `OPCODE_SYSTEM:
            begin
                
            end
            default:
            begin
                o_branch = 1'bX;
                o_jump = 2'bX;
                o_mem_read_en = 1'bX;
                o_reg_write_src = 3'bX;
                o_aluctl_op = 2'bX;
                o_mem_write_en = 1'bX;
                o_alu_src1 = 1'bX;
                o_alu_src2 = 1'bX;
                o_reg_write_en = 1'bX;
            end
        endcase
    end

endmodule