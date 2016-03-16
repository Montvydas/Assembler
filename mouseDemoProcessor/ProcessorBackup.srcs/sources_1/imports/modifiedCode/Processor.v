`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: Montvydas Klumbys
// 
// Create Date: 13.02.2016 19:40:10
// Design Name:    IR_MOUSE_CONTROLLED_CAR
// Module Name:    MicroProcessor 
// Project Name: IR_MOUSE_CONTROLLED_CAR
// Target Devices: basys3 board
// Tool versions:  vivado 16
// Description:    This is the code file of Microprocessor
//
// Dependencies:   Subroutine of top level file
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module MicroProcessor(
    //Standard signals
	 input        CLK,
    input        RESET,
    //BUS signals
	 inout  [7:0] BUS_DATA,
    output [7:0] BUS_ADDR,
    output       BUS_WE,
    //ROM signals
	 output [7:0] ROM_ADDRESS,
    input  [7:0] ROM_DATA,
    //Interrupt signals
	 input  [1:0] BUS_INTERRUPTS_RAISE,
    output [1:0] BUS_INTERRUPTS_ACK,
    output [7:0] registerA,
    output [7:0] registerB
);



//The main data bus is treated as tristate, so we need a mechanism to handle this.
//Tristate signals that interface with the main state machine
wire [7:0] BusDataIn;
reg  [7:0] CurrBusDataOut, NextBusDataOut;
reg        CurrBusDataOutWE, NextBusDataOutWE;

//Tristate Mechanism
assign BusDataIn = BUS_DATA;
assign BUS_DATA  = CurrBusDataOutWE ? CurrBusDataOut : 8'hZZ;
assign BUS_WE    = CurrBusDataOutWE;

//Address of the bus
reg [7:0] CurrBusAddr, NextBusAddr;
assign BUS_ADDR = CurrBusAddr;

//The processor has two internal registers to hold data between operations, and a third to hold
//the current program context when using function calls.
reg [7:0] CurrRegA, NextRegA;
reg [7:0] CurrRegB, NextRegB;
reg       CurrRegSelect, NextRegSelect;
reg [7:0] CurrProgContext, NextProgContext;

assign registerA = CurrRegA;
assign registerB = CurrRegB;

//Dedicated Interrupt output lines - one for each interrupt line
reg [1:0] CurrInterruptAck, NextInterruptAck;
assign BUS_INTERRUPTS_ACK = CurrInterruptAck;

//Instantiate program memory here.
//There is a program counter which points to the current operation. The program counter
//has an offset that is used to reference information that is part of the current operation.
reg  [7:0] CurrProgCounter, NextProgCounter;
reg  [1:0] CurrProgCounterOffset, NextProgCounterOffset;
wire [7:0] ProgMemoryOut;
wire [7:0] ActualAddress;
assign ActualAddress = CurrProgCounter + CurrProgCounterOffset;
// ROM signals
assign ROM_ADDRESS   = ActualAddress;
assign ProgMemoryOut = ROM_DATA;

//Instantiate the ALU
//The processor has an integrated ALU that can do several different operations
wire [7:0] AluOut;
ALU ALU0(
			//standard signals
			.CLK(CLK),
			.RESET(RESET),
			//I/O
			.IN_A(CurrRegA),
			.IN_B(CurrRegB),
//			.IN_OPP_TYPE(ProgMemoryOut[7:4]),
			.ALU_Op_Code(ProgMemoryOut[7:4]),
			.OUT_RESULT(AluOut)
			);

//The microprocessor is essentially a state machine, with one sequential pipeline
//of states for each operation.
//The current list of operations is:
// 0: Read from memory to A
// 1: Read from memory to B
// 2: Write to memory from A
// 3: Write to memory from B
// 4: Do maths with the ALU, and save result in reg A
// 5: Do maths with the ALU, and save result in reg B
// 6: if A (== or < or > B) GoTo ADDR
// 7: Goto ADDR
// 8: Go to IDLE
// 9: End thread, goto idle state and wait for interrupt.
// 10: Function call
// 11: Return from function call
// 12: Dereference A
// 13: Dereference B

//Program thread selection
parameter [7:0] IDLE                    = 8'hF0; //Waits here until an interrupt wakes up the processor.
parameter [7:0] GET_THREAD_START_ADDR_0 = 8'hF1; //Wait.
parameter [7:0] GET_THREAD_START_ADDR_1 = 8'hF2; //Apply the new address to the program counter.
parameter [7:0] GET_THREAD_START_ADDR_2 = 8'hF3; //Wait. Goto ChooseOp.

//Operation selection
//Depending on the value of ProgMemOut, goto one of the instruction start states.
parameter [7:0] CHOOSE_OPP              = 8'h00;

//Data Flow
parameter [7:0] READ_FROM_MEM_TO_A      = 8'h10; //Wait to find what address to read, save reg select.
parameter [7:0] READ_FROM_MEM_TO_B      = 8'h11; //Wait to find what address to read, save reg select.
parameter [7:0] READ_FROM_MEM_0         = 8'h12; //Set BUS_ADDR to designated address.
parameter [7:0] READ_FROM_MEM_1         = 8'h13; //wait - Increments program counter by 2. Reset offset.
parameter [7:0] READ_FROM_MEM_2 			= 8'h14; //Writes memory output to chosen register, end op.

//writing to memory
parameter [7:0] WRITE_TO_MEM_FROM_A 	 	= 8'h20; //Reads Op+1 to find what address to Write to.
parameter [7:0] WRITE_TO_MEM_FROM_B 	 	= 8'h21; //Reads Op+1 to find what address to Write to.
parameter [7:0] WRITE_TO_MEM_0 			= 8'h22; //wait - Increments program counter by 2. Reset offset.

//Data Manipulation
parameter [7:0] DO_MATHS_OPP_SAVE_IN_A  	= 8'h30; //The result of maths op. is available, save it to Reg A.
parameter [7:0] DO_MATHS_OPP_SAVE_IN_B  	= 8'h31; //The result of maths op. is available, save it to Reg B.
parameter [7:0] DO_MATHS_OPP_0 			= 8'h32; //wait for new op address to settle. end op.

//Jump Operations
parameter [7:0] IF_A_EQUALITY_B_GOTO    			= 8'h40; //	goto a specific address
parameter [7:0] IF_A_EQUALITY_B_GOTO_EQUALS    	= 8'h41;
parameter [7:0] IF_A_EQUALITY_B_GOTO_GREATER    	= 8'h42;
parameter [7:0] IF_A_EQUALITY_B_GOTO_LESS  		= 8'h43;
parameter [7:0] IF_A_EQUALITY_B_GOTO_FINISH 	   	= 8'h44;

//goto to a spec addr
parameter [7:0] GOTO_ADDR             	= 8'h50; //	also branch equal
parameter [7:0] GOTO_ADDR_0             	= 8'h51;
parameter [7:0] GOTO_ADDR_FINISH        	= 8'h52;

parameter [7:0] GOTO_IDLE          		= 8'h60;

//Function call and return
parameter [7:0] FUNCTION_START  			= 8'h70; //call instruction performed using this step
parameter [7:0] FUNCTION_START_0  		= 8'h71;
parameter [7:0] FUNCTION_START_FINISH  	= 8'h72;

parameter [7:0] RETURN          			= 8'h80; //return instr using step this
parameter [7:0] RETURN_FINISH   			= 8'h80;

//deref A or B
parameter [7:0] DE_REFERENCE_A  = 8'h90;  //used for different steps while performing 
parameter [7:0] DE_REFERENCE_B  = 8'h91; //dereference operatio
parameter [7:0] DE_REFERENCE_0  = 8'h92; 
parameter [7:0] DE_REFERENCE_1  = 8'h93; 
parameter [7:0] DE_REFERENCE_2  = 8'h94;

parameter  	LOAD_VAL_A 			= 	8'hA0;	//load val instruction is performed using this
parameter 	LOAD_VAL_A_0			= 	8'hA1;
parameter 	LOAD_VAL_B 			= 	8'hA2;
parameter 	LOAD_VAL_B_0			=	8'hA3;
parameter	LOAD_VAL_FINISH		= 	8'hA4;

//Sequential part of the State Machine.
reg [7:0] CurrState, NextState;

always @(posedge CLK) begin
	if(RESET) begin
		CurrState 				= 8'h00;
		CurrProgCounter 		 	= 8'h00;
		CurrProgCounterOffset 	= 2'h0;
		CurrBusAddr 			 	= 8'hFF; //Initial instruction after reset.
		CurrBusDataOut 		 	= 8'h00;
		CurrBusDataOutWE 		= 1'b0;
		CurrRegA 			 	= 8'h00;
		CurrRegB 			 	= 8'h00;
		CurrRegSelect 			= 1'b0;
		CurrProgContext 		 	= 8'h00;
		CurrInterruptAck 		= 2'b00;
	end
	else begin
		CurrState 				= NextState;
		CurrProgCounter 		 	= NextProgCounter;
		CurrProgCounterOffset 	= NextProgCounterOffset;
		CurrBusAddr 			 	= NextBusAddr;
		CurrBusDataOut 		 	= NextBusDataOut;
		CurrBusDataOutWE 		= NextBusDataOutWE;
		CurrRegA 				= NextRegA;
		CurrRegB 				= NextRegB;
		CurrRegSelect 			= NextRegSelect;
		CurrProgContext 		 	= NextProgContext;
		CurrInterruptAck 		= NextInterruptAck;
	end
end

//Combinatorial section
always @* begin
//Generic assignment to reduce the complexity of the rest of the S/M
		NextState 				= CurrState;
		NextProgCounter 		 	= CurrProgCounter;
		NextProgCounterOffset 	= 2'h0;
		NextBusAddr 			 	= 8'hFF;
		NextBusDataOut 		 	= CurrBusDataOut;
		NextBusDataOutWE 		= 1'b0;
		NextRegA 				= CurrRegA;
		NextRegB					= CurrRegB;
		NextRegSelect 			= CurrRegSelect;
		NextProgContext 		 	= CurrProgContext;
		NextInterruptAck		 	= 2'b00;

//Case statement to describe each state
case (CurrState)
	//Thread states.
	IDLE:
			begin
				if(BUS_INTERRUPTS_RAISE[0]) begin // Interrupt Request A.
					NextState = GET_THREAD_START_ADDR_0;
					NextProgCounter = 8'hFF;
					NextInterruptAck = 2'b01;
				end
				else if(BUS_INTERRUPTS_RAISE[1]) begin //Interrupt Request B.
					NextState = GET_THREAD_START_ADDR_0;
					NextProgCounter = 8'hFE;
					NextInterruptAck = 2'b10;
				end
				else begin
					NextState = IDLE;
					NextProgCounter = 8'hFF; //Nothing has happened.
					NextInterruptAck = 2'b00;
				end
			end

	//Wait state - for new prog address to arrive.
	GET_THREAD_START_ADDR_0:
			begin
					NextState = GET_THREAD_START_ADDR_1;
			end

	//Assign the new program counter value
	GET_THREAD_START_ADDR_1:
			begin
					NextState = GET_THREAD_START_ADDR_2;
					NextProgCounter = ProgMemoryOut;
			end

	//Wait for the new program counter value to settle
	GET_THREAD_START_ADDR_2:
					NextState = CHOOSE_OPP;

	//////////////////////////////////////////////////////////////////////////////////
	//CHOOSE_OPP - Another case statement to choose which operation to perform
	CHOOSE_OPP:
			begin
				case (ProgMemoryOut[3:0])
					4'h0: NextState = READ_FROM_MEM_TO_A;
					4'h1: NextState = READ_FROM_MEM_TO_B;
					4'h2: NextState = WRITE_TO_MEM_FROM_A;
					4'h3: NextState = WRITE_TO_MEM_FROM_B;
					4'h4: NextState = DO_MATHS_OPP_SAVE_IN_A;
					4'h5: NextState = DO_MATHS_OPP_SAVE_IN_B;
					4'h6: NextState = IF_A_EQUALITY_B_GOTO;
					4'h7: NextState = GOTO_ADDR;
					4'h8: NextState = GOTO_IDLE;
					4'h9: NextState = FUNCTION_START;
					4'hA: NextState = RETURN;
					4'hB: NextState = DE_REFERENCE_A;
					4'hC: NextState = DE_REFERENCE_B;
                    4'hD: NextState = LOAD_VAL_A;
                    4'hE: NextState = LOAD_VAL_B;
					default:
							NextState = CurrState;
				endcase
					NextProgCounterOffset = 2'h1;
			end

	//////////////////////////////////////////////////////////////////////////////////
	//READ_FROM_MEM_TO_A : here starts the memory read operational pipeline.
	//Wait state - to give time for the mem address to be read. Reg select is set to 0
	READ_FROM_MEM_TO_A:
			begin
					NextState 	  = READ_FROM_MEM_0;
					NextRegSelect = 1'b0;
			end

	//READ_FROM_MEM_TO_B : here starts the memory read operational pipeline.
	//Wait state - to give time for the mem address to be read. Reg select is set to 1
	READ_FROM_MEM_TO_B:
			begin
					NextState     = READ_FROM_MEM_0;
					NextRegSelect = 1'b1;
			end

	//The address will be valid during this state, so set the BUS_ADDR to this value.
	READ_FROM_MEM_0:
			begin
					NextState   = READ_FROM_MEM_1;
					NextBusAddr = ProgMemoryOut;
			end

	//Wait state - to give time for the mem data to be read
	//Increment the program counter here. This must be done 2 clock cycles ahead
	//so that it presents the right data when required.
	READ_FROM_MEM_1:
			begin
					NextState       = READ_FROM_MEM_2;
					NextProgCounter = CurrProgCounter + 2;
			end

	//The data will now have arrived from memory. Write it to the proper register.
	READ_FROM_MEM_2:
			begin
					NextState = CHOOSE_OPP;
				if(!CurrRegSelect)
					NextRegA = BusDataIn;
				else
					NextRegB = BusDataIn;
			end
	
	//////////////////////////////////////////////////////////////////////////////////
	//WRITE_TO_MEM_FROM_A : here starts the memory write operational pipeline.
	//Wait state - to find the address of where we are writing
	//Increment the program counter here. This must be done 2 clock cycles ahead
	//so that it presents the right data when required.
	WRITE_TO_MEM_FROM_A:
			begin
					NextState       = WRITE_TO_MEM_0;
					NextRegSelect   = 1'b0;
					NextProgCounter = CurrProgCounter + 2;
			end

	//WRITE_TO_MEM_FROM_B : here starts the memory write operational pipeline.
	//Wait state - to find the address of where we are writing
	//Increment the program counter here. This must be done 2 clock cycles ahead
	// so that it presents the right data when required.
	WRITE_TO_MEM_FROM_B:
			begin
					NextState       = WRITE_TO_MEM_0;
					NextRegSelect   = 1'b1;
					NextProgCounter = CurrProgCounter + 2;
			end

	//The address will be valid during this state, so set the BUS_ADDR to this value,
	//and write the value to the memory location.
	WRITE_TO_MEM_0:
			begin
					NextState        = CHOOSE_OPP;
					NextBusAddr      = ProgMemoryOut;
//				if(!NextRegSelect)
				if(!CurrRegSelect)
					NextBusDataOut   = CurrRegA;
				else begin
					NextBusDataOut   = CurrRegB;
				end
					NextBusDataOutWE = 1'b1;
			end

	//////////////////////////////////////////////////////////////////////////////////
	//DO_MATHS_OPP_SAVE_IN_A : here starts the DoMaths operational pipeline.
	//Reg A and Reg B must already be set to the desired values. The MSBs of the
	// Operation type determines the maths operation type. At this stage the result is
	// ready to be collected from the ALU.
	DO_MATHS_OPP_SAVE_IN_A:
			begin
					NextState       = DO_MATHS_OPP_0;
					NextRegA        = AluOut;
					NextProgCounter = CurrProgCounter + 1;
			end

	//DO_MATHS_OPP_SAVE_IN_B : here starts the DoMaths operational pipeline
	//when the result will go into reg B.
	DO_MATHS_OPP_SAVE_IN_B:
			begin
					NextState       = DO_MATHS_OPP_0;
					NextRegB        = AluOut;
					NextProgCounter = CurrProgCounter + 1;
			end

	//Wait state for new prog address to settle.
	DO_MATHS_OPP_0:
					NextState = CHOOSE_OPP;


/*
Complete the above case statement for In/Equality, Goto Address, Goto Idle, function start, Return from
function, and Dereference operations.
*/
//branch if equal in here BREQ
//Check for equality
                //IF_A_EQUALITY_B_GOTO: here start the jump operation, the following achieve the function 
                //that when A==B or A>B, then jump to the address stored in the memory
                //the first state of this operation is to wait a clk time unitl the address can be read from the memory
                        IF_A_EQUALITY_B_GOTO:begin
                            if(ProgMemoryOut[7:4]==4'b1001)
                                NextState=IF_A_EQUALITY_B_GOTO_EQUALS;
                            
                            if(ProgMemoryOut[7:4]==4'b1010)
                                NextState=IF_A_EQUALITY_B_GOTO_GREATER;
  
                           
                            if(ProgMemoryOut[7:4]==4'b1011)
                                NextState=IF_A_EQUALITY_B_GOTO_LESS; 

                            
                        end
                      
                //then the next state is according to the address read from the memory, jump to it, that is, next program counter value is that
                
                        IF_A_EQUALITY_B_GOTO_EQUALS:begin
                            if(CurrRegA==CurrRegB)
                                NextProgCounter=ProgMemoryOut;
                            else
                                NextProgCounter=CurrProgCounter+2;
                            
                            NextState=IF_A_EQUALITY_B_GOTO_FINISH;
                        end
                        
                        
                         IF_A_EQUALITY_B_GOTO_GREATER:begin
                           if(CurrRegA>CurrRegB)
                               NextProgCounter=ProgMemoryOut;
                           else
                               NextProgCounter=CurrProgCounter+2;
                               
                           NextState=IF_A_EQUALITY_B_GOTO_FINISH;
                         end
                        
                        
                         IF_A_EQUALITY_B_GOTO_LESS:begin
                            if(CurrRegA<CurrRegB)
                                NextProgCounter=ProgMemoryOut;
                            else
                                NextProgCounter=CurrProgCounter+2;
                                
                            NextState=IF_A_EQUALITY_B_GOTO_FINISH;
                         end
                        
                        
                        IF_A_EQUALITY_B_GOTO_FINISH:begin
                             NextState = CHOOSE_OPP;
                        end                
                  
                  //Jump op in here
                        GOTO_ADDR: begin
                            NextState=GOTO_ADDR_0;
                        end
                        
                        GOTO_ADDR_0:begin
                            NextProgCounter=ProgMemoryOut;
                            NextState=GOTO_ADDR_FINISH;
                        end
                        
                        GOTO_ADDR_FINISH:NextState = CHOOSE_OPP;


//go back to idle
	GOTO_IDLE:
			begin
			
					NextState = IDLE;	//go to idle
			end

                  //the next module is to achieve the function_call, it has the similiar function with the jump, but a difference
                  //is that I need to store the next program address so that when function return I can go on from this address
                  //first step is to wait unitl the address is read from the ROM
                  
                         FUNCTION_START: begin
                            NextState=FUNCTION_START_0;
                         end
                         
                         FUNCTION_START_0:begin
                            NextProgCounter=ProgMemoryOut;
                            NextProgContext=CurrProgCounter+2;
                            NextState=FUNCTION_START_FINISH;
                         end
                         
                         FUNCTION_START_FINISH:NextState = CHOOSE_OPP;
                         
                  //the next module is to achieve the function return, it has the similiar function with the jump
                  //no wait status, but just let the program counter to be the stored vale
                         RETURN:begin
                             NextState=RETURN_FINISH;
                             NextProgCounter=CurrProgContext;
                         end
                         
                         RETURN_FINISH:NextState = CHOOSE_OPP;
// DEREFERENCE operation A<-[A]
//get the value stored in the address of the value stored in A
	DE_REFERENCE_A:
			begin
					NextState     = DE_REFERENCE_0;
					NextRegSelect = 1'b0;
			end

//dereference for B reg
//B <- [B]
	DE_REFERENCE_B:
			begin
					NextState     = DE_REFERENCE_0;
					NextRegSelect = 1'b1;
			end

//next step for dere
	DE_REFERENCE_0:
			begin
					NextState   = DE_REFERENCE_1;
				if(!CurrRegSelect)
					NextBusAddr = CurrRegA;
				else
					NextBusAddr = CurrRegB;
			end

	DE_REFERENCE_1:
			begin
					NextState       = DE_REFERENCE_2;
					NextProgCounter = CurrProgCounter + 1;
			end

	DE_REFERENCE_2:
			begin
					NextState = CHOOSE_OPP;
				if(!CurrRegSelect)
					NextRegA  = BusDataIn;
				else
					NextRegB  = BusDataIn;
			end
			
//Loads a constant value defined in ROM to a specified reg A or reg B
	LOAD_VAL_A: begin
		NextState = LOAD_VAL_A_0;
		end
	LOAD_VAL_A_0: begin
		NextState = LOAD_VAL_FINISH;
		NextProgCounter = CurrProgCounter + 2;
		NextRegA = ProgMemoryOut;
	end
					
//Here loads value to a reg B					
	LOAD_VAL_B: begin
		NextState = LOAD_VAL_B_0;
	end
	LOAD_VAL_B_0: begin
		NextState = LOAD_VAL_FINISH;
		NextProgCounter = CurrProgCounter + 2;
		NextRegB = ProgMemoryOut;
	end
	LOAD_VAL_FINISH: begin
		NextState = CHOOSE_OPP;
	end

	default:
			begin
					NextRegA 			 	= 8'h00;//Specify default values for all the regs
					NextRegB 			 	= 8'h00;
					NextProgContext 		 	= 8'h00;
					NextInterruptAck 		= 2'b00;
					NextState 				= IDLE;
					NextRegSelect 			= 1'b0;
					NextProgCounter 		 	= 8'h00;
					NextProgCounterOffset 	= 2'h0;
					NextBusDataOut 		 	= 8'h00;
					NextBusAddr 			 	= 8'hFF;
					NextBusDataOutWE 		= 1'b0;

			end

//////////////////////////////////////////////////////////////////////////////////

endcase
end

endmodule
