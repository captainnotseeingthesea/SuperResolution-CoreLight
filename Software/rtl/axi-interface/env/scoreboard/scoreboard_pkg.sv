/*************************************************

 Copyright: NUDT_CoreLight

 File name: scoreboard_pkg.sv

 Author: NUDT_CoreLight

 Date: 2021-04-13


 Description:


 **************************************************/

package scoreboard_pkg;

`include "uvm_macros.svh"
import uvm_pkg::*;

import axi_lite_pkg::*;
import axi_stream_pkg::*;
import upsp_pkg::*;

`include "base_scoreboard.svh"

`include "stream_in_scoreboard.svh"

`include "stream_out_scoreboard.svh"

endpackage