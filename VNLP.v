module VNLP ( output [27:0] Sum, output [8:0] Len, output done, input start, input clk);



wire [8:0]   A_new, A_old, B_new;

wire [1:0]   p1_En;
wire [5:0]   p2_En;
wire [1:0]   p3_En;
wire [3:0]   s1_Muxes;
wire [3:0]   s2_Muxes;

wire clear_Pipes, first, out_En;



Datapath DP( 
        A_new, A_old, B_new,
        Sum,
        Len,
        clear_Pipes, first, out_En, clk,
        p3_En,
        p1_En,
        s1_Muxes,
        s2_Muxes,
        p2_En);

Control C( clear_Pipes, p1_En, p2_En, p3_En,s1_Muxes,s2_Muxes,out_En,first,done, A_new ,B_new ,A_old,start,clk);

endmodule 