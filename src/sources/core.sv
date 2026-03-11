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
    logic [4:0] w_rs1, w_rs2, w_rd;
    logic [2:0] w_funct3;
    logic [6:0] w_funct7;

    // Core ctl module signals
    logic w_branch;
    logic [1:0] w_jump;
    logic w_mem_read_en;
    logic [2:0] w_reg_write_src;
    logic [1:0] w_aluctl_op;
    logic w_mem_write_en;
    logic w_alu_src1;
    logic w_alu_src2;
    logic w_reg_write_en;

    // ALU module signals
    logic [3:0] w_alu_op;
    logic [31:0] w_alu_a, w_alu_b;
    logic [31:0] w_alu_result;
    logic w_alu_result_eqz;

    // Register module signals
    logic [31:0] w_rs1_data, w_rs2_data;
    logic [31:0] w_rd_data;

    // Immediate
    logic [31:0] w_imm;

    // Branch Logic
    logic w_take_branch;

    // ********** Stage register signal declarations **********
    // Signals from IF stage
    logic [31:0] r_pc_IF, w_pc_IF_next;
    logic [31:0] r_inst_IF, w_inst_IF_next;

    // Signals from ID stage
    logic [31:0] r_pc_ID, w_pc_ID_next;
    logic [31:0] r_rs1_data_ID, w_rs1_data_ID_next;
    logic [31:0] r_rs2_data_ID, w_rs2_data_ID_next;
    logic [4:0] r_rd_ID, w_rd_ID_next;
    logic [31:0] r_imm_ID, w_imm_ID_next;
    logic [2:0] r_funct3_ID, w_funct3_ID_next;

    logic [1:0] r_aluctl_op_ID, w_aluctl_op_ID_next;
    logic r_alu_src1_ID, w_alu_src1_ID_next;
    logic r_alu_src2_ID, w_alu_src2_ID_next;
    logic [1:0] r_jump_ID, w_jump_ID_next;
    logic r_branch_ID, w_branch_ID_next;
    logic r_mem_read_en_ID, w_mem_read_en_ID_next;
    logic r_mem_write_en_ID, w_mem_write_en_ID_next;
    logic r_reg_write_en_ID, w_reg_write_en_ID_next;
    logic [2:0] r_reg_write_src_ID, w_reg_write_src_ID_next;
    

    // Signals from EX stage
    logic [31:0] r_alu_result_EX, w_alu_result_EX_next;
    logic [31:0] r_rs2_data_EX, w_rs2_data_EX_next;
    logic [4:0] r_rd_EX, w_rd_EX_next;

    logic [1:0] r_jump_EX, w_jump_EX_next;
    logic r_branch_EX, w_branch_EX_next;
    logic r_mem_read_en_EX, w_mem_read_en_EX_next;
    logic r_mem_write_en_EX, w_mem_write_en_EX_next;
    logic r_reg_write_en_EX, w_reg_write_en_EX_next;
    logic [2:0] r_reg_write_src_EX, w_reg_write_src_EX_next;

    // Signals from MEM stage
    logic [31:0] r_alu_result_MEM, w_alu_result_MEM_next;
    logic [31:0] r_mem_read_data, w_mem_read_data_next;
    logic [4:0] r_rd_MEM, w_rd_MEM_next;

    logic r_reg_write_en_MEM, w_reg_write_en_MEM_next;
    logic [2:0] r_reg_write_src_MEM, w_reg_write_src_MEM_next;

    // ********** Stage register next assignments **********
    // Signals from IF stage
    assign w_pc_IF_next = r_pc;
    assign w_inst_IF_next = i_imem_data;

    // Signals from ID stage
    assign w_rs1_data_ID_next = w_rs1_data;
    assign w_rs2_data_ID_next = w_rs2_data;

    assign w_pc_ID_next = r_pc_IF;
    assign w_rd_ID_next = r_inst_IF[11:7];
    assign w_funct3_ID_next = r_inst_IF[14:12];
    assign w_imm_ID_next = w_imm;

    assign w_aluctl_op_ID_next = w_aluctl_op;
    assign w_alu_src1_ID_next = w_alu_src1;
    assign w_alu_src2_ID_next = w_alu_src2;
    assign w_jump_ID_next = w_jump;
    assign w_branch_ID_next = w_branch;
    assign w_mem_read_en_ID_next = w_mem_read_en;
    assign w_mem_write_en_ID_next = w_mem_write_en;
    assign w_reg_write_en_ID_next = w_reg_write_en;
    assign w_reg_write_src_ID_next = w_reg_write_src;

    // Signals from EX stage

    assign w_alu_result_EX_next = w_alu_result;

    assign w_rs2_data_EX_next = r_rs2_data_ID;
    assign w_rd_EX_next = r_rd_ID;

    assign w_jump_EX_next = r_jump_ID;
    assign w_branch_EX_next = r_branch_ID;
    assign w_mem_read_en_EX_next = r_mem_read_en_ID;
    assign w_mem_write_en_EX_next = r_mem_write_en_ID;
    assign w_reg_write_en_EX_next = r_reg_write_en_ID;
    assign w_reg_write_src_EX_next = r_reg_write_src_ID;

    // Signals from MEM stage
    assign w_mem_read_data_next = i_dmem_read_data;

    assign w_alu_result_MEM_next = r_alu_result_EX;
    assign w_rd_MEM_next = r_rd_EX;

    assign w_reg_write_en_MEM_next  = r_reg_write_en_EX;
    assign w_reg_write_src_MEM_next = r_reg_write_src_EX;

    // ********** Stage registers **********

    always_ff @(posedge i_clk, posedge i_rst)
    begin
        if (i_rst)
        begin
            r_pc_IF   <= 32'h0;
            r_inst_IF <= 32'h0;
        end
        else
        begin
            r_pc_IF   <= w_pc_IF_next;
            r_inst_IF <= w_inst_IF_next;
        end
    end

    // ID/EX
    always_ff @(posedge i_clk, posedge i_rst)
    begin
        if (i_rst)
        begin
            r_pc_ID             <= 32'h0;
            r_rs1_data_ID       <= 32'h0;
            r_rs2_data_ID       <= 32'h0;
            r_rd_ID             <= 5'h0;
            r_funct3_ID         <= 3'h0;
            r_imm_ID            <= 32'h0;
            r_aluctl_op_ID      <= `ALU_CTL_LS;
            r_alu_src1_ID       <= `ALU_SRC1_RS1;
            r_alu_src2_ID       <= `ALU_SRC2_RS2;
            r_jump_ID           <= `JUMP_NONE;
            r_branch_ID         <= 1'b0;
            r_mem_read_en_ID    <= 1'b0;
            r_mem_write_en_ID   <= 1'b0;
            r_reg_write_en_ID   <= 1'b0;
            r_reg_write_src_ID  <= `REG_RD_WRITE_ALU;
        end
        else
        begin
            r_pc_ID             <= w_pc_ID_next;
            r_rs1_data_ID       <= w_rs1_data_ID_next;
            r_rs2_data_ID       <= w_rs2_data_ID_next;
            r_rd_ID             <= w_rd_ID_next;
            r_funct3_ID         <= w_funct3_ID_next;
            r_imm_ID            <= w_imm_ID_next;
            r_aluctl_op_ID      <= w_aluctl_op_ID_next;
            r_alu_src1_ID       <= w_alu_src1_ID_next;
            r_alu_src2_ID       <= w_alu_src2_ID_next;
            r_jump_ID           <= w_jump_ID_next;
            r_branch_ID         <= w_branch_ID_next;
            r_mem_read_en_ID    <= w_mem_read_en_ID_next;
            r_mem_write_en_ID   <= w_mem_write_en_ID_next;
            r_reg_write_en_ID   <= w_reg_write_en_ID_next;
            r_reg_write_src_ID  <= w_reg_write_src_ID_next;
        end
    end

    // EX/MEM
    always_ff @(posedge i_clk, posedge i_rst)
    begin
        if (i_rst)
        begin
            r_alu_result_EX     <= 32'h0;
            r_rs2_data_EX       <= 32'h0;
            r_rd_EX             <= 5'h0;
            r_jump_EX           <= `JUMP_NONE;
            r_branch_EX         <= 1'b0;
            r_mem_read_en_EX    <= 1'b0;
            r_mem_write_en_EX   <= 1'b0;
            r_reg_write_en_EX   <= 1'b0;
            r_reg_write_src_EX  <= `REG_RD_WRITE_ALU;
        end
        else
        begin
            r_alu_result_EX     <= w_alu_result_EX_next;
            r_rs2_data_EX       <= w_rs2_data_EX_next;
            r_rd_EX             <= w_rd_EX_next;
            r_jump_EX           <= w_jump_EX_next;
            r_branch_EX         <= w_branch_EX_next;
            r_mem_read_en_EX    <= w_mem_read_en_EX_next;
            r_mem_write_en_EX   <= w_mem_write_en_EX_next;
            r_reg_write_en_EX   <= w_reg_write_en_EX_next;
            r_reg_write_src_EX  <= w_reg_write_src_EX_next;
        end
    end

    // MEM/WB
    always_ff @(posedge i_clk, posedge i_rst)
    begin
        if (i_rst)
        begin
            r_alu_result_MEM    <= 32'h0;
            r_mem_read_data     <= 32'h0;
            r_rd_MEM            <= 5'h0;
            r_reg_write_en_MEM  <= 1'b0;
            r_reg_write_src_MEM <= `REG_RD_WRITE_ALU;
        end
        else
        begin
            r_alu_result_MEM    <= w_alu_result_MEM_next;
            r_mem_read_data     <= w_mem_read_data_next;
            r_rd_MEM            <= w_rd_MEM_next;
            r_reg_write_en_MEM  <= w_reg_write_en_MEM_next;
            r_reg_write_src_MEM <= w_reg_write_src_MEM_next;
        end
    end

    // Instruction field extraction
    assign w_rd = i_imem_data[11:7];
    assign w_funct3 = i_imem_data[14:12];
    assign w_rs1 = i_imem_data[19:15];
    assign w_rs2 = i_imem_data[24:20];
    assign w_funct7 = i_imem_data[31:25];

    // PC register
    always_ff @(posedge i_clk, posedge i_rst)
    begin
        if (i_rst)
            r_pc <= 32'h0;
        else
            r_pc <= w_pc_next;
    end
    assign o_imem_addr = r_pc;
    assign w_pc_p4  = r_pc + 32'h4;
    assign w_pc_imm = r_pc + w_imm;

    // Next PC logic
    always_comb
    begin
        if (w_jump == `JUMP_JALR)
            w_pc_next = {w_alu_result[31:1], 1'b0};
        else if (w_take_branch || (w_jump == `JUMP_JAL))
            w_pc_next = w_pc_imm;
        else
            w_pc_next = w_pc_p4;
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

    // ALU input muxes
    assign w_alu_a = (w_alu_src1 == `ALU_SRC1_PC) ? r_pc : w_rs1_data;
    assign w_alu_b = (w_alu_src2 == `ALU_SRC2_IMM) ? w_imm : w_rs2_data;

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
    assign o_dmem_addr        = w_alu_result;
    assign o_dmem_write_data  = w_rs2_data;
    assign o_dmem_read_en     = w_mem_read_en;
    assign o_dmem_write_en    = w_mem_write_en;

    core_ctl u_core_ctl (
        .i_inst          (i_imem_data),
        .o_branch        (w_branch),
        .o_jump          (w_jump),
        .o_mem_read_en   (w_mem_read_en),
        .o_mem_write_en  (w_mem_write_en),
        .o_reg_write_en  (w_reg_write_en),
        .o_reg_write_src (w_reg_write_src),
        .o_aluctl_op     (w_aluctl_op),
        .o_alu_src1      (w_alu_src1),
        .o_alu_src2      (w_alu_src2)
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
        .i_a          (w_alu_a),
        .i_b          (w_alu_b),
        .o_result     (w_alu_result),
        .o_result_eqz (w_alu_result_eqz)
    );

endmodule
