`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.02.2016 15:13:01
// Design Name: 
// Module Name: Frame_Buffer
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


module Frame_Buffer(
        //port A -Read/Write
        input  A_CLK,
        input [14:0] A_ADDR,
        input A_DATA_IN,
        output reg A_DATA_OUT,
        input A_WE,
        
        //port B -ReadOnly
        input B_CLK,
        input [14:0] B_ADDR,
        output reg B_DATA

    );
    
    
    reg[0:0] Mem [2**15-1:0];
    
    always@(posedge A_CLK) begin
        if(A_WE)
        begin
            Mem[A_ADDR]<=A_DATA_IN;
            A_DATA_OUT<=Mem[A_ADDR];
        end
    end
    
    always@(posedge B_CLK) begin
         B_DATA<=Mem[B_ADDR];
         end
        
endmodule
