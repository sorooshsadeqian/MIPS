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

module MUX332(in1,in2,in3,s,out);
	input [31:0] in1,in2,in3;
	input [1:0]s;
	output [31:0] out;
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
		mem[1000]<=8;
		mem[1004]<=2;
		mem[1008]<=3;
		mem[1012]<=4;
		mem[1016]<=5;
		mem[1020]<=6;
		mem[1024]<=7;
		mem[1028]<=20;
		mem[1032]<=1;
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


module IFID(clk,in1,in2,out1,out2);
	input clk;
	input [31:0]in1,in2;
	output reg [31:0]out1,out2;
	always @(posedge clk) begin
		out1 <= in1;
		out2 <= in2;
	end
endmodule


module IDEX(clk,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,out1,out2,out3,out4,out5,out6,out7,out8,out9,out10,out11);
	input clk;
	input [2:0]in1;
	input [31:0]in4,in6,in7,in8;
	input [5:0]in3;
	input [4:0]in2,in9,in10,in11;
	input [25:0]in5;
	output reg [2:0]out1;
	output reg [31:0]out4,out6,out7,out8;
	output reg [5:0]out3;
	output reg [4:0]out2,out9,out10,out11;
	output reg [25:0]out5;	
	always @(posedge clk) begin
		{out1,out2,out3,out4,out5,out6,out7,out8,out9,out10,out11} <= {in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11};
	end
endmodule

module EXMEM(clk,in1,in2,in3,in4,in5,in6,in7,in8,in9,out1,out2,out3,out4,out5,out6,out7,out8,out9);
	input clk,in6;
	input [2:0]in1;
	input [4:0]in2,in9;
	input [31:0]in3,in4,in5,in7,in8;
	output reg out6;
	output reg [2:0]out1;
	output reg [4:0]out2,out9;
	output reg [31:0]out3,out4,out5,out7,out8;	
	always @(posedge clk) begin
		{out1,out2,out3,out4,out5,out6,out7,out8,out9} <= {in1,in2,in3,in4,in5,in6,in7,in8,in9};
	end
endmodule


module MEMWB(clk,in1,in2,in3,in4,out1,out2,out3,out4);
	input clk;
	input [2:0]in1;
	input [31:0]in2,in3;
	input [4:0]in4;
	output reg [2:0]out1;
	output reg [31:0]out2,out3;
	output reg [4:0]out4;	
	always @(posedge clk) begin 
		{out1,out2,out3,out4} <= {in1,in2,in3,in4};
	end
endmodule

