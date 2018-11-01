# pico_vivado

**目的:** 在picorv32上进行开发

**源文件:**
	src目录下包含正在测试的程序
	正在测试的 mem_test_mpu目录下的mpu以及中断
	调试完成后将会将vivado项目，移动到vivado_project目录下，源文件保留
    

**riscv_bare_metal:**

    riscv上的裸机程序

**vivado_project:**

	zynq_aximem：使用zynq调试src/s_axi_lite_mem.v，可以打开sdk进行调试查看axi-mem中
	的内容

**image:**

    image中存放了一些测试的截图
