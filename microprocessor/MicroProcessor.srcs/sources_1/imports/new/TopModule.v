`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.02.2016 14:20:23
// Design Name: 
// Module Name: Top
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


module DSL_VGA(

        input  CLK,                       //connect to the clock on the board,50Mhz only
        input  Reset,                     //connect to button to reset the whole project
       // input BUS_WE,
       // input [1:0] Msm_State,            //receive the state from master state machine
       // input [7:0] ColorIn,              //receive the value of color from the snake control
        output [7:0] ColorOut,            //cout the color. Connect to the VGA part
        output HS,                        //syn signal,connect to VGA HS
        output VS,                        //syn signal,connect to VGA VS
        inout [7:0] BusData,
        input [7:0] DataAddr,
        output reg [15:0] ColorConnect           //reg between outport and VGA module
       // output [7:0] AdressH,             //return the address signal to snake controller
       // output [6:0] AdressV

    );
    
    

    //To define the variable
                      //According to adress to allocate the Color
         wire TrigOut25M;                  //down counter's triggerout
         wire TrigToShift;                 //receive it from the VGA controllor and to triger the position counter
         wire Trig_1s;
         wire [14:0] VGA_ADDR;             //the range is 160x120
         reg BackOrFore;
         wire DATA_A;
         wire DATA_B;
         //reg [15:0] ColorConnect;           //reg between outport and VGA module
         wire DPR_CLK;
         
         always@(posedge CLK)
         begin
            if(DataAddr==8'hB0)
                ColorConnect<={BusData,~BusData};
         end
         
         assign region1=( VGA_ADDR[0]==0  && VGA_ADDR[8]==0);
//         assign region2=(VGA_ADDR[7:0]<=7 && VGA_ADDR[0]==1 && VGA_ADDR[14:8]>=113 && VGA_ADDR[8]==1);
//         assign region3=(VGA_ADDR[7:0]>=153 && VGA_ADDR[0]==1 && VGA_ADDR[14:8]<=7 && VGA_ADDR[8]==1);
//         assign region4=(VGA_ADDR[7:0]>=153 && VGA_ADDR[0]==1 && VGA_ADDR[14:8]>=113 && VGA_ADDR[8]==1);
         
         always@(posedge CLK)
         begin
            if(region1)
                BackOrFore<=1;
            else
                BackOrFore<=0;
         end

    
    

    
           Frame_Buffer
               MyFrame (
                            
                             .A_CLK(CLK),
                             .A_ADDR(VGA_ADDR),
                             .A_DATA_IN(BackOrFore),
                             .A_DATA_OUT(DATA_A),
                             .A_WE(1'b1),
                             .B_CLK(CLK),
                             .B_ADDR(VGA_ADDR),
                             .B_DATA(DATA_B)
                                  );
                                  
                                  
                                  
                                          
           CounterModule #( .Counter_Width(2),
                                 .Counter_Max(3)
                          )
              DownCounter(                     //This module is acted as a downcounter to decrease the frequence from 50MHz to 25Mhz
                                .CLK(CLK),
                                .Reset(Reset),
                                .Enable_In(1'b1),
                                .Trig_Out(TrigOut25M)
                               );
                            
            
         

           VGA_Sig_Gen
                VGA (                            //The core module of this project,return the address of pixel and let the corresponding color in
                        .CLK(TrigOut25M),
                        .Reset(Reset),
                        .Config_Colors(ColorConnect),
                        .ColorOut(ColorOut),
                        .VGA_ADDR(VGA_ADDR),      //address store in AdressH and AdressV
                        .HS(HS),
                        .VS(VS),
                        .DATA(DATA_B),
                        .TrigToShift(TrigToShift),
                        .DPR_CLK(DPR_CLK)
                        );
    
           
                          
    
    
    
    
    
endmodule
