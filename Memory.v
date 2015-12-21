module Memory_Unit (D2, D1, A2, A1, clk);
// specify parameters
	parameter word_size = 9;
	parameter memory_size = 512;
	
// define ports
	output [word_size: 0] D2;
	output [word_size: 0] D1;
	input [word_size-1: 0] A2;
	input [word_size-1: 0] A1;
	input clk;
// declare temp to cater to conditions
	reg [word_size-1: 0] Memory [memory_size-1: 0];
// Assign output ports
	assign D1 = Memory[A1];
	assign D2 = Memory[A2];

endmodule
