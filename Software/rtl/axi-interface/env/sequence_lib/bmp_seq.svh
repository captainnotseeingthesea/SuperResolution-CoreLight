/*************************************************

 Copyright: NUDT_CoreLight

 File name: bmp_seq.svh

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 Sequence for axi-lite.

 **************************************************/

class bmp_seq extends uvm_sequence #(axi_stream_trans);

    `uvm_object_utils(bmp_seq)

    function new(string name = "bmp_seq");
        super.new(name);
    endfunction: new

    axi_stream_trans t;

    string src_bmp;
    string dst_bin;
    int height;
    int width;

    extern virtual task pre_body();
    extern virtual task body();

endclass: bmp_seq


// Methods
task bmp_seq::pre_body();
    if(!uvm_config_db#(string)::get(null, get_full_name(), "src_bmp", src_bmp))
        `uvm_fatal(get_name(), "src_bmp must be set!")
    if(!uvm_config_db#(string)::get(null, get_full_name(), "dst_bin", dst_bin))
        `uvm_fatal(get_name(), "dst_bin must be set!")
    if(!uvm_config_db#(int)::get(null, get_full_name(), "height", height))
        `uvm_fatal(get_name(), "height must be set!")
    if(!uvm_config_db#(int)::get(null, get_full_name(), "width", width))
        `uvm_fatal(get_name(), "width must be set!")
endtask


task bmp_seq::body();
    bit[23:0] img[];
    int i = 0;

    img = new[width * height];

    // Transform the bmp file into binary and read
    BMP::bmp2bin(src_bmp, dst_bin);
    $readmemh(dst_bin, img);

    `uvm_info(get_name(), "generated binary from bmp", UVM_LOW)

    if(starting_phase != null)
        starting_phase.raise_objection(this);
    
    // Input stream
    repeat(width * height) begin
        `uvm_create(t)
        t.timeout = 16*height*width;
        `uvm_rand_send_with(t, {
            &t.tkeep == 1;
            &t.tstrb == 1;
            t.tid    == 0;
            t.tlast  == (i == width*height - 1);
            t.tdest  == 0;
            t.tuser  == 0;
            t.tdata  == img[i];
            t.delay  == 0;
        })
        i++;
        if(i % width == 0)
        `uvm_info(get_name() ,$sformatf("Send %d", i), UVM_HIGH)
        
    end
    `uvm_info(get_name() ,"bmp_seq finished", UVM_LOW)

    if(starting_phase != null)
        starting_phase.drop_objection(this);
endtask