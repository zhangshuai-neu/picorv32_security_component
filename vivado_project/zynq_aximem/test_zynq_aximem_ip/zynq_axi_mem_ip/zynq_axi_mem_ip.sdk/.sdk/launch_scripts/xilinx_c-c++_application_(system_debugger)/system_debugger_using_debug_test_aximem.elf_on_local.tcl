connect -url tcp:127.0.0.1:3121
source /home/zhangshuai/develop/soft_core/vivado_project/zynq_aximem/test_zynq_aximem_ip/zynq_axi_mem_ip/zynq_axi_mem_ip.sdk/design_1_wrapper_hw_platform_0/ps7_init.tcl
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent Zed 210248A499B3"} -index 0
loadhw -hw /home/zhangshuai/develop/soft_core/vivado_project/zynq_aximem/test_zynq_aximem_ip/zynq_axi_mem_ip/zynq_axi_mem_ip.sdk/design_1_wrapper_hw_platform_0/system.hdf -mem-ranges [list {0x40000000 0xbfffffff}]
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent Zed 210248A499B3"} -index 0
stop
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent Zed 210248A499B3"} -index 0
rst -processor
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent Zed 210248A499B3"} -index 0
dow /home/zhangshuai/develop/soft_core/vivado_project/zynq_aximem/test_zynq_aximem_ip/zynq_axi_mem_ip/zynq_axi_mem_ip.sdk/test_aximem/Debug/test_aximem.elf
configparams force-mem-access 0
bpadd -addr &main
