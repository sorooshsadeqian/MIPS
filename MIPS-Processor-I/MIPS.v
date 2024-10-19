`timescale 1ns/1ns

module MIPS(clk,rst);
	input clk,rst;
	wire memtoreg,memread,memwrite,alusrc,regwrite,writesel,pc1,pc2,pcsrc,zero;
	wire [1:0] regdst;
	wire [2:0] aluoperation;
	wire [5:0] opc,func;
	datapath   dp(clk,rst,memtoreg,memread,memwrite,alusrc,regwrite,regdst,writesel,pc1,pc2,aluoperation,pcsrc,opc,func,zero);
	controller cu(opc,func,zero,memtoreg,memread,memwrite,alusrc,regwrite,regdst,writesel,pc1,pc2,aluoperation,pcsrc);
endmodule