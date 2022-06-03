/*************************************************

 Copyright: NUDT_CoreLight

 File name: m_axi_stream_agent.svh

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 Agent for axi-stream master.

 **************************************************/

 class m_axi_stream_agent extends uvm_agent;


    `uvm_component_utils(m_axi_stream_agent)
    
    function new(string name = "m_axi_stream_agent", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    // A sequencer, a driver, a monitor
    m_axi_stream_sqr    sqr;
    m_axi_stream_driver drv;
    m_axi_stream_monitor  mon;

    // An analysis port points to ap inside monitor
    uvm_analysis_port #(axi_stream_trans) ap;

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    
endclass


// Methods
function void m_axi_stream_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(is_active == UVM_ACTIVE) begin
        sqr = m_axi_stream_sqr::type_id::create("sqr", this);
        drv = m_axi_stream_driver::type_id::create("drv", this); 
    end
    mon = m_axi_stream_monitor::type_id::create("mon", this);
endfunction: build_phase


function void m_axi_stream_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(is_active == UVM_ACTIVE) begin
        drv.seq_item_port.connect(sqr.seq_item_export);
    end
    ap = mon.ap;
endfunction: connect_phase
