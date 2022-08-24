/*************************************************

 Copyright: NUDT_CoreLight

 File name: upsp_trans.svh

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 Base transaction for upsp.

 **************************************************/

class upsp_trans extends uvm_sequence_item;

    function new(string name = "upsp_trans");
        super.new(name);
    endfunction: new

    int timeout = `DST_IMG_WIDTH*8;

    rand bit [7:0] data[$];
    constraint Q_SIZE;

    `uvm_object_utils_begin(upsp_trans)
        `uvm_field_queue_int(data, UVM_ALL_ON)
    `uvm_object_utils_end
    
endclass: upsp_trans

constraint upsp_trans::Q_SIZE {
    data.size() <= 16;
}