`timescale 1 ns/10 ps

module core_tb;

    // ********** Parameters **********
    localparam CLK_PERIOD = 10; // 10 ns -> 100 MHz

    // ********** DUT IO **********
    logic i_clk, i_rst;
    logic [31:0] o_imem_addr;
    logic [31:0] i_imem_data;
    logic [31:0] o_dmem_addr;
    logic [31:0] o_dmem_write_data;
    logic [31:0] i_dmem_read_data;
    logic o_dmem_write_en;
    logic o_dmem_read_en; // ignored

    // ********** Clockgen **********
    initial i_clk = 1'b0;
    always 
    begin
        #(CLK_PERIOD/2);
        i_clk = ~i_clk;
    end

    // ********** DUT Instantiation **********
    core dut_core
        (.*);

    
    logic [31:0] imem [0:255];
    logic [31:0] dmem [0:255];
    assign i_imem_data = imem[o_imem_addr[9:2]];
    assign i_dmem_read_data = dmem[o_dmem_addr[9:2]];

    always_ff @(posedge i_clk)
    begin
        if (o_dmem_write_en)
        begin
            dmem[o_dmem_addr[9:2]] <= o_dmem_write_data;
        end
    end

    initial
    begin
        $readmemh("../../../tests/add.hex", imem);

        i_rst = 1'b1;
        repeat(4) @(posedge i_clk);
        i_rst = 1'b0;

        repeat(500) @(posedge i_clk);
        $stop;
    end

endmodule