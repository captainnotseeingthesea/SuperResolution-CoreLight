# Description

- config_register_file.v
  - Configuration registers. Accessed by PS side via the AXI4-Lite interface as the slave, while simple write/busy mechanism for PL side. An interrupt signal is contained.
- access_control.v
  - Access control, receives read/write requests from PL side and transforms them into AXI4 requests to DDR in PS side as the AXI4 master.



**PLEASE DEFINE** the macro `DISABLE_SV_ASSERTION` when **NOT** in simulation.

