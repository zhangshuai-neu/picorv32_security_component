// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
// Date        : Sat Oct 20 10:10:49 2018
// Host        : zs-pc running 64-bit Linux Mint 17.3 Rosa
// Command     : write_verilog -force -mode synth_stub
//               /home/zhangshuai/develop/soft_core/vivado_project/zynq_aximem/test_zynq_aximem_ip/zynq_axi_mem_ip/zynq_axi_mem_ip.srcs/sources_1/bd/design_1/ip/design_1_s_axi_lite_mem_0_0/design_1_s_axi_lite_mem_0_0_stub.v
// Design      : design_1_s_axi_lite_mem_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "s_axi_lite_mem,Vivado 2017.4" *)
module design_1_s_axi_lite_mem_0_0(S_AXI_ACLK, S_AXI_ARESETN, S_AXI_AWADDR, 
  S_AXI_AWREADY, S_AXI_AWPROT, S_AXI_AWVALID, S_AXI_WDATA, S_AXI_WREADY, S_AXI_WSTRB, 
  S_AXI_WVALID, S_AXI_BRESP, S_AXI_BVALID, S_AXI_BREADY, S_AXI_ARADDR, S_AXI_ARREADY, 
  S_AXI_ARPROT, S_AXI_ARVALID, S_AXI_RDATA, S_AXI_RRESP, S_AXI_RREADY, S_AXI_RVALID)
/* synthesis syn_black_box black_box_pad_pin="S_AXI_ACLK,S_AXI_ARESETN,S_AXI_AWADDR[31:0],S_AXI_AWREADY,S_AXI_AWPROT[2:0],S_AXI_AWVALID,S_AXI_WDATA[31:0],S_AXI_WREADY,S_AXI_WSTRB[3:0],S_AXI_WVALID,S_AXI_BRESP[1:0],S_AXI_BVALID,S_AXI_BREADY,S_AXI_ARADDR[31:0],S_AXI_ARREADY,S_AXI_ARPROT[2:0],S_AXI_ARVALID,S_AXI_RDATA[31:0],S_AXI_RRESP[1:0],S_AXI_RREADY,S_AXI_RVALID" */;
  input S_AXI_ACLK;
  input S_AXI_ARESETN;
  input [31:0]S_AXI_AWADDR;
  output S_AXI_AWREADY;
  input [2:0]S_AXI_AWPROT;
  input S_AXI_AWVALID;
  input [31:0]S_AXI_WDATA;
  output S_AXI_WREADY;
  input [3:0]S_AXI_WSTRB;
  input S_AXI_WVALID;
  output [1:0]S_AXI_BRESP;
  output S_AXI_BVALID;
  input S_AXI_BREADY;
  input [31:0]S_AXI_ARADDR;
  output S_AXI_ARREADY;
  input [2:0]S_AXI_ARPROT;
  input S_AXI_ARVALID;
  output [31:0]S_AXI_RDATA;
  output [1:0]S_AXI_RRESP;
  input S_AXI_RREADY;
  output S_AXI_RVALID;
endmodule
