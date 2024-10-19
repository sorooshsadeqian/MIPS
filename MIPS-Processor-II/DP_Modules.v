`timescale 1ns/1ns

//PC-3*mux2-mux3-mux4-Mem-RegFile-A-B-ALUout(register)-IR-MDR-S.E-ALU-F(register)

module PC(clk,rst,pcwrite,in,out);
	input clk,rst,pcwrite;
	input [31:0]in;
	output reg [31:0]out;
	always @(posedge clk) begin
		if(rst)
			out<=32'd0;
		else
			if(pcwrite)
				out<=in;
	end
endmodule

module MUX2_32(in1,in2,s,out);
	input [31:0]in1,in2;
	input s;
	output [31:0]out;
	assign out=(s==1'b0)?in1:in2;
endmodule

module MUX2_4(in1,in2,s,out);
	input [3:0]in1,in2;
	input s;
	output [3:0]out;
	assign out=(s==1'b0)?in1:in2;
endmodule

module MUX3(in1,in2,in3,s,out);
	input [31:0]in1,in2,in3;
	input [1:0]s;
	output [31:0]out;
	assign out=(s==2'd0)?in1:
		   (s==2'd1)?in2:
		   (s==2'd2)?in3:32'dz;
endmodule

module MUX4(in1,in2,in3,in4,s,out);
	input [31:0]in1,in2,in3,in4;
	input [1:0]s;
	output [31:0]out;
	assign out=(s==2'd0)?in1:
		   (s==2'd1)?in2:
		   (s==2'd2)?in3:
		   (s==2'd3)?in4:32'dz;
endmodule

module MEM(clk,adr,data,memread,memwrite,memout);
	input [31:0]adr,data;
	input clk,memread,memwrite;
	output [31:0]memout;
	reg [31:0] mem[0:2010];
	assign memout=(memread)?mem[adr]:32'd0; //Read
	always @(posedge clk) begin
		if(memwrite)
			mem[adr]<=data;
	end

	initial begin
		//inst

		mem[0] <= 32'b11000000100000000001001111101000;
		mem[1] <= 32'b11000000100000000010000000000000;
		mem[2] <= 32'b11010000000000010011000000000000;
		mem[3] <= 32'b11000000100000000111000000000000;
		mem[4] <= 32'b11000000100000000100000000001010;
		mem[5] <= 32'b11000000011000100000000000000100;
		mem[6] <= 32'b00101000000000000000000000001000;
		mem[7] <= 32'b11010000000000010101000000000000;
		mem[8] <= 32'b11000000011001010000000000000011;
		mem[9] <= 32'b01101000000000000000000000000010;
		mem[10]<= 32'b11000000000001010011000000000000;
		mem[11]<= 32'b11000000000000100111000000000000;
		mem[12]<= 32'b11000000100000010001000000000001;
		mem[13]<= 32'b11000000100000100010000000000001;
		mem[14]<= 32'b11101011111111111111111111110110;
		mem[15]<= 32'b11010000000100000011011111010000;
		mem[16]<= 32'b11010000000100000111011111010100;

		//datas
		mem[1000] <= 32'd10;
		mem[1001] <= 32'd8;
		mem[1002] <= 32'd7;
		mem[1003] <= 32'd6;
		mem[1004] <= 32'd3;
		mem[1005] <= 32'd9;
		mem[1006] <= 32'd5;
		mem[1007] <= 32'd4;
		mem[1008] <= 32'd1;
		mem[1009] <= 32'd12;
	end
endmodule 

module IR(clk,load,in,out);
	input clk,load;
	input [31:0]in;
	output reg [31:0]out;
	always @(posedge clk) begin
		if(load)
			out <= in;
	end
endmodule

module REG(clk,in,out);
	input clk;
	input [31:0]in;
	output reg [31:0]out;
	always @(posedge clk) begin
		out<=in;
	end
endmodule

module REGFILE(clk,rst,rreg1,rreg2,wreg,wdata,regwrite,data1,data2);
	input clk,rst,regwrite;
	input [3:0] rreg1,rreg2,wreg;
	input [31:0] wdata;
	output [31:0] data1,data2;
	reg [31:0] mem [0:31];
	assign data1=mem[rreg1];
	assign data2=mem[rreg2];
	assign mem[0]=32'd0;    //R0
	integer i;
	always @(posedge clk) begin
		if(rst) begin
			for(i=0;i<16;i=i+1)
				mem[i]<=32'd0;
		end
		if(regwrite) begin
			if(wreg!=4'd0)
				mem[wreg]<=wdata;
		end
	end
endmodule

module SE12(in,out);
	input [11:0]in;
	output [31:0]out;
	assign out={{20{in[11]}},in};
endmodule

module SE26(in,out);
	input [25:0]in;
	output [31:0]out;
	assign out={{6{in[25]}},in};
endmodule

module REG_F(clk,rst,cy,ov,neg,zero,loadF,loadFF,c,v,n,z);
	input clk,rst,cy,ov,neg,zero,loadF,loadFF;
	output reg c,v,n,z;
	always @(posedge clk) begin
		if(rst)
			{z,n,c,v}=4'b0000;
		if(loadF)
			{z,n}={zero,neg};
		if(loadFF)
			{c,v}={cy,ov};
	end
endmodule

module ALU(a,b,aluoperation,aluresult,z,cy,ov,n);
	input [31:0]a,b;
	input [2:0]aluoperation;
	output [31:0] aluresult;
	reg [32:0]out;
	output z,cy,ov,n;
	assign z=(aluresult==0)?1'b1:1'b0;
	assign cy=out[32];
	assign ov=((~a[31])&(~b[31])&aluresult[31])|(a[31]&b[31]&(~aluresult[31]));
	assign n=aluresult[31];
	assign aluresult=out[31:0];
	always @(a,b,aluoperation) begin
		out=32'd0;
		case(aluoperation)
			3'b000: out=a+b;
			3'b001: out=a-b;
			3'b010: out=a&b;
			3'b011: out=b;
			3'b100: out=~b;
		endcase
	end
endmodule

