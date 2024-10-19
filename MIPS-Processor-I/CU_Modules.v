`timescale 1ns/1ns

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
