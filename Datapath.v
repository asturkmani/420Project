// Datapath Block
// EECE 420 Project - Fall 2015/2016 - American University of Beirut
// Abdel Wahab Turkmani - 201200860

module Datapath(

        output  [8:0]   A_new, A_old, B_new,
        output  [27:0]  Sum,
        output  [8:0]   Len,
        input           clear_Pipes, fireset, out_En, clk,
        input   [1:0]   p3_En,
        input   [1:0]   p1_En,
        input   [3:0]   s1_Muxes,
        input   [3:0]   s2_Muxes,
        input   [5:0]   p2_En);
	//Wires
		//stage 1
		wire [8:0] A_new_WI, A_old_WI, B_new_WI;	//WI: wire input
		wire [8:0] A_new_WO, A_old_WO, B_new_WO;	//WO: wire output
		
	
		wire [8:0] zero = 0;				//Muxes inputs
		wire [8:0] one = 1;
		wire [8:0] two = 2;
		wire [8:0] three = 3;
		
		wire [8:0] mux_out4;				//Muxes outputs
		wire [8:0] mux_out3;
		wire [8:0] mux_out2;
		wire [8:0] mux_out1;
		wire [8:0] mux_out0;
		
		wire [8:0] C2;					//Adderss computation after adders
		wire [8:0] C1;
		wire [8:0] C0;

		wire  [8:0]   Lenx;				//needed for Len computation, in the slides it is 8 bits !

		//stage 2

		wire [9:0] D1, D2;				//those are the inputs of pipeline 2
		wire [9:0] W1, W2, W3, W4, W5, W6;		//those are the outputs of pipeline 2

		wire [19:0] Prod1, Prod2, Prod3, Prod4, Prod5, Prod6;	//prod is product


		wire [19:0] mux_out8;				//Muxes outputs for stage 2
		wire [19:0] mux_out7;				
		wire [19:0] mux_out6;
		wire [19:0] mux_out5;

		//stage 3

		wire [19:0] pipe_out1;
		wire [19:0] pipe_out2;
		wire [20:0] init_sum;

		wire [27:0] sum_out3;
		wire[27:0] final_sum;
		

		wire final_En;
		

	//Simple Logic for stage output
	assign final_En = (fireset && out_En);
		

	//Design
	//---------------------------------------------------------------------------------------------------
	pipeline1 P1 ( A_new_WO, B_new_WO, D2[8:0], D1[8:0], p1_En, clear_Pipes, clk);
							// !

	Multiplexer Mux4( mux_out4, two, three, s1_Muxes[3] );
	Multiplexer Mux3( mux_out3, one, two, s1_Muxes[2] );
	Multiplexer Mux2( mux_out2, zero, two, p1_En[0]);
	Multiplexer Mux1( mux_out1, A_new_WO, C2, s1_Muxes[1] );
	Multiplexer Mux0( mux_out0, B_new_WO, C1, s1_Muxes[0]);
	
	Adder1 A2( A_new_WO, mux_out4, C2);
	Adder1 A1( mux_out3, B_new_WO, C1);
	Adder1 A0( mux_out2, Lenx, C0);			
	
	RegisterA LEN_count (Lenx, C0,one[0], clear_Pipes, clk);			//This register is for Len computation
	

	Memory_Unit M1 ( D2, D1, mux_out1, mux_out0, clk);

	assign A_new = D2;
	assign B_new = D1;
	assign A_old = A_new_WO; // !
	assign Len = Lenx;
	
	//---------------------------------------------------------------------------------------------------
	pipeline2 P2 ( W6, W5, W4, W3, W2, W1, D2, D1, D2, D1, D2, D1, p2_En, clear_Pipes, clk);
	
	Multiplier Mul_6( W6, W6, Prod6);
	Multiplier Mul_5( W5, W5, Prod5);
	Multiplier Mul_4( W4, W4, Prod4);
	Multiplier Mul_3( W3, W3, Prod3);
	Multiplier Mul_2( W2, W2, Prod2);
	Multiplier Mul_1( W1, W1, Prod1);  
	
	
	Multiplexer#(20) Mux8( mux_out8, Prod1, Prod3, s2_Muxes[3] );
	Multiplexer#(20) Mux7( mux_out7, Prod2, Prod4, s2_Muxes[2] );
	Multiplexer#(20) Mux6( mux_out6, mux_out8, Prod5, s2_Muxes[1] );
	Multiplexer#(20) Mux5( mux_out5, mux_out7, Prod6, s2_Muxes[0] );	

	//---------------------------------------------------------------------------------------------------
	pipeline3 P3 ( pipe_out2, pipe_out1, mux_out6, mux_out5, p3_En, clear_Pipes, clk);
	Adder2 A3( pipe_out1, pipe_out2, init_sum);
	Adder3 A4(init_sum,final_sum,sum_out3);

	//---------------------------------------------------------------------------------------------------
	
	
	out P5(final_sum,sum_out3, out_En, clear_Pipes, clk);
	

	//---------------------------------------------------------------------------------------------------

	
	assign Sum = final_sum;
	


