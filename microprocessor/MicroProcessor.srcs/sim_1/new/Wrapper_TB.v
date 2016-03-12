`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.03.2016 14:17:59
// Design Name: 
// Module Name: Wrapper_TB
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


module Wrapper_TB;

              reg CLK;
              reg Reset;
              wire [7:0] ColorOut;
              wire [7:0] registerA;
              wire [7:0] registerB;
              wire [1:0] Interrept;
              wire [7:0] DataBus;
              wire [7:0] DataAddress;
              wire [7:0] ROMAddress;
              wire [7:0] ROMData;
              wire BusWE;
              wire [15:0] ColorConnect;
            
    
    
    
    Wrapper uut(
                   . CLK(CLK),              //syn signal,connect to VGA VS
                   . Reset(Reset),
                   . ColorOut(ColorOut),
                   . registerA(registerA),
                   . registerB(registerB),
                   . Interrept(Interrept),
                   . DataBus(DataBus),
                   . DataAddress(DataAddress),
                   . ROMAddress(ROMAddress),
                   . ROMData(ROMData),
                   . BusWE(BusWE),
                   . ColorConnect(ColorConnect)
                  );
                  
          initial begin
          CLK=0;
          forever #1 CLK=~CLK;
          end
                  
                  
          initial begin
          #50 Reset=0;
          #50 Reset=1;
          #50 Reset=0;
          end        
                  
                  
                  
                  
                  
endmodule
