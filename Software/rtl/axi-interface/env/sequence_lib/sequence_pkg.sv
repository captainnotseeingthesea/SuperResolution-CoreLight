/*************************************************

 Copyright: NUDT_CoreLight

 File name: sequence_pkg.sv

 Author: NUDT_CoreLight

 Date: 2021-04-13


 Description:


 **************************************************/

package sequence_pkg;

`include "uvm_macros.svh"
import uvm_pkg::*;

import axi_lite_pkg::*;
import axi_stream_pkg::*;
import upsp_pkg::*;

`include "axil_start_seq.svh"
`include "axil_end_seq.svh"

`include "axis_in_seq.svh"
`include "upsp_seq.svh"

import utils_pkg::BMP;
`include "bmp_seq.svh"

endpackage