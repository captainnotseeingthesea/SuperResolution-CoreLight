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
    int count = 0;
    int img_width = `DST_IMG_WIDTH;
    bit [95:0] full;
    bit [47:0] half;

    while(1) begin
        istream.get(tmp);

        if(count%img_width == 0) begin
            full = {>>{tmp.data}};
            half = full[47:0];
            count += 2;
        end else if(count%img_width == img_width-2) begin
            full = {>>{tmp.data}};
            tmp.data.delete();
            {>>{tmp.data}} = {half, full[95:48]};
            count += 2;
            // $display("modifier generated %d \n", count);
            // tmp.print();
            ostream.write(tmp);
        end else begin
            full = {>>{tmp.data}};
            tmp.data.delete();
            {>>{tmp.data}} = {half, full[95:48]};
            half = full[47:0];
            count += 4;
            // $display("modifier generated %d \n", count);
            // tmp.print();
            ostream.write(tmp);
        end
    end
    
endtask: main_phase
