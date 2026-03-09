
`include "enums.sv"

module imm_gen
    (
        input   logic [31:0] i_inst,

        output  logic [31:0] o_imm
    );

    always_comb
    begin
        case (i_inst[6:0])
            `OPCODE_LOAD:
                o_imm = {{21{i_inst[31]}}, i_inst[30:20]}; // I-type
            `OPCODE_MISCMEM:
                o_imm = {{21{i_inst[31]}}, i_inst[30:20]}; // I-type
            `OPCODE_OP_IMM:
                o_imm = {{21{i_inst[31]}}, i_inst[30:20]}; // I-type
            `OPCODE_AUIPC:
                o_imm = {i_inst[31:12], {12{1'b0}}}; // U-type
            `OPCODE_STORE:
                o_imm = {{21{i_inst[31]}}, i_inst[30:25], i_inst[11:7]}; // S-type
            `OPCODE_LUI:
                o_imm = {i_inst[31:12], {12{1'b0}}}; // U-type
            `OPCODE_BRANCH:
                o_imm = {{20{i_inst[31]}}, i_inst[7], i_inst[30:25], i_inst[11:8] , 1'b0}; // SB-type
            `OPCODE_JALR:
                o_imm = {{21{i_inst[31]}}, i_inst[30:20]}; // I-type
            `OPCODE_JAL:
                o_imm = {{12{i_inst[31]}}, i_inst[19:12], i_inst[20], i_inst[30:21], 1'b0}; // UJ-type
            `OPCODE_SYSTEM:
                o_imm = {{21{i_inst[31]}}, i_inst[30:20]}; // I-type
            default:
                o_imm = 32'h0;
        endcase
    end
endmodule