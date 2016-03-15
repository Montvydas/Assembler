`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.02.2016 19:40:35
// Design Name: 
// Module Name: PWM
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


module PWM (	//512 bit PWM output
    CLK,	//read the following code, where these will be explained
    RESET,
    COMPARE,
    PWM,
	ENABLE
  	);
	
	parameter COUNTER_LEN = 8;	//length of PWM 

    input CLK;			//50MHz clock
    input RESET;		//reset button
    input [COUNTER_LEN - 1 : 0] COMPARE;	//value to compare with the counter
    output PWM;			//PWM output signal
	input ENABLE;		//PWM counter
   	
	reg pwm_send;
  	reg [COUNTER_LEN - 1 : 0] pwm_counter;
   
  	always @(posedge CLK) begin
  		if (RESET)begin			//reset values to 0
			pwm_send <= 1'b0;      		
			pwm_counter <= 1'b0;
		end
		else begin	
			if (ENABLE) begin	//if PWM counter available
				pwm_counter <= pwm_counter + 1;		//count
    		
				if (COMPARE > pwm_counter)			//check if need to turn on '1' or '0'
					pwm_send <= 1'b1;				
				else
					pwm_send <= 1'b0;
			end
	    end
  	end

	assign PWM = pwm_send;					//send PWM output 
endmodule
