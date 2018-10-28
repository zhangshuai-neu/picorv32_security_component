/*
 * pico片上系统内存
 *
 * mem 接口的 mem
 */
module mem_mem #(
        parameter integer WORDS = 1024
    )(
		input wire clk,
		input wire is_inst,         //判断是否为指令
		input wire [3:0]  wen,		//写使能
		input wire [21:0] addr,		//22位地址
		input wire [31:0] wdata, 	//32位写数据
		output reg [31:0] rdata	    //32位读数据
	);
	//存储器 默认大小为1024*4B = 4KB
	reg [31:0] mem [0:WORDS-1];		
    
	always @(posedge clk) begin
		rdata <= mem[addr];
		if (wen[0]) mem[addr][ 7: 0] <= wdata[ 7: 0];
		if (wen[1]) mem[addr][15: 8] <= wdata[15: 8];
		if (wen[2]) mem[addr][23:16] <= wdata[23:16];
		if (wen[3]) mem[addr][31:24] <= wdata[31:24];
	end
endmodule
