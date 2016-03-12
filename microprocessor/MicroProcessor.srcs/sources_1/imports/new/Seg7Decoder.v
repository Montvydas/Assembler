`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		 University of Edinburgh
// Engineer: 		 Theo Scott
// 
// Create Date:    11:25:21 10/08/2014 
// Design Name:    IR Transmitter
// Module Name:    Seg7Decoder 
// Project Name:   Digital Systems Lab
// Target Devices: Digilent Basys3
// Tool versions:  Vivado 2015.2
// Description:    Decodes 4-bit binary number input to an 8-bit output suitable
//                 for display on a 7 segment display. 8-bit outputs represent
//                 letters in "blueygrnd- "
// Dependencies:   none
//
// Revision: 
// Revision 1.0 - Completed and tested
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Seg7Decoder(
    input [1:0] 	SEG_SELECT_IN,
    input [3:0] 	BIN_IN,
    input 			DOT_IN,
    output reg [3:0] 	SEG_SELECT_OUT,
    output reg [7:0] 	HEX_OUT
    );
	
	//Segment Selection
	always@(SEG_SELECT_IN) begin
		case(SEG_SELECT_IN)
			2'b00		:	SEG_SELECT_OUT <= 4'b1110;
			2'b01		:	SEG_SELECT_OUT <= 4'b1101;
			2'b10		:	SEG_SELECT_OUT <= 4'b1011;
			2'b11		:	SEG_SELECT_OUT <= 4'b0111;
			default	    :	SEG_SELECT_OUT <= 4'b1111;
		endcase
	end
	
	//7-segment cathodes CA..CG
	//Letters required: blueygrnd-
	always@(BIN_IN or DOT_IN) begin
		case(BIN_IN)
			4'h0		:	HEX_OUT[6:0] <= 7'b0000011; // b
			4'h1		:	HEX_OUT[6:0] <= 7'b1000111; // l
			4'h2		:	HEX_OUT[6:0] <= 7'b1100011; // u
			4'h3		:	HEX_OUT[6:0] <= 7'b0000100; // e
			4'h4		:	HEX_OUT[6:0] <= 7'b0010001; // y
			4'h5		:	HEX_OUT[6:0] <= 7'b0010000; // g
			4'h6		:	HEX_OUT[6:0] <= 7'b1001110; // r
			4'h7		:	HEX_OUT[6:0] <= 7'b1001000; // n
			4'h8		:	HEX_OUT[6:0] <= 7'b0100001; // d
			4'h9		:	HEX_OUT[6:0] <= 7'b0111111; // -
			4'hA		:	HEX_OUT[6:0] <= 7'b0111111; // -
			4'hB		:	HEX_OUT[6:0] <= 7'b0111111; // -
			4'hC		:	HEX_OUT[6:0] <= 7'b0111111; // -
			4'hD		:	HEX_OUT[6:0] <= 7'b0111111; // -
			4'hE		:	HEX_OUT[6:0] <= 7'b0111111; // -
			4'hF		:	HEX_OUT[6:0] <= 7'b1111111; // OFF
			default	    :	HEX_OUT[6:0] <= 7'b1111111; // OFF
		endcase
		//Sets the state of the DOT
		HEX_OUT[7] <= ~DOT_IN;
	end

endmodule