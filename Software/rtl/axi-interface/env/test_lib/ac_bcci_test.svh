/*************************************************

 Copyright: NUDT_CoreLight

 File name: ac_bcci_test.svh

 Author: NUDT_CoreLight

 Date: 2021-04-14


 Description:

 **************************************************/

class ac_bcci_test extends base_test
#(.env_t(ac_bcci_env));
    
    `uvm_component_utils(ac_bcci_test)

    function new(string name = "ac_bcci_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);

endclass


// Method
function void ac_bcci_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    uvm_config_db#(uvm_object_wrapper)::set(this, 
     "env.axil_agt.sqr.configure_phase", 
     "default_sequence",
     axil_start_seq::type_id::get());

    uvm_config_db#(uvm_object_wrapper)::set(this,
     "env.axil_agt.sqr.post_main_phase", 
     "default_sequence", 
     axil_end_seq::type_id::get());

    uvm_config_db#(uvm_object_wrapper)::set(this, 
     "env.m_axis_agt.sqr.main_phase", 
     "default_sequence",
     bmp_seq::type_id::get());

endfunction: build_phase
