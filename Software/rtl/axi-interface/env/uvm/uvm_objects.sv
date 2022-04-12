`include "uvm_macros.svh"
import uvm_pkg::*;

`include "axi_lite_trans.sv"
`include "m_axi_lite_driver.sv"
`include "m_axi_lite_sqr.sv"
`include "m_axi_lite_agent.sv"

`include "axi_stream_trans.sv"
`include "axi_stream_monitor.sv"

`include "m_axi_stream_driver.sv"
`include "m_axi_stream_sqr.sv"
`include "m_axi_stream_agent.sv"

`include "s_axi_stream_driver.sv"
`include "s_axi_stream_agent.sv"

`include "upsp_trans.sv"
`include "upsp_driver.sv"
`include "upsp_monitor.sv"
`include "upsp_sqr.sv"
`include "upsp_ostream_modifier.sv"
`include "upsp_agent.sv"

`include "base_scoreboard.sv"
`include "stream_in_scoreboard.sv"
`include "stream_out_scoreboard.sv"

`include "axil_seq.sv"
`include "axis_in_seq.sv"
`include "upsp_seq.sv"

`include "ac_crf_env.sv"

`include "ac_crf_base_test.sv"