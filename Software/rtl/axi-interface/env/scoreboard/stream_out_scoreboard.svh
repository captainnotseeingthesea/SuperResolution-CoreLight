/*************************************************

 Copyright: NUDT_CoreLight

 File name: stream_out_scoreboard.svh

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 Compare upsp driver write stream and s-axi-stream driver
 receive stream.

 **************************************************/

class stream_out_scoreboard extends base_scoreboard
#(.exp_t(upsp_trans), .act_t(axi_stream_trans));
    
    
    `uvm_component_utils(stream_out_scoreboard)

    function new(string name = "stream_out_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    extern function void exp2act(upsp_trans src, axi_stream_trans target);
    extern function int compare(act_t a, act_t b);

endclass


// Methods
function void stream_out_scoreboard::exp2act(upsp_trans src, axi_stream_trans target);
    axi_stream_trans t;
    t = new("t");
    assert(t.randomize() with {
        &tkeep == 1;
        &tstrb == 1;
        tid    == 0;
        tlast  == 0;
        tdest  == 0;
        tuser  == 0;
    });

    target.copy(t);
    target.tdata = src.data;
endfunction


function int stream_out_scoreboard::compare(act_t a, act_t b);
    return (a.tdata == b.tdata);
endfunction