`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University Of Edinburgh
// Engineer: Montvydas Klumbys
// 
// Create Date: 13.02.2016 19:40:35
// Design Name: IR_MOUSE_CONTROLLED_CAR
// Module Name: DecimalSeg
// Project Name: IR_MOUSE_CONTROLLED_CAR
// Target Devices: BASYS3 Board
// Tool Versions:  Vivado
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
/////////////////////////////////////////////////////////////////////////////////
module DecimalSeg(
    input CLK,						//Internal Clock Signal
    input RESET,					//Button that resets values
    output [3:0] SEG_SELECT,	//chooses one out of 4 transistor drivers
    output [7:0] DEC_OUT,		//Turns ON diodes in 7SegDisplay
//	input [15:0] BCD_IN			//Binray codded decimal in
	//Processor part
	inout  [7:0] BUS_DATA,
	input  [7:0] BUS_ADDR,
	input        BUS_WE
    );

	parameter [7:0] SevenSegBaseAddr = 8'hD0;

	wire [1:0] StrobeCount;		//Strobe Counter for choosing a display
	wire Bit16Trigger;			//1kHz trigger 

	wire [4:0] DecCountAndDOT0;//BNN dove for DEC values with DOT
	wire [4:0] DecCountAndDOT1;
	wire [4:0] DecCountAndDOT2;
	wire [4:0] DecCountAndDOT3;
	
	wire [4:0] MuxOut;			//Output from Multiplexer - one of 4 DecCountAndDOTX values
	
	reg [3:0] dot_in;	//used to store info about which dots to light up
	reg [7:0] data_in;	//used to store binary data coming from the code...
	
	wire [7:0] BusDataIn;
	assign BusDataIn = BUS_DATA;
	
	always @(posedge CLK) begin
		if (RESET) begin
			data_in <= 8'h00;	//reset values
			dot_in <= 4'h00;
		end
		else if ( (BUS_ADDR == SevenSegBaseAddr) & BUS_WE )	//write a binary value from the bus
			data_in <= BusDataIn;	
		else if ( (BUS_ADDR == SevenSegBaseAddr + 1) & BUS_WE )	//write which dots to turn on
			dot_in <= BusDataIn[3:0];		//only have 4 dots
		else begin
			data_in <= data_in;	//otherwise leave as it was before
			dot_in <= dot_in;
		end
	end
			
	
	 //downcounter with output trigger every 1ms/1kHz
	 GenericCounter #(
							.COUNTER_WIDTH(16),		//16bits of width
							.COUNTER_MAX(49999)		//Counts to max value of 49 999 starting from 0
							)
						Bit16DownCounter (
							.CLK(CLK),					//Clock input
							.RESET(1'b0),				//No Reset
							.ENABLE_IN(1'b1),			//Always Enable
							.TRIGG_OUT(Bit16Trigger)//get 1kHz trigger
							);
	
	//Strobe Output counter for geting the value of the display
	//that should be turned ON
	GenericCounter #(
							.COUNTER_WIDTH(2),				//2bits of width
							.COUNTER_MAX(3)					//Counts to max value of 3
							)
						Bit2DownCounter (
							.CLK(CLK),							//Clock input
							.RESET(1'b0),						//No Reset
							.ENABLE_IN(Bit16Trigger),		//Trigger that enables counting in 1kHz Clock frequency
							.COUNT(StrobeCount)				//chooses the 7-seg display value
							);
							
	wire [15:0] bcd_wire;
//Module to translate from binary to BCD in hundreds, tens & ones
	BinaryToBCD binary_to_BCD (
					.BINARY(data_in),
					.HUNDREDS(bcd_wire[11:8]),
					.TENS(bcd_wire[7:4]),
					.ONES(bcd_wire[3:0])
					);

	assign DecCountAndDOT0 = {dot_in[0], bcd_wire[3:0]};	
	assign DecCountAndDOT1 = {dot_in[1], bcd_wire[7:4]};
	assign DecCountAndDOT2 = {dot_in[2], bcd_wire[11:8]};		
	assign DecCountAndDOT3 = {dot_in[3], bcd_wire[15:12]};
	
	//According to StrobeCount value choose the value to display on 7SegDisplay
	Multiplexer Mux4 (
							.CONTROL(StrobeCount),			//binary values for determining output
							.IN0(DecCountAndDOT0),			//input to be displayed as output
							.IN1(DecCountAndDOT1),			//the same
							.IN2(DecCountAndDOT2),			//the same
							.IN3(DecCountAndDOT3),			//the same
							.DISPLAY_OUT(MuxOut)			//Output: one of provided inputs
							);

	//According to input values choose which transistors & which
	//LEDs to turn ON (give logic 0)
	EasyDecode7Seg Seg7Decoder (
							.SEG_SELECT_IN(StrobeCount),	//binary value for determining which displa to turn on
							.BIN_IN(MuxOut[3:0]),			//decimal value to be displayed in binary
							.DOT_IN(MuxOut[4]),				//add DOT
							.SEG_SELECT_OUT(SEG_SELECT),	//display to be turned on for a short amount of time
							.HEX_OUT(DEC_OUT)					//binary code specialy made to turn on specific LEDs of 7Seg display
																	//to display a provided value
							);
endmodule
