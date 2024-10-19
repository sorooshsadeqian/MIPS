`timescale 1ns/1ns

`define if    4'd0
`define id    4'd1
`define b0    4'd2
`define b1    4'd3
`define dt    4'd4
`define dt01  4'd5
`define dt02  4'd6
`define dt11  4'd7
`define dt12  4'd8
`define dpi11 4'd9
`define dpi12 4'd10
`define dpi01 4'd11
`define dpi02 4'd12
`define dpi03 4'd13

module CTRL(clk,rst,tbt,opc,ld,lb,i,cond,pcsrc,pcwrite,mems,memwrite,memread,loadir,reg2,wreg,dreg,regwrite,srca,srcb,loadf,loadff,aluop);
	input clk,rst,cond,ld,lb,i;
	input [2:0]tbt,opc;
	output reg [1:0] srcb,dreg;
	output reg pcsrc,pcwrite,mems,memwrite,memread,loadir,reg2,wreg,regwrite,srca,loadf,loadff,aluop;
	reg [3:0] ps,ns;

	always @(posedge clk) begin
		if(rst)
			ps <= 4'd0;
		else
			ps <= ns;
	end
	
	always @(ps,cond,tbt,ld,lb,i) begin
		case(ps)
			`if    : ns = `id;
			`id    : begin 
				if(cond==1'b0) 
					 ns=`if;
		      		if(cond==1'b1 && tbt==3'b101 && lb==1'b0)
					 ns=`b0;
				if(cond==1'b1 && tbt==3'b101 && lb==1'b1)
					 ns=`b1;
			        if(cond==1'b1 && tbt==3'b010 )
				          ns=`dt;
                                if(cond==1'b1 && tbt==3'b000 && i==1'b1)
					  ns=`dpi11;
                                if(cond==1'b1 && tbt==3'b000 && i==1'b0) 
					  ns=`dpi01;
				end
			`b0    : ns = `if;
			`b1    : ns = `if;
			`dt    : ns = ld?`dt11:`dt01;
			`dt01  : ns = `dt02;
			`dt02  : ns = `if;
			`dt11  : ns = `dt12;
			`dt12  : ns = `if;
			`dpi11 : ns = `dpi12;
			`dpi12 : ns = `if; 
			`dpi01 : ns = `dpi02;
			`dpi02 : ns = `dpi03;
			`dpi03 : ns = `if;
			 default: ns = `if;
		endcase
	end

	always @(ps,opc) begin
		{pcsrc,pcwrite,mems,memwrite,memread,loadir,reg2,wreg,regwrite,srca,loadf,loadff,aluop,srcb,dreg}=17'd0;
		case(ps)
			`if    : begin mems=1'd0;pcwrite=1'd1;memread=1'd1;loadir=1'd1;srca=1'd0;srcb=2'd1;pcsrc=1'd0;aluop=1'd0;end 
			`id    : begin srca=1'd0;srcb=2'd2;aluop=1'd0 ; end
			`b0    : begin pcsrc=1'd1;pcwrite=1'b1; end
			`b1    : begin wreg=1'd1;dreg=2'd1;regwrite=1'd1;pcsrc=1'd1;pcwrite=1'b1; end
			`dt    : begin srca=1'd1;srcb=2'd3;aluop=1'd0;end
			`dt01  : begin mems=1'd1;memread=1'd1; end
			`dt02  : begin wreg=1'd0;dreg=2'd0;regwrite=1'd1; end
			`dt11  : begin reg2=1'd0;srca=1'd1;srcb=2'd3;aluop=1'd0; end
			`dt12  : begin mems=1'd1;memwrite=1'd1; end
			`dpi11 : begin srca=1'd1;srcb=2'd3;aluop=1'd1;loadf=1'd1;
				 if(opc==3'b000 || opc==3'b010 || opc==3'b001 || opc==3'b110) loadff=1'b1; end
			`dpi12 : begin dreg=2'd2;wreg=1'd0;regwrite=1'd1; end
			`dpi01 : begin reg2=1'd1; end
			`dpi02 : begin srca=1'd1;srcb=2'd0;aluop=1'd1;loadf=1'd1;
				 if(opc==3'b000 || opc==3'b010 || opc==3'b001 || opc==3'b110) loadff=1'b1; end
			`dpi03 : begin dreg=2'd2;wreg=1'd0;regwrite=1'd1; end
		endcase
	end

endmodule

module ALUCONTROLLER(aluop,opc,aluoperation);
	input aluop;
	input [2:0] opc;
	output reg [2:0]aluoperation;
	always @(aluop,opc) begin
		if(aluop==1'b0)
			aluoperation=3'b000;
		if(aluop==1'b1) begin
			case(opc)
				3'b000: aluoperation=3'b000;
				3'b001: aluoperation=3'b001;
				3'b101: aluoperation=3'b001;
				3'b110: aluoperation=3'b001;
				3'b011: aluoperation=3'b010;
				3'b101: aluoperation=3'b010;
				3'b100: aluoperation=3'b100;
				3'b111: aluoperation=3'b011;	
			endcase
		end
	end	
endmodule

module COND(C,z,n,v,cond);
	input [1:0]C;
	input z,n,v;
	output reg cond;
	always@(C,z,n,v) begin
		cond=1'b0;
		if(C==2'b00) begin
			if(z==1'b1)
				cond=1'b1;
		end
		if(C==2'b01) begin
			if({z,n}==2'b00)
				cond=1'b1;	
		end
		if(C==2'b10) begin
			if(n^v)
				cond=1'b1;
		end
		if(C==2'b11) begin
			cond=1'b1;	
		end
	end
endmodule

