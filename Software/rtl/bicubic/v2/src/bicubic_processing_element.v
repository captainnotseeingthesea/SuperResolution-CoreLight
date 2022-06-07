
module bicubic_processing_element
#(
    parameter BUFFER_WIDTH = 24, 
    parameter CHANNEL_WIDTH = 8,
    parameter BLOCK_SIZE = 960
)
(
    input clk,
    input rst_n,

    output wire upsp_ac_rready,
    input wire [23:0] ac_upsp_rdata,
    input wire ac_upsp_rvalid,

    input wire ac_upsp_wready,
    output wire [BUFFER_WIDTH*4-1:0] upsp_ac_wdata,

    output wire upsp_ac_wvalid

);


    wire bf_req_valid;
    wire bcci_req_ready;

    wire [BUFFER_WIDTH-1:0] out_p1;
    wire [BUFFER_WIDTH-1:0] out_p2;
    wire [BUFFER_WIDTH-1:0] out_p3;
    wire [BUFFER_WIDTH-1:0] out_p4;
    wire [BUFFER_WIDTH-1:0] out_p5;
    wire [BUFFER_WIDTH-1:0] out_p6;
    wire [BUFFER_WIDTH-1:0] out_p7;
    wire [BUFFER_WIDTH-1:0] out_p8;
    wire [BUFFER_WIDTH-1:0] out_p9;
    wire [BUFFER_WIDTH-1:0] out_p10;
    wire [BUFFER_WIDTH-1:0] out_p11;
    wire [BUFFER_WIDTH-1:0] out_p12;
    wire [BUFFER_WIDTH-1:0] out_p13;
    wire [BUFFER_WIDTH-1:0] out_p14;
    wire [BUFFER_WIDTH-1:0] out_p15;
    wire [BUFFER_WIDTH-1:0] out_p16;

    wire [BUFFER_WIDTH-1:0] bcci_rsp_data1;
    wire [BUFFER_WIDTH-1:0] bcci_rsp_data2;
    wire [BUFFER_WIDTH-1:0] bcci_rsp_data3;
    wire [BUFFER_WIDTH-1:0] bcci_rsp_data4;

    // hsk signal bcci to axi
    wire bcci_2_bf_hsked = upsp_ac_wvalid & ac_upsp_wready;


    buffer_sram #(
        .BUFFER_WIDTH(BUFFER_WIDTH),
        .BLOCK_SIZE(BLOCK_SIZE)
    ) u_buffer (
        .clk(clk),
        .rst_n(rst_n),

    `ifndef SIM_WITHOUT_AXI
        .axi_ready(upsp_ac_rready),
        .axi_data(ac_upsp_rdata),
        .axi_valid(ac_upsp_rvalid),
    `endif

        .bf_req_valid(bf_req_valid),
        .bcci_req_ready(bcci_req_ready),

        .out_p1(out_p1),
        .out_p2(out_p2),
        .out_p3(out_p3),
        .out_p4(out_p4),
        .out_p5(out_p5),
        .out_p6(out_p6),
        .out_p7(out_p7),
        .out_p8(out_p8),
        .out_p9(out_p9),
        .out_p10(out_p10),
        .out_p11(out_p11),
        .out_p12(out_p12),
        .out_p13(out_p13),
        .out_p14(out_p14),
        .out_p15(out_p15),
        .out_p16(out_p16),


    `ifdef SIM_WITHOUT_AXI
        .bcci_rsp_data1(bcci_rsp_data1),
        .bcci_rsp_data2(bcci_rsp_data2),
        .bcci_rsp_data3(bcci_rsp_data3),
        .bcci_rsp_data4(bcci_rsp_data4), 
    `endif

        .bcci_2_bf_hsked(bcci_2_bf_hsked)

    );

    wire R_bf_req_valid = bf_req_valid;
    wire G_bf_req_valid = bf_req_valid;
    wire B_bf_req_valid = bf_req_valid;
    wire R_bcci_req_ready;
    wire G_bcci_req_ready;
    wire B_bcci_req_ready;

    assign bcci_req_ready = R_bcci_req_ready & G_bcci_req_ready & B_bcci_req_ready;
    
    wire [CHANNEL_WIDTH-1:0] R_p1 = out_p1[BUFFER_WIDTH-1:16];
    wire [CHANNEL_WIDTH-1:0] G_p1 = out_p1[15:CHANNEL_WIDTH];
    wire [CHANNEL_WIDTH-1:0] B_p1 = out_p1[CHANNEL_WIDTH-1:0];

    wire [CHANNEL_WIDTH-1:0] R_p2 = out_p2[BUFFER_WIDTH-1:16];
    wire [CHANNEL_WIDTH-1:0] G_p2 = out_p2[15:CHANNEL_WIDTH];
    wire [CHANNEL_WIDTH-1:0] B_p2 = out_p2[CHANNEL_WIDTH-1:0];

    wire [CHANNEL_WIDTH-1:0] R_p3 = out_p3[BUFFER_WIDTH-1:16];
    wire [CHANNEL_WIDTH-1:0] G_p3 = out_p3[15:CHANNEL_WIDTH];
    wire [CHANNEL_WIDTH-1:0] B_p3 = out_p3[CHANNEL_WIDTH-1:0];

    wire [CHANNEL_WIDTH-1:0] R_p4 = out_p4[BUFFER_WIDTH-1:16];
    wire [CHANNEL_WIDTH-1:0] G_p4 = out_p4[15:CHANNEL_WIDTH];
    wire [CHANNEL_WIDTH-1:0] B_p4 = out_p4[CHANNEL_WIDTH-1:0];

    wire [CHANNEL_WIDTH-1:0] R_p5 = out_p5[BUFFER_WIDTH-1:16];
    wire [CHANNEL_WIDTH-1:0] G_p5 = out_p5[15:CHANNEL_WIDTH];
    wire [CHANNEL_WIDTH-1:0] B_p5 = out_p5[CHANNEL_WIDTH-1:0];

    wire [CHANNEL_WIDTH-1:0] R_p6 = out_p6[BUFFER_WIDTH-1:16];
    wire [CHANNEL_WIDTH-1:0] G_p6 = out_p6[15:CHANNEL_WIDTH];
    wire [CHANNEL_WIDTH-1:0] B_p6 = out_p6[CHANNEL_WIDTH-1:0];

    wire [CHANNEL_WIDTH-1:0] R_p7 = out_p7[BUFFER_WIDTH-1:16];
    wire [CHANNEL_WIDTH-1:0] G_p7 = out_p7[15:CHANNEL_WIDTH];
    wire [CHANNEL_WIDTH-1:0] B_p7 = out_p7[CHANNEL_WIDTH-1:0];

    wire [CHANNEL_WIDTH-1:0] R_p8 = out_p8[BUFFER_WIDTH-1:16];
    wire [CHANNEL_WIDTH-1:0] G_p8 = out_p8[15:CHANNEL_WIDTH];
    wire [CHANNEL_WIDTH-1:0] B_p8 = out_p8[CHANNEL_WIDTH-1:0];

    wire [CHANNEL_WIDTH-1:0] R_p9 = out_p9[BUFFER_WIDTH-1:16];
    wire [CHANNEL_WIDTH-1:0] G_p9 = out_p9[15:CHANNEL_WIDTH];
    wire [CHANNEL_WIDTH-1:0] B_p9 = out_p9[CHANNEL_WIDTH-1:0];

    wire [CHANNEL_WIDTH-1:0] R_p10 = out_p10[BUFFER_WIDTH-1:16];
    wire [CHANNEL_WIDTH-1:0] G_p10 = out_p10[15:CHANNEL_WIDTH];
    wire [CHANNEL_WIDTH-1:0] B_p10 = out_p10[CHANNEL_WIDTH-1:0];

    wire [CHANNEL_WIDTH-1:0] R_p11 = out_p11[BUFFER_WIDTH-1:16];
    wire [CHANNEL_WIDTH-1:0] G_p11 = out_p11[15:CHANNEL_WIDTH];
    wire [CHANNEL_WIDTH-1:0] B_p11 = out_p11[CHANNEL_WIDTH-1:0];

    wire [CHANNEL_WIDTH-1:0] R_p12 = out_p12[BUFFER_WIDTH-1:16];
    wire [CHANNEL_WIDTH-1:0] G_p12 = out_p12[15:CHANNEL_WIDTH];
    wire [CHANNEL_WIDTH-1:0] B_p12 = out_p12[CHANNEL_WIDTH-1:0];

    wire [CHANNEL_WIDTH-1:0] R_p13 = out_p13[BUFFER_WIDTH-1:16];
    wire [CHANNEL_WIDTH-1:0] G_p13 = out_p13[15:CHANNEL_WIDTH];
    wire [CHANNEL_WIDTH-1:0] B_p13 = out_p13[CHANNEL_WIDTH-1:0];

    wire [CHANNEL_WIDTH-1:0] R_p14 = out_p14[BUFFER_WIDTH-1:16];
    wire [CHANNEL_WIDTH-1:0] G_p14 = out_p14[15:CHANNEL_WIDTH];
    wire [CHANNEL_WIDTH-1:0] B_p14 = out_p14[CHANNEL_WIDTH-1:0];

    wire [CHANNEL_WIDTH-1:0] R_p15 = out_p15[BUFFER_WIDTH-1:16];
    wire [CHANNEL_WIDTH-1:0] G_p15 = out_p15[15:CHANNEL_WIDTH];
    wire [CHANNEL_WIDTH-1:0] B_p15 = out_p15[CHANNEL_WIDTH-1:0];

    wire [CHANNEL_WIDTH-1:0] R_p16 = out_p16[BUFFER_WIDTH-1:16];
    wire [CHANNEL_WIDTH-1:0] G_p16 = out_p16[15:CHANNEL_WIDTH];
    wire [CHANNEL_WIDTH-1:0] B_p16 = out_p16[CHANNEL_WIDTH-1:0];


    wire [CHANNEL_WIDTH-1:0] R_bcci_rsp_data1;
    wire [CHANNEL_WIDTH-1:0] G_bcci_rsp_data1;
    wire [CHANNEL_WIDTH-1:0] B_bcci_rsp_data1;
    wire [CHANNEL_WIDTH-1:0] R_bcci_rsp_data2;
    wire [CHANNEL_WIDTH-1:0] G_bcci_rsp_data2;
    wire [CHANNEL_WIDTH-1:0] B_bcci_rsp_data2;
    wire [CHANNEL_WIDTH-1:0] R_bcci_rsp_data3;
    wire [CHANNEL_WIDTH-1:0] G_bcci_rsp_data3;
    wire [CHANNEL_WIDTH-1:0] B_bcci_rsp_data3;
    wire [CHANNEL_WIDTH-1:0] R_bcci_rsp_data4;
    wire [CHANNEL_WIDTH-1:0] G_bcci_rsp_data4;
    wire [CHANNEL_WIDTH-1:0] B_bcci_rsp_data4;


    wire R_bcci_rsp_valid;
    wire G_bcci_rsp_valid;
    wire B_bcci_rsp_valid;

    wire R_bf_rsp_ready = ac_upsp_wready;
    wire G_bf_rsp_ready = ac_upsp_wready;
    wire B_bf_rsp_ready = ac_upsp_wready;

    bicubic_upsample #(
        .BLOCK_SIZE(BLOCK_SIZE)
    ) u_R_bicubic_upsample (
        .clk(clk),
        .rst_n(rst_n),
        .bf_req_valid(R_bf_req_valid),
        .bcci_req_ready(R_bcci_req_ready),
        .p1(R_p1),
        .p2(R_p2),
        .p3(R_p3),
        .p4(R_p4),
        .p5(R_p5),
        .p6(R_p6),
        .p7(R_p7),
        .p8(R_p8),
        .p9(R_p9),
        .p10(R_p10),
        .p11(R_p11),
        .p12(R_p12),
        .p13(R_p13),
        .p14(R_p14),
        .p15(R_p15),
        .p16(R_p16),

        .bcci_rsp_valid(R_bcci_rsp_valid),
        .bf_rsp_ready(R_bf_rsp_ready),

        .bcci_rsp_data1(R_bcci_rsp_data1),
        .bcci_rsp_data2(R_bcci_rsp_data2),
        .bcci_rsp_data3(R_bcci_rsp_data3),
        .bcci_rsp_data4(R_bcci_rsp_data4)
    );


    bicubic_upsample #(
        .BLOCK_SIZE(BLOCK_SIZE)
    ) u_G_bicubic_upsample(
        .clk(clk),
        .rst_n(rst_n),
        .bf_req_valid(G_bf_req_valid),
        .bcci_req_ready(G_bcci_req_ready),
        .p1(G_p1),
        .p2(G_p2),
        .p3(G_p3),
        .p4(G_p4),
        .p5(G_p5),
        .p6(G_p6),
        .p7(G_p7),
        .p8(G_p8),
        .p9(G_p9),
        .p10(G_p10),
        .p11(G_p11),
        .p12(G_p12),
        .p13(G_p13),
        .p14(G_p14),
        .p15(G_p15),
        .p16(G_p16),

        .bcci_rsp_valid(G_bcci_rsp_valid),
        .bf_rsp_ready(G_bf_rsp_ready),

        .bcci_rsp_data1(G_bcci_rsp_data1),
        .bcci_rsp_data2(G_bcci_rsp_data2),
        .bcci_rsp_data3(G_bcci_rsp_data3),
        .bcci_rsp_data4(G_bcci_rsp_data4)
    );

    bicubic_upsample #(
        .BLOCK_SIZE(BLOCK_SIZE)
    ) u_B_bicubic_upsample(
        .clk(clk),
        .rst_n(rst_n),
        .bf_req_valid   (B_bf_req_valid),
        .bcci_req_ready (B_bcci_req_ready),
        .p1(B_p1),
        .p2(B_p2),
        .p3(B_p3),
        .p4(B_p4),
        .p5(B_p5),
        .p6(B_p6),
        .p7(B_p7),
        .p8(B_p8),
        .p9(B_p9),
        .p10(B_p10),
        .p11(B_p11),
        .p12(B_p12),
        .p13(B_p13),
        .p14(B_p14),
        .p15(B_p15),
        .p16(B_p16),

        .bcci_rsp_valid (B_bcci_rsp_valid),
        .bf_rsp_ready   (B_bf_rsp_ready),

        .bcci_rsp_data1 (B_bcci_rsp_data1),
        .bcci_rsp_data2 (B_bcci_rsp_data2),
        .bcci_rsp_data3 (B_bcci_rsp_data3),
        .bcci_rsp_data4 (B_bcci_rsp_data4)
    );


    assign bcci_rsp_data1 = {R_bcci_rsp_data1, G_bcci_rsp_data1, B_bcci_rsp_data1};
    assign bcci_rsp_data2 = {R_bcci_rsp_data2, G_bcci_rsp_data2, B_bcci_rsp_data2};
    assign bcci_rsp_data3 = {R_bcci_rsp_data3, G_bcci_rsp_data3, B_bcci_rsp_data3};
    assign bcci_rsp_data4 = {R_bcci_rsp_data4, G_bcci_rsp_data4, B_bcci_rsp_data4};

    assign upsp_ac_wdata = {
        bcci_rsp_data1,
        bcci_rsp_data2,
        bcci_rsp_data3,
        bcci_rsp_data4
    };

 

    assign upsp_ac_wvalid = R_bcci_rsp_valid & G_bcci_rsp_valid & B_bcci_rsp_valid;


