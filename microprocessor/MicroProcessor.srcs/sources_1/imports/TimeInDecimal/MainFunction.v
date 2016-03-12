`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:30:24 10/17/2014 
// Design Name: 
// Module Name:    MainFunction 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module SevenSeg(
                          input CLK,
						  input Reset,
						  input [7:0] BUS_ADDR,
						  inout [7:0] BUS_DATA,
						  output [7:0] DecOut,
						  output [3:0] Seg_Selcet
    );
	 

                            wire TrigOutFor2Bit;
                            wire TrigOutConnect;//to define the triggout signal of every conter
                            wire [3:0] ValueToShow0;
                            wire [3:0] ValueToShow1;
                            wire [3:0] ValueToShow2;
                            wire [3:0] ValueToShow3;//to define the value to output 
                            wire [3:0] FinalOut;
                            wire [1:0] Select;
                            reg [7:0] BusValue;

                            always@(posedge CLK)
                            begin
                                if(BUS_ADDR==8'hF0)
                                    BusValue<=BUS_DATA;
                                else
                                    BusValue<=BusValue;
                            end
                            
                            
                            assign ValueToShow0=BusValue%10;
                            assign ValueToShow1=BusValue%100;
                            assign ValueToShow2=1'b0;
                            assign ValueToShow3=1'b0;
						
                            //the 2bit counter
                            CounterModule #(.Counter_Max(4),
                                            .Counter_Width(2)
                            
                                            )
                                            Counter2Bit(	  .CLK(TrigOutConnect),
                                                              .Reset(Reset),
                                                              .Enable_In(1'b1),
                                                              .Trig_Out(TrigOutFor2Bit),
                                                              .Count(Select)
                                                   );
                            
                                            
                            
                            
                            //now to define the 4-way multiplixer
                            Multi4Way  Mul4(       .Control(Select),
                                                   .In0(ValueToShow0),
                                                  .In1(ValueToShow1),
                                                  .In2(ValueToShow2),
                                                  .In3(ValueToShow3),
                                                  .Out(FinalOut)
                                                  );
                            
                            
                            //now to define the part related to the 7-segment code
                            Decode seg7(
                                         .ChooseIn(Select),
                                             .Num_Binary(FinalOut[3:0]),
                                             .Dot(1'b0),
                                             .Out(DecOut),
                                             .ChooseOut(Seg_Selcet)
                                          );









endmodule
