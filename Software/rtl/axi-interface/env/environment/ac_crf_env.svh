/*************************************************

 Copyright: NUDT_CoreLight

 File name: ac_crf_env.svh

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 Enviroment for access control and config register file.

 **************************************************/

class ac_crf_env extends base_env;
    
    
    `uvm_component_utils(ac_crf_env)

    function new(string name = "ac_crf_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

endclass


// Methods
function void ac_crf_env::build_phase(uvm_phase phase);
    super.build_phase(phase);

    axil_agt.is_active = UVM_ACTIVE;
    m_axis_agt.is_active = UVM_ACTIVE;
    s_axis_agt.is_active = UVM_ACTIVE;
    s_axis_agt.dump_enable = 0;
    upsp_agt.is_active = UVM_ACTIVE;

endfunction: build_phase


function void ac_crf_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Expected input stream to iboard
    m_axis_agt.ap.connect(istream_iboard_fifo.analysis_export);
    istream_board.exp_port.connect(istream_iboard_fifo.blocking_get_export);

    // Actual input stream to iboard
    upsp_agt.upsp_rdap.connect(upsp_iboard_fifo.analysis_export);
    istream_board.act_port.connect(upsp_iboard_fifo.blocking_get_export);

    // Expected out stream to oboard
    upsp_agt.upsp_wrtap.connect(upsp_oboard_fifo.analysis_export);
    ostream_board.exp_port.connect(upsp_oboard_fifo.blocking_get_export);
    
    // Actual out stream to oboard
    s_axis_agt.ap.connect(ostream_oboard_fifo.analysis_export);
    ostream_board.act_port.connect(ostream_oboard_fifo.blocking_get_export);
endfunction: connect_phase