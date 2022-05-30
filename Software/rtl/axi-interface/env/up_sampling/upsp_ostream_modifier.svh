/*************************************************

 Copyright: NUDT_CoreLight

 File name: upsp_ostream_modifier.svh

 Author: NUDT_CoreLight

 Date: 2021-04-11


 Description:

 upsp out stream modifier. Transform to stream from 4x4 into line by line.

 **************************************************/

 class upsp_ostream_modifier extends uvm_component;

    
    `uvm_component_utils(upsp_ostream_modifier)

    function new(string name = "upsp_ostream_modifier", uvm_component parent);
        super.new(name, parent);
    endfunction

    uvm_blocking_get_port #(upsp_trans) istream;
    uvm_analysis_port #(upsp_trans) ostream;

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    
endclass


// Methods
function void upsp_ostream_modifier::build_phase(uvm_phase phase);
    super.build_phase(phase);
    istream = new("istream", this);
    ostream = new("ostream", this);
endfunction: build_phase



task upsp_ostream_modifier::main_phase(uvm_phase phase);
    upsp_trans tmp;

    while(1) begin
        istream.get(tmp);
        ostream.write(tmp);
    end
    
endtask: main_phase
