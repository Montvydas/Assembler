`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University Of Edinburgh
// Engineer: Montvydas Klumbys
// 
// Create Date: 13.02.2016 19:40:35
// Design Name: IR_MOUSE_CONTROLLED_CAR
// Module Name: SlideSwitches
// Project Name: IR_MOUSE_CONTROLLED_CAR
// Target Devices: BASYS3 Board
// Tool Versions:  Vivado 16
// Description: slide switch, just works with processor
// 
// Dependencies: Processor wrapper
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module SlideSwitches (
    input CLK, 	//read the following code, where these will be explained
    input RESET,
    input [7:0] SLIDE_SWITCHES,
    //Processor peripherals
    inout  [7:0] BUS_DATA,
    input  [7:0] BUS_ADDR,
    input        BUS_WE
  	);
	
	parameter [7:0] SlideSwitchesBaseAddr = 8'hE0;
	
	wire [7:0] BusDataIn;
	assign BusDataIn = SLIDE_SWITCHES;
	
	reg TransmitData;
	always@ (posedge CLK)begin
		if ( (BUS_ADDR == SlideSwitchesBaseAddr) & ~BUS_WE)	//need to use regs to store data
			TransmitData <= 1;					//for one clock cycle after the data appears on the bus
		else
			TransmitData <= 0;
	end
	assign BUS_DATA = (TransmitData) ? BusDataIn : 8'hZZ;	//tristate send & high impedance
endmodule
