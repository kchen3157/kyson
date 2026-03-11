`timescale 1 ns/10 ps

`include "enums.sv"

module core
    (
        input   logic i_clk, i_rst,

        // instruction memory
        output  logic [31:0] o_imem_addr,
        input   logic [31:0] i_imem_data,

        // data memory
        output  logic [31:0] o_dmem_addr,
        output  logic [31:0] o_dmem_write_data,
        input   logic [31:0] i_dmem_read_data,
        output  logic o_dmem_write_en,
        output  logic o_dmem_read_en
    );

    // PC register signals
    logic [31:0] r_pc, w_pc_next;
    logic [31:0] w_pc_p4;
    logic [31:0] w_pc_imm;

    // Split the instruction
    logic [6:0] w_opcode;
    logic [4:0] w_rs1, w_rs2, w_rd;
    logic [2:0] w_funct3;
    logic [6:0] w_funct7;

    // Core ctl module signals
    logic w_branch;
    logic w_mem_read_en;
    logic [2:0] w_reg_write_src;
    logic [1:0] w_aluctl_op;
    logic w_mem_write_en;
    logic [1:0] w_alu_src;
    logic w_reg_write_en;

    // ALU module signals
    logic [3:0] w_alu_op;
    logic [31:0] w_alu_b;
    logic [31:0] w_alu_result;
    logic w_alu_result_eqz;

    // Register module signals
    logic [31:0] w_rs1_data, w_rs2_data;
    logic [31:0] w_rd_data;

    // Immediate
    logic [31:0] w_imm;

    // Branch Logic
    logic w_branch_cond_base;
    logic w_take_branch;

    // Instruction field extraction
    assign w_opcode = i_imem_data[6:0];
    assign w_rd = i_imem_data[11:7];
    assign w_funct3 = i_imem_data[14:12];
    assign w_rs1 = i_imem_data[19:15];
    assign w_rs2 = i_imem_data[24:20];
    assign w_funct7 = i_imem_data[31:25];

    // PC register instantiation
    always_ff @(posedge i_clk, posedge i_rst)
    begin
        if (i_rst)
        begin
            r_pc <= 32'h0;
        end
        else
        begin
            r_pc <= w_pc_next;
        end
    end
    assign o_imem_addr = r_pc;

    // Next PC logic
    always_comb
    begin
        if (w_opcode == `OPCODE_JALR)
        begin
            w_pc_next = {w_alu_result[31:1], 1'b0};
        end
        else if (w_take_branch || (w_opcode == `OPCODE_JAL))
        begin
            w_pc_next = r_pc + w_imm;
        end
        else
        begin
            w_pc_next = r_pc + 32'h4;
        end
    end

    // Branch taken logic
    always_comb
    begin
        w_take_branch = 1'b0;
        if (w_branch)
        begin
            // [ALU Calculation]
            case (w_funct3)
                `FUNCT3_BEQ: // [rs1 - rs2] == 0
                    w_take_branch = w_alu_result_eqz;
                `FUNCT3_BNE: // [rs1 - rs2] != 0
                    w_take_branch = w_alu_result[0];
                `FUNCT3_BLT: // signed[rs1 < rs2] == 0
                    w_take_branch = w_alu_result_eqz;
                `FUNCT3_BGE: // signed[rs1 < rs2] != 0
                    w_take_branch = w_alu_result[0];
                `FUNCT3_BLTU: // [rs1 < rs2] == 0
                    w_take_branch = w_alu_result_eqz;
                `FUNCT3_BGEU: // [rs1 < rs2] != 0
                    w_take_branch = w_alu_result[0];
                default:
                    w_take_branch = 1'b0;
            endcase
        end
    end

    // ALU B input logic
    always_comb
    begin
        if (w_alu_src == `ALU_SRC2_IMM)
            w_alu_b = w_imm;
        else // ALU_SRC2_RS2
            w_alu_b = w_rs2_data;
    end

    // rd write data mux
    always_comb
    begin
        case (w_reg_write_src)
            `REG_RD_WRITE_ALU:
                w_rd_data = w_alu_result;
            `REG_RD_WRITE_MEM:
                w_rd_data = i_dmem_read_data;
            `REG_RD_WRITE_UI:
                w_rd_data = w_imm;
            `REG_RD_WRITE_PC_P4:
                w_rd_data = w_pc_p4;
            `REG_RD_WRITE_PC_IMM:
                w_rd_data = w_pc_imm;
            default: 
                w_rd_data = 32'hX;
        endcase
    end

    // Data memory outputs
    assign o_dmem_addr   = w_alu_result;
    assign o_dmem_write_data  = w_rs2_data;
    assign o_dmem_read_en    = w_mem_read_en;
    assign o_dmem_write_en    = w_mem_write_en;

    core_ctl u_core_ctl (
        .i_inst          (i_imem_data),
        .o_branch        (w_branch),
        .o_mem_read_en   (w_mem_read_en),
        .o_reg_write_src (w_reg_write_src),
        .o_aluctl_op     (w_aluctl_op),
        .o_mem_write_en  (w_mem_write_en),
        .o_alu_src       (w_alu_src),
        .o_reg_write_en  (w_reg_write_en)
    );

    imm_gen u_imm_gen (
        .i_inst (i_imem_data),
        .o_imm  (w_imm)
    );

    regs u_regs (
        .i_clk         (i_clk),
        .i_rst         (i_rst),
        .i_rd_write_en (w_reg_write_en),
        .i_addr_rs1    (w_rs1),
        .i_addr_rs2    (w_rs2),
        .i_addr_rd     (w_rd),
        .i_data_rd     (w_rd_data),
        .o_data_rs1    (w_rs1_data),
        .o_data_rs2    (w_rs2_data)
    );

    alu_ctl u_alu_ctl (
        .i_aluctl_op (w_aluctl_op),
        .i_funct3    (w_funct3),
        .i_funct7    (w_funct7),
        .o_alu_op    (w_alu_op)
    );

    alu u_alu (
        .i_alu_op     (w_alu_op),
        .i_a          (w_rs1_data),
        .i_b          (w_alu_b),
        .o_result     (w_alu_result),
        .o_result_eqz (w_alu_result_eqz)
    );

endmodule
