# Description

### Files

The structure of this fold is showed below :

```
|-- axi-interface
    |-- auto.pl				# script for emacs verilog-mode
    |-- readme.md
    |-- env				    # verification environment based on UVM
    |   |-- axi_lite
    |   |-- axi_stream
    |   |-- dut
    |   |-- environment
    |   |-- interface_lib
    |   |-- scoreboard
    |   |-- sequence_lib
    |   |-- test_lib
    |   |-- testbench
    |   |-- up_sampling
    |   |-- utils
    |
    |-- sim				    # verification working directory
    |   |-- filelist
    |   |-- macros
    |   |-- onepiece540.bmp
    |   |-- onepiece540_4.bmp
    |   |-- sim.pl
    |
    |-- src				    # source files
        |-- access_control.v
        |-- config_register_file.v
        |-- stream_in.v
        |-- bram_subbank.v
        |-- axis_outbuf.v

```

**Source files :**

- config_register_file.v
  - Configuration registers. Accessed by PS side via the AXI4-Lite interface as the slave, while simple write/busy mechanism for PL side. An interrupt signal `interrupt_updone` is asserted after finishing up-sampling.
- stream_in.v
  - Stream in, acts as an AXI-Stream slave, receives data from DMA and bypass data to PL side. 
  - Signals ignored in the implementation including: **TID、TSTRB、TKEEP、TDEST and TUSER**.
- access_control.v
  - Access control, contains stream_in to serve read requests from Up-Sampling and transforms Up-Sampling write requests into AXI-Stream requests to DDR in PS side as the AXI4 master.
  - There is a ping-pong buffer ( contains 2 axis_outbuf ) for output.
- bram_subbank.v
  - one-dimensional array, using the `(*ram_style = "block"*)`  synthesis attribute to employ the bram in FPGA.
- axis_outbuf.v
  - Output buffer for AXI-Stream in `access_control.v`. Each buffer has 4 subbanks.



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