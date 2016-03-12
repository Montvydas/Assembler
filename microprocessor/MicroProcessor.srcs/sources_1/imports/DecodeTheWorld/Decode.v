`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        University of Edinburgh
// Engineer:       Yufei Sun
// 
// Create Date:    10:41:47 10/15/2014 
// Design Name:    Snake
// Module Name:    Decode 
// Project Name:   Snake
// Target Devices: Basys2
// Tool versions:  Release Version 14.4
//                 Application Version P.49d

// Description:    This module is to input the 4-bit binary number and output the decimal number to the 7-segment
//
// Dependencies:   No other dependencied
// 
// Revision:       0.01
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Decode(
					input [1:0] ChooseIn,                  //to choose the 7-segment to show the value
					input [3:0] Num_Binary,                //input the binary number,0-15
					input Dot,                             //whether to show the dot, 0 means to show it
					output reg [7:0] Out,                  //connected to the 7-segment part
					output reg [3:0] ChooseOut             //to choose which cube
				);
	 
	 
	reg A,B,C,D;
 
	always@(ChooseIn)
		begin
			case(ChooseIn) 
				2'b 00 :ChooseOut=4'b1110;                //if the input is 0, lit the last one
				2'b 01 :ChooseOut=4'b1101;                //the second one
				2'b 10 :ChooseOut=4'b1011;                //the third one
				2'b 11 :ChooseOut=4'b0111;                //the forth one
				default:ChooseOut=4'b1111;                //light all
			endcase
		end


	always@(Num_Binary)
		begin
			C<=Num_Binary[3];
			D<=Num_Binary[2];
			A<=Num_Binary[1];
			B<=Num_Binary[0];
 
				Out[0]<= ((~A)&(B)&(~C)&(~D))|((~A)&(~B)&(~C)&(D))|((~A)&(B)&(C)&(D))|((A)&(B)&(C)&(~D));
				Out[1]<= ((~A)&(B)&(~C)&(D))|((A)&(~B)&(~C)&(D))|((A)&(B)&(C)&(~D))|((~A)&(~B)&(C)&(D))|((A)&(~B)&(C)&(D))|((A)&(B)&(C)&(D));
				Out[2]<= ((A)&(~B)&(~C)&(~D))|((~A)&(~B)&(C)&(D))|((A)&(~B)&(C)&(D))|((A)&(B)&(C)&(D));
				Out[3]<= ((~A)&(B)&(~C)&(~D))|((~A)&(~B)&(~C)&(D))|((A)&(B)&(~C)&(D))|((~A)&(B)&(C)&(~D))|((A)&(~B)&(C)&(~D))|((A)&(B)&(C)&(D));
				Out[4]<= ((~A)&(B)&(~C)&(~D))|((A)&(B)&(~C)&(~D))|((~A)&(~B)&(~C)&(D))|((~A)&(B)&(~C)&(D))|((A)&(B)&(~C)&(D))|((~A)&(B)&(C)&(~D));
				Out[5]<= ((~A)&(B)&(~C)&(~D))|((A)&(~B)&(~C)&(~D))|((A)&(B)&(~C)&(~D))|((A)&(B)&(~C)&(D))|((~A)&(B)&(C)&(D));
				Out[6]<= ((~A)&(~B)&(~C)&(~D))|((~A)&(B)&(~C)&(~D))|((A)&(B)&(~C)&(D))|((~A)&(~B)&(C)&(D));
				Out[7]<= Dot;
		end

endmodule
