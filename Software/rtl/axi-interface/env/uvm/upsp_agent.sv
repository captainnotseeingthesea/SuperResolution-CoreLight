/*************************************************

 Copyright: NUDT_CoreLight

 File name: upsp_agent.sv

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 upsp agent.

 **************************************************/

class upsp_agent extends uvm_agent;
    
    
    `uvm_component_utils(upsp_agent)

    function new(string name = "upsp_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    upsp_sqr     sqr;
    upsp_driver  drv;
    upsp_monitor mon;

    upsp_ostream_modifier mod;

    // Read write aps
    uvm_analysis_port #(upsp_trans) upsp_rdap;
    uvm_analysis_port #(upsp_trans) upsp_wrtap;

    // Fifo for monitor to modifier
    uvm_tlm_analysis_fifo #(upsp_trans) mon2mod_fifo;

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    
endclass


// Methods
function void upsp_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(is_active == UVM_ACTIVE) begin
        sqr = upsp_sqr::type_id::create("sqr", this);
        drv = upsp_driver::type_id::create("drv", this);
    end
    mon = upsp_monitor::type_id::create("mon", this);
    mod = upsp_ostream_modifier::type_id::create("mod", this);
    mon2mod_fifo = new("mon2mod_fifo", this);
endfunction: build_phase


function void upsp_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(is_active == UVM_ACTIVE) begin
        drv.seq_item_port.connect(sqr.seq_item_export);
    end

    mon.upsp_wrtap.connect(mon2mod_fifo.analysis_export);
    mod.istream.connect(mon2mod_fifo.blocking_get_export);
    upsp_rdap  = mon.upsp_rdap;
    upsp_wrtap = mod.ostream;

endfunction: connect_phase