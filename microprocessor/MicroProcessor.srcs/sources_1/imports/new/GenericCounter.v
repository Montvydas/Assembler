`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		University of Edinburgh
// Engineer: 		Theo Scott
// 
// Create Date:    10:34:35 10/22/2014 
// Design Name:    IR Transmitter
// Module Name:    GenericCounter 
// Project Name:   Digital Systems Lab
// Target Devices: Digilent Basys3
// Tool versions:  Vivado 2015.2
// Description:    Counts up once per rising clock edge, storing current value in a register
//                 and resetting when reaching a specified parameter COUNTER_MAX
//
// Dependencies:   none
//
// Revision: 
// Revision 1.0 - Completed and tested
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module GenericCounter(
    CLK,
    RESET,
    ENABLE_IN,
    TRIG_OUT,
    COUNT
    );
	 
	parameter COUNTER_WIDTH = 4;
	parameter COUNTER_MAX = 9;
	
	input CLK;
	input RESET;
	input ENABLE_IN;
	output TRIG_OUT;
	output [COUNTER_WIDTH-1:0] COUNT;
	
	//Registers to store Counter and TriggerOut
	reg [COUNTER_WIDTH-1:0] Counter = 0;
	reg TriggerOut;
	
	//Synchronous Counter Logic
	always@(posedge CLK) begin
		if(RESET)
			Counter <= 0;
		else begin
			if(ENABLE_IN) begin
				if(Counter == COUNTER_MAX)
					Counter <= 0;
				else
					Counter <= Counter + 1;
			end
		end
	end
	
	//Trigger Out Logic
	always@(posedge CLK) begin
		if(RESET)
			TriggerOut <= 0;
		else begin
			if(ENABLE_IN && (Counter == COUNTER_MAX))
				TriggerOut <= 1;
			else
				TriggerOut <= 0;
			end
		end
		
	//assignments
	assign COUNT = Counter;
	assign TRIG_OUT = TriggerOut;
				

endmodule