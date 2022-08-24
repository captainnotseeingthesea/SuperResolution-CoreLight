`ifndef SIM_WITH_VERILATOR
`ifdef SIM_WITHOUT_AXI
module bicubic_top_tb();
    reg clk_tb;
    reg rst_n_tb;

    wire upsp_ac_rready_tb;
    reg [23:0] ac_upsp_rdata_tb;
    reg ac_upsp_rvalid_tb;


    localparam BUFFER_WIDTH=24;
    reg ac_upsp_wready_tb;
`ifdef GEN_IN_SIXTEEN
    wire [BUFFER_WIDTH-1:0] upsp_ac_wdata_tb;
`elsif GEN_IN_EIGHT
    wire [BUFFER_WIDTH*4-1:0] upsp_ac_wdata_tb;
`elsif GEN_IN_FOUR
    wire [BUFFER_WIDTH*4-1:0] upsp_ac_wdata_tb;
`elsif GEN_IN_TWO
    wire [BUFFER_WIDTH*16-1:0] upsp_ac_wdata_tb;
`elsif GEN_IN_ONE
    wire [BUFFER_WIDTH*16-1:0] upsp_ac_wdata_tb;
`endif
    wire upsp_ac_wvalid_tb;

    initial begin
        clk_tb = 1'b0;
        rst_n_tb = 1'b0;
        ac_upsp_rdata_tb = 24'd0;
        ac_upsp_rvalid_tb = 1'b0;
        ac_upsp_wready_tb = 1'b0;
        #7 rst_n_tb = 1'b1;
           ac_upsp_wready_tb = 1'b1;
        // #253 ac_upsp_wready_tb = 1'b0;

        // #11 ac_upsp_wready_tb = 1'b1;
    end

    always #2 clk_tb = ~clk_tb;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, bicubic_top_tb);
    end

    bicubic_top u_bicubic_top(
        .clk(clk_tb),
        .rst_n(rst_n_tb),

        .upsp_ac_rready(upsp_ac_rready_tb),
        .ac_upsp_rdata(ac_upsp_rdata_tb),
        .ac_upsp_rvalid(ac_upsp_rvalid_tb),

        .ac_upsp_wready(ac_upsp_wready_tb),
        .upsp_ac_wdata(upsp_ac_wdata_tb),
        .upsp_ac_wvalid(upsp_ac_wvalid_tb)
    );


    initial begin


        // #1320
        // #4000
        #2000
        #5 $finish;
    end

endmodule
`endif
`endif

