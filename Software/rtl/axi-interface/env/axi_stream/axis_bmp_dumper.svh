/*************************************************

 Copyright: NUDT_CoreLight

 File name: axis_bmp_dumper.svh

 Author: NUDT_CoreLight

 Date: 2021-04-14


 Description:

 Dump an axi-stream.

 **************************************************/

class axis_bmp_dumper extends uvm_component;


    `uvm_component_utils(axis_bmp_dumper)
    
    function new(string name = "axis_bmp_dumper", uvm_component parent);
        super.new(name, parent);
    endfunction

    // Stream data port
    uvm_blocking_get_port #(axi_stream_trans) dump_port;
    bit [23:0] data[];

    string src_bin;
    string dst_bmp;
    int height;
    int width;

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);

endclass


// Methods
function void axis_bmp_dumper::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(string)::get(this, "", "src_bin", src_bin))
        `uvm_fatal("axis_bmp_dumper", "src_bin must be set!")
    if(!uvm_config_db#(string)::get(this, "", "dst_bmp", dst_bmp))
        `uvm_fatal("axis_bmp_dumper", "dst_bmp must be set!")
    if(!uvm_config_db#(int)::get(this, "", "height", height))
        `uvm_fatal("axis_bmp_dumper", "height must be set!")
    if(!uvm_config_db#(int)::get(this, "", "width", width))
        `uvm_fatal("axis_bmp_dumper", "width must be set!")
    dump_port = new("dump_port", this);
endfunction: build_phase


task axis_bmp_dumper::main_phase(uvm_phase phase);
    axi_stream_trans t;
    int i = 0;
    int j = 0;

    phase.raise_objection(this);

    data = new[height*width];

    while(1) begin
        dump_port.get(t);
        data[j][i] = t.tdata;
        
        if(i == width - 1) begin
            i = 0;
            if(j == height - 1)
                j = 0;
            else
                j++;
        end else
            i++;
        
        if(t.tlast) begin
            `uvm_info("axis_bmp_dumper", "tlast valid, start dumping file", UVM_LOW)
            $writememh(src_bin, data);
            $system($sformatf("bin2bmp %s %s %d %d", src_bin, dst_bmp, height, width));
            `uvm_info("axis_bmp_dumper", "dumping over", UVM_LOW)
            break; 
        end
    end

    phase.drop_objection(this);
endtask: main_phase