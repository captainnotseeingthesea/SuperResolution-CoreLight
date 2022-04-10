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
        repeat(`SRC_IMG_WIDTH*`SRC_IMG_HEIGHT*4) begin
            `uvm_do(t)
            
            i++;
            if(i % `SRC_IMG_WIDTH)
            `uvm_info(get_name() ,$sformatf("Send %d", i), UVM_HIGH);
            
        end
        
        #1000;
        if(starting_phase != null)
            starting_phase.drop_objection(this);
    endtask

endclass: upsp_seq