/*************************************************

 Copyright: NUDT_CoreLight

 File name: ac_crf_env.svh

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 Enviroment for access control and config register file.

 **************************************************/

class ac_crf_env extends base_env;
    
    
    `uvm_component_utils(ac_crf_env)

    function new(string name = "ac_crf_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    
endclass


// Methods
function void ac_crf_env::build_phase(uvm_phase phase);
    super.build_phase(phase);

    s_axis_agt.dump_enable = 0;
endfunction: build_phase