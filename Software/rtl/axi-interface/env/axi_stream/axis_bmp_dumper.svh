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
    bit [2:0] [7:0] data[];

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
        `uvm_fatal(get_name(), "src_bin must be set!")
    if(!uvm_config_db#(string)::get(this, "", "dst_bmp", dst_bmp))
        `uvm_fatal(get_name(), "dst_bmp must be set!")
    if(!uvm_config_db#(int)::get(this, "", "height", height))
        `uvm_fatal(get_name(), "height must be set!")
    if(!uvm_config_db#(int)::get(this, "", "width", width))
        `uvm_fatal(get_name(), "width must be set!")
    dump_port = new("dump_port", this);
endfunction: build_phase


task axis_bmp_dumper::main_phase(uvm_phase phase);
    axi_stream_trans t;
    int pos = 0;
    phase.raise_objection(this);

    data = new[height*width];
    pos = 0;

    $display("dumper combined array size is %d\n", data.size());

    while(1) begin
        dump_port.get(t);

        for(int k = 0; k < t.tkeep.size(); k++) begin
            if(t.tkeep[k]) begin
                if(t.tstrb[k]) 
                    data[pos/3][2-pos%3] = t.tdata[k];
                pos++;
            end
        end
        
        if(pos == data.size()*3) begin
            `uvm_info(get_name(), "start dumping file", UVM_LOW)
            $writememh(src_bin, data);
            BMP::bin2bmp(src_bin, dst_bmp, height, width);
            `uvm_info(get_name(), "dumping over", UVM_LOW)
            break; 
        end
    end

    #1000;
    phase.drop_objection(this);
endtask: main_phase