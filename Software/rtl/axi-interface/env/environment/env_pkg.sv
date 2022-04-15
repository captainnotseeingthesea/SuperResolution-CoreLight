/*************************************************

 Copyright: NUDT_CoreLight

 File name: env_pkg.sv

 Author: NUDT_CoreLight

 Date: 2021-04-13


 Description:


 **************************************************/

package env_pkg;

`include "uvm_macros.svh"
import uvm_pkg::*;

import axi_lite_pkg::*;
import axi_stream_pkg::*;
import scoreboard_pkg::*;
import upsp_pkg::*;

`include "base_env.svh"
`include "ac_crf_env.svh"
`include "bcci_ip_env.svh"

endpackage