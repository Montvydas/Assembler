`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.03.2016 15:29:39
// Design Name: 
// Module Name: Wrapper_IR_TB
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


module Wrapper_IR_TB;

        reg CLK;
        reg RESET;
        wire IR_LED;

    
        Wrapper uut(
                   .CLK(CLK),             
                   .RESET(RESET),
                   .IR_LED(IR_LED)
                  );
    
        initial begin
        CLK=0;
        forever #5 CLK=~CLK;
        end
                
        initial begin
        #150 RESET=0;
        #5 RESET=1;
        #50 RESET=0;
        end        



endmodule
