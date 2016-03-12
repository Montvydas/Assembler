`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		University of Edinburgh
// Engineer: 		Theo Scott
// 
// Create Date:    11:02:42 10/22/2014 
// Design Name:    IR Transmitter
// Module Name:    Mux4Way 
// Project Name:   Digital Systems Lab
// Target Devices: Digilent Basys3
// Tool versions:  Vivado 2015.2
// Description:    Simple 4-to-1 multiplexer to select one of 4 inputs based on a control
//                 input
//
// Dependencies:   none
//
// Revision: 
// Revision 1.0 - Completed and tested
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Mux4Way(
    input [1:0] CONTROL,
    input [3:0] IN0,
    input [3:0] IN1,
    input [3:0] IN2,
    input [3:0] IN3,
    output reg [4:0] OUT
    );

	//Selection logic: selects which data input to put on output depending on CONTROL input
	always@(CONTROL or IN0 or IN1 or IN2 or IN3) begin
		case(CONTROL)
			2'b00		: OUT <= IN0;
			2'b01		: OUT <= IN1;
			2'b10		: OUT <= IN2;
			2'b11		: OUT <= IN3;
			default	: OUT <= 5'b00000;
		endcase
	end

endmodule