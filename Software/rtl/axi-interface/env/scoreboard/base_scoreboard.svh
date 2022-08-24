/*************************************************

 Copyright: NUDT_CoreLight

 File name: base_scoreboard.svh

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
    act_t act_q[$] = {};
    uvm_blocking_get_port #(exp_t) exp_port;
    uvm_blocking_get_port #(act_t) act_port;
    
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);
    
    pure virtual function void exp2act(exp_t src, act_t target);
    pure virtual function int compare(act_t a, act_t b);
    
endclass


// Methods
function void base_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
    exp_port = new("exp_port", this);
    act_port = new("act_port", this);
endfunction: build_phase


task base_scoreboard::main_phase(uvm_phase phase);
    exp_t exp_trans;
    act_t act_trans, tmp_act, tmp_exp;
    int count = 0;

    fork
        begin: collect_exp
            while (1) begin
                exp_port.get(exp_trans);
                exp_q.push_back(exp_trans);
            end
        end

        begin: collect_act
            while (1) begin
                act_port.get(act_trans);
                act_q.push_back(act_trans);
            end
        end

        begin: compare_exp_act
            while(1) begin
                wait(act_q.size() > 0 && exp_q.size() > 0);
                tmp_act = act_q.pop_front();
                tmp_exp = new("expt_after_convert");
                exp2act(exp_q.pop_front(), tmp_exp);

                if(!compare(tmp_exp, tmp_act)) begin
                    `uvm_error(get_name(), $sformatf("%d'th compare failed", count))
                    $display("expected:\n");
                    tmp_exp.print();
                    $display("actural:\n");
                    tmp_act.print();
                end

                count++;
                
            end

        end

    join
endtask: main_phase


function void base_scoreboard::report_phase(uvm_phase phase);
    super.report_phase(phase);

    if(exp_q.size() > 0 || act_q.size() > 0) begin
        `uvm_error(get_name(), "exp_q and act_q are not all empty!")
        `uvm_info(get_name(), $sformatf("exp_q.size = %d, act_q.size = %d", exp_q.size(), act_q.size()), UVM_LOW)
    end else begin
        `uvm_info(get_name(), "exp_q and act_q are all empty!", UVM_LOW)
    end

endfunction: report_phase
