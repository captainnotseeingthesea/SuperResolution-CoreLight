/*************************************************

 Copyright: NUDT_CoreLight

 File name: axi_lite_trans.svh

 Author: NUDT_CoreLight

 Date: 2021-04-09


 Description:

 axi-lite transaction. The transaction here is a transfer 
 in axi-lite

 **************************************************/

class axi_lite_trans extends uvm_sequence_item;

    function new(string name = "axi_lite_trans");
        super.new(name);
    endfunction

    int timeout = 32;

    // AW
    rand bit [`AXI_ADDR_WIDTH-1:0] awaddr;
    rand bit [2:0]                 awprot;
    // W
    rand bit [`AXI_DATA_WIDTH-1:0] wdata;
    rand bit [`AXI_STRB_WIDTH-1:0] wstrb;
    // B
    rand bit [1:0]                 bresp;
    // AR
    rand bit [`AXI_ADDR_WIDTH-1:0] araddr;
    rand bit [2:0]                 arprot;
    // R
    rand bit [`AXI_DATA_WIDTH-1:0] rdata;
    rand bit [1:0]                 rresp;

    `uvm_object_utils_begin(axi_lite_trans)
        `uvm_field_int(awaddr, UVM_ALL_ON)
        `uvm_field_int(awprot,UVM_ALL_ON)
        `uvm_field_int(wdata,UVM_ALL_ON)
        `uvm_field_int(wstrb,UVM_ALL_ON)
        `uvm_field_int(bresp,UVM_ALL_ON)
        `uvm_field_int(araddr,UVM_ALL_ON)
        `uvm_field_int(arprot,UVM_ALL_ON)
        `uvm_field_int(rdata,UVM_ALL_ON)
        `uvm_field_int(rresp,UVM_ALL_ON)
    `uvm_object_utils_end
    
endclass