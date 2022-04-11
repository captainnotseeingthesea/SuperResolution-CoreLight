/*************************************************

 Copyright: NUDT_CoreLight

 File name: ac_crf_base_test.sv

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 Base test for access control and config register file.

 **************************************************/

class ac_crf_base_test extends uvm_test;
    
    
    `uvm_component_utils(ac_crf_base_test)

    function new(string name = "ac_crf_base_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    ac_crf_env env;

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);

endclass


// Methods
function void ac_crf_base_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = ac_crf_env::type_id::create("env", this);

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


function void ac_crf_base_test::report_phase(uvm_phase phase);
    uvm_report_server server;
    int err_num;
    
    super.report_phase(phase);

    server = get_report_server();
    err_num = server.get_severity_count(UVM_ERROR);

    if(err_num == 0) begin
        $display("\n TESET PASSED");
    end else begin
        $display("\n TESET FAILED");
    end 
endfunction: report_phase
