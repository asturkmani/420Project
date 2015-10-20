
module RegisterFile(Read_Data_1,Read_Data_2,Clock,Reset,WEn,Read_Adr_1,Read_Adr_2,Write_Adr,Write_Data);
  
  //Defining our inputs and outputs
  output    [31:0]  Read_Data_1,Read_Data_2;
  input     [31:0]  Write_Data;
  input     [4:0]   Read_Adr_1,Read_Adr_2,Write_Adr;
  input             Clock,Reset,WEn;
  
  //Define our register file as a 2D array of registers.
  reg       [31:0] Register_File [31:0];
  integer k;
  
  // Asynchronous reset to clear the register file
  always @ (Reset)
  begin
  if (Reset==1)
    begin
      // iterate through register file and assign 0 to all registers
      for (k=0; k<=31; k=k+1) begin
      Register_File[k]=0;
      end
    end  
  end
  
  // Asynchronous reading from register
  
  // Enable asynchronous reading when writing to register you want to read from
  assign Read_Data_1 = (WEn == 0)? Register_File[Read_Adr_1]:
                      (Write_Adr == Read_Adr_1) ? Write_Data:
                                   Register_File[Read_Adr_1];
                                    
                                    
                                    
  assign Read_Data_2 = (WEn == 0)? Register_File[Read_Adr_2]:
                      (Write_Adr == Read_Adr_2) ? Write_Data:
                                   Register_File[Read_Adr_2];

  // Synchronous Writing
  always @ (posedge Clock) begin
    if(WEn) begin
	Register_File[Write_Adr] <= Write_Data;
	end
  end
endmodule
  
  