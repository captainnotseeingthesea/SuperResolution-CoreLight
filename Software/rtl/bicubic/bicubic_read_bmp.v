
module bicubic_read_bmp (
    input wire clk, 
    input wire rst_n,
    input wire ready,
    output wire [24-1:0] data,
    output wire valid

);

    localparam HEIGHT = 540;
    localparam WIDTH  = 960;

    // localparam HEIGHT = 6;
    // localparam WIDTH  = 11;

    localparam OFFSET = 138;
    localparam TOTAL_SIZE = HEIGHT * WIDTH *3 + OFFSET;
    localparam SIZE = (HEIGHT+3) * (WIDTH+3) ;

    reg [7:0] bmp_data [TOTAL_SIZE:0];
    reg [23:0] shaped_data [SIZE-1:0];


    localparam RESULT_SIZE = HEIGHT*WIDTH*3*4*4 + OFFSET;
    reg [23:0] result_data [RESULT_SIZE-1:0];

    integer shaped_index = WIDTH+4;
    integer com = 0;
    integer bmp_file_id, icode, index = 0;

    integer img_width, img_height, img_start_index, img_size;
    integer ii, i, j;
    // initial begin
    //     for (ii = 0; ii < RESULT_SIZE; ii = ii+1) begin
    //         result_data[ii] = 0;
    //     end
    //     #1
    //     for (ii =0; ii < OFFSET; i = i + 1) begin
    //         result_data[ii] = bmp_data[ii];
    //     end
    //     // #1
    //     //     result_data[25] = 8'h0;
    //     //     result_data[24] = 8'h0;
    //     //     result_data[23] = 8'h08;
    //     //     result_data[22] = 8'h70;

    //     //     result_data[20] = 8'h0;
    //     //     result_data[19] = 8'h0;
    //     //     result_data[18] = 8'h0f;
    //     //     result_data[17] = 8'h0;

    //     //     result_data[5] = 8'h0;
    //     //     result_data[4] = 8'h1f;
    //     //     result_data[3] = 8'ha4;
    //     //     result_data[2] = 8'h00;
    // end

            

    initial begin
        for (ii = 0; ii < SIZE; ii = ii+1) begin
            shaped_data[ii] = 0;
        end
        
        #1
        // bmp_file_id = $fopen("2.bmp", "rb");

        bmp_file_id = $fopen("49_1k.bmp", "rb");
        icode = $fread(bmp_data, bmp_file_id);

        img_width = {bmp_data[21], bmp_data[20], bmp_data[19], bmp_data[18]};
        img_height = {bmp_data[25], bmp_data[24], bmp_data[23], bmp_data[22]};
        img_start_index = {bmp_data[13], bmp_data[12], bmp_data[11], bmp_data[10]};
        img_size = {bmp_data[5], bmp_data[4], bmp_data[3], bmp_data[2]};

        $fclose(bmp_file_id);


        for (i = img_height - 1; i >= 0; i = i - 1) begin
            for(j = 0; j < img_width; j = j + 1) begin
                // if it is odd of width, then use (width+1), the extra bits are set to 00 0000
                index = i * (img_width) * 3 + j * 3 + img_start_index;
                shaped_data[shaped_index+com] = {bmp_data[index+2], bmp_data[index+1], bmp_data[index+0]};
                shaped_index = shaped_index + 1;
            end
            com = com + 3;
        end





        // in bmp format, the last row of the data is stored first (Revese order).

        // index = (img_height-1) * (img_width+1) * 3 + 0 * 3 + img_start_index;
        // $display("(0, 0): %x, %x, %x", bmp_data[index+2], bmp_data[index+1], bmp_data[index+0]);
        // $display("(0, 1): %x, %x, %x", bmp_data[index+5], bmp_data[index+4], bmp_data[index+3]);
        // $display("(0, 2): %x, %x, %x", bmp_data[index+8], bmp_data[index+7], bmp_data[index+6]);

        // index = (img_height-2) * (img_width+1) * 3 + 0 * 3 + img_start_index;
        // $display("(1, 0): %x, %x, %x", bmp_data[index+2], bmp_data[index+1], bmp_data[index+0]);
        // $display("(1, 1): %x, %x, %x", bmp_data[index+5], bmp_data[index+4], bmp_data[index+3]);
        // $display("(1, 2): %x, %x, %x", bmp_data[index+8], bmp_data[index+7], bmp_data[index+6]);

        // $display("shaped data");
        // $display("(0, 0): %x", shaped_data[0]);
        // $display("(0, 1): %x", shaped_data[1]);
        // $display("(1, 1): %x", shaped_data[(WIDTH+3)*1+1]);
        // $display("(2, 1): %x", shaped_data[(WIDTH+3)*2+1]);

    end


    wire bmp_hsked = ready & valid;
    reg [31:0] ptr;
    reg [23:0] data_reg;
    reg valid_reg;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            ptr <= 32'd1;
            data_reg <= 24'd0;
            valid_reg <= 1'b0;
        end
        else begin
            valid_reg <= #1 1'b1;
            if(bmp_hsked) begin
                data_reg <= #1 shaped_data[ptr];
                ptr <= #1 ptr + 1;
            end
        end

    end
    wire cur_is_last_data = (ptr % (WIDTH+3)) ? 1'b0 : 1'b1;
    assign valid = valid_reg;
    assign data = data_reg;

endmodule


// module bicubic_read_bmp_tb();
//     reg clk_tb;
//     reg rst_n_tb;
//     reg ready_tb;
//     wire [24-1:0] data_tb;
//     wire valid_tb;

//     initial begin
//         clk_tb = 1'b0;
//         rst_n_tb = 1'b0;
//         ready_tb = 1'b0;
//         #5 rst_n_tb = 1'b1;
//         #4 ready_tb = 1'b1;


//         #2000 $finish;
//     end
//     always #2 clk_tb = ~clk_tb;
    
//     bicubic_read_bmp u_bicubic_read_bmp(
//         .clk(clk_tb),
//         .rst_n(rst_n_tb),
//         .ready(ready_tb),
//         .data(data_tb),
//         .valid(valid_tb)
//     );
//     // initial begin
//     //     $monitor("data: %x", data_tb);
//     // end

//     initial begin
//         $dumpfile("wave.vcd");
//         $dumpvars(0, bicubic_read_bmp_tb);
//     end


// endmodule


