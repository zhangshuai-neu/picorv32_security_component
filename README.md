# pico_vivado

**目的:** 创建一个在vivado中调试的picorv32处理器的片上系统

**源文件:**

    src/picorv32.v       :   处理器代码（axi-lite接口）
    src/s_axi_lite_mem.v :   axi-lite接口的存储器
    src/picosoc.v        :   片上系统

    将所有文件导入vivado项目中，再将picosoc作为顶层文件进行仿真即可

**riscv_bare_metal:**

    riscv上的裸机程序

**vivado_project:**

	zynq_aximem：使用zynq调试src/s_axi_lite_mem.v，可以打开sdk进行调试查看axi-mem中
	的内容

**image:**

    image中存放了一些测试的截图
