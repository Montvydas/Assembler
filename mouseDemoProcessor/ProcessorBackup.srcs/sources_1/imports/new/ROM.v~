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
        
        initial $readmemh("/home/s1349598/DSL4/MicroProcessor/Assembler/translator/results_rom.txt", ROM); 
        // Load program
        
        
        //the following part is for test
        initial 
            begin
                
                //the location of the interrupt service
                //idle here
                
//                ROM[0]=8'h00;//load a E0
//                ROM[1]=8'hE0;                
                
           //     ROM[8]=8'h02;//store 00 a
           //     ROM[9]=8'h00;
                
                
          //      ROM[11]=8'hF0;
                
          //      ROM[0]=8'h00;//load a 00
          //      ROM[1]=8'h00;
                
//                ROM[2]=8'h02;//store D0 a
//                ROM[3]=8'hD0;   




/*                
                ROM[0]=8'h00;//load a 00
                ROM[1]=8'h00;              
                
                ROM[2]=8'h02;//load a 00
                ROM[3]=8'hC0;  
                
                
             //   ROM[2]=8'h02;//store C0 a
            //    ROM[3]=8'h0C; 
                
                ROM[4]=8'h07;
                ROM[5]=8'hFF;	//goto 00
                
                
                ROM[8'hFF]=8'h06;
               //mouse_isr:
                ROM[6]=8'h00;//load a 00
                ROM[7]=8'hA1; 
                
                ROM[8]=8'h02;//store 00 a
                ROM[9]=8'h00; 
                
                ROM[10]=8'h02;//load a 00
                ROM[11]=8'hC0;  
                	ROM[8'h0A]=8'h08;//goto_idle 
                
                
                
                //timer_isr:
                ROM[8'hFE]=12;
                
                ROM[12]=8'h00;//load a 00
                ROM[13]=8'hE0;
                
                ROM[14]=8'h02;//store 01 a
                ROM[15]=8'h01;   
                
                ROM[14]=8'h02;//store 01 a
                ROM[15]=8'hD0;            
                	ROM[8'h0F]=8'h08;//goto_idle 
 */               	
               
               // ROM[10]=8'h02;//store F0 a
                
                
                
                
                
                /*
                //load memory[1] to registerB
                ROM[2]=8'b00000001;
                ROM[3]=8'b00000001;
                
                //if registerA and registerB are equal, jump to 8'hF0, that is, go back to idle
                ROM[4]=8'b10010110;
                ROM[5]=8'hF0;
                
                //else, do function call
                //do function call
                ROM[6]=8'b00001001;
                ROM[7]=8'hE0;
                
                //function call return, dereference B,then go back to idle
                ROM[8]=8'b00001100;
                ROM[9]=8'b00001000;
                
                
                //function call place, dereference A,then function return
                ROM[8'hE0]=8'b00001011;
                ROM[8'hE1]=8'b00001010;;
                
                //go back to idle
                ROM[8'hF0]=8'b00001000;
*/
            end
                
        //single port ram
        always@(posedge CLK)
        DATA <= ROM[ADDR];
        
        
        endmodule
