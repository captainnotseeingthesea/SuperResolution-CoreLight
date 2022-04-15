/*************************************************

 Copyright: NUDT_CoreLight

 File name: axi_stream_pkg.sv

 Author: NUDT_CoreLight

 Date: 2021-04-13


 Description:


 **************************************************/

package axi_stream_pkg;

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "axi_stream_trans.svh"

`include "axi_stream_monitor.svh"

import utils_pkg::BMP;
`include "axis_bmp_dumper.svh"

`include "m_axi_stream_driver.svh"
`include "m_axi_stream_sqr.svh"
`include "m_axi_stream_agent.svh"

`include "s_axi_stream_driver.svh"
`include "s_axi_stream_agent.svh"
    
endpackage