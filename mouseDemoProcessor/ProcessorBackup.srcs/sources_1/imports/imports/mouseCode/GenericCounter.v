`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.02.2016 20:50:30
// Design Name: 
// Module Name: GenericCounter
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
module GenericCounter(
		CLK,				//Clock input signal
		RESET,			//resets COUNT values input signal
		ENABLE_IN,		//enables counting inout signal
		TRIGG_OUT,		//triggers output signal for one clock cycle
		COUNT				//Counter value
    );
	 
	parameter COUNTER_WIDTH = 4;	//parameters to be used within this code. Width is specified as
											//a number of bits that represents the max value to be counted
	parameter COUNTER_MAX = 9;		//Max value to be counted
											//Default values were chosen to be like that because these were the most common values used in 
											//counter modules
											//these values are changed in TopModule level to get other values

	input CLK;										//input clock signal
	input RESET;									//enables reseting with a button
	input ENABLE_IN;								//enables counting/used as a downClock input
	output reg TRIGG_OUT;						//output trigger which will be used as a clk/triggerIn in another counter module
	output reg [COUNTER_WIDTH-1:0] COUNT;	//Counted value


	initial begin
		COUNT <= 0;					// Initialise COUNT to be 0 at the begining for simulation
	end
	
	//Synchronous counter & asynchronous RESET
	always@ (posedge CLK or posedge RESET) begin
		if (RESET) 								//if RESET is HIGH, reset the value of counter
			COUNT <= 0;
		else begin
			if (ENABLE_IN) begin				//if enabled to count -> do so
				if (COUNT == COUNTER_MAX)	//if max value was reached -> reset counter
					COUNT <= 0;
				else 
					COUNT <= COUNT + 1;		//else add one 
			end
		end
	end
	
	//Synchronous TriggerOut & asynchronous RESET
	always @(posedge CLK or posedge RESET) begin
		if (RESET)					//if RESET is HIGH, then rmake trigger to be 0
			TRIGG_OUT <= 0;
		else begin
			if (ENABLE_IN && (COUNT == COUNTER_MAX))
				TRIGG_OUT <= 1;	//if enables counting & max value was reached
			else						//then trigger out a pulse for one clock cycle
				TRIGG_OUT <= 0;	//else don trigger pulse
		end
	end
	
endmodule
