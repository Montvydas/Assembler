`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University Of Edinburgh
// Engineer: Montvydas Klumbys
// 
// Create Date: 13.02.2016 19:40:35
// Design Name: IR_MOUSE_CONTROLLED_CAR
// Module Name: LED 
// Project Name: IR_MOUSE_CONTROLLED_CAR
// Target Devices: BASYS3 Board
// Tool Versions:  Vivado 16
// Description: 	 This is a code for the LED module to be connected to the processor
// 
// Dependencies: Depends on the wrapper top module
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module LED (
    input CLK, 	//read the following code, where these will be explained
    input RESET,
    output [7:0] LED,
    //Processor peripherals
    inout  [7:0] BUS_DATA,
    input  [7:0] BUS_ADDR,
    input        BUS_WE
  	);
	
	parameter [7:0] LEDBaseAddr = 8'hC0;
	
	wire [7:0] BusDataIn;
	
	assign BusDataIn = BUS_DATA;
	//assign led to be the value of a bus if bus addr is the same as base addr and processor is writing
	assign LED = ( (BUS_ADDR == LEDBaseAddr)  & BUS_WE) ? BusDataIn : LED;
	
endmodule
