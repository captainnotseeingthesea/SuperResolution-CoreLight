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
    upsp_trans buffer[4][`DST_IMG_WIDTH];
    int idx = 0;
    int base = 0, count = 0;

    while(1) begin
        istream.get(tmp);

        count = idx % 16;
        base = (idx - count)/4;

        // Store 16 trans into a 4x4 matrix
        buffer[count[3:2]][base + count[1:0]] = tmp;
        idx++;

        // Ouput a line by line stream
        if(idx == 4 * `DST_IMG_WIDTH) begin
            foreach(buffer[i,j]) ostream.write(buffer[i][j]);
            idx = 0;
        end
    end
    
endtask: main_phase
