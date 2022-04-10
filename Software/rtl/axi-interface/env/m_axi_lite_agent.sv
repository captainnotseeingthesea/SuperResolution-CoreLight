/*************************************************

 Copyright: NUDT_CoreLight

 File name: m_axi_lite_agent.sv

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 Agent for axi-stream master.

 **************************************************/

 class m_axi_lite_agent extends uvm_agent;


    `uvm_component_utils(m_axi_lite_agent)
    
    function new(string name = "m_axi_lite_agent", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    // A sequencer, a driver
    m_axi_lite_sqr sqr;
    m_axi_lite_driver drv;

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    
endclass


// Methods
function void m_axi_lite_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(is_active == UVM_ACTIVE) begin
        sqr = m_axi_lite_sqr::type_id::create("sqr", this);
        drv = m_axi_lite_driver::type_id::create("drv", this); 
    end
endfunction: build_phase


function void m_axi_lite_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(is_active == UVM_ACTIVE) begin
        drv.seq_item_port.connect(sqr.seq_item_export);
    end
endfunction: connect_phase
