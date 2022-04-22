/*************************************************

 Copyright: NUDT_CoreLight

 File name: m_axi_stream_driver.svh

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 Driver as axi-stream master, put an axi-stream transaction 
 on bus.

 **************************************************/

class m_axi_stream_driver extends uvm_driver # (axi_stream_trans);


    `uvm_component_utils(m_axi_stream_driver)

    function new(string name = "m_axi_stream_driver", uvm_component parent);
      super.new(name, parent);
    endfunction

    virtual axi_stream_if vif;

    int count;

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    
    extern task write_one_trans(axi_stream_trans t);
    
endclass


// Methods
function void m_axi_stream_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual axi_stream_if)::get(this,"","vif",vif))
        `uvm_fatal(get_name(), "vif must be set!")
endfunction


task m_axi_stream_driver::reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_name(), "<reset_phase> started, objection raised.", UVM_NONE)

    count = 0;

    vif.axis_tvalid <= 0;
    vif.axis_tid    <= 0;
    vif.axis_tdata  <= 0;
    vif.axis_tkeep  <= 0;
    vif.axis_tstrb  <= 0;
    vif.axis_tlast  <= 0;
    vif.axis_tdest  <= 0;
    vif.axis_user   <= 0;
    while(!vif.arstn) @(posedge vif.aclk);

    phase.drop_objection(this);
    `uvm_info(get_name(), "<reset_phase> finished, objection dropped.", UVM_NONE)
endtask: reset_phase


task m_axi_stream_driver::main_phase(uvm_phase phase);
    while(1) begin
        seq_item_port.get_next_item(req);
        write_one_trans(req);
        seq_item_port.item_done();
        count++;
    end
endtask: main_phase


task m_axi_stream_driver::write_one_trans(axi_stream_trans t);
    int i;
    vif.axis_tvalid <= 1'b0    ;
    repeat(t.delay) @(posedge vif.aclk);

    vif.axis_tvalid <= 1'b1    ;
    vif.axis_tid    <= t.tid   ;
    vif.axis_tdata  <= t.tdata ;
    vif.axis_tkeep  <= t.tkeep ;
    vif.axis_tstrb  <= t.tstrb ;
    vif.axis_tlast  <= t.tlast ;
    vif.axis_tdest  <= t.tdest ;
    vif.axis_user   <= t.tuser ;

    for(i = 0; i < t.timeout; i++) begin
        if(vif.axis_tvalid && vif.axis_tready) break;
        @(posedge vif.aclk);
    end
    if(i == t.timeout) `uvm_error(get_name(), $sformatf("%d'th transaction waits tready for too many cycles", count))
    vif.axis_tvalid <= 0;
endtask