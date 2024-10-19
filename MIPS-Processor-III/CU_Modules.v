module CTRL(opc,func,memtoreg,writesel,regwrite,pc1,pc2,memwrite,memread,branch,alusrc,regdst,aluoperation);
	input [5:0] opc,func;
	output memtoreg,writesel,regwrite; //WB
	output pc1,pc2,memwrite,memread,branch; //M
	output alusrc;output [1:0]regdst;output [2:0]aluoperation; //EX
	wire [1:0]aluop;
	SC	sc(opc,memtoreg,memread,memwrite,alusrc,regwrite,regdst,writesel,pc1,pc2,aluop,branch);
	AC	ac(aluop,func,aluoperation);
endmodule

module PCSRC(rst,zout,branch,pcsrc);
	input rst,zout,branch;
	output reg pcsrc;
	always @(*) begin
		if(rst)
			pcsrc=1'b0;

		if(zout==1'b1 && branch==1'b1)
			pcsrc=1'b1;
		else
			pcsrc=1'b0;
	end
endmodule

module SPC2(rst,pc2,spc2);
	input rst,pc2;
	output reg spc2;
	always @(*) begin
		if(rst)
			spc2=1'b0;

		if(pc2==1'b1)
			spc2=1'b1;
		else
			spc2=1'b0;
	end
endmodule

module SC(opc,memtoreg,memread,memwrite,alusrc,regwrite,regdst,writesel,pc1,pc2,aluop,branch);
	input [5:0]opc;
	output reg memtoreg,memread,memwrite,alusrc,regwrite,writesel,pc1,pc2,branch;
	output reg [1:0]regdst,aluop;
	always @(opc) begin
		{aluop,memtoreg,memread,memwrite,alusrc,regwrite,regdst,writesel,pc1,pc2,branch}=13'd0;
		case(opc)
			6'b000000: // R-Type
			 begin aluop=2'b10;{memtoreg,memread,memwrite,alusrc,regwrite,writesel,pc2,branch}=8'b00001100;regdst=2'b10; end
			6'b000001: //addi
			 begin aluop=2'b01;{memtoreg,memread,memwrite,alusrc,regwrite,writesel,pc2,branch}=8'b00011100;regdst=2'b00; end
			6'b000010: //slti
			 begin aluop=2'b11;{memtoreg,memread,memwrite,alusrc,regwrite,writesel,pc2,branch}=8'b00011100;regdst=2'b00; end
			6'b000011: //lw
			 begin aluop=2'b01;{memtoreg,memread,memwrite,alusrc,regwrite,writesel,pc2,branch}=8'b11011100;regdst=2'b00; end
			6'b000100: //sw
			 begin aluop=2'b01;{memread,memwrite,alusrc,pc2,branch}=5'b01100; end
			6'b000101: //beq
			 begin aluop=2'b00;{alusrc,pc2,branch}=3'b001; end
			6'b000110: //j
			 begin {pc1,pc2,branch}=3'b010; end
			6'b000111: //jr
			 begin {pc1,pc2,branch}=3'b110; end
			6'b001000: //jal
			 begin regdst=2'b01; {regwrite,writesel,pc1,pc2,branch}=5'b10010; end
			default: {aluop,memtoreg,memread,memwrite,alusrc,regwrite,regdst,writesel,pc1,pc2,branch}=13'd0;
		endcase
	end
endmodule

module AC(aluop,func,aluoperation);
	input [5:0] func;
	input [1:0] aluop;
	output reg [2:0] aluoperation;
	always @(aluop,func) begin
		aluoperation=3'd0;
		if(aluop==2'b00) //beq
			aluoperation=3'b011;
		if(aluop==2'b01) //memref,addi
			aluoperation=3'b010;
		if(aluop==2'b11) //slti
			aluoperation=3'b111;
		if(aluop==2'b10) begin  //rtype
			if(func==6'd1)
				aluoperation=3'b010;
			if(func==6'd2)
				aluoperation=3'b011;
			if(func==6'd4)
				aluoperation=3'b000;
			if(func==6'd8)
				aluoperation=3'b001;
			if(func==6'd16)
				aluoperation=3'b111;
		end
	end
endmodule


//Units related to Hazard

module FU(exmem_regwrite,exmem_rd,idex_rs,idex_rt,memwb_regwrite,memwb_rd,fu1,fu2);
	input exmem_regwrite,memwb_regwrite;
	input [4:0]exmem_rd,idex_rs,idex_rt,memwb_rd;
	output reg [1:0]fu1,fu2;
	always @(*) begin
		{fu1,fu2} = 4'b0000;
		if(memwb_regwrite && memwb_rd!=5'd0 && memwb_rd==idex_rs)
			fu1=2'd1;
		if(memwb_regwrite && memwb_rd!=5'd0 && memwb_rd==idex_rt)
			fu2=2'd1;
		if(exmem_regwrite && exmem_rd!=5'd0 && exmem_rd==idex_rs)
			fu1=2'd2;
		if(exmem_regwrite && exmem_rd!=5'd0 && exmem_rd==idex_rt)
			fu2=2'd2;
	end
endmodule

module HU(idex_memread,idex_rt,ifid_rs,ifid_rt,pc_write,ifid_write,cs);
	input idex_memread;
	input [4:0]idex_rt,ifid_rs,ifid_rt;
	output reg pc_write,ifid_write;
	output reg cs;
	always @(*) begin
		{pc_write,ifid_write,cs}=3'b111;
		if(idex_memread && (idex_rt==ifid_rs || idex_rt==ifid_rt ))
			{pc_write,ifid_write,cs}=3'b000;	
	end
endmodule 

