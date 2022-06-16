
module bicubic_vector_mult #
(
    parameter PRODUCT_WIDTH = 32
)
(
    input wire [3:0] weight_1,
    input wire [PRODUCT_WIDTH - 1:0] pixel_1,
    input wire [3:0] weight_2,
    input wire [PRODUCT_WIDTH - 1:0] pixel_2,
    input wire [3:0] weight_3,
    input wire [PRODUCT_WIDTH - 1:0] pixel_3,
    input wire [3:0] weight_4,
    input wire [PRODUCT_WIDTH - 1:0] pixel_4,

    output wire [PRODUCT_WIDTH - 2:0] inner_product,
    output wire inner_product_sign
);


    wire [PRODUCT_WIDTH - 1:0] product_t1, product_t2, product_t3, product_t4;
    bicubic_mult #(.PRODUCT_WIDTH(PRODUCT_WIDTH - 1)) u_bicubic_mult_1(
        .weight       (weight_1[2:0]  ),
        .weight_sign  (weight_1[3]    ),
        .pixel        (pixel_1[PRODUCT_WIDTH - 2: 0]   ),
        .pixel_sign   (pixel_1[PRODUCT_WIDTH - 1]     ),
        .product      (product_t1[PRODUCT_WIDTH - 2:0]),
        .product_sign (product_t1[PRODUCT_WIDTH - 1]  )
    );
    bicubic_mult #(.PRODUCT_WIDTH(PRODUCT_WIDTH - 1)) u_bicubic_mult_2(
        .weight       (weight_2[2:0]  ),
        .weight_sign  (weight_2[3]    ),
        .pixel        (pixel_2[PRODUCT_WIDTH - 2: 0]   ),
        .pixel_sign   (pixel_2[PRODUCT_WIDTH - 1]      ),
        .product      (product_t2[PRODUCT_WIDTH - 2: 0]),
        .product_sign (product_t2[PRODUCT_WIDTH - 1]   )
    );
    bicubic_mult #(.PRODUCT_WIDTH(PRODUCT_WIDTH - 1)) u_bicubic_mult_3(
        .weight       (weight_3[2:0]  ),
        .weight_sign  (weight_3[3]    ),
        .pixel        (pixel_3[PRODUCT_WIDTH - 2: 0]   ),
        .pixel_sign   (pixel_3[PRODUCT_WIDTH - 1]      ),
        .product      (product_t3[PRODUCT_WIDTH - 2: 0]),
        .product_sign (product_t3[PRODUCT_WIDTH - 1]   )
    );
    bicubic_mult #(.PRODUCT_WIDTH(PRODUCT_WIDTH - 1)) u_bicubic_mult_4(
        .weight       (weight_4[2:0]  ),
        .weight_sign  (weight_4[3]    ),
        .pixel        (pixel_4[PRODUCT_WIDTH - 2: 0]   ),
        .pixel_sign   (pixel_4[PRODUCT_WIDTH - 1]      ),
        .product      (product_t4[PRODUCT_WIDTH - 2: 0]),
        .product_sign (product_t4[PRODUCT_WIDTH - 1]   )
    );

    wire t1_is_0 = (~(|product_t1[PRODUCT_WIDTH - 2:0])) ? 1'b1 : 1'b0;
    wire t2_is_0 = (~(|product_t2[PRODUCT_WIDTH - 2:0])) ? 1'b1 : 1'b0;
    wire t3_is_0 = (~(|product_t3[PRODUCT_WIDTH - 2:0])) ? 1'b1 : 1'b0;
    wire t4_is_0 = (~(|product_t4[PRODUCT_WIDTH - 2:0])) ? 1'b1 : 1'b0;
        
    wire [PRODUCT_WIDTH - 2:0] t1_complement = (~product_t1[PRODUCT_WIDTH - 2:0]) + 1;
    wire [PRODUCT_WIDTH - 2:0] t2_complement = (~product_t2[PRODUCT_WIDTH - 2:0]) + 1;
    wire [PRODUCT_WIDTH - 2:0] t3_complement = (~product_t3[PRODUCT_WIDTH - 2:0]) + 1;
    wire [PRODUCT_WIDTH - 2:0] t4_complement = (~product_t4[PRODUCT_WIDTH - 2:0]) + 1;

    wire [PRODUCT_WIDTH:0] adder1_src1 = t1_is_0 ? 'b0 : product_t1[PRODUCT_WIDTH - 1] ? {2'b11, t1_complement} : {2'b00, product_t1[PRODUCT_WIDTH - 2:0]};
    wire [PRODUCT_WIDTH:0] adder1_src2 = t2_is_0 ? 'b0 : product_t2[PRODUCT_WIDTH - 1] ? {2'b11, t2_complement} : {2'b00, product_t2[PRODUCT_WIDTH - 2:0]};

    wire [PRODUCT_WIDTH:0] adder2_src1 = t3_is_0 ? 'b0 : product_t3[PRODUCT_WIDTH - 1] ? {2'b11, t3_complement} : {2'b00, product_t3[PRODUCT_WIDTH - 2:0]};
    wire [PRODUCT_WIDTH:0] adder2_src2 = t4_is_0 ? 'b0 : product_t4[PRODUCT_WIDTH - 1] ? {2'b11, t4_complement} : {2'b00, product_t4[PRODUCT_WIDTH - 2:0]};   

    wire [PRODUCT_WIDTH:0] result1 = adder1_src1 + adder1_src2;
    wire [PRODUCT_WIDTH:0] result2 = adder2_src1 + adder2_src2;

    wire result1_overflow = result1[PRODUCT_WIDTH] ^ result1[PRODUCT_WIDTH - 1];
    wire result2_overflow = result2[PRODUCT_WIDTH] ^ result2[PRODUCT_WIDTH - 1];


    wire [PRODUCT_WIDTH:0] result3 = result1 + result2;

    wire result3_overflow = result3[PRODUCT_WIDTH] ^ result3[PRODUCT_WIDTH - 1];

    wire overflow = result1_overflow | result2_overflow | result3_overflow;
    // assert (overflow) $fatal("expression overflow!");

    assign inner_product = result3_overflow ? {PRODUCT_WIDTH - 1{1'b1}} : result3[PRODUCT_WIDTH] ? (~result3[PRODUCT_WIDTH - 2 : 0] + 1) : result3[PRODUCT_WIDTH - 2: 0];
    assign inner_product_sign = result3[PRODUCT_WIDTH];

endmodule
