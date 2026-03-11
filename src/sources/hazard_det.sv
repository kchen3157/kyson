`timescale 1 ns/10 ps
`include "enums.sv"

module hazard_det
    (
        input   logic i_reg_write_en_EX, i_reg_write_en_MEM,
        input   logic i_mem_read_en_ID,

        input   logic i_take_branch_EX,

        input   logic [4:0] i_rs1_IF,       // Source 1 from IF stage
        input   logic [4:0] i_rs2_IF,       // Source 2 from IF stage

        input   logic [4:0] i_rs1_ID,       // Source 1 from ID stage
        input   logic [4:0] i_rs2_ID,       // Source 2 from ID stage
        input   logic [4:0] i_rd_ID,        // Destination from ID stage

        input   logic [4:0] i_rd_EX,        // Destination from EX stage
        input   logic [4:0] i_rd_MEM,       // Destination from MEM stage

        output  logic [1:0] o_alu_rs1_fw,   // RS1_FORWARD_XXX
        output  logic [1:0] o_alu_rs2_fw,   // RS2_FORWARD_XXX
        output  logic o_insert_nop,         // Whether to insert a nop (in case of a load-use)
        output  logic o_flush               // Whether to flush stages after control hazard
    );

    always_comb
    begin
        o_alu_rs1_fw = `RS1_FORWARD_NONE;
        o_alu_rs2_fw = `RS2_FORWARD_NONE;
        o_insert_nop = 1'b0;
        o_flush = i_take_branch_EX;

        if (i_reg_write_en_EX && (i_rd_EX != 0) &&
            i_rd_EX == i_rs1_ID)
        begin
            o_alu_rs1_fw = `RS1_FORWARD_EX;
        end
        else if (i_reg_write_en_MEM && (i_rd_MEM != 0) &&
                 i_rd_MEM == i_rs1_ID)
        begin
            o_alu_rs1_fw = `RS1_FORWARD_MEM;
        end

        if (i_reg_write_en_EX && (i_rd_EX != 0) &&
            i_rd_EX == i_rs2_ID)
        begin
            o_alu_rs2_fw = `RS2_FORWARD_EX;
        end
        else if (i_reg_write_en_MEM && (i_rd_MEM != 0) &&
                 i_rd_MEM == i_rs2_ID)
        begin
            o_alu_rs2_fw = `RS2_FORWARD_MEM;
        end

        if (i_mem_read_en_ID &&
            (i_rd_ID == i_rs1_IF || i_rd_ID == i_rs2_IF))
        begin
            o_insert_nop = 1'b1;
        end
    end

endmodule