/*************************************************

 Copyright: NUDT_CoreLight

 File name: m_axi_lite_driver.svh

 Author: NUDT_CoreLight

 Date: 2021-04-09


 Description:

 Driver as axi-lite master, put an axi-lite transaction 
 on bus.

 **************************************************/

class m_axi_lite_driver extends uvm_driver #(axi_lite_trans);


    `uvm_component_utils(m_axi_lite_driver)

    function new(string name = "m_axi_lite_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual axi_lite_if vif;
    virtual ac_if acif;

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task configure_phase(uvm_phase phase);
    extern virtual task post_main_phase(uvm_phase phase);
    
    extern task write_one_trans(axi_lite_trans t);
    
endclass


// Methods
function void m_axi_lite_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual axi_lite_if)::get(this, "", "vif", vif))
        `uvm_fatal(get_name(), "vif must be set!")
    if(!uvm_config_db#(virtual ac_if)::get(this, "", "acif", acif))
        `uvm_fatal(get_name(), "acif must be set!")
endfunction


task m_axi_lite_driver::reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_name(), "<reset_phase> started, objection raised.", UVM_NONE)

    vif.axi_awvalid <= 0;
    vif.axi_awaddr  <= 0;
    vif.axi_awprot  <= 0;
    vif.axi_wvalid  <= 0;
    vif.axi_wdata   <= 0;
    vif.axi_wstrb   <= 0;
    vif.axi_bready  <= 0;
    vif.axi_arvalid <= 0;
    vif.axi_araddr  <= 0;
    vif.axi_arprot  <= 0;
    vif.axi_rready  <= 0;
    while(!vif.arstn) @(posedge vif.aclk);

    phase.drop_objection(this);
    `uvm_info(get_name(), "<reset_phase> finished, objection dropped.", UVM_NONE)
endtask: reset_phase


task m_axi_lite_driver::configure_phase(uvm_phase phase);
    
    while(1) begin
        seq_item_port.get_next_item(req);
        write_one_trans(req);
        seq_item_port.item_done();
    end

endtask: configure_phase


task m_axi_lite_driver::post_main_phase(uvm_phase phase);
    
    while(acif.interrupt_updone == 1'b0) @(posedge vif.aclk);

    while(1) begin
        seq_item_port.get_next_item(req);
        write_one_trans(req);
        seq_item_port.item_done();
    end

endtask: post_main_phase


task m_axi_lite_driver::write_one_trans(axi_lite_trans t);
    int i;
    // WA handshake
    vif.axi_awvalid <= 1'b1;
    vif.axi_awaddr  <= t.awaddr;
    vif.axi_awprot  <= t.awprot;
    for(i = 0; i < t.timeout; i++) begin
        if(vif.axi_awvalid && vif.axi_awready) break;
        @(posedge vif.aclk);
    end
    if(i == t.timeout) `uvm_error(get_name(), "AW channel waits awready for too many cycles")
    vif.axi_awvalid <= 0;

    // W handshake
    vif.axi_wvalid <= 1'b1;
    vif.axi_wdata  <= t.wdata;
    vif.axi_wstrb  <= t.wstrb;
    for(i = 0; i < t.timeout; i++) begin
        if(vif.axi_wvalid && vif.axi_wready) break;
        @(posedge vif.aclk);
    end
    if(i == t.timeout) `uvm_error(get_name(), "W channel waits wready for too many cycles")
    vif.axi_wvalid <= 1'b0;

    // B handshake
    vif.axi_bready <= 1'b1;
    for(i = 0; i < t.timeout; i++) begin
        if(vif.axi_bvalid && vif.axi_bready) break;
        @(posedge vif.aclk);
    end
    if(i == t.timeout) `uvm_error(get_name(), "B channel waits bvalid for too many cycles")
    vif.axi_bready <= 1'b0;
    
    `uvm_info(get_name(), "A write transaction done:", UVM_LOW)
    t.print();
endtask