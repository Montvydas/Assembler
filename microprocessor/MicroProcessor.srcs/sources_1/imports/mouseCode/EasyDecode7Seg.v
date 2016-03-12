`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.02.2016 20:48:32
// Design Name: 
// Module Name: EasyDecode7Seg
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
module EasyDecode7Seg(
	input [1:0] SEG_SELECT_IN,		//2 slider switches for choosing one display
    input [3:0] BIN_IN,					//4 slider switches for writing binary value
    input DOT_IN,							//decimal dot
    output reg [3:0] SEG_SELECT_OUT,//4 displays to be used
    output reg [7:0] HEX_OUT			//Hexadecimal value to be displayed + decimal point
    );

	always@ (SEG_SELECT_IN) begin //if slider SEG_SELECT_IN position changes
		case (SEG_SELECT_IN) 		//evaluate SEG_SELECT_IN value
		
	//when both switchs are LOW choose first display to be ON
	// as binary 0 turns transistor ON, thus turns display ON
			2'b00	 :	SEG_SELECT_OUT <= 4'b1110;//only one display at a time
			2'b01	 :	SEG_SELECT_OUT <= 4'b1101;//consequently for others
			2'b10	 :	SEG_SELECT_OUT <= 4'b1011;
			2'b11	 :	SEG_SELECT_OUT <= 4'b0111;
			default:	SEG_SELECT_OUT <= 4'b1111;//by default all displays should be off if unvalid signal appears
		endcase
	end
	
	always@ (BIN_IN or DOT_IN) begin //if sliders BIN_IN or DOT_IN position changes
		case (BIN_IN) 						//evaluate BIN_IN value
		
	//if all switches are LOW, write number 0 on 7-seg display.
	//binary 0 turns LED ON. 7 LEDs on 7-seg display.
	//LSB represents CA LED, MSB represents CG LED - view datasheet of BASYS2 page 5
			4'h0	 :	HEX_OUT[6:0] <= 7'b1000000;	
			4'h1	 :	HEX_OUT[6:0] <= 7'b1111001;//consequently for others
			4'h2	 :	HEX_OUT[6:0] <= 7'b0100100;
			4'h3	 :	HEX_OUT[6:0] <= 7'b0110000;
			
			4'h4	 :	HEX_OUT[6:0] <= 7'b0011001;
			4'h5	 :	HEX_OUT[6:0] <= 7'b0010010;
			4'h6	 :	HEX_OUT[6:0] <= 7'b0000010;
			4'h7	 :	HEX_OUT[6:0] <= 7'b1111000;
			
			4'h8	 :	HEX_OUT[6:0] <= 7'b0000000;
			4'h9	 :	HEX_OUT[6:0] <= 7'b0011000;
			4'hA	 :	HEX_OUT[6:0] <= 7'b0001000;
			4'hB	 :	HEX_OUT[6:0] <= 7'b0000011;
			
			4'hC	 :	HEX_OUT[6:0] <= 7'b1000110;
			4'hD	 :	HEX_OUT[6:0] <= 7'b0100001;
			4'hE	 :	HEX_OUT[6:0] <= 7'b0000110;
			4'hF	 :	HEX_OUT[6:0] <= 7'b0001110;
			
			default: HEX_OUT[6:0] <= 7'b1111111;//by default no value should be present at a display in case of unvalid signal
		endcase
		
		HEX_OUT[7] <= ~DOT_IN; 	//decimal dot is turned on if slider is in HIGH position
	end								//as bin 0 turns LED ON
	
endmodule
