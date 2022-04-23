/*************************************************

 Copyright: NUDT_CoreLight

 File name: test_pkg.sv

 Author: NUDT_CoreLight

 Date: 2021-04-13


 Description:


 **************************************************/

package test_pkg;

`include "uvm_macros.svh"
import uvm_pkg::*;

import env_pkg::*;
import sequence_pkg::*;

`include "base_test.svh"
`include "ac_crf_base_test.svh"
`include "ac_bcci_test.svh"
`include "bcci_ip_test.svh"

endpackage