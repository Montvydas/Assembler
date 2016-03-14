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
        reg Reset;
        wire [3:0] SEG_SELECT_OUT;
        wire [7:0] DEC_OUT;
        wire IR_LED;

    
        Wrapper uut(
                   .CLK(CLK),             
                   .Reset(Reset),
                   .SEG_SELECT_OUT(SEG_SELECT_OUT),
                   .DEC_OUT(DEC_OUT),
                   .IR_LED(IR_LED)
                  );
    
        initial begin
        CLK=0;
        forever #5 CLK=~CLK;
        end
                
        initial begin
        #50 Reset=0;
        #50 Reset=1;
        #50 Reset=0;
        end        



endmodule
