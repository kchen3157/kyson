`timescale 1 ns/10 ps

module regs
    (
        input   logic i_clk, i_rst,
        input   logic i_rd_write_en,
        input   logic [4:0] i_addr_rs1,
        input   logic [4:0] i_addr_rs2,
        input   logic [4:0] i_addr_rd,
        input   logic [31:0] i_data_rd,

        output  logic [31:0] o_data_rs1,
        output  logic [31:0] o_data_rs2
    );

    logic [31:0] r_regs [31:0];
    
    always_ff @(posedge i_clk)
    begin
        if (i_rd_write_en && (i_addr_rd != 5'h00))
        begin
            r_regs[i_addr_rd] <= i_data_rd;
        end
    end

    assign o_data_rs1 = (i_addr_rs1 == 5'h0) ? 32'h0 : r_regs[i_addr_rs1];
    assign o_data_rs2 = (i_addr_rs2 == 5'h0) ? 32'h0 : r_regs[i_addr_rs2];

endmodule