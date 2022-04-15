/*************************************************

 Copyright: NUDT_CoreLight

 File name: axi_stream_trans.svh

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 axi-stream transaction. The transaction here is a transfer 
 in axi-stream

 **************************************************/

class axi_stream_trans extends uvm_sequence_item;
    
    function new(string name = "axi_stream_trans");
        super.new(name);
    endfunction

    int timeout = 32;

    rand bit [`AXIS_DATA_WIDTH-1:0] tdata;
    rand bit [`AXIS_STRB_WIDTH-1:0] tkeep;
    rand bit [`AXIS_STRB_WIDTH-1:0] tstrb;

    rand bit tid;
    rand bit tlast;
    rand bit tdest;
    rand bit tuser;

    `uvm_object_utils_begin(axi_stream_trans)
        `uvm_field_int(tdata, UVM_ALL_ON)
        `uvm_field_int(tkeep, UVM_ALL_ON)
        `uvm_field_int(tstrb, UVM_ALL_ON)
        `uvm_field_int(tid, UVM_ALL_ON)
        `uvm_field_int(tlast, UVM_ALL_ON)
        `uvm_field_int(tdest, UVM_ALL_ON)
        `uvm_field_int(tuser, UVM_ALL_ON)
    `uvm_object_utils_end
    
endclass