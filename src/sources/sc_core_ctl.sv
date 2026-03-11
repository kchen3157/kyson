`timescale 1 ns/10 ps

`include "enums.sv"

module sc_core_ctl
    (
        input   logic [31:0] i_inst,

        output  logic o_branch, // this is a branch type instruction
        output  logic o_mem_read_en, // whether to read data memory
        output  logic [2:0] o_reg_write_src, // what to write to rd (REG_RD_WRITE_XXX)
        output  logic [1:0] o_aluctl_op, // alu operation (ALU_CTL)
        output  logic o_mem_write_en, // whether to write to data memory
        output  logic [1:0] o_alu_src, // switch between immediate (1) and rs2 (0) for alu input 2
        output  logic o_reg_write_en // whether to write to register
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
        o_alu_src = `ALU_SRC2_RS2;
        o_reg_write_en = 1'b0;
        case (w_opcode)
            `OPCODE_LOAD:
            begin
                o_mem_read_en = 1'b1;
                o_reg_write_src = `REG_RD_WRITE_MEM;
                o_alu_src = `ALU_SRC2_IMM;
                o_reg_write_en = 1'b1;
            end
            `OPCODE_MISCMEM:
            begin
                
            end
            `OPCODE_OP_IMM:
            begin
                o_aluctl_op = `ALU_CTL_OP_IMM;
                o_alu_src = `ALU_SRC2_IMM;
                o_reg_write_en = 1'b1;
            end
            `OPCODE_AUIPC: 
            begin
                o_reg_write_en = 1'b1;
                o_reg_write_src = `REG_RD_WRITE_PC_IMM;
            end
            `OPCODE_STORE: 
            begin
                o_mem_write_en = 1'b1;
                o_alu_src = `ALU_SRC2_IMM;
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
                o_alu_src = `ALU_SRC2_IMM;
            end  
            `OPCODE_JAL:
            begin
                o_reg_write_en = 1'b1;
                o_reg_write_src = `REG_RD_WRITE_PC_P4;
            end  
            `OPCODE_SYSTEM:
            begin
                
            end
            default:
            begin
                o_branch = 1'bX;
                o_mem_read_en = 1'bX;
                o_reg_write_src = 1'bX;
                o_aluctl_op = 2'hX;
                o_mem_write_en = 1'bX;
                o_alu_src = 1'bX;
                o_reg_write_en = 1'bX;
            end
        endcase
    end

endmodule