`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.02.2016 20:49:37
// Design Name: 
// Module Name: Multiplexer
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
module Multiplexer(
    input [1:0] CONTROL,			//Controls which input to connect to output connection
    input [4:0] IN0,					//first input
    input [4:0] IN1,					//second input
    input [4:0] IN2,					//third input
    input [4:0] IN3,					//fourth input
	 output reg[4:0] DISPLAY_OUT	//output to be displayed	// 
    );

	always @(CONTROL or IN0 or IN1 or IN2 or IN3)begin //if any of input values change
		case (CONTROL)	//check the control value
			2'b00		:	DISPLAY_OUT <= IN0;	//if it is binary 00, then output goes from first input
			2'b01		:	DISPLAY_OUT <= IN1;	//similarly with the other inputs & control signals
			2'b10		:	DISPLAY_OUT <= IN2;
			2'b11		:	DISPLAY_OUT <= IN3;
			default	:	DISPLAY_OUT <= 5'b00000;	//by default, value of 0 is displayed if CONTROL signal is invalid
		endcase
	end

endmodule
