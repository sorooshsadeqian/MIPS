`timescale 1ns/1ns

module tb();
	reg clk=0;
	reg rst=0;
	Processor PUT(clk,rst);
	always begin
		#5 clk=~clk;
	end
	initial begin
		#1 rst=1;
		#5 rst=0;
		#50000
		$stop;
	end
endmodule
