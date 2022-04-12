/*************************************************

 Copyright: NUDT_CoreLight

 File name: upsp_sqr.sv

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 Sequencer for upsp.

 **************************************************/

class upsp_sqr extends uvm_sequencer #(upsp_trans);
    
    
    `uvm_component_utils(upsp_sqr)

    function new(string name = "upsp_sqr", uvm_component parent);
        super.new(name, parent);
    endfunction

endclass