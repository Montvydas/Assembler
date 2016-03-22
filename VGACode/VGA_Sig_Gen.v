`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.02.2016 15:25:19
// Design Name: 
// Module Name: VGA_Sig_Gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module VGA_Sig_Gen(
            input CLK,
			//input [7:0] ColorIn,							//to receive the Color to output
			input Reset, 									//if reset,all counter turn to 0
			input [15:0] Config_Colors,
			input DATA,
			output reg [7:0] ColorOut,					//to output the Color
			output  [14:0] VGA_ADDR,
			output reg HS,									//syn HS, turn low when a row is over
			output reg VS,									//syn VS, turn low when a frame is over
			output TrigToShift,
			output DPR_CLK

    );
	 
//now to define the parameter
        parameter ToDefineHs = 10'd96;						//larger this, HS becomes to 1
        parameter RangeHBegin = 10'd144;						//begin range for row
        parameter RangeHEnd =10'd784;						//end range for row,784-144=640
        parameter CounterHMax= 10'd800;						//end for a row

        parameter ToDefineVs = 10'd2;							//larger than this,VS becomes to 1
        parameter RangeVBegin = 10'd31;						//begin range for column
        parameter RangeVEnd =10'd511;							//end range for column
        parameter CounterVMax= 10'd521;						//end for column

        wire [9:0] Count1;										//to count the row from 1 to 799
        wire [9:0] Count2;										//to count the column from 1 to 520
        wire triggout;
        reg [9:0] AddressHer;				//return the address to the top module to 
        reg [8:0] AddressVer;                //return the vertical address
//now to begin the code

   //the first is to define the basic counter for v direction and h direction
	     CounterModule #( .Counter_Width(10),
		                   .Counter_Max(CounterHMax-1)
								 )
					BisicHCounter							//this counter is triggered by 25MHZ to count the row
					(  .CLK(CLK),
					   .Reset(Reset),						//the aim of reset is to give the initial number
						.Enable_In(1'b1),					//enable is one to let it work forever
						.Count(Count1),
						.Trig_Out(triggout)
						);
		 
		 
	     CounterModule #( .Counter_Width(10),
		                   .Counter_Max(CounterVMax-1)
								 )
					BisicVCounter							//this counter is triggered by last counter to count the column
					(  .CLK(CLK),
					   .Reset(Reset),
						.Enable_In(triggout),			//use the last triggerout as clock
						.Count(Count2),					//count2 gains slower than count1
						.Trig_Out(TrigToShift)
						);
    //according to the slide,to define the output regarding the value of counter
	      
			//First to define the HS and VS		
					always@(posedge CLK or posedge Reset)  			//when clk changes
					  begin
					    if(Reset)
						    HS<=0;           								//syn the HS
						 else
					       if(Count1>=ToDefineHs)
						       HS<=1;
						    else
						       HS<=0;        								 //if count1 is larger than 96,Hs turn to 1
					    end
					 
					always@(posedge triggout or posedge Reset)
					  begin
					    if(Reset)
					      VS<=0;
						 else
					       if(Count2>=ToDefineVs)  						//two varaible is independent between HS and VS
						       VS<=1;
						    else
						       VS<=0;
					  end					   
			//Next to define the Color should be output
			
			    
			      always@(posedge CLK)
					  begin
					    if((Count1>RangeHBegin)&&(Count1<RangeHEnd)&&(Count2>RangeVBegin)&&(Count2<RangeVEnd)&&(DATA==1))
						   ColorOut<=Config_Colors[7:0];								//if the count is in the range,so the color is defined by the input,
						 else 
						      if((Count1>RangeHBegin)&&(Count1<RangeHEnd)&&(Count2>RangeVBegin)&&(Count2<RangeVEnd)&&(DATA==0))
						        ColorOut<=Config_Colors[15:8];
						      else
						        ColorOut<=8'b00000000; 							//else, make the color black
					  end
			//The Final to do is to decode the address from the two counters
					always@(posedge CLK)
					 begin
					    if((Count1>RangeHBegin)&&(Count1<RangeHEnd)&&(Count2>RangeVBegin)&&(Count2<RangeVEnd))
			             begin
							   AddressHer<=Count1-144;
								AddressVer<=Count2-31;						//if the range is display, return the address to top module to define the color
							 end
						 else
						    begin 
							   AddressHer<=0;
			               AddressVer<=0;									//else, the address is turned to 0 
							 end
					 end
					 
					 assign DPR_CLK=CLK;
					 assign VGA_ADDR={AddressVer[8:2],AddressHer[9:2]};
					 
//now the code is over

endmodule
