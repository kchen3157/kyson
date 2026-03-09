`include "enums.sv"

module alu_ctl
    (
        input   logic [1:0] i_aluctl_op,
        input   logic [2:0] i_funct3,
        input   logic [6:0] i_funct7,

        output  logic [3:0] o_alu_op
    );

    logic [3:0] w_op_op, w_branch_op;
    logic [3:0] w_alt_op, w_alt_imm_op; // for when FUNCT7[5] = 1

    always_comb
    begin
        case (i_aluctl_op)
            `ALU_CTL_LS:
                o_alu_op = `ALU_OP_ADD;
            `ALU_CTL_BRANCH:
                o_alu_op = w_branch_op;
            `ALU_CTL_OP:
            begin
                if (i_funct7[5] == 1'b1)
                    o_alu_op = w_alt_op;
                else
                    o_alu_op = w_op_op;
            end
            `ALU_CTL_OP_IMM:
            begin
                if ((i_funct7[5] == 1'b1) && (i_funct3 == `FUNCT3_SRL_SRA))
                    o_alu_op = w_alt_imm_op;
                else
                    o_alu_op = w_op_op;
            end
            default:
                o_alu_op = 4'hX;
        endcase
    end

    // Secondary functions when FUNCT7 is nonzero
    always_comb
    begin
        case (i_funct3)
            `FUNCT3_ADD_SUB:
            begin
                w_alt_op = `ALU_OP_SUB;
                w_alt_imm_op = `ALU_OP_ADD;
            end
            `FUNCT3_SRL_SRA:
            begin
                w_alt_op = `ALU_OP_SRA;
                w_alt_imm_op = `ALU_OP_SRA;
            end
            default:
            begin
                w_alt_op = 4'hX;
                w_alt_imm_op = 4'hX;
            end
        endcase
    end

    // For branch functions
    always_comb
    begin
        case (i_funct3)
            `FUNCT3_BEQ:
                w_branch_op = `ALU_OP_SUB;
            `FUNCT3_BNE:
                w_branch_op = `ALU_OP_SUB;
            `FUNCT3_BLT:
                w_branch_op = `ALU_OP_SLT;
            `FUNCT3_BGE:
                w_branch_op = `ALU_OP_SLT;
            `FUNCT3_BLTU:
                w_branch_op = `ALU_OP_SLTU;
            `FUNCT3_BGEU:
                w_branch_op = `ALU_OP_SLTU;
            default:
                w_branch_op = 4'hX;
        endcase
    end

    // For operation functions
    always_comb
    begin
        case (i_funct3)
            `FUNCT3_ADD_SUB:
                w_op_op = `ALU_OP_ADD;
            `FUNCT3_SLL:
                w_op_op = `ALU_OP_SLL;  
            `FUNCT3_SLT:
                w_op_op = `ALU_OP_SLT;
            `FUNCT3_SLTU:
                w_op_op = `ALU_OP_SLTU;
            `FUNCT3_XOR:
                w_op_op = `ALU_OP_XOR;
            `FUNCT3_SRL_SRA:
                w_op_op = `ALU_OP_SRL;
            `FUNCT3_OR:
                w_op_op = `ALU_OP_OR;  
            `FUNCT3_AND:
                w_op_op = `ALU_OP_AND;
            default:
                w_op_op = 4'hX;
        endcase
    end


endmodule