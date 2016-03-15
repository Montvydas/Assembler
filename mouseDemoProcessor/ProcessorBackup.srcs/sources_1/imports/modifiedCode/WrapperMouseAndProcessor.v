`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.03.2016 11:01:52
// Design Name: 
// Module Name: WrapperMouseAndProcessor
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


module WrapperMouseAndProcessor(
            
            //the following is the VGA part
              input  CLK,                       //connect to the clock on the board,50Mhz only
              input  Reset,                     //connect to button to reset the whole project

              output [3:0] SEG_SELECT_OUT,
              output [7:0] DEC_OUT,
         //     output reg IR_LED,
  			//slide switches
              input [7:0] SLIDE_SWITCHES,
              //digital led
              output [7:0] LED,
              //pwm generated LED
              output [3:0] PWM_LED,
              //mouse connection
              inout CLK_MOUSE,
              inout DATA_MOUSE,
           	
            output LED_TEST,
            input SLIDE_TEST
    );
    
    assign LED_TEST = SLIDE_TEST;
   
       wire BusWE;
       wire [1:0] Interrept_ACK;
    
       wire [7:0] registerA;
       wire [7:0] registerB;
       wire [1:0] Interrept;
       wire [7:0] DataBus;
       wire [7:0] DataAddress;
       wire [7:0] ROMAddress;
       wire [7:0] ROMData;
       
       
//       wire [15:0] ColorConnect;
/*
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

  */    
           
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
                          .BUS_INTERRUPT_RAISE(Interrept[1]),
                          .BUS_INTERRUPT_ACK(Interrept_ACK[1])
                         );
                         
   /*                      
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
     */             
             
        MouseWrapper
            myMouse(
                          .RESET(Reset),
                          .CLK(CLK),
                          .CLK_MOUSE(CLK_MOUSE),
                          .DATA_MOUSE(DATA_MOUSE),
						  .BUS_DATA(DataBus),
						  .BUS_ADDR(DataAddress),
						  .BUS_INTERRUPT_RAISE(Interrept[0]),
						  .BUS_INTERRUPT_ACK(Interrept_ACK[0]),
						  .BUS_WE(BusWE)	
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
                            
                            
                            
                            //[7:0]ROMAddress
                            //[7:0]RegA
                            //[7:0]BUS_DATA
                            //[7:0]BUS_ADDR
                            //int_ack
                            //int
wire int_ack;
wire int;

assign int =  Interrept[1];
assign int_ack = Interrept_ACK[1];
/*
ila_0 your_instance_name (
	.clk(CLK), // input wire clk


	.probe0(int), // input wire [0:0]  probe0  
	.probe1(int_ack), // input wire [0:0]  probe1 
	.probe2(DataBus) // input wire [7:0]  probe2
);
*/

wire [7:0] data_bus_wire;
wire [7:0] rom_addr_wire;
wire [7:0] reg_a_wire;
wire [7:0] data_addr_wire;
assign data_bus_wire = DataBus;
assign rom_addr_wire = ROMAddress;
assign reg_a_wire = registerA;
assign data_addr_wire = DataAddress;

ila_2 your_instance_name (
	.clk(CLK), // input wire clk


	.probe0(int), // input wire [0:0]  probe0  
	.probe1(int_ack), // input wire [0:0]  probe1 
	.probe2(rom_addr_wire), // input wire [7:0]  probe2 
	.probe3(reg_a_wire), // input wire [7:0]  probe3 
	.probe4(data_bus_wire), // input wire [7:0]  probe4 
	.probe5(data_addr_wire) // input wire [7:0]  probe5
);

        //LEDs with their bus  
        LED myLED (
                         
                         //Standard Signals
                          .CLK(CLK),
                          .RESET(Reset),
                         //LED wiring
                          .LED (LED),
                         //BUS Signals
                          .BUS_DATA(DataBus),
                          .BUS_ADDR(DataAddress),
                          .BUS_WE(BusWE)
                          
                          	);
                          
        SlideSwitches mySlideSwitches (
                         
                         //Standard Signals
                          .CLK(CLK),
                          .RESET(Reset),
                         //LED wiring
                          .SLIDE_SWITCHES (SLIDE_SWITCHES),
                         //BUS Signals
                          .BUS_DATA(DataBus),
                          .BUS_ADDR(DataAddress),
                          .BUS_WE(BusWE)
                          
                          	);
                          	
                          	
//Seven segment module in here        
         DecimalSeg
            mySevenSeg(
                           . CLK(CLK),
                           . RESET(Reset),
                           . BUS_ADDR(DataAddress),
                           . BUS_DATA(DataBus),
                           . BUS_WE (BusWE),
                           . DEC_OUT(DEC_OUT),
                           . SEG_SELECT(SEG_SELECT_OUT)
                                 
                                 );  
                                
                                 
//PWM LED in here                                 
        PWM_Wrapper                     #(
                                        .COUNTER_LEN(8),
                                        .PWM_BASE_ADDR(8'hC1)
                                        )
                        pwm_module_for_4_LEDs (
                                        .CLK (CLK),
                                        .RESET(Reset),
                                        .PWM_LED(PWM_LED),
                                        .BUS_DATA(DataBus),
                                        .BUS_ADDR(DataAddress),
                                        .BUS_WE(BusWE)
                                        );   
                                       
         /*SevenSeg
            mySevenSeg(
                           . CLK(CLK),
                           . Reset(Reset),
                           . BUS_ADDR(DataAddress),
                           . BUS_DATA(DataBus),
                           . BUS_WE (BusWE),
                           . DecOut(DEC_OUT),
                           . Seg_Selcet(SEG_SELECT)
                                 );*/
               
    
    
    
endmodule
