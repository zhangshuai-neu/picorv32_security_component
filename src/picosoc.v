/*
 * pico片上系统
 * 
 * 使用picorv32连接各种存储器和设备
 * 存储器(mem)包括：sram(内部存储)，flash，外部存储
 *
 * 已有部件：
 * 1) picorv32 cpu 核心
 * 2) axi-lite memory sram 存储器 
 *	占用地址：0x0000_0000 .. 0x0000_0400
 * 
 */
module picosoc ();

	//参数：传递给picorv32 和 picosoc_mem 
	parameter integer MEM_WORDS = 256;
	parameter [31:0] STACKADDR = (4*MEM_WORDS);
	parameter [31:0] PROGADDR_RESET = 32'h00000000;
	parameter integer DATA_WIDTH = 32;
	parameter integer ADDR_WIDTH = 32;

    reg clk;
    reg resetn;
    reg mem_resetn;
	reg sram_ready;
	
	/*
	 * 连接picorv32 axi 和 axi-lite memory
	 */
	wire                   mem_axi_awvalid;
	wire                   mem_axi_awready;
	wire [ADDR_WIDTH-1:0]  mem_axi_awaddr;
	wire [2 : 0]           mem_axi_awprot;
	
	wire                   mem_axi_wvalid;
	wire                   mem_axi_wready;
    wire [DATA_WIDTH-1:0]  mem_axi_wdata;
    wire                   mem_axi_wstrb;
    
    wire                   mem_axi_bvalid;
    wire                   mem_axi_bready;

    wire                   mem_axi_arvalid;
    wire                   mem_axi_arready;
    wire [ADDR_WIDTH-1:0]  mem_axi_araddr;
    wire [2 : 0]           mem_axi_arprot;

    wire                   mem_axi_rvalid;
    wire                   mem_axi_rready;
    wire [DATA_WIDTH-1:0]  mem_axi_rdata;

	integer i;
	initial begin
		clk = 0;
        resetn = 0;
        mem_resetn = 0;
		$readmemh("/home/zhangshuai/develop/soft_core/vivado_project/picorv32_aximem/picorv32_aximem/asm_main.data",sram.mem,0);
		
		for(i=0;i<13;i=i+1)
			$display("sram.mem[%d] = %h",i,sram.mem[i]);
	end
	
	always #5  clk=~clk;
	always #30 resetn=1;
	always #15  mem_resetn=1;
    
	//1） picorv32 core
    picorv32_axi #(
        .PROGADDR_RESET (PROGADDR_RESET),
        .STACKADDR      (STACKADDR)
    ) cpu (
        .clk        (clk), 
        .resetn     (resetn),
        // AXI4-lite master memory interface
        .mem_axi_awvalid    (mem_axi_awvalid),
        .mem_axi_awready    (mem_axi_awready),
        .mem_axi_awaddr     (mem_axi_awaddr),
        .mem_axi_awprot     (mem_axi_awprot),
    
        .mem_axi_wvalid     (mem_axi_wvalid),
        .mem_axi_wready     (mem_axi_wready),
        .mem_axi_wdata      (mem_axi_wdata),
        .mem_axi_wstrb      (mem_axi_wstrb),
    
        .mem_axi_bvalid     (mem_axi_bvalid),
        .mem_axi_bready     (mem_axi_bready),
    
        .mem_axi_arvalid    (mem_axi_arvalid),
        .mem_axi_arready    (mem_axi_arready),
        .mem_axi_araddr     (mem_axi_araddr),
        .mem_axi_arprot     (mem_axi_arprot),
    
        .mem_axi_rvalid     (mem_axi_rvalid),
        .mem_axi_rready     (mem_axi_rready),
        .mem_axi_rdata      (mem_axi_rdata)
    );
		
	//2） picosoc_sram
	s_axi_lite_mem # () sram (   
        .S_AXI_ACLK(clk),           //全局时钟信号
        .S_AXI_ARESETN(resetn),      //全局复位有效，低位有效
        
        .S_AXI_AWADDR(mem_axi_awaddr),      //写地址，由master发射，slave接收
        .S_AXI_AWREADY(mem_axi_wready),     //写地址准备读，表示slave准备好接受地址和相关控制信号
        .S_AXI_AWPROT(mem_axi_awprot),      //（一般不管）写信道保护类型，表示特权和保护级别，和是否可以数据访问或者指令访问
        .S_AXI_AWVALID(mem_axi_awvalid),    //写地址可用，表明master的地址和控制信息有效
        
        .S_AXI_WDATA(mem_axi_wdata),        //写数据，master发出，slave接收
        .S_AXI_WREADY(mem_axi_wready),      //写数据准备好，slave发出，表示准备好接收数据
        .S_AXI_WSTRB(mem_axi_wstrb),        //master发出。此信号指示哪些字节通道持有有效数据。写数据总线的每个8位都有一个写频闪点
        .S_AXI_WVALID(mem_axi_wvalid),      //写数据有效，master发出，表示写数据和写频闪点可用
        
        // .S_AXI_BRESP(),                  //写响应，表示写事务的状态
        .S_AXI_BVALID(mem_axi_bvalid),      //写响应可用
        .S_AXI_BREADY(mem_axi_bready),      //写响应准备好，表示master准备好接受写响应  
        
        .S_AXI_ARADDR(mem_axi_araddr),      //读地址，master发出，slave接收
        .S_AXI_ARREADY(mem_axi_arready),    //读地址准备好，表明从设备准备好接收地址和相关控制信息
        .S_AXI_ARPROT(mem_axi_arprot),      //（一般不管）读信道保护类型，表示特权和保护级别，和是否可以数据访问或者指令访问
        .S_AXI_ARVALID(mem_axi_arvalid),    //读地址可用，表明master的地址和控制信息有效
        
        .S_AXI_RDATA(mem_axi_rdata),        //读数据，由slave发送数据
        // .S_AXI_RRESP(),                  //读响应，这个信号表明读传输的状态
        .S_AXI_RREADY(mem_axi_rready),      //读准备好，表明master准备好接收数据和相应信息
        .S_AXI_RVALID(mem_axi_rvalid)       //读可用，表明信道上有被读的数据
    );

endmodule