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
            
            //the following is the VGA part
              input  CLK,                       //connect to the clock on the board,50Mhz only
              input  Reset,                     //connect to button to reset the whole project
              output [7:0] ColorOut,
              output HS,
              output VS,
              input BTN_R,                      
              input BTN_L,
              input BTN_B,
              input BTN_F,
              input SEL_BLU,
              input SEL_YEL,
              input SEL_GRN,
              input SEL_RED,    
              output [3:0] SEG_SELECT_OUT,
              output [7:0] DEC_OUT,
              output reg IR_LED
            
    );
    
   
       wire BusWE;
       wire Int_1s;
       wire [1:0] Interrept_ACK;
    
       wire [7:0] registerA;
       wire [7:0] registerB;
       wire [1:0] Interrept;
       wire [7:0] DataBus;
       wire [7:0] DataAddress;
       wire [7:0] ROMAddress;
       wire [7:0] ROMData;
       wire [15:0] ColorConnect;

     
     assign Interrept={Int_1s,1'b0};

     DSL_VGA
        myVGA(
              .CLK(CLK),                      //connect to the clock on the board,50Mhz only
              .Reset(Reset),                  //connect to button to reset the whole project
              .ColorOut(ColorOut),            //cout the color. Connect to the VGA part
              .HS(HS),                        //syn signal,connect to VGA HS
              .VS(VS),                        //syn signal,connect to VGA VS
              .BusData(DataBus),
              .DataAddr(DataAddress),
              .ColorConnect(ColorConnect)
              //.BUS_WE(BusWE)

             );

               
     ROM
        myROM(
               .CLK(CLK),
              //bus signals
               .DATA(ROMData),
               .ADDR(ROMAddress)
               
               );
               
                
       RAM
          myRAM(
                 .CLK(CLK),
                //bus signals
                 .BUS_DATA(DataBus),
                 .BUS_ADDR(DataAddress),
                 .BUS_WE(BusWE)

                 );  
    
       Timer
          myTimer(
                         //standard signals
                          .CLK(CLK),
                          .RESET(Reset),
                         //BUS signals
                          .BUS_DATA(DataBus),
                          .BUS_ADDR(DataAddress),
                          .BUS_WE(BusWE),
                          .BUS_INTERRUPT_RAISE(Int_1s),
                          .BUS_INTERRUPT_ACK(Interrept_ACK[1])
                         );
                         
        IRTransmitterWrapper
            myIR(
                          .CLK(CLK),
                          .RESET(Reset),
                          .BTN_R(BTN_R),
                          .BTN_L(BTN_L),
                          .BTN_B(BTN_B),
                          .BTN_F(BTN_F),
                          .SEL_BLU(SEL_BLU),
                          .SEL_YEL(SEL_YEL),
                          .SEL_GRN(SEL_GRN),
                          .SEL_RED(SEL_RED),
                          .SEG_SELECT_OUT(SEG_SELECT_OUT),
                          .DEC_OUT(DEC_OUT),
                          .IR_LED(IR_LED)
                         );
                          
        MouseWrapper
            myMouse(
                          .RESET(Reset),
                          .CLK_100(CLK),
                          .CLK_MOUSE(),
                          .DATA_MOUSE(),
                          .LED_OUT(),
                          .MOUSE_STATUS(),
                          .POSITION_OR_SPEED(),
                          .ENABLE_X_Y(), 
                          .SEG_SELECT(),
                          .DEC_OUT(),
                          .LED_X(),
                          .LED_Y(),
                          .SOUND_X(),
                          .SOUND_Y()
                         );
                         
        MicroProcessor 
            myMicroProcessor(
                         
                         //Standard Signals
                          .CLK(CLK),
                          .RESET(Reset),
                         //BUS Signals
                          .BUS_DATA(DataBus),
                          .BUS_ADDR(DataAddress),
                          .BUS_WE(BusWE),
                         // ROM signals
                          .ROM_ADDRESS(ROMAddress),
                          .ROM_DATA(ROMData),
                         // INTERRUPT signals
                          .BUS_INTERRUPTS_RAISE(Interrept),
                          .BUS_INTERRUPTS_ACK(Interrept_ACK),
                          .registerA(registerA),
                          .registerB(registerB)
                         
                             );
                             
         /*SevenSeg
            mySevenSeg(
                           . CLK(CLK),
                           . Reset(Reset),
                           . BUS_ADDR(DataAddress),
                           . BUS_DATA(DataBus),
                           . DecOut(DecOut),
                           . Seg_Selcet(Seg_Selcet)
                                 );*/
               
    
    
    
endmodule
