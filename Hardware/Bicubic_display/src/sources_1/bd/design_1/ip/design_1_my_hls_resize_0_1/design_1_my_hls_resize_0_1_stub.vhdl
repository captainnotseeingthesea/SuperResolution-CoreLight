-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Mon May  2 20:55:38 2022
-- Host        : DESKTOP-6S8DB8B running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               d:/competion_2022/hardware/bicubic_display/hdmi_display.srcs/sources_1/bd/design_1/ip/design_1_my_hls_resize_0_1/design_1_my_hls_resize_0_1_stub.vhdl
-- Design      : design_1_my_hls_resize_0_1
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity design_1_my_hls_resize_0_1 is
  Port ( 
    src_axi_TVALID : in STD_LOGIC;
    src_axi_TREADY : out STD_LOGIC;
    src_axi_TDATA : in STD_LOGIC_VECTOR ( 23 downto 0 );
    src_axi_TKEEP : in STD_LOGIC_VECTOR ( 2 downto 0 );
    src_axi_TSTRB : in STD_LOGIC_VECTOR ( 2 downto 0 );
    src_axi_TUSER : in STD_LOGIC_VECTOR ( 0 to 0 );
    src_axi_TLAST : in STD_LOGIC_VECTOR ( 0 to 0 );
    src_axi_TID : in STD_LOGIC_VECTOR ( 0 to 0 );
    src_axi_TDEST : in STD_LOGIC_VECTOR ( 0 to 0 );
    dst_axi_TVALID : out STD_LOGIC;
    dst_axi_TREADY : in STD_LOGIC;
    dst_axi_TDATA : out STD_LOGIC_VECTOR ( 23 downto 0 );
    dst_axi_TKEEP : out STD_LOGIC_VECTOR ( 2 downto 0 );
    dst_axi_TSTRB : out STD_LOGIC_VECTOR ( 2 downto 0 );
    dst_axi_TUSER : out STD_LOGIC_VECTOR ( 0 to 0 );
    dst_axi_TLAST : out STD_LOGIC_VECTOR ( 0 to 0 );
    dst_axi_TID : out STD_LOGIC_VECTOR ( 0 to 0 );
    dst_axi_TDEST : out STD_LOGIC_VECTOR ( 0 to 0 );
    ap_clk : in STD_LOGIC;
    ap_rst_n : in STD_LOGIC
  );

end design_1_my_hls_resize_0_1;

architecture stub of design_1_my_hls_resize_0_1 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "src_axi_TVALID,src_axi_TREADY,src_axi_TDATA[23:0],src_axi_TKEEP[2:0],src_axi_TSTRB[2:0],src_axi_TUSER[0:0],src_axi_TLAST[0:0],src_axi_TID[0:0],src_axi_TDEST[0:0],dst_axi_TVALID,dst_axi_TREADY,dst_axi_TDATA[23:0],dst_axi_TKEEP[2:0],dst_axi_TSTRB[2:0],dst_axi_TUSER[0:0],dst_axi_TLAST[0:0],dst_axi_TID[0:0],dst_axi_TDEST[0:0],ap_clk,ap_rst_n";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "my_hls_resize,Vivado 2018.3";
begin
end;
