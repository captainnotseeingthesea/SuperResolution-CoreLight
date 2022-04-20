/*************************************************

 Copyright: NUDT_CoreLight

 File name: base_env.svh

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 **************************************************/

class base_env extends uvm_env;
    
    
    `uvm_component_utils(base_env)

    function new(string name = "base_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    // Components
    m_axi_lite_agent      axil_agt;
    m_axi_stream_agent    m_axis_agt;
    s_axi_stream_agent    s_axis_agt;
    upsp_agent            upsp_agt;
    stream_in_scoreboard  istream_board;
    stream_out_scoreboard ostream_board;

    // Fifos
    uvm_tlm_analysis_fifo #(axi_stream_trans) istream_iboard_fifo;
    uvm_tlm_analysis_fifo #(upsp_trans)       upsp_iboard_fifo;
    uvm_tlm_analysis_fifo #(upsp_trans)       upsp_oboard_fifo;
    uvm_tlm_analysis_fifo #(axi_stream_trans) ostream_oboard_fifo;

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    
endclass


// Methods
function void base_env::build_phase(uvm_phase phase);
    super.build_phase(phase);
    axil_agt      = m_axi_lite_agent::type_id::create("axil_agt", this);
    upsp_agt      = upsp_agent::type_id::create("upsp_agt", this);
    s_axis_agt    = s_axi_stream_agent::type_id::create("s_axis_agt", this);   
    m_axis_agt    = m_axi_stream_agent::type_id::create("m_axis_agt", this);    
    istream_board = stream_in_scoreboard::type_id::create("istream_board", this); 
    ostream_board = stream_out_scoreboard::type_id::create("ostream_board", this);

    istream_iboard_fifo = new("istream_iboard_fifo", this);
    upsp_iboard_fifo    = new("upsp_iboard_fifo", this);
    upsp_oboard_fifo    = new("upsp_oboard_fifo", this);
    ostream_oboard_fifo = new("ostream_oboard_fifo", this);
endfunction: build_phase


function void base_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction: connect_phase
