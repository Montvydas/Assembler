`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.03.2016 11:01:52
// Design Name: 
// Module Name: Wrapper
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


module Wrapper(
      input  CLK,                      
      input  RESET,                    
      output IR_LED
    );
    
   
       wire BusWE;
       wire Int_1s;
       wire [1:0] Interrupt_ACK, Interrupt;
       wire [7:0] registerA, registerB, DataBus, DataAddress, ROMAddress, ROMData;

     
     assign Interrupt={Int_1s,1'b0};

     ROM
        myROM(
            .CLK(CLK),
            .DATA(ROMData),
            .ADDR(ROMAddress)
            );
               
                
       RAM
          myRAM(
            .CLK(CLK),
            .BUS_DATA(DataBus),
            .BUS_ADDR(DataAddress),
            .BUS_WE(BusWE)
            );  
    
       Timer
          myTimer(
            .CLK(CLK),
            .RESET(RESET),
            .BUS_DATA(DataBus),
            .BUS_ADDR(DataAddress),
            .BUS_WE(BusWE),
            .BUS_INTERRUPT_RAISE(Int_1s),
            .BUS_INTERRUPT_ACK(Interrupt_ACK[1])
            );
            
       IRTransmitterWrapper
          myIR(
            .CLK(CLK),
            .RESET(RESET),
            .BUS_DATA(DataBus),
            .BUS_ADDR(DataAddress),
            .BUS_WE(BusWE),
            .IR_LED(IR_LED)
            );

       MicroProcessor 
          myMicroProcessor(
                         
            .CLK(CLK),
            .RESET(RESET),
            .BUS_DATA(DataBus),
            .BUS_ADDR(DataAddress),
            .BUS_WE(BusWE),
            .ROM_ADDRESS(ROMAddress),
            .ROM_DATA(ROMData),
            .BUS_INTERRUPTS_RAISE(Interrupt),
            .BUS_INTERRUPTS_ACK(Interrupt_ACK)
            );

    
endmodule
