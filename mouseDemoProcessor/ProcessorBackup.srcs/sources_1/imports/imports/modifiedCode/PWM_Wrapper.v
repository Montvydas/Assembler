`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.02.2016 19:40:35
// Design Name: 
// Module Name: PWM_Wrapper
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


module PWM_Wrapper (	//256 bit PWM output
    CLK,	//read the following code, where these will be explained
    RESET,
  //  COMPARE,
    PWM_LED,
	BUS_DATA,
	BUS_ADDR,
	BUS_WE
  	);
	
	parameter PWM_BASE_ADDR = 8'hC1;	//base address for pwm module
	parameter COUNTER_LEN = 8;	//length of PWM 

//Processor I/O
	inout 	[7:0] BUS_DATA;
	input	[7:0] BUS_ADDR;
	input 	BUS_WE;

    input 	CLK;			//50MHz clock
    input 	RESET;			//reset button
    
    reg 	[COUNTER_LEN - 1 : 0] compare [3:0];	//value to compare with the counter
//    wire 	[COUNTER_LEN - 1 : 0] compare1;	//value to compare with the counter
//    wire 	[COUNTER_LEN - 1 : 0] compare2;	//value to compare with the counter
//    wire 	[COUNTER_LEN - 1 : 0] compare3;	//value to compare with the counter
    
    output 	[3:0] PWM_LED;	//PWM output signal for 4 LEDs
   	
	wire 		[3:0]pwm_send;
   
    reg CLK_50;
    //Downcounter to 50MHz for Everything else that was built for 50MHz, not 100MHz
    always @(posedge CLK)
    		CLK_50 <= ~CLK_50;
   
   
//100kHz clock for PWM outputs
        wire pwm_clk;   //PWM clock connected to all PWMs
        GenericCounter #(
                                        .COUNTER_WIDTH(9),              //9bits of width
                                        .COUNTER_MAX(499)               //Counts to max value of 499 starting from 0
                                        )
                                pwm_clk_counter (
                                        .CLK(CLK_50),                           //Clock input
                                        .RESET(1'b0),                           //No Reset
                                        .ENABLE_IN(1'b1),                       //Always Enable
                                        .TRIGG_OUT(pwm_clk)                     //get 100kHz trigger
                                        );


//PWM[0] LED in here                                 
        PWM                     #(
                                        .COUNTER_LEN(COUNTER_LEN)
                                        )
                        		pwm_led_0 (
                                        .CLK (CLK_50),
                                        .RESET(RESET),
                                        .ENABLE (pwm_clk),
                                        .PWM(pwm_send[0]),
                                        .COMPARE(compare[0])
                                        );  
//PWM[1] LED in here                                 
        PWM                     #(
                                        .COUNTER_LEN(COUNTER_LEN)
                                        )
                        		pwm_led_1 (
                                        .CLK (CLK_50),
                                        .RESET(RESET),
                                        .ENABLE (pwm_clk),
                                        .PWM(pwm_send[1]),
                                        .COMPARE(compare[1])
                                        );  
//PWM[2] LED in here                                 
        PWM                     #(
                                        .COUNTER_LEN(COUNTER_LEN)
                                        )
                        		pwm_led_2 (
                                        .CLK (CLK_50),
                                        .RESET(RESET),
                                        .ENABLE (pwm_clk),
                                        .PWM(pwm_send[2]),
                                        .COMPARE(compare[2])
                                        );  
//PWM[3] LED in here                                 
        PWM                     #(
                                        .COUNTER_LEN(COUNTER_LEN)
                                        )
                        		pwm_led_3 (
                                        .CLK (CLK_50),
                                        .RESET(RESET),
                                        .ENABLE (pwm_clk),
                                        .PWM(pwm_send[3]),
                                        .COMPARE(compare[3])
                                        );  
	always @(posedge CLK) begin
		if (RESET) begin
			compare[0] <= 1'b0;
			compare[1] <= 1'b0;
			compare[2] <= 1'b0;
			compare[3] <= 1'b0;
		end
		else if ( (BUS_ADDR == PWM_BASE_ADDR) & BUS_WE)
			compare[0] <= BUS_DATA;
		else if ( (BUS_ADDR == PWM_BASE_ADDR + 1) & BUS_WE)
			compare[1] <= BUS_DATA;
		else if ( (BUS_ADDR == PWM_BASE_ADDR + 2) & BUS_WE)
			compare[2] <= BUS_DATA;
		else if ( (BUS_ADDR == PWM_BASE_ADDR + 3) & BUS_WE)
			compare[3] <= BUS_DATA;
	end
		
	assign PWM_LED = pwm_send;					//send PWM output 
endmodule
