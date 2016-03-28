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
        input BUS_WE,
       // input [1:0] Msm_State,            //receive the state from master state machine
       // input [7:0] ColorIn,              //receive the value of color from the snake control
        output [7:0] ColorOut,              //cout the color. Connect to the VGA part
        output HS,                          //syn signal,connect to VGA HS
        output VS,                          //syn signal,connect to VGA VS
        inout [7:0] BusData,
        input [7:0] DataAddr,
        //input Bus_WE,
        output  [15:0] ColorConnect           //reg between outport and VGA module
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
         wire DPR_CLK;
         reg W_EN;
         reg [7:0] BusBuffer;
         reg [7:0] Fresh_X=0;
         reg [6:0] Fresh_Y=0;
         wire [14:0] MEMIN;
         reg [7:0] ReceivedColor;

         
         
       //  reg WriteX;
       //  reg WriteY;
         
        assign MEMIN={Fresh_Y,Fresh_X};
        assign ColorConnect={ReceivedColor,~ReceivedColor};
        //assign BusData=(WriteX) ? Fresh_X : 8'hZZ;
        //assign BusData=(WriteY) ? {1'b0,Fresh_Y} : 8'hZZ;

         /*always@(posedge CLK) begin
            if((DataAddr==8'hB0) & ~BUS_WE)begin
               WriteX <= 1;
           end
           else WriteX <= 0;
               
               
           if((DataAddr==8'hB1) & ~BUS_WE)begin
                WriteY <= 1;
           end
           else WriteY <= 0;  
               
           if((DataAddr==8'hB2) & BUS_WE ) begin  
               BackOrFore <= BusData[0];
               W_EN <= 1'b1;
           end
           else begin
              W_EN <= 1'b0;
              BackOrFore <=  BackOrFore;
          end 
         end
          
         always@(posedge CLK)begin
            if(Fresh_X ==8'b11111111 && Fresh_Y ==7'b1111111)begin         //next clock start from 00 to wait next interrupt, then can fresh the frame again 
                Fresh_X <= 8'b00000000;
                Fresh_Y <= 7'b0000000;
            end
            else
                if(W_EN==1'b1)begin
                    if(Fresh_X>=8'd159 && Fresh_Y>=8'd119) begin            //give out the signal when a frame is finished
                        Fresh_Y <= 7'b1111111;
                        Fresh_X <= 8'b11111111;
                    end
                    else
                        if(Fresh_X==8'd159) begin
                            Fresh_Y <= Fresh_Y+1'b1;
                            Fresh_X <= 8'b00000000;
                        end
                        else begin
                            Fresh_Y <= Fresh_Y;
                            Fresh_X <= Fresh_X+1'b1;
                        end
                end
        end*/
        
        always@(posedge CLK)begin
        
            if(DataAddr==8'hB0)
                Fresh_X <= BusData;  
            else
                Fresh_X <= Fresh_X;
            if(DataAddr==8'hB1)
                Fresh_Y <= 8'd119 - BusData[6:0];
            else 
                Fresh_Y <= Fresh_Y;
            if(DataAddr==8'hB2 ) begin
                BackOrFore <= BusData[0];
                W_EN <= 1'b1;
            end
          	else begin
                BackOrFore <= BackOrFore;
                W_EN <= 1'b0;
            end
            
            if(DataAddr==8'hB3 ) 
                ReceivedColor <= BusData;
            else
                ReceivedColor <= ReceivedColor;
        end
                
                
            
         //assign region1=( VGA_ADDR[0]==0  && VGA_ADDR[8]==0);
//         assign region2=(VGA_ADDR[7:0]<=7 && VGA_ADDR[0]==1 && VGA_ADDR[14:8]>=113 && VGA_ADDR[8]==1);
//         assign region3=(VGA_ADDR[7:0]>=153 && VGA_ADDR[0]==1 && VGA_ADDR[14:8]<=7 && VGA_ADDR[8]==1);
//         assign region4=(VGA_ADDR[7:0]>=153 && VGA_ADDR[0]==1 && VGA_ADDR[14:8]>=113 && VGA_ADDR[8]==1);
         
        /* always@(posedge CLK)
         begin
            if(region1)
                BackOrFore<=1;
            else
                BackOrFore<=0;
         end*/

    
    

    
           Frame_Buffer
               MyFrame (
                            
                             .A_CLK(CLK),
                             .A_ADDR(MEMIN),
                             .A_DATA_IN(BackOrFore),
                             .A_DATA_OUT(DATA_A),
                             .A_WE(W_EN),
                             .B_CLK(CLK),
                             .B_ADDR(VGA_ADDR),
                             .B_DATA(DATA_B)
                                  );
                                  
                                  
                                  
                                          
                                 GenericCounter #(
                                        .COUNTER_WIDTH(2),              
                                        .COUNTER_MAX(3)               
                                        )
                                DownCounter (			//This module is acted as a downcounter to decrease the frequence from 100MHz to 25Mhz
                                        .CLK(CLK),                           //Clock input
                                        .RESET(Reset),                          
                                        .ENABLE_IN(1'b1),                       //Always Enable
                                        .TRIGG_OUT(TrigOut25M)                     
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
