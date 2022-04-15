/*************************************************

 Copyright: NUDT_CoreLight

 File name: ac_crf_base_test.svh

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 Base test for access control and config register file.

 **************************************************/

class ac_crf_base_test extends base_test 
#(.env_t(ac_crf_env));
    
    
    `uvm_component_utils(ac_crf_base_test)

    function new(string name = "ac_crf_base_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);

endclass


// Methods
function void ac_crf_base_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    uvm_config_db#(uvm_object_wrapper)::set(this, 
     "env.axil_agt.sqr.main_phase", 
     "default_sequence",
     axil_seq::type_id::get());

     uvm_config_db#(uvm_object_wrapper)::set(this, 
     "env.m_axis_agt.sqr.main_phase", 
     "default_sequence",
     axis_in_seq::type_id::get());

     uvm_config_db#(uvm_object_wrapper)::set(this, 
     "env.upsp_agt.sqr.main_phase", 
     "default_sequence",
     upsp_seq::type_id::get());
endfunction: build_phase
