module PU(clk,rst);
	input clk,rst;
	wire [31:0]pcin,pcout,pcadd,prepc0,ir,instr,idexpcadd,ifidpcadd,r1,r2,offset,wd,adress1,ofs,adr1,idexr1,idexr2,a,b0,b,
		  ar,offout,adress2,adr2,aout,arout,b0out,rdata,rdout,b001,out,prepc1;
	wire [25:0]ins1;
	wire [4:0]rt,rd,rs,wr1,wr2,wr;
	wire z,zout;

	wire [5:0]func,opc; // to cu

	wire pcsrc;
	wire spc2;
	wire [2:0]wb; wire [4:0]m;wire [5:0]ex;
	wire [2:0]ifid_wb; wire [4:0]ifid_m; wire [5:0]ifid_ex;
	wire [2:0]idex_wb; wire [4:0]idex_m;
	wire [2:0]exmem_wb;
	wire memtoreg,writesel,regwrite; //WB
	wire pc1,pc2,memwrite,memread,branch; //M
	wire alusrc;
	wire [1:0]regdst;
	wire [2:0]aluoperation; //EX	
	wire cmemtoreg,cwritesel,cregwrite;
	wire cpc1,cpc2,cmemwrite,cmemread,cbranch;
	wire calusrc;
	wire [1:0] cregdst;
	wire [2:0] caluoperation;
	
	wire [1:0]fu1,fu2;

	assign ifid_wb={memtoreg,writesel,regwrite};
	assign ifid_m={pc1,pc2,memwrite,memread,branch};
	assign ifid_ex={alusrc,regdst,aluoperation};
	assign {cmemtoreg,cwritesel,cregwrite}=wb;
	assign {cpc1,cpc2,cmemwrite,cmemread,cbranch}=m;
	assign {calusrc,cregdst,caluoperation}=ex;
	
	assign opc=instr[31:26];
	assign func=instr[5:0];
	assign adress1={idexpcadd[31:28],ins1,2'b00};
	assign a=idexr1;				//hazard *
	assign b0=idexr2;				//hazard *
	MUX2			muxpc2(prepc0,prepc1,spc2,pcin);
	MUX2			muxsrc(pcadd,adr2,pcsrc,prepc0);
	MUX2			muxwd(ifidpcadd,out,cwritesel,wd);
	MUX2			muxalu(b0,offout,calusrc,b);
	MUX2			muxpc1(adress2,aout,cpc1,prepc1);
	MUX2			muxreg(b001,rdout,cmemtoreg,out);
	MUX3			muxwr(rt,5'd31,rd,cregdst,wr1);
	SE			se(instr[15:0],offset);
	SHL2			shl2(offout,ofs);
	ADDER			adderpc(pcout,32'd4,pcadd);
	ADDER			adderbq(ofs,idexpcadd,adr1);
	PC			pc(clk,rst,pcin,pcout);
	PCSRC			pcs(rst,zout,cbranch,pcsrc);
	SPC2			spc(rst,cpc2,spc2);
	ALU			aluu(a,b,caluoperation,ar,z);
	REGFILE			regfile(clk,rst,instr[25:21],instr[20:16],wr,wd,cregwrite,r1,r2);
	DATAMEM			dmem(clk,arout,b0out,cmemread,cmemwrite,rdata);
	INSTMEM			imem(pcout,ir);
	CTRL			control(opc,func,memtoreg,writesel,regwrite,pc1,pc2,memwrite,memread,branch,alusrc,regdst,aluoperation);

	FU			forwarding_unit(exmem_wb[0],wr2,rs,rt,cregwrite,wr,fu1,fu2);

	IFID			ifid(clk,pcadd,ir,ifidpcadd,instr);
	IDEX			idex(clk,ifid_wb,ifid_m,ifid_ex,ifidpcadd,instr[25:0],r1,r2,offset,instr[20:16],instr[15:11],instr[25:21],
					 idex_wb,idex_m,ex,idexpcadd,ins1,idexr1,idexr2,offout,rt,rd,rs);
	EXMEM			exmem(clk,idex_wb,idex_m,adress1,adr1,a,z,ar,b0,wr1,
					  exmem_wb,m,adress2,adr2,aout,zout,arout,b0out,wr2);
	MEMWB			memwb(clk,exmem_wb,rdata,arout,wr2,
					  wb,rdout,b001,wr);

endmodule