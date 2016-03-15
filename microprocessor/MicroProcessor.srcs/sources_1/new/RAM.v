`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.02.2016 09:17:43
// Design Name: 
// Module Name: RAM
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


module RAM(

        //standard signals
        input CLK,
        //bus signals
        inout [7:0] BUS_DATA,
        input [7:0] BUS_ADDR,
        input BUS_WE


    );
    
    //just for test
   
    
    parameter RAMBaseAddr =0;
    parameter RAMAddrWidth =7;
    
    //tristate
    wire [7:0] BufferedBusData;
    reg[7:0] Out;
    reg RAMBusWE;
    
    //on;y place data on the bus is the processor is not writing, and it is addressing this memory
    assign BUS_DATA =(RAMBusWE)? Out:8'hZZ;
    assign BufferedBusData = BUS_DATA;
    
    //Memory
    reg[7:0] Mem [2**RAMAddrWidth-1:0];
    
    
    
   initial $readmemh("/afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/microprocessor/Complete_Demo_RAM.txt", Mem);
    
       
    //single port ram
    
    always@(posedge CLK)
    begin
            //Brute-force RAM address decoding
            if((BUS_ADDR>=RAMBaseAddr)&(BUS_ADDR<RAMBaseAddr+128))begin
                if(BUS_WE)begin
                Mem[BUS_ADDR[6:0]]<=BufferedBusData;
                RAMBusWE<=1'b0;
                end else
                RAMBusWE<=1'b1;
             end else
                RAMBusWE<=1'b0;
             Out<=Mem[BUS_ADDR[6:0]];
             

     end
endmodule
