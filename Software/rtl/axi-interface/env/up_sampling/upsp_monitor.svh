/*************************************************

 Copyright: NUDT_CoreLight

 File name: upsp_monitor.svh

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 Monitor for upsp. Two aps for upsp read data and upsp
 write data.

 **************************************************/

class upsp_monitor extends uvm_monitor;
    
    
    `uvm_component_utils(upsp_monitor)

    function new(string name = "upsp_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual upsp_if vif;
    uvm_analysis_port #(upsp_trans) upsp_wrtap;
    uvm_analysis_port #(upsp_trans) upsp_rdap;

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    
endclass


// Methods
function void upsp_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual upsp_if)::get(this, "", "vif", vif))
        `uvm_fatal(get_name(), "vif must be set!")
    upsp_wrtap = new("upsp_wrtap", this);
    upsp_rdap = new("upsp_rdap", this);
endfunction: build_phase


task upsp_monitor::main_phase(uvm_phase phase);
    upsp_trans rt, wt;

    forever begin
        if(vif.ac_upsp_rvalid & vif.upsp_ac_rready) begin
            rt = new("upsprt");
            rt.data = vif.ac_upsp_rdata;
            upsp_rdap.write(rt);
        end

        if(vif.upsp_ac_wvalid && vif.ac_upsp_wready) begin
            wt = new("upspwt");
            wt.data = vif.upsp_ac_wdata;
            upsp_wrtap.write(wt);
        end
        @(posedge vif.clk);
    end
endtask: main_phase