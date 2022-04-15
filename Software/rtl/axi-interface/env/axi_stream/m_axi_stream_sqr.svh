/*************************************************

 Copyright: NUDT_CoreLight

 File name: m_axi_stream_sqr.svh

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 Sequencer for axi-stream master.

 **************************************************/

class m_axi_stream_sqr extends uvm_sequencer #(axi_stream_trans);


    `uvm_component_utils(m_axi_stream_sqr)
    
    function new(string name = "m_axi_stream_sqr", uvm_component parent);
        super.new(name, parent);
    endfunction
      
endclass