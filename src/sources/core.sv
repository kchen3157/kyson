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
        output  logic [3:0]  o_dmem_byte_en,
        input   logic [31:0] i_dmem_read_data,
        output  logic o_dmem_write_en,
        output  logic o_dmem_read_en
    );

    // PC register signals
    logic [31:0] r_pc, w_pc_next;

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

    // Extra signal to enable forwarding from EX to EX
    // This is the final signal that is written by the instruction
    logic [31:0] w_forward_ex_val;

    // Hazard signals
    logic [1:0] w_alu_rs1_fw;
    logic [1:0] w_alu_rs2_fw;
    logic w_insert_nop;
    logic w_flush;        
    logic w_flush_branch;  // flush from hazard unit (branch taken)

    // Intermediate signals for loads and subword loads
    logic [31:0] w_load_data;
    logic [7:0] w_load_byte;
    logic [15:0] w_load_half;

    // ********** Stage register signal declarations **********
    // Signals from IF stage
    logic [31:0] r_pc_IF, w_pc_IF_next;
    logic [31:0] r_inst_IF, w_inst_IF_next;

    // Signals from ID stage
    logic [31:0] r_pc_ID, w_pc_ID_next;
    logic [31:0] r_rs1_data_ID, w_rs1_data_ID_next;
    logic [31:0] r_rs2_data_ID, w_rs2_data_ID_next;
    logic [4:0] r_rs1_ID, w_rs1_ID_next;
    logic [4:0] r_rs2_ID, w_rs2_ID_next;
    logic [4:0] r_rd_ID, w_rd_ID_next;
    logic [31:0] r_imm_ID, w_imm_ID_next;
    logic [2:0] r_funct3_ID, w_funct3_ID_next;
    logic [6:0] r_funct7_ID, w_funct7_ID_next;

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
    logic [31:0] r_imm_EX, w_imm_EX_next;
    logic [31:0] r_pc_p4_EX, w_pc_p4_EX_next;
    logic [4:0] r_rd_EX, w_rd_EX_next;
    logic [2:0] r_funct3_EX, w_funct3_EX_next;

    logic [1:0] r_jump_EX, w_jump_EX_next;
    logic r_branch_EX, w_branch_EX_next;
    logic r_mem_read_en_EX, w_mem_read_en_EX_next;
    logic r_mem_write_en_EX, w_mem_write_en_EX_next;
    logic r_reg_write_en_EX, w_reg_write_en_EX_next;
    logic [2:0] r_reg_write_src_EX, w_reg_write_src_EX_next;

    // Signals from MEM stage
    logic [31:0] r_alu_result_MEM, w_alu_result_MEM_next;
    logic [31:0] r_mem_read_data, w_mem_read_data_next;
    logic [31:0] r_imm_MEM, w_imm_MEM_next;
    logic [31:0] r_pc_p4_MEM, w_pc_p4_MEM_next;
    logic [4:0] r_rd_MEM, w_rd_MEM_next;
    logic [2:0] r_funct3_MEM, w_funct3_MEM_next;

    logic r_reg_write_en_MEM, w_reg_write_en_MEM_next;
    logic [2:0] r_reg_write_src_MEM, w_reg_write_src_MEM_next;

    // ********** Stage register next assignments **********
    // Signals from IF stage
    always_comb
    begin
        w_pc_IF_next = r_pc;
        w_inst_IF_next = i_imem_data;
        if (w_flush)
        begin
            w_pc_IF_next = 32'h0;
            w_inst_IF_next = 32'h0;
        end
        else if (w_insert_nop)
        begin
            w_pc_IF_next = r_pc_IF;
            w_inst_IF_next = r_inst_IF;
        end
    end

    // Signals from ID stage
    assign w_rs1_data_ID_next = w_rs1_data;
    assign w_rs2_data_ID_next = w_rs2_data;
    assign w_rs1_ID_next = w_rs1;
    assign w_rs2_ID_next = w_rs2;

    assign w_pc_ID_next = r_pc_IF;
    assign w_rd_ID_next = r_inst_IF[11:7];
    assign w_funct3_ID_next = r_inst_IF[14:12];
    assign w_funct7_ID_next = r_inst_IF[31:25];
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

    // Forwarding for store instructions
    always_comb
    begin
        w_rs2_data_EX_next = r_rs2_data_ID;
        if (w_alu_rs2_fw == `RS2_FORWARD_EX)
            w_rs2_data_EX_next = w_forward_ex_val;
        else if (w_alu_rs2_fw == `RS2_FORWARD_MEM)
            w_rs2_data_EX_next = w_rd_data;
    end
    assign w_imm_EX_next = r_imm_ID;
    assign w_pc_p4_EX_next = r_pc_ID + 32'h4;
    assign w_rd_EX_next = r_rd_ID;
    assign w_funct3_EX_next = r_funct3_ID;

    assign w_jump_EX_next = r_jump_ID;
    assign w_branch_EX_next = r_branch_ID;
    assign w_mem_read_en_EX_next = r_mem_read_en_ID;
    assign w_mem_write_en_EX_next = r_mem_write_en_ID;
    assign w_reg_write_en_EX_next = r_reg_write_en_ID;
    assign w_reg_write_src_EX_next = r_reg_write_src_ID;

    // Signals from MEM stage
    assign w_mem_read_data_next = i_dmem_read_data;

    assign w_alu_result_MEM_next = r_alu_result_EX;
    assign w_imm_MEM_next = r_imm_EX;
    assign w_pc_p4_MEM_next = r_pc_p4_EX;
    assign w_rd_MEM_next = r_rd_EX;
    assign w_funct3_MEM_next = r_funct3_EX;

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
        if (i_rst | w_insert_nop | w_flush)
        begin
            r_pc_ID             <= 32'h0;
            r_rs1_data_ID       <= 32'h0;
            r_rs2_data_ID       <= 32'h0;
            r_rs1_ID            <= 5'h0;
            r_rs2_ID            <= 5'h0;
            r_rd_ID             <= 5'h0;
            r_funct3_ID         <= 3'h0;
            r_funct7_ID         <= 7'h0;
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
            r_rs1_ID            <= w_rs1_ID_next;
            r_rs2_ID            <= w_rs2_ID_next;
            r_rd_ID             <= w_rd_ID_next;
            r_funct3_ID         <= w_funct3_ID_next;
            r_funct7_ID         <= w_funct7_ID_next;
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
            r_imm_EX            <= 32'h0;
            r_pc_p4_EX          <= 32'h0;
            r_rd_EX             <= 5'h0;
            r_funct3_EX         <= 3'h0;
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
            r_imm_EX            <= w_imm_EX_next;
            r_pc_p4_EX          <= w_pc_p4_EX_next;
            r_rd_EX             <= w_rd_EX_next;
            r_funct3_EX         <= w_funct3_EX_next;
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
            r_imm_MEM           <= 32'h0;
            r_pc_p4_MEM         <= 32'h0;
            r_rd_MEM            <= 5'h0;
            r_funct3_MEM        <= 3'h0;
            r_reg_write_en_MEM  <= 1'b0;
            r_reg_write_src_MEM <= `REG_RD_WRITE_ALU;
        end
        else
        begin
            r_alu_result_MEM    <= w_alu_result_MEM_next;
            r_mem_read_data     <= w_mem_read_data_next;
            r_imm_MEM           <= w_imm_MEM_next;
            r_pc_p4_MEM         <= w_pc_p4_MEM_next;
            r_rd_MEM            <= w_rd_MEM_next;
            r_funct3_MEM        <= w_funct3_MEM_next;
            r_reg_write_en_MEM  <= w_reg_write_en_MEM_next;
            r_reg_write_src_MEM <= w_reg_write_src_MEM_next;
        end
    end

    // Instruction field extraction (ID)
    assign w_rd = r_inst_IF[11:7];
    assign w_funct3 = r_inst_IF[14:12];
    assign w_rs1 = r_inst_IF[19:15];
    assign w_rs2 = r_inst_IF[24:20];
    assign w_funct7 = r_inst_IF[31:25];

    // PC register (IF)
    always_ff @(posedge i_clk, posedge i_rst)
    begin
        if (i_rst)
            r_pc <= 32'h0;
        else
            r_pc <= w_pc_next;
    end
    assign o_imem_addr = r_pc;

    // Next PC logic (EX)
    always_comb
    begin
        if (w_insert_nop)
            w_pc_next = r_pc;
        else if (r_jump_ID == `JUMP_JALR)
            w_pc_next = {w_alu_result[31:1], 1'b0};
        else if (w_take_branch || (r_jump_ID == `JUMP_JAL))
            w_pc_next = r_pc_ID + r_imm_ID;
        else
            w_pc_next = r_pc + 32'h4;
    end

    // Branch taken logic (EX)
    always_comb
    begin
        w_take_branch = 1'b0;
        if (r_branch_ID)
        begin
            // [ALU Calculation]
            case (r_funct3_ID)
                `FUNCT3_BEQ: // [rs1 - rs2] == 0
                    w_take_branch = w_alu_result_eqz;
                `FUNCT3_BNE: // [rs1 - rs2] != 0
                    w_take_branch = ~w_alu_result_eqz;
                `FUNCT3_BLT: // signed[rs1 < rs2] == 0
                    w_take_branch = w_alu_result[0];
                `FUNCT3_BGE: // signed[rs1 < rs2] != 0
                    w_take_branch = ~w_alu_result[0];
                `FUNCT3_BLTU: // [rs1 < rs2] == 0
                    w_take_branch = w_alu_result[0];
                `FUNCT3_BGEU: // [rs1 < rs2] != 0
                    w_take_branch = ~w_alu_result[0];
                default:
                    w_take_branch = 1'b0;
            endcase
        end
    end

    // ALU input
    always_comb
    begin
        w_alu_a = r_rs1_data_ID;
        w_alu_b = r_rs2_data_ID;

        if (r_alu_src1_ID == `ALU_SRC1_PC)
            w_alu_a = r_pc_ID;
        else if (w_alu_rs1_fw == `RS1_FORWARD_EX)
            w_alu_a = w_forward_ex_val;
        else if (w_alu_rs1_fw == `RS1_FORWARD_MEM)
            w_alu_a = w_rd_data;

        if (r_alu_src2_ID == `ALU_SRC2_IMM)
            w_alu_b = r_imm_ID;
        else if (w_alu_rs2_fw == `RS2_FORWARD_EX)
            w_alu_b = w_forward_ex_val;
        else if (w_alu_rs2_fw == `RS2_FORWARD_MEM)
            w_alu_b = w_rd_data;
    end

    // Actual value written by instruction for forwarding EX to EX
    always_comb
    begin
        case (r_reg_write_src_EX)
            `REG_RD_WRITE_UI:
                w_forward_ex_val = r_imm_EX;
            `REG_RD_WRITE_PC_P4:
                w_forward_ex_val = r_pc_p4_EX;
            default: // regular instruction
                w_forward_ex_val = r_alu_result_EX;
        endcase
    end

    // For sub-word load instructions
    always_comb
    begin
        // Right align the data
        w_load_byte = r_mem_read_data >> {r_alu_result_MEM[1:0], 3'b0};
        w_load_half = r_mem_read_data >> {r_alu_result_MEM[1],   4'b0};
        
        // Pack the data correctly into w_load_data, according to size
        // and signedness
        case (r_funct3_MEM)
            `FUNCT3_LB:
                w_load_data = {{24{w_load_byte[7]}}, w_load_byte};
            `FUNCT3_LH:
                w_load_data = {{16{w_load_half[15]}}, w_load_half};
            `FUNCT3_LBU:
                w_load_data = {24'h0, w_load_byte};
            `FUNCT3_LHU:
                w_load_data = {16'h0, w_load_half};
            default: // LW, etc.
                w_load_data = r_mem_read_data;
        endcase
    end

    // What data to write to rd (WB)
    always_comb
    begin
        case (r_reg_write_src_MEM)
            `REG_RD_WRITE_ALU:
                w_rd_data = r_alu_result_MEM;
            `REG_RD_WRITE_MEM:
                w_rd_data = w_load_data;
            `REG_RD_WRITE_UI:
                w_rd_data = r_imm_MEM;
            `REG_RD_WRITE_PC_P4:
                w_rd_data = r_pc_p4_MEM;
            `REG_RD_WRITE_PC_IMM:
                w_rd_data = r_alu_result_MEM; // AUIPC: ALU computed PC+IMM
            default:
                w_rd_data = 32'h0;
        endcase
    end

    // Data memory outputs (MEM)
    assign o_dmem_addr        = r_alu_result_EX;
    assign o_dmem_read_en     = r_mem_read_en_EX;
    assign o_dmem_write_en    = r_mem_write_en_EX;

    // Sub-word functionality for stores (MEM)
    // Writes are still protected by o_dmem_write_en
    always_comb
    begin
        // alu result stores address of store + immediate offset
        // data then must be shifted left by (byte position) * 2^3 or (2 byte position) * 2^4
        case (r_funct3_EX)
            `FUNCT3_SB: begin
                o_dmem_byte_en   = 4'b0001 << r_alu_result_EX[1:0];
                o_dmem_write_data = r_rs2_data_EX << {r_alu_result_EX[1:0], 3'b0};
            end
            `FUNCT3_SH: begin
                o_dmem_byte_en   = r_alu_result_EX[1] ? 4'b1100 : 4'b0011;
                o_dmem_write_data = r_rs2_data_EX << {r_alu_result_EX[1], 4'b0};
            end
            default: begin  // FUNCT3_SW
                o_dmem_byte_en   = 4'b1111;
                o_dmem_write_data = r_rs2_data_EX;
            end
        endcase
    end

    // Core control module (ID)
    core_ctl u_core_ctl
    (
        .i_inst          (r_inst_IF),
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

    // Immediate generator module (ID)
    imm_gen u_imm_gen
    (
        .i_inst (r_inst_IF),
        .o_imm  (w_imm)
    );

    // Registers module (ID and WB)
    regs u_regs
    (
        .i_clk         (i_clk),
        .i_rst         (i_rst),
        .i_rd_write_en (r_reg_write_en_MEM),
        .i_addr_rs1    (w_rs1),
        .i_addr_rs2    (w_rs2),
        .i_addr_rd     (r_rd_MEM),
        .i_data_rd     (w_rd_data),
        .o_data_rs1    (w_rs1_data),
        .o_data_rs2    (w_rs2_data)
    );

    // Flush in cases of branch or jump
    assign w_flush = w_flush_branch || (r_jump_ID != `JUMP_NONE);

    // ALU control module (EX)
    alu_ctl u_alu_ctl (
        .i_aluctl_op (r_aluctl_op_ID),
        .i_funct3    (r_funct3_ID),
        .i_funct7    (r_funct7_ID),
        .o_alu_op    (w_alu_op)
    );

    // ALU control module (EX)
    alu u_alu
    (
        .i_alu_op     (w_alu_op),
        .i_a          (w_alu_a),
        .i_b          (w_alu_b),
        .o_result     (w_alu_result),
        .o_result_eqz (w_alu_result_eqz)
    );

    // Hazard detection module
    hazard_det u_hazard_det
    (
        .i_reg_write_en_EX(r_reg_write_en_EX), .i_reg_write_en_MEM(r_reg_write_en_MEM),
        .i_mem_read_en_ID(r_mem_read_en_ID),
        .i_take_branch_EX(w_take_branch),
        .i_rs1_IF(w_rs1),    
        .i_rs2_IF(w_rs2),    
        .i_rs1_ID(r_rs1_ID),    
        .i_rs2_ID(r_rs2_ID),    
        .i_rd_ID(r_rd_ID),     
        .i_rd_EX(r_rd_EX),     
        .i_rd_MEM(r_rd_MEM),    
        .o_alu_rs1_fw(w_alu_rs1_fw), // Forward to ALU rs1/operand A
        .o_alu_rs2_fw(w_alu_rs2_fw), // Forward to ALU rs2/operand B
        .o_insert_nop(w_insert_nop), // Stall in case of load-use hazard
        .o_flush(w_flush_branch) // Flush out instructions already in pipeline after branch is taken
    );

endmodule
