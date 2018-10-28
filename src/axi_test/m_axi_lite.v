
`timescale 1 ns / 1 ps

	module m_axi_lite #
	(
		// 用户参数 开始

		// 用户参数 结束

		//从C_M_START_DATA_VALUE开始生成数据
		parameter  C_M_START_DATA_VALUE	= 32'hAA000000,
    	//master要求目标slave的基地址（master将会使用该基地址初始化读写事务）
		parameter  C_M_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,
    	//axi master端口的地址总线宽度
		parameter integer C_M_AXI_ADDR_WIDTH	= 32, 
	    //axi master端口的数据总线宽度
		parameter integer C_M_AXI_DATA_WIDTH	= 32,
    	//写和读事务的数量
		parameter integer C_M_TRANSACTIONS_NUM	= 4
	)
	(
		// 用户端口 start

		// 用户端口 end		

	//input 为slave或者其他外设发出的，由当前IP master接收
	//output 为master发出的，由slave所在IP接收
	//其他
		input wire  INIT_AXI_TXN,								//发起AXI事务	，为1时触发
		output reg  ERROR,										//检测的error
		output wire TXN_DONE,									//判断AXI事务是否完成
	//时钟
		input wire  M_AXI_ACLK,									//axi时钟信号
		input wire  M_AXI_ARESETN,								//axi活动的低位重置信号（0时，有效）
	//写	事务
		//地址
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,	//master接口的写地址信号接口
		output wire [2 : 0] M_AXI_AWPROT,						//写信道保护类型，表示事务的特权级别
		output wire  M_AXI_AWVALID,								//写地址可用，表明master的写地址和控制信息可用
		input  wire  M_AXI_AWREADY,								//写地址准备好，表示从设备准备好接受数据
		//数据
		output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,		//写数据，master发出，slave接收
		output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,	//master发出。此信号指示哪些字节通道持有有效数据，
																//写数据总线的每个8位都有一个写频闪点。
		output wire  M_AXI_WVALID,								//写数据有效，master发出，表示写数据和写频闪点可用
		input wire  M_AXI_WREADY,								//写数据准备好，slave发出，表示准备好接收数据
		//响应
		input wire [1 : 0] M_AXI_BRESP,							//写响应，表示写事务的状态
		input wire  M_AXI_BVALID,								//写响应可用
		output wire  M_AXI_BREADY,								//写响应准备好，表示master准备好接受写响应
	//读事务
		//地址
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,	//读地址，master发出，slave接收
		output wire [2 : 0] M_AXI_ARPROT,						//（一般不管）读信道保护类型，表示特权和保护级别，//和是否可以数据访问或者指令访问											
		output wire  M_AXI_ARVALID,								//读地址可用，表明master的地址和控制信息有效
		input wire   M_AXI_ARREADY,								//读地址准备好，表明从设备准备好接收地址和相关控制信息
		//数据
		input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,		//读数据，由slave发送数据
		input wire [1 : 0] M_AXI_RRESP,							//读响应，这个信号表明读传输的状态
		input wire  M_AXI_RVALID,								//读可用，表明信道上有被读的数据
		output wire  M_AXI_RREADY								//读准备好，表明master准备好接收数据和相应信息
	);

	//返回log2(bit_depth)
	 function integer clogb2 (input integer bit_depth);
		 begin
		 for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
			 bit_depth = bit_depth >> 1;
		 end
	 endfunction

	//索引计数器的位宽TRANS_NUM_BITS 
	 localparam integer TRANS_NUM_BITS = clogb2(C_M_TRANSACTIONS_NUM-1);

	//样例：初始化计数器的状态，初始化写事务、读事务和读写数据的比较
	parameter [1:0] IDLE 			= 2'b00, 		//该状态由AXI4Lite事务触发，当INIT_AXI_TXN从0变成1时，进入INIT_WRITE状态
					INIT_WRITE  	= 2'b01, 		//初始化写事务，一旦写完成，则进入INIT_READ状态
					INIT_READ 		= 2'b10, 		//初始化读事务，一旦读取完成，则进入INIT_COMPARE状态
					INIT_COMPARE 	= 2'b11; 		//被写数据和读数据比较
					
	reg [1:0] mst_exec_state;	//状态机的执行状态

	// AXI4LITE信号

	reg  							axi_awvalid;		//写地址可用
	reg  							axi_wvalid;			//写数据可用
	reg  							axi_arvalid;		//读地址可用
	reg  							axi_rready;			//读数据接收
	reg  							axi_bready;			//写响应接收
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;			//写地址
	reg [C_M_AXI_DATA_WIDTH-1 : 0] 	axi_wdata;			//写数据
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;			//读地址
	wire  							write_resp_error;	//写响应出错时为1
	wire  							read_resp_error;	//读响应出错时为1
	reg  							start_single_write;	//一个脉冲触发写事务
	reg  							start_single_read;	//一个脉冲触发读事务
	reg  							write_issued;		//当一个节拍触发写事务，直到写事务完成，一直为1
	reg  							read_issued;		//当一个节拍触发读事务，直到读事务完成，一直为1
	reg  							writes_done;		//标志，标记写事务完成，写事务的数量通过C_M_TRANSACTIONS_NUM参数指定
	reg  							reads_done;			//标志，标记读事务完成，读事务的数量通过C_M_TRANSACTIONS_NUM参数指定
	reg  							error_reg;			//错误寄存器，当读写响应错误、数据不匹配时，被置1
	reg [TRANS_NUM_BITS : 0] 		write_index;		//被触发的写事务的索引计数
	reg [TRANS_NUM_BITS : 0] 		read_index;			//被触发的读事务的索引计数
	reg [C_M_AXI_DATA_WIDTH-1 : 0] 	expected_rdata;		//期望读到的数据和真实读到的数据进行比较
	reg  							compare_done;		//期望读到的数据 和 真实读到的数据 比较完成 的标志
	reg  							read_mismatch;		//期望读到的数据 和 真实读到的数据 不一致 的标志
	reg  							last_write;			//到达最后一次写事务的标志
	reg  							last_read;			//到达最后一次写事务的标志
	reg  							init_txn_ff;		//
	reg  							init_txn_ff2;		//
	reg  							init_txn_edge;		//没用到
	wire  							init_txn_pulse;		//


	// I/O Connections assignments
	assign M_AXI_AWADDR	= C_M_TARGET_SLAVE_BASE_ADDR + axi_awaddr;			//Adding the offset address to the base addr of the slave
	assign M_AXI_WDATA	= axi_wdata;										//AXI 4 write data
	assign M_AXI_AWPROT	= 3'b000;											//
	assign M_AXI_AWVALID= axi_awvalid;										//
	assign M_AXI_WVALID	= axi_wvalid;										//Write Data(W)
	assign M_AXI_WSTRB	= 4'b1111;											//Set all byte strobes in this example
	assign M_AXI_BREADY	= axi_bready;										//Write Response (B)
	assign M_AXI_ARADDR	= C_M_TARGET_SLAVE_BASE_ADDR + axi_araddr;			//Read Address (AR)
	assign M_AXI_ARVALID= axi_arvalid;										//
	assign M_AXI_ARPROT	= 3'b001;											//
	assign M_AXI_RREADY	= axi_rready;										//Read and Read Response (R)
	assign TXN_DONE		= compare_done;										//Example design I/O
	assign init_txn_pulse	= (!init_txn_ff2) && init_txn_ff;				//init_txn_ff2和init_txn_ff相等，所以默认为0


	//产生脉冲用来出发AXI事务
	always @(posedge M_AXI_ACLK)										      
	  begin                                                                        
	    //触发AXI事务的延迟（可以在该行之后添加）
	    if (M_AXI_ARESETN == 0 ) begin                                                                    
	        init_txn_ff <= 1'b0;                                                   
	        init_txn_ff2 <= 1'b0;                                                   
	      end                                                                               
	    else begin  
	        init_txn_ff <= INIT_AXI_TXN;	
	        init_txn_ff2 <= init_txn_ff;                                                                 
	      end                                                                      
	  end     

	//写地址信道
		/*
			写地址信道的目的是请求地址和命令信息，这是一个简单的节拍信息。
			axi_awvalid/axi_wvalid采用相同的时钟，这是一种低效率的做法，但是比较容易控制。
			AXI VALID必须保持有效，直到协作者接收数据。
			当master的数据valid且slave准备好接收（ready），传输的数据被slave接收。
			master也可以通过加入休息周期，在不取消确认的情况下，生成不连续的请求。
			由于用户设置只发射了一个未完成的事务，在相同时钟的“新请求”和“接受请求”之之间没有冲突。
		*/  
	  always @(posedge M_AXI_ACLK)										      
	  begin                                                                        
	    //复位，axi_awvalid置0
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1) begin                                                                    
	        axi_awvalid <= 1'b0;                                                   
	      end                                                                           
	    else                                                                       
	      begin                                                                    
	        if (start_single_write)                                                
	          begin                                                                
	            axi_awvalid <= 1'b1;                                               
	          end                                                                  
	    	 //地址被interconnect 或 这slave接收
	        else if (M_AXI_AWREADY && axi_awvalid)                                 
	          begin                                                                
	            axi_awvalid <= 1'b0;                                               
	          end                                                                  
	      end                                                                      
	  end                                                                          

	  // start_single_write触发一个新的写事务，计数器要加1
	  always @(posedge M_AXI_ACLK)                                                 
	  begin                                                                        
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                   
	      begin                                                                    
	        write_index <= 0;                                                      
	      end                                                                                                                    
	    else if (start_single_write)                                               
	      begin                                                                    
	        write_index <= write_index + 1;                                        
	      end                                                                      
	  end                                                                          

	//写数据信道
	 	/*
	 		写数据通道用来传输实际的数据
	 		样例设计：只有WVALID/WREADY的握手
	 	*/
	   always @(posedge M_AXI_ACLK)                                        
	   begin                                                                         
	     if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                                    
	       begin                                                                     
	         axi_wvalid <= 1'b0;                                                     
	       end                                                                       
		//数据可用
	     else if (start_single_write)                                                
	       begin                                                                     
	         axi_wvalid <= 1'b1;                                                     
	       end                                                                       
	     //数据已经被接收   
	     else if (M_AXI_WREADY && axi_wvalid)                                        
	       begin                                                                     
	        axi_wvalid <= 1'b0;                                                      
	       end                                                                       
	   end                                                                           

	//写响应信道
		/*
			写响应通道提供了写入已经提交给内存的反馈。
			在数据和写入地址都到达并被从机接受之后，会发生BREADY，
			并且可以保证之前的其他的访问不会被重新排序。			
			
			BRESP的bit [1] 用来表明iinterconnect或者slave在写事务中的错误
			
			在master和slave有不同的复位延迟时，建议重置READY信号
		*/
	  always @(posedge M_AXI_ACLK)                                    
	  begin                                                                
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                           
	      begin                                                            
	        axi_bready <= 1'b0;                                            
	      end                                                              
	    //slave 响应用，master还未ready
	    else if (M_AXI_BVALID && ~axi_bready) begin                                                            
	        axi_bready <= 1'b1;                                            
	      end                                                              
	    //下一个时钟，将axi_bready重新置0
	    else if (axi_bready) begin                                                            
	        axi_bready <= 1'b0;                                            
	      end                                                              
	    //保持先前的值
	    else                                                               
	      axi_bready <= axi_bready;                                        
	  end
	//写响应出错                                                  
	assign write_resp_error = (axi_bready & M_AXI_BVALID & M_AXI_BRESP[1]);
	
	//读地址信道
		/*
			start_single_read出发新的读事务
			读索引计数器加1
		*/
	  always @(posedge M_AXI_ACLK)                                                     
	  begin                                                                            
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                       
	      begin                                                                        
	        read_index <= 0;                                                           
	      end                                                                                      
	    else if (start_single_read)                                                    
	      begin                                                                        
	        read_index <= read_index + 1;                                              
	      end                                                                          
	  end                                                                              
	                                                                                   
	  // 当master有可用读地址时， axi_arvalid置1
	  always @(posedge M_AXI_ACLK)                                                     
	  begin                                                                            
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                       
	      begin                                                                        
	        axi_arvalid <= 1'b0;                                                       
	      end                                                                          
	    else if (start_single_read)                                                    
	      begin                                                                        
	        axi_arvalid <= 1'b1;                                                       
	      end                                                                          
	    //读地址已经被interconnect/slave接收
	    else if (M_AXI_ARREADY && axi_arvalid)                                         
	      begin                                                                        
	        axi_arvalid <= 1'b0;                                                       
	      end                                                                          
	    // retain the previous value                                                   
	  end                                                                              

	//读数据(读响应)信道
		/*
			读取数据通道返回读取请求的结果。
			当存在有效的读取数据时，主设备将通过声明axi_rready来接受读取的数据。
			虽然不是每个规范都必须的，但是如果主/从之间的复位延迟不同，则建议复位READY信号。		
		
		*/
	  always @(posedge M_AXI_ACLK)                                    
	  begin                                                                 
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                            
	      begin                                                             
	        axi_rready <= 1'b0;                                             
	      end                                                               
	    //当slave将M_AXI_RVALID置为1时，接收读数据/读响应
	    else if (M_AXI_RVALID && ~axi_rready)                               
	      begin                                                             
	        axi_rready <= 1'b1;                                             
	      end                                                               
	    // 下一个时钟，axi_rready为0
	    else if (axi_rready)                                                
	      begin                                                             
	        axi_rready <= 1'b0;                                             
	      end                                                               
	    // retain the previous value                                        
	  end                                                                   
	                                                                        
	//读响应错误标志                                          
	assign read_resp_error = (axi_rready & M_AXI_RVALID & M_AXI_RRESP[1]);  


	//--------------------------------
	//用户逻辑
	//--------------------------------
	//地址、数据仿真
	//地址数据应该为一对，读写值应该匹配
	//如果要构建不同的地址模式的话，可以修改该下面的内容               
	  always @(posedge M_AXI_ACLK)                                  
	      begin                                                     
	        if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                
	          begin                                                 
	            axi_awaddr <= 0;                                    
	          end                                                   
	          //读写完成，地址 +4                        
	        else if (M_AXI_AWREADY && axi_awvalid)                  
	          begin                                                 
	            axi_awaddr <= axi_awaddr + 32'h00000004;            
	          end                                                   
	      end                                                       
	  //写数据
	  //写数据复位时，写数据为C_M_START_DATA_VALUE
	  //写事务时，写数据为C_M_START_DATA_VALUE + write_index 
	  always @(posedge M_AXI_ACLK)                                  
	      begin                                                     
	        if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 )                                
	          begin                                                 
	            axi_wdata <= C_M_START_DATA_VALUE;                  
	          end                                                   
	        //写地址和写数据是可用的
	        else if (M_AXI_WREADY && axi_wvalid)                    
	          begin                                              
	            axi_wdata <= C_M_START_DATA_VALUE + write_index;    
	          end                                                   
	        end          	                                       
	  //读地址                                             
	  always @(posedge M_AXI_ACLK)                                  
	      begin                                                     
	        if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                
	          begin                                                 
	            axi_araddr <= 0;
	          end                                                   
	          //写地址+4
	        else if (M_AXI_ARREADY && axi_arvalid)
	          begin                                                 
	            axi_araddr <= axi_araddr + 32'h00000004;            
	          end                                                   
	      end                                                       
	  //读数据                                             
	  always @(posedge M_AXI_ACLK)                                  
	      begin                                                     
	        if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                
	          begin                                                 
	            expected_rdata <= C_M_START_DATA_VALUE;             
	          end
	          //期望的数据
	        else if (M_AXI_RVALID && axi_rready)                    
	          begin                                                 
	            expected_rdata <= C_M_START_DATA_VALUE + read_index;
	          end                                                   
	      end                                                       
	  
	  //实现master命令接口状态机
	  always @ ( posedge M_AXI_ACLK)                                                    
	  begin                                                                             
	    if (M_AXI_ARESETN == 1'b0)                                                     
	      begin                                                                         
	      //将所有的信号复位为默认值
	        mst_exec_state  <= IDLE;                                            
	        start_single_write <= 1'b0;                                                 
	        write_issued  <= 1'b0;                                                      
	        start_single_read  <= 1'b0;                                                 
	        read_issued   <= 1'b0;                                                      
	        compare_done  <= 1'b0;                                                      
	        ERROR <= 1'b0;
	      end                                                                           
	    else                                                                            
	      begin                                                                         
	       // 状态变换                                                          
	        case (mst_exec_state)                                                       
	                                                                                    
	          IDLE:                                                             
	          //该状态由init_txn_pulse触发
	            if ( init_txn_pulse == 1'b1 )
	              begin                                                                 
	                mst_exec_state  <= INIT_WRITE;                                      
	                ERROR <= 1'b0;
	                compare_done <= 1'b0;
	              end                                                                   
	            else                                                                    
	              begin                                                                 
	                mst_exec_state  <= IDLE;                                    
	              end                                                                   
	                                                                                    
	          INIT_WRITE:                                                               
	            // 该状态将发射 start_single_write脉冲，触发写事务
	            // 写事务应该会一直发射，直到last_write信号为1
	            if (writes_done)                                                        
	              begin                                                                 
	                mst_exec_state <= INIT_READ;
	              end                                                                   
	            else                                                                    
	              begin                                                                 
	                mst_exec_state  <= INIT_WRITE;                                                                
	                  if (~axi_awvalid && ~axi_wvalid && ~M_AXI_BVALID && ~last_write && ~start_single_write && ~write_issued)
	                    begin                                                           
	                      start_single_write <= 1'b1;                                   
	                      write_issued  <= 1'b1;                                        
	                    end                                                             
	                  else if (axi_bready)                                              
	                    begin                                                           
	                      write_issued  <= 1'b0;                                        
	                    end                                                             
	                  else                                                              
	                    begin                                                           
	                      start_single_write <= 1'b0; //停止写事务
	                    end                                                             
	              end                                                                   
	                                                                                    
	          INIT_READ:                                                                
	            // 该状态发射start_single_read 脉冲，触发读事务
	            // 读事务一直发射，直到last_read
	             if (reads_done)                                                        
	               begin                                                                
	                 mst_exec_state <= INIT_COMPARE;                                    
	               end                                                                  
	             else                                                                   
	               begin                                                                
	                 mst_exec_state  <= INIT_READ;                                      
	                                                                                    
	                 if (~axi_arvalid && ~M_AXI_RVALID && ~last_read && ~start_single_read && ~read_issued)
	                   begin                                                            
	                     start_single_read <= 1'b1;                                     
	                     read_issued  <= 1'b1;                                          
	                   end                                                              
	                 else if (axi_rready)                                               
	                   begin                                                            
	                     read_issued  <= 1'b0;                                          
	                   end                                                              
	                 else                                                               
	                   begin                                                            
	                     start_single_read <= 1'b0; //停止读事务 
	                   end                                                              
	               end                                                                  
	                                                                                    
	           INIT_COMPARE:                                                            
	             begin
	                 // 该状态进行已经写的数据和读取的数据的比较
	                 // 如果没有错误就将compare_done置1，标志比较完成

	                 //样例代码中并没有比较
	                 ERROR <= error_reg; 
	                 mst_exec_state <= IDLE;                                    
	                 compare_done <= 1'b1;                                              
	             end                                                                  
	           default:                                                                
	             begin                                                                  
	               mst_exec_state  <= IDLE;                                     
	             end                                                                    
	        endcase                                                                     
	    end                                                                             
	  end //master的执行处理                                                      
	                                                                                    
	  //写计数终止                                     
	  always @(posedge M_AXI_ACLK)                                                      
	  begin                                                                             
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                         
	      last_write <= 1'b0;                                                           
	    //最后一次写 应该和写地址的响应相关
	    else if ((write_index == C_M_TRANSACTIONS_NUM) && M_AXI_AWREADY)                
	      last_write <= 1'b1;                                                           
	    else                                                                            
	      last_write <= last_write;                                                     
	  end                                                                               
	                                                                                                                                              
	 //检查最后一次写完成                                                                                   
	 //该逻辑用来确认最后的写响应，表明写操作已经被提交
	  always @(posedge M_AXI_ACLK)                                                      
	  begin                                                                             
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                         
	      writes_done <= 1'b0;                                                          
			//写完成应该和写响应关联起来
	    else if (last_write && M_AXI_BVALID && axi_bready)                              
	      writes_done <= 1'b1;                                                          
	    else                                                                            
	      writes_done <= writes_done;                                                   
	  end                                                                               
	                                                                                    
	//读样例：
		//读计数终止
	  always @(posedge M_AXI_ACLK)                                                      
	  begin                                                                             
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                         
	      last_read <= 1'b0;                                                                                                                    
	    //最后一次读应该和读地址相关         
	    else if ((read_index == C_M_TRANSACTIONS_NUM) && (M_AXI_ARREADY) )              
	      last_read <= 1'b1;                                                            
	    else                                                                            
	      last_read <= last_read;                                                       
	  end                                                                               
	                                                                                    
	//检查最后一次读完成                                                                            
	  always @(posedge M_AXI_ACLK)                                                      
	  begin                                                                             
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                         
	      reads_done <= 1'b0;                                                           
	    //读完成应该和读响应完成结合起来
	    else if (last_read && M_AXI_RVALID && axi_rready)                               
	      reads_done <= 1'b1;                                                           
	    else                                                                            
	      reads_done <= reads_done;                                                     
	    end                                                                             
	                                                                                    
	//样例设计 错误寄存器                                                                       
	//数据比较
	  always @(posedge M_AXI_ACLK)                                                      
	  begin                                                                             
	    if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                                         
	    read_mismatch <= 1'b0;                                                          
		//当axi_rready为1,读到的数据和期望数据进行比较
	    else if ((M_AXI_RVALID && axi_rready) && (M_AXI_RDATA != expected_rdata))         
	      read_mismatch <= 1'b1;                                                        
	    else                                                                            
	      read_mismatch <= read_mismatch;                                               
	  end                                                                               
	                                                                                    
	//寄存器持有所有数据不匹配，读写接口错误
	  always @(posedge M_AXI_ACLK)                                                      
	  begin                                                                             
	    if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                                         
	      error_reg <= 1'b0;                                                            
		//捕获错误类型
	    else if (read_mismatch || write_resp_error || read_resp_error)                  
	      error_reg <= 1'b1;                                                            
	    else                                                                            
	      error_reg <= error_reg;                                                       
	  end                                                                               
	endmodule

