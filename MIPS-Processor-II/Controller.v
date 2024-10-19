`timescale 1ns/1ns

module CU(clk,rst,it,opc,C,z,n,v,ld,lb,i,
	  cond,aluoperation,pcsrc,pcwrite,mems,memwrite,memread,loadir,reg2,wreg,dreg,regwrite,srca,srcb,loadf,loadff);
	input clk,rst,z,n,v,ld,lb,i;
	input [2:0]it,opc;
	input [1:0]C;
	output cond,pcsrc,pcwrite,mems,memwrite,memread,loadir,reg2,wreg,regwrite,srca,loadf,loadff;
	output [1:0]srcb,dreg;
	output [2:0]aluoperation;
	wire aluop;
	ALUCONTROLLER alucu(aluop,opc,aluoperation);
	COND	      con(C,z,n,v,cond);
	CTRL	      ctrl(clk,rst,it,opc,ld,lb,i,cond,pcsrc,pcwrite,mems,memwrite,memread,
			   loadir,reg2,wreg,dreg,regwrite,srca,srcb,loadf,loadff,aluop);
endmodule