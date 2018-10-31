`timescale 1ns / 1ns

/*
 * pico片上系统
 * 
 * 使用picorv32连接各种存储器和设备
 * 存储器(mem)包括：sram(内部存储)
 *
 * 已有部件：
 * 1) picorv32 core 核心
 * 2) mpu 内存保护单元
 * 3) sram
 *	占用地址：0-4k
 *  0-3k为正常程序，3k-4k为控制、安全信息
 */

module picosoc ();
	parameter integer MEM_WORDS = 1024;
	parameter [31:0] STACKADDR = 512*4;
	parameter [31:0] PROGADDR_RESET = 32'h00000000;

    reg clk;
    reg resetn;
	
    // cpu -> mpu 的连线
    wire [31:0] cpu_mpu_pc_addr;    //pc的地址
    
	wire cpu_mpu_valid;
	wire cpu_mpu_instr;         //1表示取指令
    wire inform_cpu_wait;       //通知cpu等待
    
	wire cpu_mpu_ready;
	wire [31:0] cpu_mpu_addr;	//指定内存地址
	wire [31:0] cpu_mpu_wdata;	//写入内存
	wire [3:0]  cpu_mpu_wstrb;	//链接"写使能"，指定那些Byte被写
	wire [31:0] cpu_mpu_rdata;	//存储器读取
	
    // mpu -> mem 的连线
	wire [3:0]  mpu_mem_wen;	  //写使能
    wire [21:0] mpu_mem_addr;     //22位地址
    wire [31:0] mpu_mem_wdata;    //32位写数据
    wire [31:0] mpu_mem_rdata;    //32位读数据
    
    //============================================
    integer i;
	initial begin
		clk = 0;
        resetn = 0;
		//加在一段程序
        $readmemh("/home/zhangshuai/develop/pico_vivado/src/mem_test/src/asm_main.data",sram.mem,0);
		//加在MPU
        $readmemh("/home/zhangshuai/develop/pico_vivado/src/mem_test/src/mpu_conf.data",sram.mem,768);
        
		for(i=0;i<13;i=i+1)
			$display("sram.mem[%d] = %h",i,sram.mem[i]);
			
        for(i=768;i<768+5;i=i+1)
			$display("sram.mem[%d] = %h",i,sram.mem[i]);
	end
	
	always #5 clk=~clk;
	always #30 resetn=1;
    //============================================
    
	//1） picorv32 core
	picorv32 #(
            .STACKADDR(STACKADDR),				// x2 堆栈指针的值
            .PROGADDR_RESET(PROGADDR_RESET),	//程序的开始地址
            .BARREL_SHIFTER(1),
            .ENABLE_IRQ(1),
            .ENABLE_IRQ_QREGS(0)
		) 
		cpu 
        (
			.clk         (clk        ),		// input
			.resetn      (resetn     ),		// input
            
            .reg_pc      (cpu_mpu_pc_addr),   //optput
            .mpu_inform_wait(inform_cpu_wait),  //input
            
			.mem_valid   (cpu_mpu_valid  ),		// output
			.mem_instr   (cpu_mpu_instr  ),		// output
			.mem_ready   (cpu_mpu_ready  ),		// input
			.mem_addr    (cpu_mpu_addr   ),		// output
			.mem_wdata   (cpu_mpu_wdata  ),		// output
			.mem_wstrb   (cpu_mpu_wstrb  ),		// output
			.mem_rdata   (cpu_mpu_rdata  )		// input
		);
    
    //2) mem_mpu mem接口的mpu
    mem_mpu #(
        .DATA_WIDTH(32),
        .MPU_START_ADDR(768),
        .MPU_LEN(16)
    ) 
    pico_mem_mpu
    (
        .clk(clk),
        .resetn(resetn),
        
        //连接cpu的接口
        .is_inst(cpu_mpu_instr),    //判断是否为指令
        .pc_addr(cpu_mpu_pc_addr),  //数据操作指令的pc
        .inform_cpu_wait(inform_cpu_wait),
        
        .cpu_valid   (cpu_mpu_valid  ),
		.cpu_ready   (cpu_mpu_ready  ),
		.cpu_addr    (cpu_mpu_addr[23:2]),
		.cpu_wdata   (cpu_mpu_wdata  ),
		.cpu_wstrb   (cpu_mpu_wstrb  ),
        .cpu_rdata   (cpu_mpu_rdata  ),
        
		//连接mem的接口
		.mem_wen(mpu_mem_wen),	    //写使能
        .mem_addr(mpu_mem_addr),    //22位地址
        .mem_wdata(mpu_mem_wdata),  //32位写数据
        .mem_rdata(mpu_mem_rdata)   //32位读数据
	);
    
	//3）sram
	mem_mem #(.WORDS(MEM_WORDS)) sram (
		.clk(clk),
		.wen(mpu_mem_wen),
		.addr(mpu_mem_addr),
		.wdata(mpu_mem_wdata),
		.rdata(mpu_mem_rdata)
	);
endmodule



