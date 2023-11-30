// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
// Date        : Fri Jul  2 18:59:17 2021
// Host        : goedel running 64-bit Ubuntu 20.04.2 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/jkaps/projects/FOBOS/fobos3/control/ip_repo/powermanager_1.1/src/xadc_wiz_0/xadc_wiz_0_stub.v
// Design      : xadc_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module xadc_wiz_0(daddr_in, den_in, di_in, dwe_in, do_out, drdy_out, 
  dclk_in, reset_in, vauxp1, vauxn1, vauxp5, vauxn5, vauxp6, vauxn6, vauxp9, vauxn9, vauxp13, vauxn13, 
  vauxp15, vauxn15, busy_out, channel_out, eoc_out, eos_out, alarm_out, vp_in, vn_in)
/* synthesis syn_black_box black_box_pad_pin="daddr_in[6:0],den_in,di_in[15:0],dwe_in,do_out[15:0],drdy_out,dclk_in,reset_in,vauxp1,vauxn1,vauxp5,vauxn5,vauxp6,vauxn6,vauxp9,vauxn9,vauxp13,vauxn13,vauxp15,vauxn15,busy_out,channel_out[4:0],eoc_out,eos_out,alarm_out,vp_in,vn_in" */;
  input [6:0]daddr_in;
  input den_in;
  input [15:0]di_in;
  input dwe_in;
  output [15:0]do_out;
  output drdy_out;
  input dclk_in;
  input reset_in;
  input vauxp1;
  input vauxn1;
  input vauxp5;
  input vauxn5;
  input vauxp6;
  input vauxn6;
  input vauxp9;
  input vauxn9;
  input vauxp13;
  input vauxn13;
  input vauxp15;
  input vauxn15;
  output busy_out;
  output [4:0]channel_out;
  output eoc_out;
  output eos_out;
  output alarm_out;
  input vp_in;
  input vn_in;
endmodule
