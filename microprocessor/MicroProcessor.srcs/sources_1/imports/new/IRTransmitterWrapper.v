`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     University of Edinburgh
// Engineer:    Theo Scott
// 
// Create Date: 16.02.2016 12:41:15
// Design Name: IR Transmitter
// Module Name: IRTransmitterWrapper
// Project Name: Digital Systems Lab
// Target Devices: Digilent Basys3
// Tool Versions: Vivado 2015.2
// Description: Wrapper file to instantiate submodules and connect them together
// 
// Dependencies: GenericCounter.v
//               IRTransmitterSM.v
//               Mux4Way.v
//               Seg7Decoder.v
// 
// Revision: 
// Revision 1.0 - Completed and tested
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IRTransmitterWrapper(
    input CLK,
    input RESET,
    inout [7:0] BUS_DATA,
    input [7:0] BUS_ADDR,
    output reg [3:0] CAR_SELECT_OUT,  
    output reg IR_LED
    );

//Current command and car selection
    reg [3:0] COMMAND;
    reg [3:0] CAR_SELECT;
    always@(RESET) begin
        COMMAND = 4'b0101; 
        CAR_SELECT = 4'b0100; //YELLOW init
    end
//Connections to bus
    //IR transmitter base address defined on course doc
    parameter BASE_ADDR = 8'h90;
    //wire to read new data when IR address is on address bus
    wire ADDR_ENABLE;
    assign ADDR_ENABLE = (BUS_ADDR == BASE_ADDR) ? 1'b1 : 1'b0;
    //read in new command if ADDR_ENABLE true, else stop car
//    always@(posedge CLK) begin
        
//        if(ADDR_ENABLE) begin
//            CAR_SELECT = 4'b0100;
//            CAR_SELECT_OUT <= CAR_SELECT;
//            COMMAND = BUS_DATA[7:4];
//        end
//        else begin
//            COMMAND = 4'b0000;
//            CAR_SELECT = 4'b0000;
//            CAR_SELECT_OUT <= 4'b0000;
//        end
//    end
    
    
//Instantiations of counters to generate 10Hz trigger for each colour code of car    

    //generic counter configured to trigger packet sending for blue-coded car at 10Hz
    wire SEND_PACKET_BLU;
    GenericCounter #(.COUNTER_WIDTH(24), .COUNTER_MAX(10000000)) 
        TEN_CLK_COUNT_BLU(.CLK(CLK), .RESET(RESET), .ENABLE_IN(CAR_SELECT[0]), .TRIGG_OUT(SEND_PACKET_BLU), .COUNT());
   
    //generic counter configured to trigger packet sending for yellow-coded car at 10Hz
    wire SEND_PACKET_YEL;
    GenericCounter #(.COUNTER_WIDTH(24), .COUNTER_MAX(10000000)) 
        TEN_CLK_COUNT_YEL(.CLK(CLK), .RESET(RESET), .ENABLE_IN(CAR_SELECT[1]), .TRIGG_OUT(SEND_PACKET_YEL), .COUNT());
   
    //generic counter configured to trigger packet sending for green-coded car at 10Hz
    wire SEND_PACKET_GRN;
    GenericCounter #(.COUNTER_WIDTH(24), .COUNTER_MAX(10000000)) 
        TEN_CLK_COUNT_GRN(.CLK(CLK), .RESET(RESET), .ENABLE_IN(CAR_SELECT[2]), .TRIGG_OUT(SEND_PACKET_GRN), .COUNT());
   
    //generic counter configured to trigger packet sending for red-coded car at 10Hz
    wire SEND_PACKET_RED;
    GenericCounter #(.COUNTER_WIDTH(24), .COUNTER_MAX(10000000)) 
        TEN_CLK_COUNT_RED(.CLK(CLK), .RESET(RESET), .ENABLE_IN(CAR_SELECT[3]), .TRIGG_OUT(SEND_PACKET_RED), .COUNT());

 //Instantiations of each colour code of car
    
    //instantiates module for blue coded car
    wire IR_LED_BLU;
    IRTransmitterSM #(.StartBurstSize(191), .GapSize(25), .CarSelectBurstSize(47), .AssertBurstSize(47), .DeassertBurstSize(22), .MaxCount(1389))
        BlueCar(.CLK(CLK), .RESET(RESET), .COMMAND(COMMAND), .SEND_PACKET(SEND_PACKET_BLU), .IR_LED(IR_LED_BLU));
        
    //instantiates module for yellow coded car
    wire IR_LED_YEL;
    IRTransmitterSM #(.StartBurstSize(88), .GapSize(40), .CarSelectBurstSize(22), .AssertBurstSize(44), .DeassertBurstSize(22), .MaxCount(1250))
        YellowCar(.CLK(CLK), .RESET(RESET), .COMMAND(COMMAND), .SEND_PACKET(SEND_PACKET_YEL), .IR_LED(IR_LED_YEL));
        
    //instantiates module for green coded car
    wire IR_LED_GRN;
    IRTransmitterSM #(.StartBurstSize(88), .GapSize(40), .CarSelectBurstSize(44), .AssertBurstSize(44), .DeassertBurstSize(22), .MaxCount(1333))
        GreenCar(.CLK(CLK), .RESET(RESET), .COMMAND(COMMAND), .SEND_PACKET(SEND_PACKET_GRN), .IR_LED(IR_LED_GRN));
        
    //instantiates module for red coded car
    wire IR_LED_RED;
    IRTransmitterSM #(.StartBurstSize(192), .GapSize(24), .CarSelectBurstSize(24), .AssertBurstSize(48), .DeassertBurstSize(24), .MaxCount(1389))
        RedCar(.CLK(CLK), .RESET(RESET), .COMMAND(COMMAND), .SEND_PACKET(SEND_PACKET_RED), .IR_LED(IR_LED_RED));
    
    
    
//Output assignments

    // sets IR_LED to colour code wire based on input switches
    always@(CAR_SELECT) begin
        if(CAR_SELECT[0]) begin
            IR_LED <= IR_LED_BLU;
        end
        else if(CAR_SELECT[1]) begin
            IR_LED <= IR_LED_YEL;
        end
        else if(CAR_SELECT[2]) begin
            IR_LED <= IR_LED_GRN;
        end
        else if(CAR_SELECT[3]) begin
            IR_LED <= IR_LED_RED;
        end
        else begin
            IR_LED <= 0;
        end
    end
    
    
endmodule
