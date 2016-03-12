`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		University of Edinburgh
// Engineer: 		Theo Scott
// 
// Create Date:    22:34:51 11/02/2014 
// Design Name:    IR Transmitter
// Module Name:    BasicStateMachine 
// Project Name:   Digital Systems Lab
// Target Devices: Digilent Basys3
// Tool versions:  Vivado 2015.2
// Description:    Simple state machine which transitions between states after a certain
//                 number of clock cycles have passed and outputs high or low depending on
//                 its current state
//
// Dependencies:   GenericCounter.v
//
// Revision: 
// Revision 1.0 - Completed and tested
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module BasicStateMachine(
    input CLK,
    input RESET,
    input ENABLE_IN,
    input [3:0] COMMAND,
    output [3:0] STATE_OUT,
    output reg OUT
    );
	 
	 //Hold parameters for car
	 parameter StartBurstSize        = 88;
     parameter GapSize               = 40;
     parameter CarSelectBurstSize    = 22;
     parameter AssertBurstSize       = 44;
     parameter DeassertBurstSize     = 22;
     parameter MaxCount              = 1250;

	 
	 //Registers to hold current-state value
	 //Needs 4 bits, as packet has 12 (1100) states
	 reg [3:0] CurrState;
	 //register to hold count of generic counter
	 wire [7:0] PacketCount;
	 //register to hold current command
	 reg [3:0] Command;
	 //reg to reset PACKET_COUNT
	 reg PACKET_COUNT_RST;
	 
//	 assign STATE_OUT = CurrState[3:0];
	 
	 //Counter to hold number of pulses counted through for each segment of the packet
	 GenericCounter #(.COUNTER_WIDTH(8), .COUNTER_MAX(192))
	   PACKET_COUNT(.CLK(CLK), .RESET(PACKET_COUNT_RST), .ENABLE_IN(1), .TRIG_OUT(), .COUNT(PacketCount));
	 
	 //Combinatorial logic to set CurrState values
	 always@(posedge CLK or posedge ENABLE_IN or posedge RESET) begin
	 
	    if(RESET || ENABLE_IN) begin
            CurrState <= 4'd0;
            Command <= COMMAND;
            PACKET_COUNT_RST <= 1;
	    end
	   
	    else begin
            case (CurrState)
                //State 0 - start burst
                4'd0	:	begin
                    if(PacketCount == StartBurstSize - 1) begin
                        CurrState <= 4'd1;
                        PACKET_COUNT_RST <= 1;
                        OUT <= 0;
                    end
                    else begin
                        PACKET_COUNT_RST <= 0;
                        OUT <= 1;
                    end
                end
                //State 1 - gap
                4'd1	:	begin
                    if(PacketCount == GapSize - 1) begin
                        CurrState <= 4'd2;
                        PACKET_COUNT_RST <= 1;
                        OUT <= 0;
                    end
                    else begin
                        PACKET_COUNT_RST <= 0;
                        OUT <= 0;
                    end
                end
                //State 2 - car select burst
                4'd2	:	begin
                    if(PacketCount == CarSelectBurstSize - 1) begin
                        CurrState <= 4'd3;
                        PACKET_COUNT_RST <= 1;
                        OUT <= 0;
                    end
                    else begin
                        PACKET_COUNT_RST <= 0;
                        OUT <= 1;
                    end
                end
                //State 3 - gap
                4'd3	:	begin
                    if(PacketCount == GapSize - 1) begin
                        CurrState <= 4'd4;
                        PACKET_COUNT_RST <= 1;
                        OUT <= 0;
                    end
                    else begin
                        PACKET_COUNT_RST <= 0;
                        OUT <= 0;
                    end
                end
                //State 4 - right
                4'd4	:	begin
                    //if asserted
                    if(Command[0] == 1) begin
                        if(PacketCount == AssertBurstSize - 1) begin
                            CurrState <= 4'd5;
                            PACKET_COUNT_RST <= 1;
                            OUT <= 0;
                        end
                        else begin
                            PACKET_COUNT_RST <= 0;
                            OUT <= 1;
                        end
                    end
                    //if deasserted
                    else begin
                        if(PacketCount == DeassertBurstSize - 1) begin
                            CurrState <= 4'd5;
                            PACKET_COUNT_RST <= 1;
                            OUT <= 0;
                        end
                        else begin
                            PACKET_COUNT_RST <= 0;
                            OUT <= 1;
                        end
                    end
                end
                //State 5 - gap
                4'd5	:	begin
                    if(PacketCount == GapSize - 1) begin
                        CurrState <= 4'd6;
                        PACKET_COUNT_RST <= 1;
                        OUT <= 0;
                    end
                    else begin
                        PACKET_COUNT_RST <= 0;
                        OUT <= 0;
                    end
                end
                //State 6 - left
                4'd6	:	begin
                    //if asserted
                    if(Command[1] == 1) begin
                        if(PacketCount == AssertBurstSize - 1) begin
                            CurrState <= 4'd7;
                            PACKET_COUNT_RST <= 1;
                            OUT <= 0;
                        end
                        else begin
                            PACKET_COUNT_RST <= 0;
                            OUT <= 1;
                        end
                    end
                    //if deasserted
                    else begin
                        if(PacketCount == DeassertBurstSize - 1) begin
                            CurrState <= 4'd7;
                            PACKET_COUNT_RST <= 1;
                            OUT <= 0;
                        end
                        else begin
                            PACKET_COUNT_RST <= 0;
                            OUT <= 1;
                        end
                    end
                end
                //State 7 - gap
                4'd7	:	begin
                    if(PacketCount == GapSize - 1) begin
                        CurrState <= 4'd8;
                        PACKET_COUNT_RST <= 1;
                        OUT <= 0;
                    end
                    else begin
                        PACKET_COUNT_RST <= 0;
                        OUT <= 0;
                    end
                end
                //State 8 - back
                4'd8    :   begin
                    //if asserted
                    if(Command[2] == 1) begin
                        if(PacketCount == AssertBurstSize - 1) begin
                            CurrState <= 4'd9;
                            PACKET_COUNT_RST <= 1;
                            OUT <= 0;
                        end
                        else begin
                            PACKET_COUNT_RST <= 0;
                            OUT <= 1;
                        end
                    end
                    //if deasserted
                    else begin
                        if(PacketCount == DeassertBurstSize - 1) begin
                            CurrState <= 4'd9;
                            PACKET_COUNT_RST <= 1;
                            OUT <= 0;
                        end
                        else begin
                            PACKET_COUNT_RST <= 0;
                            OUT <= 1;
                        end
                    end
                end
                //State 9 - gap
                4'd9    :   begin
                        if(PacketCount == GapSize - 1) begin
                        CurrState <= 4'd10;
                        PACKET_COUNT_RST <= 1;
                        OUT <= 0;
                    end
                    else begin
                        PACKET_COUNT_RST <= 0;
                        OUT <= 0;
                    end
                end
                //State 10 - forward
                4'd10   :   begin
                    //if asserted
                    if(Command[3] == 1) begin
                        if(PacketCount == AssertBurstSize - 1) begin
                            CurrState <= 4'd11;
                            PACKET_COUNT_RST <= 1;
                            OUT <= 0;
                        end
                        else begin
                            PACKET_COUNT_RST <= 0;
                            OUT <= 1;
                        end
                    end
                    //if deasserted
                    else begin
                        if(PacketCount == DeassertBurstSize - 1) begin
                            CurrState <= 4'd11;
                            PACKET_COUNT_RST <= 1;
                            OUT <= 0;
                        end
                        else begin
                            PACKET_COUNT_RST <= 0;
                            OUT <= 1;
                        end
                    end
                end
                //State 11 - gap
                4'd11   :   begin
                    if(PacketCount == GapSize - 1) begin
                        CurrState <= 4'd12;
                        PACKET_COUNT_RST <= 1;
                        OUT <= 0;
                    end
                    else begin
                        PACKET_COUNT_RST <= 0;
                        OUT <= 0;
                    end
                end
                //State 12 - idle, stay here until reset
                4'd12   :   begin
                    OUT <= 0;
                end
                
                default:
                    CurrState <= 4'd0;
                    
            endcase
		end
	end

endmodule