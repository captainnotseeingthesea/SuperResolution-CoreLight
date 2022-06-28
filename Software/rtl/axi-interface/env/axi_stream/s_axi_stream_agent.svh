/*************************************************

 Copyright: NUDT_CoreLight

 File name: s_axi_stream_agent.svh

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 Agent for axi-stream slave.

 **************************************************/

 class s_axi_stream_agent extends uvm_agent;


    `uvm_component_utils(s_axi_stream_agent)
    
    function new(string name = "s_axi_stream_agent", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    // A driver, a monitor, a dumper
    s_axi_stream_driver drv;
    s_axi_stream_monitor mon;
    axis_bmp_dumper dmp;

    // An analysis port points to ap inside monitor
    uvm_analysis_port #(axi_stream_trans) ap;

    // An fifo from monitor to dumper
    uvm_tlm_analysis_fifo #(axi_stream_trans) mon_dmp_fifo;

    // Whether to dump or not
    int dump_enable = 0;


    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    
endclass


// Methods
function void s_axi_stream_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(is_active == UVM_ACTIVE) begin
        drv = s_axi_stream_driver::type_id::create("drv", this); 
    end
    if(dump_enable) begin
        dmp = axis_bmp_dumper::type_id::create("dmp", this);
        mon_dmp_fifo = new("mon_dmp_fifo", this);
    end
    mon = s_axi_stream_monitor::type_id::create("mon", this);
endfunction: build_phase


function void s_axi_stream_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(dump_enable) begin
       mon.ap.connect(mon_dmp_fifo.analysis_export);
       dmp.dump_port.connect(mon_dmp_fifo.blocking_get_export);
    end
    ap = mon.ap;
endfunction: connect_phase
