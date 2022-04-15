/*************************************************

 Copyright: NUDT_CoreLight

 File name: bcci_ip_test.svh

 Author: NUDT_CoreLight

 Date: 2021-04-14


 Description:

 **************************************************/

class bcci_ip_test extends base_test
#(.env_t(bcci_ip_env));
    
    `uvm_component_utils(bcci_ip_test)

    function new(string name = "bcci_ip_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);

endclass


// Method
function void bcci_ip_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    uvm_config_db#(uvm_object_wrapper)::set(this, 
     "env.axil_agt.sqr.main_phase", 
     "default_sequence",
     axil_seq::type_id::get());

     uvm_config_db#(uvm_object_wrapper)::set(this, 
     "env.m_axis_agt.sqr.main_phase", 
     "default_sequence",
     bmp_seq::type_id::get());

endfunction: build_phase
