/*************************************************

 Copyright: NUDT_CoreLight

 File name: upsp_driver.svh

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 Driver as upsp. Read all the time, write generated data;

 **************************************************/

class upsp_driver extends uvm_driver #(upsp_trans) ;
    
    
    `uvm_component_utils(upsp_driver)

    function new(string name = "upsp_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual upsp_if vif;

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    
    extern task read_forever();
    extern task write_one_trans(upsp_trans t);
endclass


// Methods
function void upsp_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual upsp_if)::get(this, "", "vif", vif))
        `uvm_fatal(get_name(), "vif must be set!")
endfunction: build_phase


task upsp_driver::reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_name(), "<reset_phase> started, objection raised.", UVM_NONE)

    vif.upsp_ac_rready <= 0;
    vif.upsp_ac_wvalid <= 0;    
    vif.upsp_ac_wdata  <= 0;
    while(!vif.rst_n) @(posedge vif.clk);

    phase.drop_objection(this);
    `uvm_info(get_name(), "<reset_phase> finished, objection dropped.", UVM_NONE)
endtask: reset_phase


task upsp_driver::main_phase(uvm_phase phase);
    fork
        read_forever();

        begin
            while(1) begin
                seq_item_port.get_next_item(req);
                write_one_trans(req);
                seq_item_port.item_done();
            end
        end
    join
endtask: main_phase


task upsp_driver::read_forever();
    forever begin
        vif.upsp_ac_rready <= 1'b1;
        @(posedge vif.clk);
    end
endtask


task upsp_driver::write_one_trans(upsp_trans t);
    int i;
    while(!vif.UPSTR) @(posedge vif.clk);
    vif.upsp_ac_wvalid <= 1'b1;    
    vif.upsp_ac_wdata  <= {>>{t.data}};

    for(i = 0; i < t.timeout; i++) begin
        if(vif.ac_upsp_wready && vif.upsp_ac_wvalid) break;
        @(posedge vif.clk);
    end
    if(i == t.timeout) `uvm_error(get_name(), "waits ac_upsp_wready for too many cycles")

    vif.upsp_ac_wvalid <= 1'b0;
endtask