`timescale 1ns/1ns

module tb();
	reg clk=0;
	reg rst=0;
	MIPS PUT(clk,rst);
	always begin
		#100 clk=~clk;
	end
	initial begin
		#10 rst=1;
		#100 rst=0;
		#100000
		$stop;
	end
endmodule