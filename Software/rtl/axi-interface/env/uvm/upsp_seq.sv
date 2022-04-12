/*************************************************

 Copyright: NUDT_CoreLight

 File name: upsp_seq.sv

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 Sequence for axi-lite.

 **************************************************/

 class upsp_seq extends uvm_sequence #(upsp_trans);
    
    `uvm_object_utils(upsp_seq)

    function new(string name = "upsp_seq");
        super.new(name);
    endfunction: new

    upsp_trans t;

    int i = 0;

    virtual task body();
        if(starting_phase != null)
            starting_phase.raise_objection(this);

        // Output stream
        repeat(`DST_IMG_WIDTH*`DST_IMG_HEIGHT) begin
            `uvm_do(t)
            
            i++;
            if(i % `DST_IMG_WIDTH == 0)
            `uvm_info(get_name() ,$sformatf("Send %d", i), UVM_HIGH)
            
        end
        `uvm_info(get_name(), "upsp_seq finished", UVM_LOW)
        
        #10000000;
        if(starting_phase != null)
            starting_phase.drop_objection(this);
    endtask

endclass: upsp_seq