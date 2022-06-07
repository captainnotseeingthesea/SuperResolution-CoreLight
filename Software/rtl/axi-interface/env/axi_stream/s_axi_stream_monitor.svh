/*************************************************

 Copyright: NUDT_CoreLight

 File name: s_axi_stream_monitor.svh

 Author: NUDT_CoreLight

 Date: 2021-05-29


 Description:

 Monitoring output axi-stream bus, create a transactin
 for each transfer.

 **************************************************/

class s_axi_stream_monitor extends uvm_monitor;


    `uvm_component_utils(s_axi_stream_monitor)
    
    function new(string name = "s_axi_stream_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    uvm_analysis_port #(axi_stream_trans) ap;
    virtual axi_stream_if#(.AXIS_DATA_WIDTH(`AXISOUT_DATA_WIDTH)) vif;
    int axis_strb_width;

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);

endclass


// Methods
function void s_axi_stream_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual axi_stream_if#(.AXIS_DATA_WIDTH(`AXISOUT_DATA_WIDTH)))::get(this,"","vif",vif))
        `uvm_fatal(get_name(), "vif must be set!")
    ap = new("ap", this);
    axis_strb_width = vif.get_strb_width();
endfunction: build_phase


task s_axi_stream_monitor::main_phase(uvm_phase phase);
    axi_stream_trans t;

    forever begin
        if(vif.axis_tvalid && vif.axis_tready) begin
            t = new("axis_t");
            t.tid   =  vif.axis_tid  ;

            {>>{t.tdata}} = vif.axis_tdata;
            {>>{t.tkeep}} = vif.axis_tkeep;
            {>>{t.tstrb}} = vif.axis_tstrb;

            t.tlast =  vif.axis_tlast;
            t.tdest =  vif.axis_tdest;
            t.tuser =  vif.axis_user ;
            
            ap.write(t);
        end
        @(posedge vif.aclk);
    end
endtask: main_phase