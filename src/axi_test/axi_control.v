
`timescale 1 ns / 1 ps

	module axi_ms #
	(
		// 其他参数
		parameter integer INST_ADDR_WIDTH 		=32,

		// slave 接口参数
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		parameter integer C_S_AXI_ADDR_WIDTH	= 4,

		// master 接口参数
		parameter integer C_M_AXI_ADDR_WIDTH	= 32,
		parameter integer C_M_AXI_DATA_WIDTH	= 32
	)
	(
        // cpu 接口
        reg [0:INST_ADDR_WIDTH-1] 				inst_addr,
        
		// axi-lite 的 slave 接口
		input wire  							s_axi_aclk,
		input wire  							s_axi_aresetn,
		
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] 	s_axi_awaddr,
		input wire [2 : 0] 						s_axi_awprot,
		input wire  							s_axi_awvalid,
		output reg  							s_axi_awready,
		input wire [C_S_AXI_DATA_WIDTH-1 : 0]	s_axi_wdata,
		
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0]	s_axi_wstrb,
		input wire  								s_axi_wvalid,
		output reg  								s_axi_wready,
		
		output reg [1 : 0] 					    s_axi_bresp,
		output reg  							s_axi_bvalid,
		input wire  							s_axi_bready,
		
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0]	s_axi_araddr,
		input wire [2 : 0] 						s_axi_arprot,
		input wire  							s_axi_arvalid,
		output reg  							s_axi_arready,
		
		output reg [C_S_AXI_DATA_WIDTH-1 : 0]	s_axi_rdata,
		output reg [1 : 0]						s_axi_rresp,
		output reg 							    s_axi_rvalid,
		input wire								s_axi_rready,

		// axi-lite 的 master 接口
		input wire  m_axi_aclk,
        input wire  m_axi_aresetn,
		
		output reg [C_M_AXI_ADDR_WIDTH-1 : 0]	m_axi_awaddr,
		output reg [2 : 0] 					m_axi_awprot,
		output reg  							m_axi_awvalid,
		input wire  							m_axi_awready,
		
		output reg [C_M_AXI_DATA_WIDTH-1 : 0] 	 m_axi_wdata,
		output reg [C_M_AXI_DATA_WIDTH/8-1 : 0] m_axi_wstrb,
		output reg  						     m_axi_wvalid,
		input wire  							 m_axi_wready,
		
		input wire [1 : 0] 						 m_axi_bresp,
		input wire  							 m_axi_bvalid,
		output reg  							 m_axi_bready,
		
		output reg [C_M_AXI_ADDR_WIDTH-1 : 0]   m_axi_araddr,
		output reg [2 : 0] 				        m_axi_arprot,
		output reg                              m_axi_arvalid,
		input wire  						    m_axi_arready,
		
		input wire [C_M_AXI_DATA_WIDTH-1 : 0] m_axi_rdata,
		input wire [1 : 0] 					  m_axi_rresp,
		input wire  					      m_axi_rvalid,
		output reg                           m_axi_rready
	);
    
    // 用来判断 slave 接口行为
    reg is_s_read;
    reg is_s_write;
    
    
    
    // read 操作
    axi_lite_master_read
    
    
    // write 操作
    
    
    
    
	
	endmodule
