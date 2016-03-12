`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.02.2016 10:17:25
// Design Name: 
// Module Name: MouseWrapper
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


module MouseWrapper(
//Standard Inputs
	input RESET,
	input CLK_100,
//IO - Mouse side
	inout CLK_MOUSE,
	inout DATA_MOUSE,
// Mouse data information
	output [7:0] LED_OUT,
	output [3:0] MOUSE_STATUS,
//7Seg Display
	input POSITION_OR_SPEED,
	input ENABLE_X_Y,			//used to decide if enbale x or enbale y
    output [3:0] SEG_SELECT,	//chooses one out of 4 transistor drivers
    output [7:0] DEC_OUT,		//Turns ON diodes in 7SegDisplay
//LEDs for the Extra Stuff
	output LED_X,
	output LED_Y,
	output SOUND_X,
	output SOUND_Y
 	);

	reg CLK_50;
	//Downcounter to 50MHz for Everything else that was built for 50MHz, not 100MHz	
	always @(posedge CLK_100) 
		CLK_50 <= ~CLK_50;
	
	wire [3:0] mouse_status;
	wire [7:0] mouse_y;
	wire [7:0] mouse_x;
	wire [7:0] mouse_move_x;
	wire [7:0] mouse_move_y;
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
					.MOUSE_MOVE_Y(mouse_move_y)
					);
	assign MOUSE_STATUS = mouse_status;	

	assign LED_OUT = ENABLE_X_Y ? mouse_y : mouse_x;	//show either Horizontal or Vertical position on LEDs

	wire [15:0] bcd_wire;									//binary codded decimal wire connected to segment display
	wire [7:0] binary_x_y;									//wire connectingto mouse_x or mouse_y
	assign bcd_wire[15:12] = 4'h0;							//thousands always 0

//decide if show position or speed and if show for x or for y coordinates 	
	assign binary_x_y = POSITION_OR_SPEED ? (ENABLE_X_Y ? mouse_move_y : mouse_move_x) : (ENABLE_X_Y ? mouse_y : mouse_x);	

//Module to translate from binary to BCD in hundreds, tens & ones
	BinaryToBCD binary_to_BCD (
					.BINARY(binary_x_y),
					.HUNDREDS(bcd_wire[11:8]),
					.TENS(bcd_wire[7:4]),
					.ONES(bcd_wire[3:0])
					);
	
//place X or Y values on 7seg
	DecimalSeg decimal_num_to_seg(
					.CLK(CLK_50),
					.RESET(RESET),
					.SEG_SELECT(SEG_SELECT),
					.DEC_OUT(DEC_OUT),
					.BCD_IN(bcd_wire)
					);

//100kHz clock for PWM outputs
	wire pwm_clk;	//PWM clock connected to all PWMs
	GenericCounter #(
					.COUNTER_WIDTH(9),		//9bits of width
					.COUNTER_MAX(499)		//Counts to max value of 499 starting from 0
					)
				pwm_clk_counter (
					.CLK(CLK_50),				//Clock input
					.RESET(1'b0),				//No Reset
					.ENABLE_IN(1'b1),			//Always Enable
					.TRIGG_OUT(pwm_clk)			//get 100kHz trigger
					);
//Regulate LED brightness depending on the position of the mouse in Y direction
	PWM  			#(
					.COUNTER_LEN(8)
					)
			pwm_module_led_x (
					.CLK (CLK_50),
					.RESET(RESET),
					.ENABLE (pwm_clk),
					.PWM(LED_X),
					.COMPARE(mouse_x)
					);
//Regulate LED brightness depending on the position of the mouse in Y direction
	PWM  			#(
					.COUNTER_LEN(8)
					)
			pwm_module_led_y (
					.CLK (CLK_50),
					.RESET(RESET),
					.ENABLE (pwm_clk),
					.PWM(LED_Y),
					.COMPARE(mouse_y)
					);
//produce sound using PWM from how fast the mouse is moving in X direction
	PWM  			#(
					.COUNTER_LEN(8)
					)
			pwm_module_sound_x (
					.CLK (CLK_50),
					.RESET(RESET),
					.ENABLE (pwm_clk),
					.PWM(SOUND_X),
					.COMPARE(mouse_move_x)
					);
//produce sound using PWM from how fast the mouse is moving in Y direction
	PWM  			#(
					.COUNTER_LEN(8)
					)
			pwm_module_sound_y (
					.CLK (CLK_50),
					.RESET(RESET),
					.ENABLE (pwm_clk),
					.PWM(SOUND_Y),
					.COMPARE(mouse_move_y)
					);
endmodule
