`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:59:44 10/17/2014 
// Design Name: 
// Module Name:    Multi4Way 
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
module Multi4Way(
    input [1:0] Control,
    input [3:0] In0,
    input [3:0] In1,
    input [3:0] In2,
    input [3:0] In3,
    output reg [3:0] Out
    );
	 
always@(Control or In0 or In1 or In2 or In3)
begin  
  case(Control)
  2'b 00:Out<=In0;
  2'b 01:Out<=In1;
  2'b 10:Out<=In2;
  2'b 11:Out<=In3;
  default :Out<=0000;
  endcase
end

endmodule
