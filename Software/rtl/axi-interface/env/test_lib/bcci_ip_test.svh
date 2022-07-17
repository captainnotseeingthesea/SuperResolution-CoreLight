/*************************************************

 Copyright: NUDT_CoreLight

 File name: bcci_ip_test.svh

 Author: NUDT_CoreLight

 Date: 2021-04-23


 Description:

 **************************************************/

class bcci_ip_test extends base_test
#(.env_t(bcci_ip_env));
    
    `uvm_component_utils(bcci_ip_test)

    int N_run = 4;

    function new(string name = "bcci_ip_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task post_main_phase(uvm_phase phase);

endclass


// Method
function void bcci_ip_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    uvm_config_db#(uvm_object_wrapper)::set(this, 
     "env.axil_agt.sqr.configure_phase", 
     "default_sequence",
     axil_start_seq::type_id::get());

    uvm_config_db#(uvm_object_wrapper)::set(this,
     "env.axil_agt.sqr.main_phase", 
     "default_sequence", 
     axil_end_seq::type_id::get());

    uvm_config_db#(uvm_object_wrapper)::set(this, 
     "env.m_axis_agt.sqr.main_phase", 
     "default_sequence",
     bmp_seq::type_id::get());

    N_run--;

endfunction: build_phase


task bcci_ip_test::post_main_phase(uvm_phase phase);
    // phase.raise_objection(this);

    if(N_run > 0) begin

        uvm_config_db#(uvm_object_wrapper)::set(this, 
        "env.axil_agt.sqr.configure_phase", 
        "default_sequence",
        axil_start_seq::type_id::get());
   
       uvm_config_db#(uvm_object_wrapper)::set(this,
        "env.axil_agt.sqr.main_phase", 
        "default_sequence", 
        axil_end_seq::type_id::get());
   
       uvm_config_db#(uvm_object_wrapper)::set(this, 
        "env.m_axis_agt.sqr.main_phase", 
        "default_sequence",
        bmp_seq::type_id::get());

        N_run--;
        phase.jump(uvm_configure_phase::get());
    end

    // phase.drop_objection(this);

endtask: post_main_phase
