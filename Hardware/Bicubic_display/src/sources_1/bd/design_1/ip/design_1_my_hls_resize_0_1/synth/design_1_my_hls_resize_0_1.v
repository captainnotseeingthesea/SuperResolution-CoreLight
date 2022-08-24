// (c) Copyright 1995-2022 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:hls:my_hls_resize:1.0
// IP Revision: 2112487849

(* X_CORE_INFO = "my_hls_resize,Vivado 2018.3" *)
(* CHECK_LICENSE_TYPE = "design_1_my_hls_resize_0_1,my_hls_resize,{}" *)
(* CORE_GENERATION_INFO = "design_1_my_hls_resize_0_1,my_hls_resize,{x_ipProduct=Vivado 2018.3,x_ipVendor=xilinx.com,x_ipLibrary=hls,x_ipName=my_hls_resize,x_ipVersion=1.0,x_ipCoreRevision=2112487849,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED}" *)
(* IP_DEFINITION_SOURCE = "HLS" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_my_hls_resize_0_1 (
  src_axi_TVALID,
  src_axi_TREADY,
  src_axi_TDATA,
  src_axi_TKEEP,
  src_axi_TSTRB,
  src_axi_TUSER,
  src_axi_TLAST,
  src_axi_TID,
  src_axi_TDEST,
  dst_axi_TVALID,
  dst_axi_TREADY,
  dst_axi_TDATA,
  dst_axi_TKEEP,
  dst_axi_TSTRB,
  dst_axi_TUSER,
  dst_axi_TLAST,
  dst_axi_TID,
  dst_axi_TDEST,
  ap_clk,
  ap_rst_n
);

(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 src_axi TVALID" *)
input wire src_axi_TVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 src_axi TREADY" *)
output wire src_axi_TREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 src_axi TDATA" *)
input wire [23 : 0] src_axi_TDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 src_axi TKEEP" *)
input wire [2 : 0] src_axi_TKEEP;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 src_axi TSTRB" *)
input wire [2 : 0] src_axi_TSTRB;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 src_axi TUSER" *)
input wire [0 : 0] src_axi_TUSER;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 src_axi TLAST" *)
input wire [0 : 0] src_axi_TLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 src_axi TID" *)
input wire [0 : 0] src_axi_TID;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME src_axi, TDATA_NUM_BYTES 3, TDEST_WIDTH 1, TID_WIDTH 1, TUSER_WIDTH 1, LAYERED_METADATA undef, HAS_TREADY 1, HAS_TSTRB 1, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 1e+08, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 src_axi TDEST" *)
input wire [0 : 0] src_axi_TDEST;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 dst_axi TVALID" *)
output wire dst_axi_TVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 dst_axi TREADY" *)
input wire dst_axi_TREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 dst_axi TDATA" *)
output wire [23 : 0] dst_axi_TDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 dst_axi TKEEP" *)
output wire [2 : 0] dst_axi_TKEEP;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 dst_axi TSTRB" *)
output wire [2 : 0] dst_axi_TSTRB;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 dst_axi TUSER" *)
output wire [0 : 0] dst_axi_TUSER;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 dst_axi TLAST" *)
output wire [0 : 0] dst_axi_TLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 dst_axi TID" *)
output wire [0 : 0] dst_axi_TID;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME dst_axi, TDATA_NUM_BYTES 3, TDEST_WIDTH 1, TID_WIDTH 1, TUSER_WIDTH 1, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {CLK {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} TDATA {datatype {name {attribs {resolve_t\
ype immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 24} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}} TDATA_WIDTH 24 TUSER {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} \
maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}} TUSER_WIDTH 1}, HAS_TREADY 1, HAS_TSTRB 1, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 1e+08, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 dst_axi TDEST" *)
output wire [0 : 0] dst_axi_TDEST;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ap_clk, ASSOCIATED_BUSIF src_axi:dst_axi, ASSOCIATED_RESET ap_rst_n, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {CLK {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}}}, FREQ_HZ 1e+08, PHASE 0.000, CLK_DOMAIN de\
sign_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 ap_clk CLK" *)
input wire ap_clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ap_rst_n, POLARITY ACTIVE_LOW, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {RST {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}}}, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 ap_rst_n RST" *)
input wire ap_rst_n;

  my_hls_resize inst (
    .src_axi_TVALID(src_axi_TVALID),
    .src_axi_TREADY(src_axi_TREADY),
    .src_axi_TDATA(src_axi_TDATA),
    .src_axi_TKEEP(src_axi_TKEEP),
    .src_axi_TSTRB(src_axi_TSTRB),
    .src_axi_TUSER(src_axi_TUSER),
    .src_axi_TLAST(src_axi_TLAST),
    .src_axi_TID(src_axi_TID),
    .src_axi_TDEST(src_axi_TDEST),
    .dst_axi_TVALID(dst_axi_TVALID),
    .dst_axi_TREADY(dst_axi_TREADY),
    .dst_axi_TDATA(dst_axi_TDATA),
    .dst_axi_TKEEP(dst_axi_TKEEP),
    .dst_axi_TSTRB(dst_axi_TSTRB),
    .dst_axi_TUSER(dst_axi_TUSER),
    .dst_axi_TLAST(dst_axi_TLAST),
    .dst_axi_TID(dst_axi_TID),
    .dst_axi_TDEST(dst_axi_TDEST),
    .ap_clk(ap_clk),
    .ap_rst_n(ap_rst_n)
  );
endmodule
