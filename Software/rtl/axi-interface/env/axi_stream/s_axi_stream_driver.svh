/*************************************************

 Copyright: NUDT_CoreLight

 File name: s_axi_stream_driver.svh

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 Driver as axi-lite slave. Just assert tready all the time.

 **************************************************/

class s_axi_stream_driver extends uvm_driver #(axi_stream_trans);


    `uvm_component_utils(s_axi_stream_driver)

    function new(string name = "s_axi_stream_driver", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual axi_stream_if vif;

    int receive_random = 0;

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    
endclass


// Methods
function void s_axi_stream_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual axi_stream_if)::get(this,"","vif",vif))
        `uvm_fatal(get_name(), "vif must be set!")
endfunction: build_phase


task s_axi_stream_driver::reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_name(), "<reset_phase> started, objection raised.", UVM_NONE)

    vif.axis_tready <= 1'b0;
    while(!vif.arstn) @(posedge vif.aclk);

    phase.drop_objection(this);
    `uvm_info(get_name(), "<reset_phase> finished, objection dropped.", UVM_NONE)
endtask: reset_phase


task s_axi_stream_driver::main_phase(uvm_phase phase);
    forever begin
        @(posedge vif.aclk);
        // vif.axis_tready <= receive_random? {$random}%2: 1'b1;
        vif.axis_tready <= {$random}%2;
    end
endtask: main_phase