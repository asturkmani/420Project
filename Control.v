

module Control( clear_Pipes,p1_En,p2_En,p3_En,s1_Muxes,s2_Muxes,out_En,first,done, A_new ,B_new ,A_old,start,clk);
parameter state_size=3;

//Inputs/Outputs
input clk,start;
input  [8:0]   A_new, A_old, B_new;

output [1:0]   p1_En;
output [5:0]   p2_En;
output [1:0]   p3_En;
output [3:0]   s1_Muxes;
output [3:0]   s2_Muxes;
output	clear_Pipes, first, out_En;
output	done;

//state code
parameter S_start = 0, S_init=1, Done=5;
parameter S_1=2, S_2=3, S_3=4;


// Datapath and State Register Variables
reg [state_size-1: 0] state, next_state;
reg clear_Pipes_R;
reg [1:0]   p1_En_R;
reg [5:0]   p2_En_R;
reg [1:0]   p3_En_R;
reg [3:0]   s1_Muxes_R;
reg [3:0]   s2_Muxes_R;
reg	p4_En_R, first_R, out_En_R;
reg	done_R;

wire [8:0]   B_new11;


//Counters
integer count_to_full_pipeline;	//initialisation counter

reg[3:0] multiplier_counter;
reg[3:0] mux_counter;

reg[3:0] count_to_empty_pipeline;

always @ (posedge clk or posedge start) begin: State_transitions
	//increment pipeline counter
	count_to_full_pipeline = count_to_full_pipeline+1;
	if (start == 1)
		state <= S_start;
	else
		state <= next_state; 
end

always @ (state) begin: State_Description
case (state) 

S_start: begin
	// initialize the pipeline: clear all registers, disable register loading until pipeline is full (or appropirate stage in pipeline)
	p1_En_R=3'b00;
	p2_En_R=6'b000000;
	p3_En_R=2'b00;
	out_En_R=1'b0;

	s1_Muxes_R=4'b0000;
	s2_Muxes_R=4'b0000;
	first_R=0;
	done_R=0;
	clear_Pipes_R=1;
	next_state = S_init;

 	count_to_full_pipeline=0;	//initialisation counter

	multiplier_counter=0;
	mux_counter=0;

	count_to_empty_pipeline=0;
	end

S_init: begin
	//pipe stage 1 -- initialization
	p1_En_R=2'b01;
	p2_En_R=6'b000000;
	p3_En_R=2'b00;
	out_En_R=1'b0;

	s1_Muxes_R=4'b0001;
	s2_Muxes_R=4'b0000;
	first_R=0;
	done_R=0;
	clear_Pipes_R=0;
	next_state = S_1;
	end

S_1: begin
	//pipestage 1 -- state 1
	//if(B_new != A_old-1)  --- MOVE TO S3
		//begin
	p1_En_R=2'b00;
	//p2_En_R=6'b000000;
	p3_En_R=2'b11;
	out_En_R=1'b1;

	if (multiplier_counter == 2)
		multiplier_counter = 0;
	else
		multiplier_counter = multiplier_counter+1;

	if (multiplier_counter == 0) begin
		p2_En_R = 6'b110000;
		s2_Muxes_R = 4'b0000; end
	else if (multiplier_counter == 1) begin
		p2_En_R = 6'b001100;
		s2_Muxes_R = 4'b1100; end
	else begin
		p2_En_R = 6'b000011;
		s2_Muxes_R = 4'b0011; end


	s1_Muxes_R=4'b0111;
	//s2_Muxes_R=4'b0000;// don't cares actually

	if (count_to_full_pipeline == 9) // !!!!!!
		first_R=1;
	else
		count_to_full_pipeline <= count_to_full_pipeline+1;
	done_R=0;
	clear_Pipes_R=0;

	if (B_new - 1 == A_new) begin
		count_to_empty_pipeline <= count_to_empty_pipeline + 1;
		if (count_to_empty_pipeline == 5) begin
			p3_En_R = 2'b00;
			next_state=S_2; end
		else if (count_to_empty_pipeline == 6) begin
			out_En_R = 1'b0;
			next_state=Done; end
	end
		//end
	else 
		next_state = S_2;
end
S_2: begin

	if (multiplier_counter == 2)
		multiplier_counter = 0;
	else
		multiplier_counter = multiplier_counter+1;

	if (multiplier_counter == 0) begin
		p2_En_R = 6'b110000;
		s2_Muxes_R = 4'b0000; end
	else if (multiplier_counter == 1) begin
		p2_En_R = 6'b001100;
		s2_Muxes_R = 4'b1100; end
	else begin
		p2_En_R = 6'b000011;
		s2_Muxes_R = 4'b0011; end

	p1_En_R=2'b00;
	//p2_En_R=6'b000000;
	p3_En_R=2'b11;
	out_En_R=1'b1;

	s1_Muxes_R=4'b1011;
	done_R=0;
	clear_Pipes_R=0;

	next_state = S_3;
end
S_3: begin

	p1_En_R=2'b11;
	p2_En_R=6'b000000;
	s2_Muxes_R=4'b0000;
	p3_En_R=2'b11;
	out_En_R=1'b1;

	s1_Muxes_R=4'b1100;
	//B_new11 = B_new - 1;
	if ( A_old == B_new -1) begin
		count_to_empty_pipeline <= count_to_empty_pipeline + 1;
		if (count_to_empty_pipeline == 5) begin
			p3_En_R = 2'b00;
			next_state=S_1; end
		else if (count_to_empty_pipeline == 6) begin
			out_En_R = 1'b0;
			next_state=Done; end
	end
		//next_state=Done;
	else
		next_state=S_1;

end
Done: begin
	p1_En_R=3'b00;
	p2_En_R=6'b000000;
	p3_En_R=2'b00;
	out_En_R=1'b0;
end
endcase 
end

//assign statements
assign clear_Pipes = clear_Pipes_R;
assign p1_En = p1_En_R;
assign p2_En = p2_En_R;
assign p3_En = p3_En_R;
assign p4_En = p4_En_R;
assign out_En = out_En_R;

assign s1_Muxes = s1_Muxes_R;
assign s2_Muxes = s2_Muxes_R;

assign first = first_R;
assign done = done_R;




endmodule 