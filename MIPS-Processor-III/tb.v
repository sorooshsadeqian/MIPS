`timescale 1ns/1ns

module tb();
	reg clk=0;
	reg rst=0;
	PU UUT(clk,rst);
	always begin
		#5 clk=~clk;
	end
	initial begin
		#1 rst=1;
		#5 rst=0;
		#80000
		$stop;
	end	
endmodule
