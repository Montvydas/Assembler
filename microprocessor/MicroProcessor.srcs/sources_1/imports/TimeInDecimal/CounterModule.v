`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:          University of Edinburgh
// Engineer:         Yufei Sun
//  
// Create Date:      11:05:34 10/17/2014 
// Design Name:      Snake
// Module Name:      CounterModule 
// Project Name:     Snake
// Target Devices:   Basys2
// Tool versions:    Release Version 14.4
//                   Application Version P.49d

// Description:      This moudule is the basic module to count from 0 to the max, and triger a signal
//
// Dependencies:     no other dependencies
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module CounterModule(
							CLK,                                             //The clock to triger the count,
							Reset,                                           //If reset, the value of the counter turn to 0
							Enable_In,                                       //only enable, can the counter be woreked
							Trig_Out,                                        //if the value is max, give a high volt
							Count,                                           //The value of the counter now
							ReStart                                          //The restart has the same function with reset
							);
	 
	 parameter Counter_Width=4;
	 parameter Counter_Max=10;
	
	 input CLK;                                                        
	 input Reset;
	 input Enable_In;
	 output Trig_Out;
	 output [Counter_Width-1:0] Count;
	 input ReStart;
	 reg [Counter_Width-1:0] Counter;
	 reg Trigger;
	 

//now to deifne the counter part
	always@(posedge CLK or posedge Reset or posedge ReStart) 
		begin
			if(Reset)                  
				Counter<=0;
			else
				if(ReStart)
					Counter<=0;                                            //If reset or restart, the value of the counter will be turn to 0
				else
					if(Enable_In)
						if(Counter==Counter_Max)                            //If count to maximum, let the value be 0
							Counter<=0;
						else
							Counter<=Counter+1;                              //else, the counter add one
					else;
	
		end

//now begin to define the carry logic part

		always@(posedge CLK or posedge Reset or posedge ReStart)
			begin
				if (Reset)
					Trigger<=0;
				else
					if(ReStart)
						Trigger<=0; 
					else
						if(Enable_In&&(Counter==Counter_Max))
							Trigger<=1;                                       //only at the maximum, let the triggerout be 1
						else
							Trigger<=0;

			end
  
		assign Count=Counter;
		assign Trig_Out=Trigger;		
		
		

endmodule
