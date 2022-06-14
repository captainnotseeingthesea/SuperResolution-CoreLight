`ifndef SIM_WITH_VERILATOR
`ifdef SIM_WITHOUT_AXI
module bicubic_processing_element_tb();
    reg clk_tb;
    reg rst_n_tb;

    wire upsp_ac_rready_tb;
    reg [23:0] ac_upsp_rdata_tb;
    reg ac_upsp_rvalid_tb;


    localparam BUFFER_WIDTH=24;
    reg ac_upsp_wready_tb;
    wire [BUFFER_WIDTH*4-1:0] upsp_ac_wdata_tb;
    wire upsp_ac_wvalid_tb;

    always #2 clk_tb = ~clk_tb;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, bicubic_processing_element_tb);
    end

    bicubic_processing_element #(
        .BLOCK_SIZE(11)
    ) u_processing_element(
        .clk(clk_tb),
        .rst_n(rst_n_tb),

        .upsp_ac_rready(upsp_ac_rready_tb),
        .ac_upsp_rdata(ac_upsp_rdata_tb),
        .ac_upsp_rvalid(ac_upsp_rvalid_tb),

        .ac_upsp_wready(ac_upsp_wready_tb),
        .upsp_ac_wdata(upsp_ac_wdata_tb),
        .upsp_ac_wvalid(upsp_ac_wvalid_tb)
    );

    task random_wready();
        forever begin  
            @(posedge clk_tb) begin
                #1 ac_upsp_wready_tb = {$random}%2;
            end
        end
    endtask


    initial begin


        // #1320
        #4000
        // #200000
        #5 $finish;
    end

    initial begin
        clk_tb = 1'b0;
        rst_n_tb = 1'b0;
        ac_upsp_rdata_tb = 24'd0;
        ac_upsp_rvalid_tb = 1'b0;
        ac_upsp_wready_tb = 1'b0;
        #7 rst_n_tb = 1'b1;
           ac_upsp_wready_tb = 1'b1;

        // the following code is used to test the cur_col_cnt signal.   
        #180 ac_upsp_wready_tb = 1'b0;
        #8 ac_upsp_wready_tb = 1'b1;
        #1   random_wready();

    end


endmodule
`endif
`endif

