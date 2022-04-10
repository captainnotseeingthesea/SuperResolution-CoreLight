/*************************************************

 Copyright: NUDT_CoreLight

 File name: base_scoreboard.sv

 Author: NUDT_CoreLight

 Date: 2021-04-10


 Description:

 Base scoreboard.

 **************************************************/

 virtual class base_scoreboard #(type exp_t=uvm_transaction, type act_t=uvm_transaction) extends uvm_scoreboard;
    
    
    `uvm_component_utils(base_scoreboard)

    function new(string name = "base_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    exp_t exp_q[$] = {};
    uvm_blocking_get_port #(exp_t) exp_port;
    uvm_blocking_get_port #(act_t) act_port;
    
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    
    pure virtual function void exp2act(exp_t src, act_t target);
    
endclass


// Methods
function void base_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
    exp_port = new("exp_port", this);
    act_port = new("act_port", this);
endfunction: build_phase


task base_scoreboard::main_phase(uvm_phase phase);
    exp_t exp_trans;
    act_t act_trans, tmp_trans;
    fork
        begin: collect_exp
            while (1) begin
                exp_port.get(exp_trans);
                exp_q.push_back(exp_trans);
            end
        end

        begin: get_act_and_compare
            while (1) begin
                act_port.get(act_trans);

                if(exp_q.size() > 0) begin
                    tmp_trans = new("exp_trans_after_covert");
                    exp2act(exp_q.pop_front(),tmp_trans);

                    if(!tmp_trans.compare(act_trans)) begin
                        `uvm_error(get_name(), "compare failed")
                        $display("expected:\n");
                        tmp_trans.print();
                        $display("actural:\n");
                        act_trans.print();
                    end

                end else begin
                    `uvm_error(get_name(), "act_trans received while exp_q is empty")
                    $display("actural:\n");
                    act_trans.print();
                end
            end
        end

    join
endtask: main_phase