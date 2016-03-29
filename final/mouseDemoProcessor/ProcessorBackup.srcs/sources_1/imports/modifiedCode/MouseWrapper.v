`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University Of Edinburgh
// Engineer: Montvydas Klumbys
// 
// Create Date: 13.02.2016 19:40:35
// Design Name: IR_MOUSE_CONTROLLED_CAR
// Module Name: MouseWrapper
// Project Name: IR_MOUSE_CONTROLLED_CAR
// Target Devices: BASYS3 Board
// Tool Versions:  Vivado 16
// Description: mouse wrapper is used to connect the processor to 
//the mouse module through bus and addresses
// 
// Dependencies: Processor Wrapper
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MouseWrapper(
//Standard Inputs
	input 	RESET,
	input 	CLK,
//IO - Mouse side
	inout 	CLK_MOUSE,
	inout 	DATA_MOUSE,
//For MicroProcessor
    inout 	[7:0] BUS_DATA,
    input 	[7:0] BUS_ADDR,
    output 	BUS_INTERRUPT_RAISE,
    input 	BUS_INTERRUPT_ACK,
    input 	BUS_WE
 	);

    parameter [7:0] MouseBaseAddr = 8'hA0; // Timer Base Address in the Memory Map

	reg CLK_50;
	//Downcounter to 50MHz for Everything else that was built for 50MHz, not 100MHz	
	always @(posedge CLK) 
		CLK_50 <= ~CLK_50;
	
	wire [3:0] mouse_status;
	wire [7:0] mouse_y;
	wire [7:0] mouse_x;
	wire [7:0] mouse_move_x;
	wire [7:0] mouse_move_y;
	
	wire send_interrupt;
//Mouse Module gives values for X, Y & Status
	MouseTransceiver usb_mouse (
					.RESET(RESET),
					.CLK(CLK_50),
					.CLK_MOUSE(CLK_MOUSE),
					.DATA_MOUSE(DATA_MOUSE),
					.MOUSE_STATUS(mouse_status),
					.MOUSE_X(mouse_x),
					.MOUSE_Y(mouse_y),
					.MOUSE_MOVE_X(mouse_move_x),
					.MOUSE_MOVE_Y(mouse_move_y),
					.SEND_INTERRUPT(send_interrupt)
					);
				

// 1 - have all of the values to be transmitter ready
// 2 - If base address is correct, pass the right value to the BUS_DATA
// 3 - if BUS_WE, means the processor is writing data to the BUS, so we need to check for ~BUS_WE
//which means the processor will read the data from the BUS
		reg TransmitStatus;
		reg TransmitMouseX;
		reg TransmitMouseY;

		always@(posedge CLK) begin
			if ( (BUS_ADDR == MouseBaseAddr) & ~BUS_WE)				//base address is for status
				TransmitStatus <= 1'b1;
			else TransmitStatus <= 1'b0;
            
            if ( (BUS_ADDR == MouseBaseAddr + 1'h1) & ~BUS_WE)	//base address + 1 is for mouse x
				TransmitMouseX <= 1'b1;
			else TransmitMouseX <= 1'b0;
			
            if ( (BUS_ADDR == MouseBaseAddr + 2'h2) & ~BUS_WE)	//base address + 2 is for mouse y
				TransmitMouseY <= 1'b1;
			else TransmitMouseY <= 1'b0;
		end
		
		//specify for each x, y & status. Only one will be on at the same time
		assign BUS_DATA = (TransmitStatus) ? {4'h0, mouse_status} : 8'hZZ;
		assign BUS_DATA = (TransmitMouseX) ? mouse_x : 8'hZZ;
		assign BUS_DATA = (TransmitMouseY) ? mouse_y : 8'hZZ;
		
        //assign BUS_DATA = TransmitMouseValue[7:0];
        
        

// 1 - if mouse is moved or pressed, trigger an event (pass through all states), which triggers an interrupt
// 2 - if this interrupt isreceived, set the interrupt flag to be 1 for the processor & wait for ack
// 3 - if ack received, then set the flag back to 0
//Broadcast the Interrupt
        reg Interrupt;
        always@(posedge CLK) begin
                if(RESET)
                    Interrupt <= 1'b0;
                else if(send_interrupt)		//interrupt coming from the mouse
                    Interrupt <= 1'b1;      
                else if(BUS_INTERRUPT_ACK)	//send ack signal
                	Interrupt <= 1'b0;
        end
        assign BUS_INTERRUPT_RAISE = Interrupt;
endmodule
