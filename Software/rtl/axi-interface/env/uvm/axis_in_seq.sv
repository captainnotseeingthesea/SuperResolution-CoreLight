/*************************************************

 Copyright: NUDT_CoreLight

 File name: axis_in_seq.sv

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 Sequence for input axi-stream.

 **************************************************/

 class axis_in_seq extends uvm_sequence #(axi_stream_trans);
    
    `uvm_object_utils(axis_in_seq)

    function new(string name = "axis_in_seq");
        super.new(name);
    endfunction: new

    axi_stream_trans t;

    int i = 0;

    virtual task body();
        if(starting_phase != null)
            starting_phase.raise_objection(this);

        // Input stream
        repeat(`SRC_IMG_WIDTH*`SRC_IMG_HEIGHT-1) begin
            `uvm_do_with(t, {
                &t.tkeep == 1;
                &t.tstrb == 1;
                t.tid    == 0;
                t.tlast  == 0;
                t.tdest  == 0;
                t.tuser  == 0;
            })
            i++;
            if(i % `SRC_IMG_WIDTH == 0)
            `uvm_info(get_name() ,$sformatf("Send %d", i), UVM_HIGH)
            
        end
        // The last pixel
        `uvm_do_with(t, {
            &t.tkeep == 1;
            &t.tstrb == 1;
            t.tid    == 0;
            t.tlast  == 1;
            t.tdest  == 0;
            t.tuser  == 0;
        })

        `uvm_info(get_name() ,"axis_in_seq finished", UVM_LOW)

        #1000;
        if(starting_phase != null)
            starting_phase.drop_objection(this);
    endtask

endclass: axis_in_seq