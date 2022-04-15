/*************************************************

 Copyright: NUDT_CoreLight

 File name: bcci_ip_env.svh

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 Enviroment for bcci ip.

 **************************************************/

class bcci_ip_env extends base_env;
    
    
    `uvm_component_utils(bcci_ip_env)

    function new(string name = "bcci_ip_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);

endclass


// Methods
function void bcci_ip_env::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Disable upup driver because we already have ip.
    upsp_agt.is_active = UVM_PASSIVE;
endfunction: build_phase