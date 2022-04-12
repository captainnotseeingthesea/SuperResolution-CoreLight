/*************************************************

 Copyright: NUDT_CoreLight

 File name: axi_stream_monitor.sv

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 Monitoring an axi-stream bus, create a transactin
 for each transfer.

 **************************************************/

class axi_stream_monitor extends uvm_monitor;


    `uvm_component_utils(axi_stream_monitor)
    
    function new(string name = "axi_stream_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    uvm_analysis_port #(axi_stream_trans) ap;
    virtual axi_stream_if vif;

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);

endclass


// Methods
function void axi_stream_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual axi_stream_if)::get(this,"","vif",vif))
        `uvm_fatal(get_name(), "vif must be set!")
    ap = new("ap", this);
endfunction: build_phase


task axi_stream_monitor::main_phase(uvm_phase phase);
    axi_stream_trans t;
    forever begin
        if(vif.axis_tvalid && vif.axis_tready) begin
            t = new("axis_t");
            t.tid   =  vif.axis_tid  ;
            t.tdata =  vif.axis_tdata;
            t.tkeep =  vif.axis_tkeep;
            t.tstrb =  vif.axis_tstrb;
            t.tlast =  vif.axis_tlast;
            t.tdest =  vif.axis_tdest;
            t.tuser =  vif.axis_user ;
            ap.write(t);
            t.print();
        end
        @(posedge vif.aclk);
    end
endtask: main_phase