`timescale 1ns / 1ps

module alu_tb;

    // ********** DUT IO **********
    logic [3:0] i_opcode;
    logic [31:0] i_a, i_b;

    logic [31:0] o_result;
    logic o_result_eqz;

    // ********** DUT Instantiation **********
    alu dut_alu
        (.*);

    initial
    begin
        i_a = 32'h02305E8F;
        i_b = 32'h09;

        for (logic [3:0] i = 0; i < 4'hF; i++)
        begin
            i_opcode = i;
            #(50);
        end

        i_a = 32'h02305E8F;
        i_b = 32'h3842;

        for (logic [3:0] i = 0; i < 4'hF; i++)
        begin
            i_opcode = i;
            #(50);
        end

        $stop;
    end


endmodule