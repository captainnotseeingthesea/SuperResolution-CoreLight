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

    rand bit [7:0] tdata[$];
    rand bit       tkeep[$];
    rand bit       tstrb[$];

    rand bit tid;
    rand bit tlast;
    rand bit tdest;
    rand bit tuser;

    // Delay for this trans
    rand int unsigned delay = 0;
    constraint DELAY;
    constraint Q_SIZE;

    `uvm_object_utils_begin(axi_stream_trans)
        `uvm_field_queue_int(tdata, UVM_ALL_ON)
        `uvm_field_queue_int(tkeep, UVM_ALL_ON)
        `uvm_field_queue_int(tstrb, UVM_ALL_ON)
        `uvm_field_int(tid, UVM_ALL_ON)
        `uvm_field_int(tlast, UVM_ALL_ON)
        `uvm_field_int(tdest, UVM_ALL_ON)
        `uvm_field_int(tuser, UVM_ALL_ON)
        `uvm_field_int(delay, UVM_ALL_ON|UVM_NOCOMPARE)
    `uvm_object_utils_end
    
endclass


constraint axi_stream_trans::DELAY {
    delay >= 0;
    delay <= 5;
}

constraint axi_stream_trans::Q_SIZE {
    tkeep.size() <= 16;
    tdata.size() == tkeep.size();
    tstrb.size() == tkeep.size();
}