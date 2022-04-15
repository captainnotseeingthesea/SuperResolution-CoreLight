/*************************************************

 Copyright: NUDT_CoreLight

 File name: base_test.svh

 Author: NUDT_CoreLight

 Date: 2021-04-15


 Description:

 **************************************************/

class base_test #(type env_t=base_env) extends uvm_test;
    
    
    `uvm_component_utils(base_test)

    function new(string name = "base_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    env_t env;

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);

endclass


// Methods
function void base_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = env_t::type_id::create("env", this);
endfunction: build_phase


function void base_test::report_phase(uvm_phase phase);
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
