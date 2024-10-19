`timescale 1ns/1ns

module DP(clk,rst,pcsrc,pcwrite,mems,memwrite,memread,loadir,reg2,wreg,dreg,regwrite,srca,srcb,aluoperation,loadf,loadff,
	  it,opc,ld,lb,i,C,c,v,n,z);
	input clk,rst,pcsrc,pcwrite,mems,memwrite,memread,loadir,wreg,reg2,regwrite,srca,loadf,loadff;
	input [1:0]srcb,dreg;
	input [2:0] aluoperation;
	output [2:0]it,opc;
	output [1:0]C;
	output ld,lb,i,c,v,n,z;
	wire   [31:0] pcin,pcout,adr,memout,inst,mdrout,d,r1in,r2in,r1out,r2out,a,b,ar,aluregout,se26,se12;
	wire  cy,ov,neg,zero;
	wire [3:0] r1,r2,wr;
	MUX2_32 		muxpc(ar,aluregout,pcsrc,pcin);
	MUX2_32			muxme(pcout,aluregout,mems,adr);
	MUX2_32			muxsa(pcout,r1out,srca,a);
	MUX2_4			muxr2(inst[15:12],inst[3:0],reg2,r2);
	MUX2_4			muxwr(inst[15:12],4'd15,wreg,wr);
	MUX3			muxd(mdrout,pcout,aluregout,dreg,d);
	MUX4			muxsb(r2out,32'd1,se26,se12,srcb,b);
	PC			pc(clk,rst,pcwrite,pcin,pcout);
	MEM			mem(clk,adr,r2out,memread,memwrite,memout);
	IR			ir(clk,loadir,memout,inst);
	REG			mdr(clk,memout,mdrout);
	REG			R1(clk,r1in,r1out);
	REG			R2(clk,r2in,r2out);
	REG			aluout(clk,ar,aluregout);
	REG_F			F(clk,rst,cy,ov,neg,zero,loadf,loadff,c,v,n,z);
	SE12			SE1(inst[11:0],se12);
	SE26			SE2(inst[25:0],se26);
	REGFILE			regfile(clk,rst,r1,r2,wr,d,regwrite,r1in,r2in);
	ALU			alu(a,b,aluoperation,ar,zero,cy,ov,neg);
	assign C=inst[31:30];
	assign r1=inst[19:16];
	assign it=inst[29:27];
	assign opc=inst[22:20];
	assign ld=inst[20]; //Data Transfer
	assign lb=inst[26]; //Branch
	assign i=inst[23];
endmodule