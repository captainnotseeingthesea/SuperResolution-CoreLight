/*************************************************

 Copyright: NUDT_CoreLight

 File name: bcci_ip_env.svh

 Author: NUDT_CoreLight

 Date: 2021-04-23


 Description:

 Enviroment for bcci ip.

 **************************************************/

 class bcci_ip_env extends base_env;
    
    
    `uvm_component_utils(bcci_ip_env)

    function new(string name = "bcci_ip_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

endclass


// Methods
function void bcci_ip_env::build_phase(uvm_phase phase);
    super.build_phase(phase);
    axil_agt      = m_axi_lite_agent::type_id::create("axil_agt", this);
    upsp_agt      = upsp_agent::type_id::create("upsp_agt", this);
    s_axis_agt    = s_axi_stream_agent::type_id::create("s_axis_agt", this);   
    m_axis_agt    = m_axi_stream_agent::type_id::create("m_axis_agt", this);    

    axil_agt.is_active = UVM_ACTIVE;
    m_axis_agt.is_active = UVM_ACTIVE;
    s_axis_agt.is_active = UVM_ACTIVE;
    s_axis_agt.dump_enable = 1;

    // Disable upup driver because we already have ip.
    upsp_agt.is_active = UVM_PASSIVE;
endfunction: build_phase


function void bcci_ip_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction: connect_phase