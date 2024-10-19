`timescale 1ns/1ns

module controller(opc,func,zero,memtoreg,memread,memwrite,alusrc,regwrite,regdst,writesel,pc1,pc2,aluoperation,pcsrc);
	input [5:0] opc,func;
	input zero;
	output memtoreg,memread,memwrite,alusrc,regwrite,writesel,pc1,pc2,pcsrc;
	output [1:0] regdst;
	output [2:0] aluoperation;
	wire [1:0] aluop;
	wire branch;
	SC sc(opc,memtoreg,memread,memwrite,alusrc,regwrite,regdst,writesel,pc1,pc2,aluop,branch);
	AC ac(aluop,func,aluoperation);
	assign pcsrc=branch&zero;
endmodule