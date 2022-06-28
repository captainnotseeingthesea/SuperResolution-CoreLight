/*************************************************

 Copyright: NUDT_CoreLight

 File name: axil_end_seq.svh

 Author: NUDT_CoreLight

 Date: 2021-04-22


 Description:

 Sequence for axi-lite.

 **************************************************/

class axil_end_seq extends uvm_sequence #(axi_lite_trans);
    
    `uvm_object_utils(axil_end_seq)

    function new(string name = "axil_end_seq");
        super.new(name);
    endfunction: new

    axi_lite_trans t;

    extern virtual task body();

endclass: axil_end_seq


// Methods
task axil_end_seq::body();
    if(starting_phase != null)
        starting_phase.raise_objection(this);
    
    // Clear UPENDR
    `uvm_do_with(t, {
        t.awaddr  == 0;
        t.awprot  == 0;
        t.wdata   == 0;
        &t.wstrb  == 1;
        t.bresp   == 0;
        t.araddr  == 0;
        t.arprot  == 0;
        t.rdata   == 0;
        t.rresp   == 0;
    })
    `uvm_info(get_name(), "axil_end_seq finished", UVM_LOW)
    
    #1000;
    if(starting_phase != null)
        starting_phase.drop_objection(this);
endtask