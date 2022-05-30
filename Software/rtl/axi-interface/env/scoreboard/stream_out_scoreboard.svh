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
    
    int count = 0;

    extern function void exp2act(exp_t src, act_t target);
    extern function int compare(act_t a, act_t b);

endclass


// Methods
function void stream_out_scoreboard::exp2act(exp_t src, act_t target);
    act_t t;
    t = new("t");
    assert(t.randomize() with {
        t.tdata.size() == `AXISOUT_DATA_WIDTH/8;
        foreach(t.tkeep[k]) t.tkeep[k] == 1;
        foreach(t.tstrb[k]) t.tkeep[k] == 1;
        tid    == 0;
        tlast  == 0;
        tdest  == 0;
        tuser  == 0;
    });

    if(count == 0) begin
        t.tkeep[0:2*3-1] = {0, 0, 0, 0, 0, 0};
        t.tstrb[0:2*3-1] = {0, 0, 0, 0, 0, 0};
    end
    if(count >= `DST_IMG_WIDTH * `DST_IMG_HEIGHT - 4) begin
        t.tkeep[`AXISOUT_DATA_WIDTH/8-2*3:`AXISOUT_DATA_WIDTH/8-1] = {0, 0, 0, 0, 0, 0};
        t.tstrb[`AXISOUT_DATA_WIDTH/8-2*3:`AXISOUT_DATA_WIDTH/8-1] = {0, 0, 0, 0, 0, 0};
    end

    foreach(t.tkeep[i])
        count += t.tkeep[i];

    target.copy(t);
    target.tdata = src.data;
endfunction


function int stream_out_scoreboard::compare(act_t a, act_t b);
    return (a.tdata == b.tdata);
endfunction