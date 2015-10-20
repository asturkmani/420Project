// Define the test bench module
module RegisterFile_TB;

//Declare inputs to the DUT as Reg and outputs as wires

  wire    [31:0]  Read_Data_1,Read_Data_2;
  reg     [31:0]  Write_Data;
  reg     [4:0]   Read_Adr_1,Read_Adr_2,Write_Adr;
  reg             Clock,Reset,WEn;
  
//Instantiate it by calling it's module name, here RegisterFile and give it a variable name, here DUT.
RegisterFile DUT(Read_Data_1,Read_Data_2,Clock,Reset,WEn,Read_Adr_1,Read_Adr_2,Write_Adr,Write_Data);

//drive all inputs to the DUT to a known initial state. Zero out registers, etc
initial begin
Clock = 0; Reset = 1; WEn = 0; Write_Data=0; Read_Adr_1 = 0; Read_Adr_2 = 0; Write_Adr = 0;
end

//Simulate a Clock at every 5 ticks of the processor.
always
 #5 Clock = !Clock;

//Begin Testing:

//clear
initial begin

#3 Reset = 0;
end

//Test regular witing
initial begin 
#9 WEn = 1; Write_Adr=1; Write_Data=32;
end
//Test writing with WEn disabled.
initial begin
#19 WEn = 0; Write_Adr=2; Write_Data=64;
end

//Test regular reading
initial begin
#29 Read_Adr_1 = 1; Read_Adr_2 = 2;
end

//Test simulatenous Read and Write
initial begin
#39 WEn = 1; Write_Data=128; Write_Adr=3; Read_Adr_1=3;
end

//Test reading from register after simulatenous Read/Write
initial begin
#49 WEn = 0; Read_Adr_2 = 3; Read_Adr_1=1;
end

initial begin
#59 Reset = 1; WEn=0;
end
//Store Waveform
initial  begin
     $dumpfile ("RegisterFile.vcd"); 
     $dumpvars; 
end 


initial begin
$display("\ttime, \tRead_Data_1 ,\tRead_Data_2,\tClock,\tReset,\tWEn,\tRead_Adr_1,\tRead_Adr_2,\tWrite_Adr,\tWrite_Data");
$monitor($time, "Read_Data_1 =%b ,Read_Data_2 =%b,Clock =%b ,Reset =%b ,WEn =%b ,Read_Adr_1 =%b,Read_Adr_2 =%b,Write_Adr =%b,Write_Data =%b", Read_Data_1,Read_Data_2,Clock,Reset,WEn,Read_Adr_1,Read_Adr_2,Write_Adr,Write_Data);
end
//Set an end to the simulation.
initial
 #65 $stop;

endmodule

