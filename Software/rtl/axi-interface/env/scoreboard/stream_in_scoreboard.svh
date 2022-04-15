/*************************************************

 Copyright: NUDT_CoreLight

 File name: stream_in_scoreboard.svh

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 Compare axi-lite driver input stream and upsp read stream.

 **************************************************/

class stream_in_scoreboard extends base_scoreboard 
#(.exp_t(axi_stream_trans), .act_t(upsp_trans));
    
    
    `uvm_component_utils(stream_in_scoreboard)

    function new(string name = "stream_in_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    extern function void exp2act(axi_stream_trans src, upsp_trans target);
    extern function int compare(act_t a, act_t b);
endclass


// Methods
function void stream_in_scoreboard::exp2act(axi_stream_trans src, upsp_trans target);
    target.data = src.tdata;
endfunction


function int stream_in_scoreboard::compare(act_t a, act_t b);
    return a.compare(b);
endfunction