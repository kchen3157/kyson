`timescale 1ns / 1ps

`include "enums.sv"


module alu
    (
        input   logic [3:0] i_alu_op,
        input   logic [31:0] i_a,
        input   logic [31:0] i_b,

        output  logic [31:0] o_result,
        output  logic o_result_eqz
    );

    always_comb
    begin
        case (i_alu_op)
            `ALU_OP_ADD:
                o_result = i_a + i_b;
            `ALU_OP_AND:
                o_result = i_a & i_b;
            `ALU_OP_SLT:
                o_result = {31'h0, $signed(i_a) < $signed(i_b)};
            `ALU_OP_SLTU:
                o_result = {31'h0, i_a < i_b};
            `ALU_OP_SLL:
                o_result = i_a << i_b[4:0];
            `ALU_OP_SRL:
                o_result = i_a >> i_b[4:0];
            `ALU_OP_SRA:
                o_result = $signed(i_a) >>> i_b[4:0];
            `ALU_OP_OR:
                o_result = i_a | i_b;
            `ALU_OP_XOR:
                o_result = i_a ^ i_b;
            `ALU_OP_SUB:
                o_result = i_a - i_b;
            default:
                o_result = 0;
        endcase
    end

    assign o_result_eqz = (o_result == 0);

endmodule