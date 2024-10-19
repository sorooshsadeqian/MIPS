`timescale 1ns/1ns

module Processor(clk,rst);
	input clk,rst;
	wire pcsrc,pcwrite,mems,memwrite,memread,loadir,reg2,wreg,
		   regwrite,srca,loadf,loadff,
	  	   ld,lb,i,c,v,n,z;
	wire [1:0] dreg,srcb,C;
	wire [2:0] it,opc,aluoperation;
	DP	dp(clk,rst,pcsrc,pcwrite,mems,memwrite,memread,loadir,reg2,wreg,dreg,
		   regwrite,srca,srcb,aluoperation,loadf,loadff,
	  	   it,opc,ld,lb,i,C,c,v,n,z);
	CU	cu(clk,rst,it,opc,C,z,n,v,ld,lb,i,
	           cond,aluoperation,pcsrc,pcwrite,mems,
		   memwrite,memread,loadir,reg2,wreg,dreg,regwrite,srca,srcb,loadf,loadff);
endmodule
