module m_axi_lite_op (
    parameter MPU_ADDR = 32'h00000000,
    parameter MPU_END =  32'h00000000
    )
    (
	input clk, resetn,
    
	// axi_lite master接口
	output reg        mem_axi_awvalid,
	input wire        mem_axi_awready,
	output reg [31:0] mem_axi_awaddr,
	output reg [ 2:0] mem_axi_awprot,

	output reg        mem_axi_wvalid,
	input wire        mem_axi_wready,
	output reg [31:0] mem_axi_wdata,
	output reg [ 3:0] mem_axi_wstrb,

	input wire        mem_axi_bvalid,
	output reg        mem_axi_bready,

	output reg        mem_axi_arvalid,
	input wire        mem_axi_arready,
	output reg [31:0] mem_axi_araddr,
	output reg [ 2:0] mem_axi_arprot,

	input wire        mem_axi_rvalid,
	output reg        mem_axi_rready,
	input wire [31:0] mem_axi_rdata,

	// Native PicoRV32 memory interface

	input wire        mem_valid,    //表示要进行内存操作
	input wire        mem_instr,    //表示读指令
	output reg        mem_ready,    //
	input wire [31:0] mem_addr,
	input wire [31:0] mem_wdata,
	input wire [ 3:0] mem_wstrb,
	output reg [31:0] mem_rdata
);
	reg ack_awvalid;
	reg ack_arvalid;
	reg ack_wvalid;
	reg xfer_done;

	assign mem_axi_awvalid = mem_valid && |mem_wstrb && !ack_awvalid;
	assign mem_axi_awaddr = mem_addr;
	assign mem_axi_awprot = 0;

	assign mem_axi_arvalid = mem_valid && !mem_wstrb && !ack_arvalid;
	assign mem_axi_araddr = mem_addr;
	assign mem_axi_arprot = mem_instr ? 3'b100 : 3'b000;

	assign mem_axi_wvalid = mem_valid && |mem_wstrb && !ack_wvalid;
	assign mem_axi_wdata = mem_wdata;
	assign mem_axi_wstrb = mem_wstrb;

	assign mem_ready = mem_axi_bvalid || mem_axi_rvalid;
	assign mem_axi_bready = mem_valid && |mem_wstrb;
	assign mem_axi_rready = mem_valid && !mem_wstrb;
	assign mem_rdata = mem_axi_rdata;

	always @(posedge clk) begin
		if (!resetn) begin
			ack_awvalid <= 0;
		end else begin
			xfer_done <= mem_valid && mem_ready;
			if (mem_axi_awready && mem_axi_awvalid)
				ack_awvalid <= 1;
			if (mem_axi_arready && mem_axi_arvalid)
				ack_arvalid <= 1;
			if (mem_axi_wready && mem_axi_wvalid)
				ack_wvalid <= 1;
			if (xfer_done || !mem_valid) begin
				ack_awvalid <= 0;
				ack_arvalid <= 0;
				ack_wvalid <= 0;
			end
		end
	end
endmodule
