`timescale 1ns/1ns

module PC(clk,rst,in,out);
	input clk,rst;
	input [31:0] in;
	output reg [31:0]out;
	always @(posedge clk) begin
		if(rst)
			out <= 32'd0;
		else
			out <= in;
	end
endmodule

module ADDER(in1,in2,out);
	input [31:0] in1,in2;
	output [31:0] out;
	wire cy;
	assign {cy,out}=in1+in2;
endmodule

module SHL2(in,out);
	input [31:0]in;
	output [31:0] out;
	assign out=in<<2;
endmodule

module MUX2(in1,in2,s,out);
	input [31:0]in1,in2;
	input s;
	output [31:0]out;
	assign out=(s==0)?in1:in2;
endmodule

module MUX3(in1,in2,in3,s,out);
	input [4:0] in1,in2,in3;
	input [1:0]s;
	output [4:0] out;
	assign out=(s==2'd0)?in1:
		   (s==2'd1)?in2:
		   (s==2'd2)?in3:32'dz;
endmodule

module SE(in,out);
	input [15:0]in;
	output [31:0]out;
	assign out={{16{in[15]}},in};
endmodule

module ALU(A,B,aluoperation,ALUResult,zero);
	input [31:0]A,B;
	input [2:0]aluoperation;
	output reg [31:0] ALUResult;
	output zero;
	reg cy;
	assign zero=(ALUResult==0)?1'b1:1'b0;
	always @(A,B,aluoperation) begin
		ALUResult=32'd0;
		cy=1'b0;
		case(aluoperation)
			3'b000: ALUResult=A&B;
			3'b001: ALUResult=A|B;
			3'b010: {cy,ALUResult}=A+B;
			3'b011: ALUResult=A-B;
			3'b111: ALUResult=(A<B)?32'd1:32'd0;
			default: ALUResult=32'd0;
		endcase
	end
endmodule

module REGFILE(clk,rst,rreg1,rreg2,wreg,wdata,regwrite,data1,data2);
	input clk,rst,regwrite;
	input [4:0] rreg1,rreg2,wreg;
	input [31:0] wdata;
	output [31:0] data1,data2;
	reg [31:0] mem [0:31];
	assign data1=mem[rreg1];
	assign data2=mem[rreg2];
	assign mem[0]=32'd0;    //R0
	integer i;
	always @(posedge clk) begin
		if(rst) begin
			for(i=0;i<32;i=i+1)
				mem[i]<=32'd0;
		end
		if(regwrite) begin
			if(wreg!=5'd0)
				mem[wreg]<=wdata;
		end
	end
endmodule

module DATAMEM(clk,adr,wdata,memread,memwrite,rdata);
	input [31:0]adr,wdata;
	input clk,memread,memwrite;
	output [31:0]rdata;
	reg [31:0] mem[1000:2010];
	assign rdata=(memread)?mem[adr]:32'd0; //Read
	always @(posedge clk) begin
		if(memwrite)
			mem[adr]<=wdata;
	end
	
	initial begin
		mem[1000]<=1;
		mem[1004]<=2;
		mem[1008]<=3;
		mem[1012]<=4;
		mem[1016]<=5;
		mem[1020]<=6;
		mem[1024]<=7;
		mem[1028]<=20;
		mem[1032]<=8;
		mem[1036]<=9;
		mem[1040]<=10;
		mem[1044]<=11;
		mem[1048]<=12;
		mem[1052]<=13;
		mem[1056]<=14;
		mem[1060]<=15;
		mem[1064]<=16;
		mem[1068]<=17;
		mem[1072]<=18;
		mem[1076]<=19;
	end
	
endmodule


module INSTMEM(adr,inst);
	input [31:0] adr;
	output [31:0] inst;
	reg [31:0] mem [0:200];
	assign inst=mem[adr];

	initial begin
		$readmemb("inst.txt",mem);
	end
endmodule
