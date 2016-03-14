`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.02.2016 09:30:29
// Design Name: 
// Module Name: ROM
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


module ROM(
            //standard signals
            input CLK,
            //BUS signals
            output reg [7:0] DATA,
            input [7:0] ADDR
           
            
            );
        parameter RAMAddrWidth = 8;
        //Memory
        reg [7:0] ROM [2**RAMAddrWidth-1:0];
        
        initial
        begin
         $readmemh("/home/s1231174/Assembler/microprocessor/Complete_Demo_ROM.txt", ROM); 
         ROM[8'hFE]=8'b00000000;
         end
        // Load program
        
        
        //the following part is for test
       /* initial 
            begin
                
//                //the location of the interrupt service
                ROM[8'hFE]=8'b00000000;
                
                
                //first is to read data from memory 0 to register A
//                ROM[0]=8'b00000000;
//                ROM[1]=8'b00000000;
                
          //load a constant value of 01 to reg A
                ROM[0] = 8'h0D;
                ROM[1] = 8'h01;
                
                //then read data from memory 1 to register B
//                ROM[2]=8'b00000001;
//                ROM[3]=8'b00000001;
                
          //then load a constant value of 01 to reg B
                ROM[2]=8'h0E;
                ROM[3]=8'h01;
                
                //add two register A and B and store in A
                ROM[4]=8'b00000100;
                
                //store register A store it in memory block 1
                ROM[5]=8'b00000010;
                ROM[6]=8'b00000001;
                
                //inform the VGA part that the color is sent
                ROM[7]=8'b00000010;
                ROM[8]=8'hB0;
                
                //inform the timer part that output the interrput times
                ROM[9]=8'b00000010;
                ROM[10]=8'hF0;
                
                //then go back to idle
                ROM[11]=8'b00001000;
             end*/
                
                
                
                
                
                
                
                

                
        //single port ram
        always@(posedge CLK)
        DATA <= ROM[ADDR];
        
        
        endmodule
