
module bicubic_read_bmp (
    input wire clk, 
    input wire rst_n,
    input wire ready,
    output wire [24-1:0] data,
    output wire valid

);

    localparam HEIGHT = `SRC_IMG_HEIGHT;
    localparam WIDTH  = `SRC_IMG_WIDTH;

    localparam OFFSET = 138;
    localparam TOTAL_SIZE = HEIGHT * WIDTH *3 + OFFSET;
    localparam SIZE = (HEIGHT) * (WIDTH) ;

    reg [7:0] bmp_data [TOTAL_SIZE:0];
    reg [23:0] shaped_data [SIZE-1:0];


    localparam RESULT_SIZE = HEIGHT*WIDTH*3*4*4 + OFFSET;
    reg [23:0] result_data [RESULT_SIZE-1:0];

    integer shaped_index = 0;
    integer com = 0;
    integer bmp_file_id, icode, index = 0;

    integer img_width, img_height, img_start_index, img_size;
    integer ii, i, j;

    initial begin
        for (ii = 0; ii < SIZE; ii = ii+1) begin
            shaped_data[ii] = 0;
        end
        `ifndef SIM_WITH_VERILATOR  
            #1
        `endif

        bmp_file_id = $fopen("0.bmp", "rb");
        // bmp_file_id = $fopen("49_1k.bmp", "rb");
        // bmp_file_id = $fopen("4.bmp", "rb");
        icode = $fread(bmp_data, bmp_file_id);

        img_width = {bmp_data[21], bmp_data[20], bmp_data[19], bmp_data[18]};
        img_height = {bmp_data[25], bmp_data[24], bmp_data[23], bmp_data[22]};
        img_start_index = {bmp_data[13], bmp_data[12], bmp_data[11], bmp_data[10]};
        img_size = {bmp_data[5], bmp_data[4], bmp_data[3], bmp_data[2]};
        $fclose(bmp_file_id);

        `ifndef SIM_WITH_VERILATOR  
            #2
        `endif
        
        `ifndef SIM_WITH_VERILATOR  
            #1
        `endif

        // The following code to revese the data
        //
        // for (i = img_height - 1; i >= 0; i = i - 1) begin
        //     for(j = 0; j < img_width; j = j + 1) begin
        //         // if it is odd of width, then use (width+1), the extra bits are set to 00 0000
        //         index = i * (img_width) * 3 + j * 3 + img_start_index;
        //         shaped_data[shaped_index] = {bmp_data[index+2], bmp_data[index+1], bmp_data[index+0]};
        //         shaped_index = shaped_index + 1;
        //     end
        // end
        for (i = 0; i < img_height; i = i + 1) begin
            for(j = 0; j < img_width; j = j + 1) begin
                // if it is odd of width, then use (width+1), the extra bits are set to 00 0000
                index = i * (img_width) * 3 + j * 3 + img_start_index;
                shaped_data[shaped_index] = {bmp_data[index+2], bmp_data[index+1], bmp_data[index+0]};
                shaped_index = shaped_index + 1;
            end
        end

    end

    wire bmp_hsked = ready & valid;
    reg [31:0] ptr;
    reg [23:0] data_reg;
    reg valid_reg;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            ptr <= 32'd0;
            data_reg <= 24'd0;
            valid_reg <= 1'b0;
        end
        else begin
            valid_reg <= #1 1'b1;
            if(bmp_hsked) begin
                ptr <= #1 ptr + 1;
                data_reg <= #1 shaped_data[ptr+1];
                // $display("cur data: %x", data);
            end
            else begin
                data_reg <= #1 shaped_data[ptr];
            end
        end

    end
    wire cur_is_last_data = (ptr % (WIDTH)) ? 1'b0 : 1'b1;

    assign valid = valid_reg;
    assign data = data_reg;

endmodule
