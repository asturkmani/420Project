
// Define the test bench module
module VNLP_tb;

wire [27:0] Result;
	wire [8:0] Len;
	wire Done;
	reg Start;
	reg Reset;
	reg Clk;
  
//Instantiate it by calling it's module name, here RegisterFile and give it a variable name, here DUT.
VNLP V( Result,Len, Done, Start, Clk);

//Reset
reg [9:0] k;
	initial begin: Flush_Memory
		#2 for (k= 0; k < 512; k=k+1) V.DP.M1.Memory[k]= 0;
	end


initial begin: Initialize_Values
		Clk= 0;
		#7
		Start= 0;
		//Reset= 1;
		#1
		//Reset= 0;
		Start= 1;
		#7
		Start= 0;
	end

// Load M.Memory
initial begin
  #10

	V.DP.M1.Memory[0] = 49;
	V.DP.M1.Memory[1] = 34;
	V.DP.M1.Memory[2] = 33;
	V.DP.M1.Memory[3] = 23;
 
	V.DP.M1.Memory[5] = 17;
	V.DP.M1.Memory[6] = 40;
	V.DP.M1.Memory[7] = 19;
	V.DP.M1.Memory[8] = 102;
 
	V.DP.M1.Memory[11] = 22;
	V.DP.M1.Memory[12] = 18;
	V.DP.M1.Memory[13] = 25;
	V.DP.M1.Memory[14] = 93;
 
	V.DP.M1.Memory[17] = 11;
	V.DP.M1.Memory[18] = 6;
	V.DP.M1.Memory[19] = 8;
	V.DP.M1.Memory[20] = 90;
 
	V.DP.M1.Memory[22] = 33;
	V.DP.M1.Memory[23] = 12;
	V.DP.M1.Memory[24] = 31;
	V.DP.M1.Memory[25] = 32;
 
	V.DP.M1.Memory[28] = 102;
	V.DP.M1.Memory[29] = 240;
	V.DP.M1.Memory[30] = 47;
	V.DP.M1.Memory[31] = 11;
 
	V.DP.M1.Memory[33] = 0;
	V.DP.M1.Memory[34] = 23;
	V.DP.M1.Memory[35] = 25;
	V.DP.M1.Memory[36] = 88;
 
	V.DP.M1.Memory[39] = 5;
	V.DP.M1.Memory[40] = 50;
	V.DP.M1.Memory[41] = 56;
	V.DP.M1.Memory[42] = 48;
 
	V.DP.M1.Memory[44] = 56;
	V.DP.M1.Memory[45] = 88;
	V.DP.M1.Memory[46] = 112;
	V.DP.M1.Memory[47] = 69;
 
	V.DP.M1.Memory[49] = 39;
	V.DP.M1.Memory[50] = 1;
	V.DP.M1.Memory[51] = 101;
	V.DP.M1.Memory[52] = 63;
end

always begin
	#10 Clk= ~Clk;
end

initial begin

end

endmodule
