`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2016 19:41:17
// Design Name: 
// Module Name: Seg7Wrapper
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


module Seg7Wrapper(
    input CLK,
    input RESET,
    input [3:0] CAR_SELECT,
    inout [7:0] BUS_DATA,
    input [7:0] BUS_ADDR,
    input BUS_WE,
    output [3:0] SEG_SELECT_OUT,
    output [7:0] DEC_OUT
    );
    
    //wire to hold which section of the 7 seg to display on
    wire [1:0] SegWire;
    //register holding the "word" to be displayed on 7 segment display, stored in hex
    reg [15:0] MuxIn;
    //wire to transmit the required letter for the section of the 7 segment display
    wire [3:0] MuxOut;
    
    // Divider to output 200Hz clock on StrobeTrig
    wire StrobeTrig;
    GenericCounter #(.COUNTER_WIDTH(24), .COUNTER_MAX(500000))
        mySeg7Divider(.CLK(CLK), .RESET(RESET), .ENABLE_IN(1), .TRIGG_OUT(StrobeTrig), .COUNT());
    
    // Strobes between 4 sections of display giving 50Hz refresh per section
    GenericCounter #(.COUNTER_WIDTH(2), .COUNTER_MAX(3)) 
        mySeg7Strobe(.CLK(CLK), .RESET(RESET), .ENABLE_IN(StrobeTrig), .COUNT(SegWire));
   
    // 4 way mux to select which 7seg display is active and selects correct letter to display
    Mux4Way 
       myMux(.CONTROL(SegWire), .IN0(MuxIn[15:12]), .IN1(MuxIn[11:8]), .IN2(MuxIn[7:4]), .IN3(MuxIn[3:0]), .OUT(MuxOut));
    
    // 7-segment decoder to translate from hex value of a letter to the segments required to be lit
    Seg7Decoder 
       mySeg7(
                       .SEG_SELECT_IN(SegWire), 
                       .BIN_IN(MuxOut), 
                       .DOT_IN(1'b0), 
                       .SEG_SELECT_OUT(SEG_SELECT_OUT), 
                       .HEX_OUT(DEC_OUT)
                       );

    
    //Output assignments

    // sets IR_LED to colour code wire based on input switches
    // sets 7 segment display input based on input switches
    always@(CAR_SELECT) begin
        if(CAR_SELECT[0]) begin
            MuxIn <= 16'h3210; //"blue"
        end
        else if(CAR_SELECT[1]) begin
            MuxIn <= 16'hF134; // "yel "
        end
        else if(CAR_SELECT[2]) begin
            MuxIn <= 16'hF765; // "grn "
        end
        else if(CAR_SELECT[3]) begin
            MuxIn <= 16'hF836; // "red "
        end
        else begin
            MuxIn <= 16'hFFFF; // "    "
        end
    end
    

    
    
    
    
endmodule
