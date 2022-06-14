// use verilator 
#include "Vbicubic_processing_element.h"
#include "verilated.h"
#include <verilated_vcd_c.h>
#include <iostream>
int main(int argc, char** argv, char** env) {
    VerilatedContext* contextp = new VerilatedContext;
    Verilated::traceEverOn(true);
    contextp->commandArgs(argc, argv);
    Vbicubic_processing_element* top = new Vbicubic_processing_element{contextp};


    // VerilatedVcdC* tfp = new VerilatedVcdC;
    // top->trace (tfp, 99);	// Trace 99 levels of hierarchy
    // tfp->open ("wave.vcd");	// Open the dump file

    unsigned int clock = 0;
    unsigned int random_wready;
    #define PERIOD 4
    while (!contextp->gotFinish() && (clock < 30000000)) { 
        clock++;
        top->ac_upsp_wready = 0x0;
        top->ac_upsp_rvalid = 0x0;
        top->ac_upsp_rdata = 0x0;
        if(clock%PERIOD == 1){
          top->clk = 0x1;
        }
        if(clock%PERIOD == 3){
          top->clk = 0x0;
        }
        if(clock < 11){
          top->rst_n = 0x0;
        } 
        else {
          top->rst_n = 0x1;
          top->ac_upsp_wready = rand()%2;
          // top->ac_upsp_wready = 0x1;
        }

        top->eval(); 

        // if (tfp){
        //   tfp->dump (clock);
        // }
    }
    // if (tfp){
    //   tfp->close();
    // }

    // Verilated::mkdir("logs");
    // Verilated::threadContextp()->coveragep()->write("logs/coverage.dat");
  
    delete top;
    delete contextp;
    return 0;
}