endmodule

//Pipelines
module pipeline1#(parameter word_size=9)(A, B, A_new, B_new, p_En, reset, clk);

        parameter length = 2;
	output  [word_size-1:0] A;
        output  [word_size-1:0] B;

        input   [word_size-1:0] A_new;
	input   [word_size-1:0] B_new;
        

        input   [length-1:0]            p_En;
        input   reset,clk;

        RegisterA#(word_size)   A_R(A, A_new, p_En[length-1], clk, reset);
        RegisterA#(word_size)   B_R(B, B_new, p_En[length-2], clk, reset);

endmodule

module pipeline2#(parameter word_size=10)(data_out6, data_out5, data_out4, data_out3, data_out2, data_out1, data_in6, data_in5, data_in4, data_in3, data_in2, data_in1, p_En, reset, clk);

        parameter length = 6;
       input   [word_size-1:0] data_in6;
        input   [word_size-1:0] data_in5;
        input   [word_size-1:0] data_in4;
        input   [word_size-1:0] data_in3;
        input   [word_size-1:0] data_in2;
        input   [word_size-1:0] data_in1;

        output  [word_size-1:0] data_out6;
        output  [word_size-1:0] data_out5;
        output  [word_size-1:0] data_out4;
        output  [word_size-1:0] data_out3;
        output  [word_size-1:0] data_out2;
	output  [word_size-1:0] data_out1;

        input   [length-1:0]            p_En;
        input   reset,clk;

        RegisterA#(word_size)   R1(data_out6, data_in6, p_En[length-1], clk, reset);
        RegisterA#(word_size)   R2(data_out5, data_in5, p_En[length-2], clk, reset);
        RegisterA#(word_size)   R3(data_out4, data_in4, p_En[length-3], clk, reset);
        RegisterA#(word_size)   R4(data_out3, data_in3, p_En[length-4], clk, reset);
        RegisterA#(word_size)   R5(data_out2, data_in2, p_En[length-5], clk, reset);
        RegisterA#(word_size)   R6(data_out1, data_in1, p_En[length-6], clk, reset);

endmodule

module pipeline3#(parameter word_size=20)(data_out2, data_out1, data_in2, data_in1, p_En, reset, clk);

        parameter length = 2;
        output  [word_size-1:0] data_out2;
        output  [word_size-1:0] data_out1;
        
        
		input   [word_size-1:0] data_in2;
        input   [word_size-1:0] data_in1;
        

        input   [length-1:0]            p_En;
        input   reset,clk;

        RegisterA#(word_size)   R2(data_out2, data_in2, p_En[length-1], clk, reset);
        RegisterA#(word_size)   R1(data_out1, data_in1, p_En[length-2], clk, reset);

endmodule


module out#(parameter word_size=28)(data_out, data_in, p_En, reset, clk);

        output  [word_size-1:0] data_out;
        input   [word_size-1:0] data_in;
        input                   p_En;
        input           reset,clk;

        RegisterA#(word_size) R1(data_out, data_in, p_En, clk, reset);

endmodule

// Register
module RegisterA#(parameter word_size = 9)(data_out1, data_in,load,clk,reset);

output [word_size-1:0]  data_out1;
input [word_size-1:0] data_in;
input load,clk,reset;

reg [word_size-1:0] data_out;

    always@(posedge clk or posedge reset)
       if(reset==1) data_out<=0;
        else if (load) data_out<=data_in;

assign data_out1 = data_out;
endmodule

// Multiplexer
module Multiplexer#(parameter word_size=9) (mux_out, data_a, data_b, sel);
input [word_size - 1 : 0] data_a, data_b;
input                     sel;
output [word_size - 1 : 0] mux_out;

assign mux_out = (sel == 0) ? data_a: (sel == 1) ? data_b :  'bx;
endmodule

// Adder
module Adder1#(parameter word_size=9) (A,B,C);
        input [word_size-1:0] A,B;
        output[word_size-1:0] C;

        assign C = A + B;
endmodule
//adder for stage 3
module Adder2#(parameter word_size=20) (A,B,C);
        input [word_size-1:0] B;
        input [word_size-1:0] A;
        output[word_size:0] C;

        assign C = A + B;
endmodule
// Adder for last stage
module Adder3#(parameter word_size=28) (A,B,C);
        input [word_size-1:0] B;
        input [20:0] A;
        output[word_size-1:0] C;

        assign C = A + B;
endmodule

module Multiplier#(parameter word_size=10) (A,B,C);
        input  signed [word_size-1:0]   A, B;
        output signed [2*word_size-1:0] C;	
        assign C = A*B;
endmodule