endmodule

// `ifndef SIM_WITH_VERILATOR
// `ifdef SIM_WITHOUT_AXI
// module bicubic_top_tb();
//     reg clk_tb;
//     reg rst_n_tb;

//     wire upsp_ac_rready_tb;
//     reg [23:0] ac_upsp_rdata_tb;
//     reg ac_upsp_rvalid_tb;

//     reg ac_upsp_wready_tb;
//     wire [23:0] upsp_ac_wdata_tb;
//     wire upsp_ac_wvalid_tb;

//     initial begin
//         clk_tb = 1'b0;
//         rst_n_tb = 1'b0;
//         ac_upsp_rdata_tb = 24'd0;
//         ac_upsp_rvalid_tb = 1'b0;
//         ac_upsp_wready_tb = 1'b0;
//         #7 rst_n_tb = 1'b1;
//            ac_upsp_wready_tb = 1'b1;
//         #253 ac_upsp_wready_tb = 1'b0;

//         #11 ac_upsp_wready_tb = 1'b1;
//     end

//     always #2 clk_tb = ~clk_tb;

//     initial begin
//         $dumpfile("wave.vcd");
//         $dumpvars(0, bicubic_top_tb);
//     end

//     bicubic_top u_bicubic_top(
//         .clk(clk_tb),
//         .rst_n(rst_n_tb),

//         .upsp_ac_rready(upsp_ac_rready_tb),
//         .ac_upsp_rdata(ac_upsp_rdata_tb),
//         .ac_upsp_rvalid(ac_upsp_rvalid_tb),

//         .ac_upsp_wready(ac_upsp_wready_tb),
//         .upsp_ac_wdata(upsp_ac_wdata_tb),
//         .upsp_ac_wvalid(upsp_ac_wvalid_tb)
//     );


//     initial begin


//         // #1320
//         // #4000
//         #6000
//         #5 $finish;
//     end

// endmodule
// `endif
// `endif
