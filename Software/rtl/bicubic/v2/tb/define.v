
`define SIM_WITH_VERILATOR  
`define SIM_WITHOUT_AXI

`define UPSP_DATA_WIDTH 24
`define SRC_IMG_WIDTH 96
`define SRC_IMG_HEIGHT 54


// `define USE_IPs


// configure the total cycles of the two multiplier operation

// `define MULT_IN_TWO_CYCLE
// `define MULT_IN_THREE_CYCLE
// `define MULT_IN_FOUR_CYCLE
// `define MULT_IN_FIVE_CYCLE
`define MULT_IN_SIX_CYCLE


// configure the total cycles of the first multiplier
// `define STAGE1_MULT_IN_ONE_CYCLE
// `define STAGE1_MULT_IN_TWO_CYCLE
`define STAGE1_MULT_IN_THREE_CYCLE

// configure the total cycles of the second multiplier
// `define STAGE2_MULT_IN_ONE_CYCLE
// `define STAGE2_MULT_IN_TWO_CYCLE
`define STAGE2_MULT_IN_THREE_CYCLE
