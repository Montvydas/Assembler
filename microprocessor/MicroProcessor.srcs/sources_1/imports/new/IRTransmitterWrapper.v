`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     University of Edinburgh
// Engineer:    Theo Scott
// 
// Create Date: 16.02.2016 12:41:15
// Design Name: IR Transmitter
// Module Name: IRTransmitterWrapper
// Project Name: Digital Systems Lab
// Target Devices: Digilent Basys3
// Tool Versions: Vivado 2015.2
// Description: Wrapper file to instantiate submodules and connect them together
// 
// Dependencies: GenericCounter.v
//               IRTransmitterSM.v
//               Mux4Way.v
//               Seg7Decoder.v
// 
// Revision: 
// Revision 1.0 - Completed and tested
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IRTransmitterWrapper(
    input CLK,
    input RESET,
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
    
//Instantiations of counters to generate 10Hz trigger for each colour code of car    

    //generic counter configured to trigger packet sending for blue-coded car at 10Hz
    wire SEND_PACKET_BLU;
    GenericCounter #(.COUNTER_WIDTH(24), .COUNTER_MAX(10000000)) 
        TEN_CLK_COUNT_BLU(.CLK(CLK), .RESET(RESET), .ENABLE_IN(SEL_BLU & ~SEL_YEL & ~SEL_GRN & ~SEL_RED), .TRIG_OUT(SEND_PACKET_BLU), .COUNT());
   
    //generic counter configured to trigger packet sending for yellow-coded car at 10Hz
    wire SEND_PACKET_YEL;
    GenericCounter #(.COUNTER_WIDTH(24), .COUNTER_MAX(10000000)) 
        TEN_CLK_COUNT_YEL(.CLK(CLK), .RESET(RESET), .ENABLE_IN(~SEL_BLU & SEL_YEL & ~SEL_GRN & ~SEL_RED), .TRIG_OUT(SEND_PACKET_YEL), .COUNT());
   
    //generic counter configured to trigger packet sending for green-coded car at 10Hz
    wire SEND_PACKET_GRN;
    GenericCounter #(.COUNTER_WIDTH(24), .COUNTER_MAX(10000000)) 
        TEN_CLK_COUNT_GRN(.CLK(CLK), .RESET(RESET), .ENABLE_IN(~SEL_BLU & ~SEL_YEL & SEL_GRN & ~SEL_RED), .TRIG_OUT(SEND_PACKET_GRN), .COUNT());
   
    //generic counter configured to trigger packet sending for red-coded car at 10Hz
    wire SEND_PACKET_RED;
    GenericCounter #(.COUNTER_WIDTH(24), .COUNTER_MAX(10000000)) 
        TEN_CLK_COUNT_RED(.CLK(CLK), .RESET(RESET), .ENABLE_IN(~SEL_BLU & ~SEL_YEL & ~SEL_GRN & SEL_RED), .TRIG_OUT(SEND_PACKET_RED), .COUNT());

 //Instantiations of each colour code of car
    
    //instantiates module for blue coded car
    wire IR_LED_BLU;
    IRTransmitterSM #(.StartBurstSize(191), .GapSize(25), .CarSelectBurstSize(47), .AssertBurstSize(47), .DeassertBurstSize(22), .MaxCount(1389))
        BlueCar(.CLK(CLK), .RESET(RESET), .COMMAND({BTN_F, BTN_B, BTN_L, BTN_R}), .SEND_PACKET(SEND_PACKET_BLU), .IR_LED(IR_LED_BLU));
        
    //instantiates module for yellow coded car
    wire IR_LED_YEL;
    IRTransmitterSM #(.StartBurstSize(88), .GapSize(40), .CarSelectBurstSize(22), .AssertBurstSize(44), .DeassertBurstSize(22), .MaxCount(1250))
        YellowCar(.CLK(CLK), .RESET(RESET), .COMMAND({BTN_F, BTN_B, BTN_L, BTN_R}), .SEND_PACKET(SEND_PACKET_YEL), .IR_LED(IR_LED_YEL));
        
    //instantiates module for green coded car
    wire IR_LED_GRN;
    IRTransmitterSM #(.StartBurstSize(88), .GapSize(40), .CarSelectBurstSize(44), .AssertBurstSize(44), .DeassertBurstSize(22), .MaxCount(1333))
        GreenCar(.CLK(CLK), .RESET(RESET), .COMMAND({BTN_F, BTN_B, BTN_L, BTN_R}), .SEND_PACKET(SEND_PACKET_GRN), .IR_LED(IR_LED_GRN));
        
    //instantiates module for red coded car
    wire IR_LED_RED;
    IRTransmitterSM #(.StartBurstSize(192), .GapSize(24), .CarSelectBurstSize(24), .AssertBurstSize(48), .DeassertBurstSize(24), .MaxCount(1389))
        RedCar(.CLK(CLK), .RESET(RESET), .COMMAND({BTN_F, BTN_B, BTN_L, BTN_R}), .SEND_PACKET(SEND_PACKET_RED), .IR_LED(IR_LED_RED));
    
    
//Instantiation of 7-segment display to show which colour code is selected
    //wire to hold which section of the 7 seg to display on
	wire [1:0] SegWire;
	//register holding the "word" to be displayed on 7 segment display, stored in hex
	reg [15:0] MuxIn;
	//wire to transmit the required letter for the section of the 7 segment display
	wire [3:0] MuxOut;
	// Divider to output 200Hz clock on StrobeTrig
	wire StrobeTrig;
	GenericCounter #(.COUNTER_WIDTH(24), .COUNTER_MAX(500000))
		Seg7Divider(.CLK(CLK), .RESET(RESET), .ENABLE_IN(1), .TRIG_OUT(StrobeTrig), .COUNT());
	// Strobes between 4 sections of display giving 50Hz refresh per section
	GenericCounter #(.COUNTER_WIDTH(2), .COUNTER_MAX(3)) 
		Seg7Strobe(.CLK(CLK), .RESET(RESET), .ENABLE_IN(StrobeTrig), .COUNT(SegWire));
	// 4 way mux to select which 7seg display is active and selects correct letter to display
	Mux4Way Mux(.CONTROL(SegWire), .IN0(MuxIn[15:12]), .IN1(MuxIn[11:8]), .IN2(MuxIn[7:4]), .IN3(MuxIn[3:0]), .OUT(MuxOut));
	// 7-segment decoder to translate from hex value of a letter to the segments required to be lit
	Seg7Decoder Seg7(.SEG_SELECT_IN(SegWire), .BIN_IN(MuxOut), .DOT_IN(1'b0), .SEG_SELECT_OUT(SEG_SELECT_OUT), .HEX_OUT(DEC_OUT));

    
//Output assignments

    // sets IR_LED to colour code wire based on input switches
    // sets 7 segment display input based on input switches
    always@(SEL_BLU or SEL_YEL or SEL_GRN or SEL_RED) begin
        if(SEL_BLU & ~SEL_YEL & ~SEL_GRN & ~SEL_RED) begin
            IR_LED <= IR_LED_BLU;
            MuxIn <= 16'h3210; //"blue"
        end
        else if(~SEL_BLU & SEL_YEL & ~SEL_GRN & ~SEL_RED) begin
            IR_LED <= IR_LED_YEL;
            MuxIn <= 16'hF134; // "yel "
        end
        else if(~SEL_BLU & ~SEL_YEL & SEL_GRN & ~SEL_RED) begin
            IR_LED <= IR_LED_GRN;
            MuxIn <= 16'hF765; // "grn "
        end
        else if(~SEL_BLU & ~SEL_YEL & ~SEL_GRN & SEL_RED) begin
            IR_LED <= IR_LED_RED;
            MuxIn <= 16'hF836; // "red "
        end
        else begin
            IR_LED <= 0;
            MuxIn <= 16'hFFFF; // "    "
        end
    end
    
    
endmodule
