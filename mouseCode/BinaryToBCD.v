`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.02.2016 18:34:15
// Design Name: 
// Module Name: BinaryToBCD
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


module BinaryToBCD(
    input  [7:0] BINARY,
    output [3:0] HUNDREDS,
    output [3:0] TENS,
    output [3:0] ONES
);

reg [3:0] hundreds;
reg [3:0] tens;
reg [3:0] ones;

integer i;
always @(BINARY) begin
    // reset hundreds, tens & ones to zero
    hundreds = 4'd0;
    tens = 4'd0;
    ones = 4'd0;

    for (i=7; i>=0; i=i-1) begin
        // add 3 to columns >= 5
        if (hundreds >= 5)
            hundreds = hundreds + 3;
        if (tens >= 5)
            tens = tens + 3;
        if (ones >= 5)
            ones = ones + 3;

        // shift left one
        hundreds = hundreds << 1;
        hundreds[0] = tens[3];
        tens = tens << 1;
        tens[0] = ones[3];
        ones = ones << 1;
        ones[0] = BINARY[i];
    end
end

assign HUNDREDS = hundreds;
assign TENS = tens;
assign ONES = ones;
endmodule
