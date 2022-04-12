# Description

### Files

The structure of this fold is showed below :

```
|-- axi-interface
    |-- auto.pl				# script for emacs verilog-mode
    |-- readme.md
    |-- env		    	# environment for verification.
    |   |-- ifs.sv			# interface
    |   |-- tb_ac_crf.sv	# testbench
    |   |-- top.sv			# top modult, DUT
    |   |-- uvm				# uvm classes written for env
    |-- sim				
    |   |-- filelist
    |   |-- macros
    |   |-- sim.pl			# simulation script
    |-- src
        |-- access_control.v
        |-- config_register_file.v
        |-- stream_in.v
```

**Source files :**

- config_register_file.v
  - Configuration registers. Accessed by PS side via the AXI4-Lite interface as the slave, while simple write/busy mechanism for PL side. An interrupt signal is contained.
- stream_in.v
  - Stream in, acts as an AXI-Stream slave, receives data from DMA and bypass data to PL side. 
  - Signals ignored in the implementation including: **TID、TSTRB、TKEEP、TDEST and TUSER**.
- access_control.v
  - Access control, contains stream_in to serve read requests from Up-Sampling and transforms Up-Sampling write requests into AXI4 requests to DDR in PS side as the AXI4 master.



### Macros

- There are some assertions for checking design features, please **define** `DISABLE_SV_ASSERTION` **to disable** SVA.
- There are some code for easy debugging, the functionality does not depends on these code, please **define** `DISABLE_DEBUG_CODE` **to disable** these additional code.



### Simulation

run the following command :

```
$ cd sim
$ ./sim.pl
```

`xcelium` **MUST BE INSTALLED**