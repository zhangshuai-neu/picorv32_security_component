#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/opt/Xilinx_2017/SDK/2017.4/bin:/opt/Xilinx_2017/Vivado/2017.4/ids_lite/ISE/bin/lin64:/opt/Xilinx_2017/Vivado/2017.4/bin
else
  PATH=/opt/Xilinx_2017/SDK/2017.4/bin:/opt/Xilinx_2017/Vivado/2017.4/ids_lite/ISE/bin/lin64:/opt/Xilinx_2017/Vivado/2017.4/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=/opt/Xilinx_2017/Vivado/2017.4/ids_lite/ISE/lib/lin64
else
  LD_LIBRARY_PATH=/opt/Xilinx_2017/Vivado/2017.4/ids_lite/ISE/lib/lin64:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/zhangshuai/develop/soft_core/vivado_project/zynq_aximem/test_zynq_aximem_ip/zynq_axi_mem_ip/zynq_axi_mem_ip.runs/design_1_rst_ps7_0_100M_0_synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log design_1_rst_ps7_0_100M_0.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source design_1_rst_ps7_0_100M_0.tcl