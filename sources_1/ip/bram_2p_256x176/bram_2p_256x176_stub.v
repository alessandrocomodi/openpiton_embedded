// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.4 (lin64) Build 1756540 Mon Jan 23 19:11:19 MST 2017
// Date        : Mon Mar 13 16:04:44 2017
// Host        : thecommodore running 64-bit Ubuntu 16.04.2 LTS
// Command     : write_verilog -force -mode synth_stub -rename_top bram_2p_256x176 -prefix
//               bram_2p_256x176_ bram_2p_256x176_stub.v
// Design      : bram_2p_256x176
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx485tffg1761-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_3_5,Vivado 2016.4" *)
module bram_2p_256x176(clka, ena, wea, addra, dina, douta, clkb, enb, web, addrb, 
  dinb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[21:0],addra[7:0],dina[175:0],douta[175:0],clkb,enb,web[21:0],addrb[7:0],dinb[175:0],doutb[175:0]" */;
  input clka;
  input ena;
  input [21:0]wea;
  input [7:0]addra;
  input [175:0]dina;
  output [175:0]douta;
  input clkb;
  input enb;
  input [21:0]web;
  input [7:0]addrb;
  input [175:0]dinb;
  output [175:0]doutb;
endmodule
