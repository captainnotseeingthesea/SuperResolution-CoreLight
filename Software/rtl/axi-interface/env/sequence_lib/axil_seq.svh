/*************************************************

 Copyright: NUDT_CoreLight

 File name: axil_seq.svh

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 Sequence for axi-lite.

 **************************************************/

class axil_seq extends uvm_sequence #(axi_lite_trans);
    
    `uvm_object_utils(axil_seq)

    function new(string name = "axil_seq");
        super.new(name);
    endfunction: new

    axi_lite_trans t;

    virtual task body();
        if(starting_phase != null)
            starting_phase.raise_objection(this);

        // Write UPSTR
        `uvm_do_with(t, {
            t.awaddr  == 0;
            t.awprot  == 0;
            t.wdata   == 1;
            &t.wstrb  == 1;
            t.bresp   == 0;
            t.araddr  == 0;
            t.arprot  == 0;
            t.rdata   == 0;
            t.rresp   == 0;
        })
        `uvm_info(get_name(), "axil_seq finished", UVM_LOW)
        
        if(starting_phase != null)
            starting_phase.drop_objection(this);
    endtask

endclass: axil_seq