module INSTMEM(adr,inst);
	input [31:0] adr;
	output [31:0] inst;
	reg [31:0] mem [0:600];
	assign inst=mem[adr];

	//insert inst	
	initial begin
		mem[0]<=32'b00000100000000010000001111101000;
		mem[4]<=32'b00000000000000000000000000000000;
		mem[8]<=32'b00000000000000000000000000000000;
		mem[12]<=32'b00000000000000000000000000000000;
		mem[16]<=32'b00000000000000000000000000000000;
		mem[20]<=32'b00000100000000100000000000000000;
		mem[24]<=32'b00000000000000000000000000000000;
		mem[28]<=32'b00000000000000000000000000000000;
		mem[32]<=32'b00000000000000000000000000000000;
		mem[36]<=32'b00000000000000000000000000000000;
		mem[40]<=32'b00001100001000110000000000000000;
		mem[44]<=32'b00000000000000000000000000000000;
		mem[48]<=32'b00000000000000000000000000000000;
		mem[52]<=32'b00000000000000000000000000000000;
		mem[56]<=32'b00000000000000000000000000000000;
		mem[60]<=32'b00000100000001110000000000000000;
		mem[64]<=32'b00000000000000000000000000000000;
		mem[68]<=32'b00000000000000000000000000000000;
		mem[72]<=32'b00000000000000000000000000000000;
		mem[76]<=32'b00000000000000000000000000000000;
		mem[80]<=32'b00000100000001000000000000010100;
		mem[84]<=32'b00000000000000000000000000000000;
		mem[88]<=32'b00000000000000000000000000000000;
		mem[92]<=32'b00000000000000000000000000000000;
		mem[96]<=32'b00000000000000000000000000000000;
		mem[100]<=32'b00010100010001000000000000110001;
		mem[104]<=32'b00000000000000000000000000000000;
		mem[108]<=32'b00000000000000000000000000000000;
		mem[112]<=32'b00000000000000000000000000000000;
		mem[116]<=32'b00000000000000000000000000000000;
		mem[120]<=32'b00001100001001010000000000000000;
		mem[124]<=32'b00000000000000000000000000000000;
		mem[128]<=32'b00000000000000000000000000000000;
		mem[132]<=32'b00000000000000000000000000000000;
		mem[136]<=32'b00000000000000000000000000000000;
		mem[140]<=32'b00000000011001010011000000010000;
		mem[144]<=32'b00000000000000000000000000000000;
		mem[148]<=32'b00000000000000000000000000000000;
		mem[152]<=32'b00000000000000000000000000000000;
		mem[156]<=32'b00000000000000000000000000000000;
		mem[160]<=32'b00010100110000000000000000001001;
		mem[164]<=32'b00000000000000000000000000000000;
		mem[168]<=32'b00000000000000000000000000000000;
		mem[172]<=32'b00000000000000000000000000000000;
		mem[176]<=32'b00000000000000000000000000000000;
		mem[180]<=32'b00011000000000000000000000111100;
		mem[184]<=32'b00000000000000000000000000000000;
		mem[188]<=32'b00000000000000000000000000000000;
		mem[192]<=32'b00000000000000000000000000000000;
		mem[196]<=32'b00000000000000000000000000000000;
		mem[200]<=32'b00000000101000000001100000000001;
		mem[204]<=32'b00000000000000000000000000000000;
		mem[208]<=32'b00000000000000000000000000000000;
		mem[212]<=32'b00000000000000000000000000000000;
		mem[216]<=32'b00000000000000000000000000000000;
		mem[220]<=32'b00000000010000000011100000000001;
		mem[224]<=32'b00000000000000000000000000000000;
		mem[228]<=32'b00000000000000000000000000000000;
		mem[232]<=32'b00000000000000000000000000000000;
		mem[236]<=32'b00000000000000000000000000000000;
		mem[240]<=32'b00000100001000010000000000000100;
		mem[244]<=32'b00000000000000000000000000000000;
		mem[248]<=32'b00000000000000000000000000000000;
		mem[252]<=32'b00000000000000000000000000000000;
		mem[256]<=32'b00000000000000000000000000000000;
		mem[260]<=32'b00000100010000100000000000000001;
		mem[264]<=32'b00000000000000000000000000000000;
		mem[268]<=32'b00000000000000000000000000000000;
		mem[272]<=32'b00000000000000000000000000000000;
		mem[276]<=32'b00000000000000000000000000000000;
		mem[280]<=32'b00011000000000000000000000011001;
		mem[284]<=32'b00000000000000000000000000000000;
		mem[288]<=32'b00000000000000000000000000000000;
		mem[292]<=32'b00000000000000000000000000000000;
		mem[296]<=32'b00000000000000000000000000000000;
		mem[300]<=32'b00010000000000110000011111010000;
		mem[304]<=32'b00000000000000000000000000000000;
		mem[308]<=32'b00000000000000000000000000000000;
		mem[312]<=32'b00000000000000000000000000000000;
		mem[316]<=32'b00000000000000000000000000000000;
		mem[320]<=32'b00010000000001110000011111010100;
		mem[324]<=32'b00000000000000000000000000000000;
		mem[328]<=32'b00000000000000000000000000000000;
		mem[332]<=32'b00000000000000000000000000000000;
		mem[336]<=32'b00000000000000000000000000000000;
	end

endmodule

