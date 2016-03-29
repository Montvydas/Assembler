`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19.01.2016 10:43:32
// Design Name:    IR Transmitter
// Module Name:    IRTransmitterSM
// Project Name:   Digital Systems Lab
// Target Devices: Digilent Basys3
// Tool Versions:  Vivado 2015.2
// Description:    State Machine which outputs packet to be transmitted to a car
//                 based on specified parameters for length of packet sections
//                 and pulse frequency
// 
// Dependencies:   GenericCounter.v
//                 BasicStateMachine.v
// 
// Revision:
// Revision 1.0 - Completed and tested
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IRTransmitterSM(
    input RESET,
    input CLK,
    input [3:0] COMMAND,
    input SEND_PACKET,
    output IR_LED
    );
    
    // Coded for yellow car, but overridden by wrapper instantiations
    parameter StartBurstSize        = 88;
    parameter GapSize               = 40;
    parameter CarSelectBurstSize    = 22;
    parameter AssertBurstSize       = 44;
    parameter DeassertBurstSize     = 22;
    parameter MaxCount              = 1250;
    
/*
This section converts the 50MHz clock signal into the frequency required for each car.
Car frequencies are: BLUE = 36kHz, YELLOW = 40kHz, GREEN = 37.5kHz, RED = 36kHz.
To do this, create a register which holds the number of clock periods passed.
Depending on which colour-code of car is being used, this reduces the clock frequency to the required pulse frequency.
The Basys3 clock is 100MHz --> clock period is 10ns.
RED/BLUE = 36kHz --> clock period is 27777.77...ns --> toggle = 13888.88...ns ~ 13890ns --> count to 1389
GREEN = 37.5kHz --> clock period is 26666.66...ns --> toggle = 13333.33...ns ~ 13330ns --> count to 1333
YELLOW = 40kHz --> clock period is 25000ns --> toggle = 12500ns --> count to 1250
i.e. for a pulse frequency signal with 50% duty cycle we need it to toggle every 0.5*(period time)ns.
*/

    // wire to trigger the toggling of the pulse clock
    wire PULSE_CLK_TRIG;
    // wire which acts as the clock with required frequency for car
    reg PULSE_CLK = 0;

    
    // outputs the clock trigger onto PULSE_CLK_TRIG when counter reaches MaxCount parameter for car
    GenericCounter #(.COUNTER_WIDTH(12), .COUNTER_MAX(MaxCount)) 
        PULSE_CLK_COUNT(.CLK(CLK), .RESET(RESET), .ENABLE_IN(1), .TRIGG_OUT(PULSE_CLK_TRIG), .COUNT());
    
    // logic which produces a pulse clock frequency as required for car:
    always@(posedge PULSE_CLK_TRIG)
        PULSE_CLK = ~PULSE_CLK;
    
/*
This section generates the states of the packet
Functions as a simple state machine
The packet is generated depending on the command input
The command input consists of: bit 0 == right assertion; bit 1 == left; bit 2 == backward; bit 3 == forward.
*/
    
    // Output of Packet state machine
    wire PACKET_SM_OUT;
    BasicStateMachine #(.StartBurstSize(StartBurstSize), 
                        .GapSize(GapSize), 
                        .CarSelectBurstSize(CarSelectBurstSize), 
                        .AssertBurstSize (AssertBurstSize), 
                        .DeassertBurstSize (DeassertBurstSize), 
                        .MaxCount(MaxCount))
        PACKET_SM(.CLK(PULSE_CLK), .RESET(RESET), .ENABLE_IN(SEND_PACKET), .COMMAND(COMMAND), .STATE_OUT(), .OUT(PACKET_SM_OUT));


/*
This combines the packet state with the pulse generator to generate IR_LED
*/

    assign IR_LED = PACKET_SM_OUT && PULSE_CLK;
        

endmodule
