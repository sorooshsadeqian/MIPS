`timescale 1ns/1ns

module datapath(clk,rst,memtoreg,memread,memwrite,alusrc,regwrite,regdst,writesel,pc1,pc2,aluoperation,pcsrc,opc,func,zero);
	input clk,rst,memtoreg,memread,memwrite,alusrc,regwrite,writesel,pc1,pc2,pcsrc;
	input [1:0] regdst;
	input [2:0] aluoperation;
	output [5:0] opc,func;
	output zero;
	wire [31:0] pcin,pcout,pcnext,I,wd,A,rd2,O4,B,O4sh,bc,p1,p2,ar,rd,out,O5;
	wire [25:0] I5;
	wire [15:0] I4;
	wire [4:0] I1,I2,I3,wr;
	assign I5=I[25:0];
	assign I4=I[15:0];
	assign {I1,I2,I3}={I[25:21],I[20:16],I[15:11]};
	assign O5={pcnext[31:28],I5,2'b00};
	assign  opc=I[31:26];
	assign  func=I[5:0];
	MUX2	muxpc(p1,p2,pc2,pcin);
	MUX2	muxwd(pcnext,out,writesel,wd);
	MUX2	muxalu(rd2,O4,alusrc,B);
	MUX2	muxp1(pcnext,bc,pcsrc,p1);
	MUX2	muxp2(O5,A,pc1,p2);
	MUX2	muxmr(ar,rd,memtoreg,out);
	MUX3	muxwr(I2,5'd31,I3,regdst,wr);
	ADDER	pcadder(pcout,32'd4,pcnext);
	ADDER	beadder(O4sh,pcnext,bc);
	SHL2	shl2(O4,O4sh);
	SE	se(I4,O4);
	ALU	alu(A,B,aluoperation,ar,zero);
	REGFILE	rf(clk,rst,I1,I2,wr,wd,regwrite,A,rd2);
	DATAMEM dm(clk,ar,rd2,memread,memwrite,rd);
	INSTMEM	im(pcout,I);
	PC	pc(clk,rst,pcin,pcout);
endmodule

