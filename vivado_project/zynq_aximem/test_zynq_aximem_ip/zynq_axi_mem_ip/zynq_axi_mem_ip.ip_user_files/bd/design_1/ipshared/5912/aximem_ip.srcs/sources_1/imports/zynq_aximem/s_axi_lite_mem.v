`timescale 1ns / 1ps

module s_axi_lite_mem # (
    // 用户参数 起始
    parameter integer MEM_SIZE = 256,   //MEM_SIZE * 4Byte
    // 用户参数 结束
    // Do not modify the parameters beyond this line
    // Width of S_AXI data bus
    parameter integer C_S_AXI_DATA_WIDTH    = 32,
    // Width of S_AXI address bus
    parameter integer C_S_AXI_ADDR_WIDTH    = 32 	//后面需要修改
)
(
    //input 为master发出的，由当前IP slave接收
    //output 为slave发出的，由master所在IP接收

//时钟        
    input wire  							S_AXI_ACLK,         //全局时钟信号
    input wire  							S_AXI_ARESETN,      //全局复位有效，低位有效
//写信号
    //地址
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] 	S_AXI_AWADDR,   	//写地址，由master发射，slave接收
    output wire  							S_AXI_AWREADY,      //写地址准备读，表示slave准备好接受地址和相关控制信号
    input wire [2 : 0] 						S_AXI_AWPROT,       //（一般不管）写信道保护类型，表示特权和保护级别，和是否可以数据访问或者指令访问
    input wire  							S_AXI_AWVALID,      //写地址可用，表明master的地址和控制信息有效
    
    //数据
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] 		S_AXI_WDATA,    //写数据，master发出，slave接收
    output wire  							    S_AXI_WREADY,   //写数据准备好，slave发出，表示准备好接收数据
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] 	S_AXI_WSTRB,    //master发出。此信号指示哪些字节通道持有有效数据。写数据总线的每个8位都有一个写频闪点
    input wire  							    S_AXI_WVALID,   //写数据有效，master发出，表示写数据和写频闪点可用
    
    //响应
    output wire [1 : 0] 					S_AXI_BRESP,    	//写响应，表示写事务的状态
    output wire  							S_AXI_BVALID,       //写响应可用
    input wire  							S_AXI_BREADY,       //写响应准备好，表示master准备好接受写响应
//读信号    
    //读地址
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0]   S_AXI_ARADDR,       //读地址，master发出，slave接收
    output wire  							S_AXI_ARREADY,      //读地址准备好，表明从设备准备好接收地址和相关控制信息
    input wire [2 : 0] 						S_AXI_ARPROT,       //（一般不管）读信道保护类型，表示特权和保护级别，和是否可以数据访问或者指令访问
    input wire  							S_AXI_ARVALID,      //读地址可用，表明master的地址和控制信息有效
    
	//读数据
    output wire [C_S_AXI_DATA_WIDTH-1 : 0]  S_AXI_RDATA, 		//读数据，由slave发送数据
    output wire [1 : 0] 					S_AXI_RRESP,		//读响应，这个信号表明读传输的状态
    input wire  							S_AXI_RREADY, 		//读准备好，表明master准备好接收数据和相应信息
    output wire  							S_AXI_RVALID		//读可用，表明信道上有被读的数据
);

// 内部寄存器,以word为单位进行查找
wire [C_S_AXI_ADDR_WIDTH-1 : 0]     word_araddr;

// AXI4LITE signals，AXIlite信号的寄存器
reg [C_S_AXI_ADDR_WIDTH-1 : 0]     	axi_awaddr;	
reg      							axi_awready;
reg      							axi_wready;
reg [1 : 0]     					axi_bresp;
reg      							axi_bvalid;
reg [C_S_AXI_ADDR_WIDTH-1 : 0]     	axi_araddr;
reg      							axi_arready;
reg [C_S_AXI_DATA_WIDTH-1 : 0]     	axi_rdata;
reg [1 : 0]    						axi_rresp;
reg      							axi_rvalid;

// 样例信号
// 本地地址宽度参数 C_S_AXI_DATA_WIDTH,32 bit或者64 bit
// ADDR_LSB 对于寻找寄存器有用
localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1; 	//用来标记总线位数，32bit（2），64bit（3）
localparam integer OPT_MEM_ADDR_BITS = 1;


//用户添加 开始
	//内部存储器（用来存放数据）
    // 默认大小为1K = 256*4B
    reg [C_S_AXI_DATA_WIDTH-1 : 0]      mem[0:MEM_SIZE-1];
    
//用户添加 结束

wire     slv_reg_rden; 							//读使能，为1时，可以从总线读取数据（从存储器读取）
wire     slv_reg_wren; 							//写使能，为1时，可以从总线读取数据（写入存储器）
reg [C_S_AXI_DATA_WIDTH-1:0]     reg_data_out; 	//数据out
integer     byte_index; 						//字节索引


//内部处理

assign word_araddr = S_AXI_ARADDR>>2;

//将信号和寄存器连接起来
assign S_AXI_AWREADY    = axi_awready;
assign S_AXI_WREADY     = axi_wready;
assign S_AXI_BRESP      = axi_bresp;
assign S_AXI_BVALID     = axi_bvalid;
assign S_AXI_ARREADY    = axi_arready;
assign S_AXI_RDATA      = axi_rdata;
assign S_AXI_RRESP      = axi_rresp;
assign S_AXI_RVALID     = axi_rvalid;


// axi_awready AXI地址准备好的处理
// axi_awready 在 S_AXI_ACLK 上升沿时处理
//		S_AXI_AWVALID 和 S_AXI_WVALID 为1, axi_awready 为0时, 将 axi_awready置为1
// 		否则 axi_awready 为0
// axi_awready 在复位信号为0时，复位为0
always @( posedge S_AXI_ACLK )
begin
  if ( S_AXI_ARESETN == 1'b0 )
    begin
      axi_awready <= 1'b0;
    end 
  else
    begin    
      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
        begin
		  // slave 准备接收写地址，当写地址和写数据都都可用
          axi_awready <= 1'b1;
        end
      else           
        begin
          axi_awready <= 1'b0;
        end
    end 
end       

// 在 S_AXI_ACLK 上升沿时
// 在 S_AXI_AWVALID and S_AXI_WVALID 都可用时，实现 axi_awaddr 锁存
always @( posedge S_AXI_ACLK )
begin
  if ( S_AXI_ARESETN == 1'b0 )
    begin
      axi_awaddr <= 0;
    end 
  else
    begin    
      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
        begin
          //写地址锁存
          axi_awaddr <= S_AXI_AWADDR;
        end
    end 
end     

// AXI 写数据准备好的处理
// axi_awready 在 S_AXI_ACLK 上升沿时处理
//		S_AXI_AWVALID 和 S_AXI_WVALID 为1, axi_wready 为0时, 将 axi_wready置为1
// axi_awready 在复位信号为0时，复位为0
always @( posedge S_AXI_ACLK )
begin
  if ( S_AXI_ARESETN == 1'b0 )
    begin
      axi_wready <= 1'b0;
    end 
  else
    begin    
      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID)
        begin
		  // slave 准备接收写数据
          axi_wready <= 1'b1;
        end
      else
        begin
          axi_wready <= 1'b0;
        end
    end 
end       

// 寄存器的选择和写入
// 当axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID 全为1时，表示可以从写总写读取数据并存入存储器
// 复位时，存储器清0
// 按字节存储到寄存器（S_AXI_WSTRB）
assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;
always @( posedge S_AXI_ACLK )
begin
    if (slv_reg_wren) begin
        mem[axi_awaddr] <= S_AXI_WDATA;
    end
end

// 写响应
// 在“axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID为1”且“axi_bvalid为0”时，设置 写响应可用 和 写响应
// 标志写事务的状态
// 复位时，axi_bvalid为0，axi_bresp为0
always @( posedge S_AXI_ACLK )
begin
  if ( S_AXI_ARESETN == 1'b0 ) begin
      axi_bvalid  <= 0;
      axi_bresp   <= 2'b0;
	end 
  else begin    
      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID) begin
		  // 表明写响应可用
          axi_bvalid <= 1'b1;
          axi_bresp  <= 2'b0; // 'OKAY' response 
        end                   // work error responses in future
      else begin
          if (S_AXI_BREADY && axi_bvalid) begin
			  //如果bready 和 bvalid为1,则重新置0
              axi_bvalid <= 1'b0; 
            end  
        end
    end
end   

// 读地址
// 当axi_awready为0 且 S_AXI_ARVALID为1，
// 复位时，axi_arready和axi_araddr都置0，axi_arready置1，将S_AXI_ARADDR写入axi_araddr
always @( posedge S_AXI_ACLK )
begin
  if ( S_AXI_ARESETN == 1'b0 ) begin
      axi_arready <= 1'b0;
      axi_araddr  <= 32'b0;
    end 
  else begin    
      if (~axi_arready && S_AXI_ARVALID) begin
          axi_arready <= 1'b1;				//表明slave准备好接收“读地址”
          axi_araddr  <= word_araddr;		//读地址
        end
      else begin
          axi_arready <= 1'b0;
        end
    end 
end       

// 读响应
// 读地址准备好，读地址可用，读地址可用
// axi_arready && S_AXI_ARVALID && ~axi_rvalid成立时，axi_rvalid写1,axi_rresp写0
always @( posedge S_AXI_ACLK )
begin
  if ( S_AXI_ARESETN == 1'b0 )
    begin
      axi_rvalid <= 0;
      axi_rresp  <= 0;
    end 
  else
    begin    
      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
        begin
          // Valid read data is available at the read data bus
          axi_rvalid <= 1'b1;
          axi_rresp  <= 2'b0; // 'OKAY' response
        end   
      else if (axi_rvalid && S_AXI_RREADY)
        begin
		  //读数据已经被master接受
          axi_rvalid <= 1'b0;
        end                
    end
end    

// 读数据
// 根据地址将内容写出到reg_data_out
// axi_arready和S_AXI_ARVALID为1，axi_rvalid为0 时，slave的读寄存器slv_reg_rden被使能
assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;

//在任何一个右端信号改变时，会被触发
always @(*)
begin
      //从mem中读出数据
      reg_data_out <= mem[axi_araddr];
end

//输出数据到read bus
//复位为0，axi_rdata重置为0
always @( posedge S_AXI_ACLK )
begin
  if ( S_AXI_ARESETN == 1'b0 ) begin
      axi_rdata  <= 0;
    end 
  else begin    
	  //当读寄存器使能时，读取数据到read bus
      if (slv_reg_rden) begin
          axi_rdata <= reg_data_out;     //输出读出数据
        end   
    end
end    

endmodule
