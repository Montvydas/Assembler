/**
 * Created by Monte (Montvydas Klumbys) on 11/3/16, The University of Edinburgh
 * This is an Assembler code for 8 bit microprocessor 
 */

import java.io.*;
import java.util.*;

import javax.sound.midi.SysexMessage;

public class TranslatorMain {

	static int lineNr = 0;                  
	static String data = new String ();     //data line to be read from the file
	static boolean containsErrors = false;  //error flag
    
    static String addressOfTimerISR = "11111110";
    static String addressOfMouseISR = "11111111";
    
    static boolean timerIntUsed = false;
    static boolean mouseIntUsed = false;   //to make sure they were only used once
    
    static String instructionAddressInHex = "00";  //instruction addr in hex
    
    static Map<String, String> functionTag = new HashMap<String, String>();
    
    public static void main(String args[]) {
        try {
            
          // get the user file
          Scanner sc = new Scanner (new File (args[0]));
//          Scanner sc = new Scanner (new File ("jump_instructions.txt"));
          
            // output file
//            File outputFile = new File("jump_results.txt");
            File outputFile = new File(args[1]);
            FileWriter fw = new FileWriter(outputFile);
            
            boolean blockCommented = false;         //for detecting block comments
            int instructionAddress = 0;             //store the instruction address to be performed
            
            
            
      //Start line scanning
            while (sc.hasNextLine()){	            //scan all of the file
            	lineNr++;
            	
                String tmp = sc.nextLine();
                //print line with a line number
                System.out.println(lineNr + " " + tmp);
                
                
                //take away block comments... Detect a block comment
                if (tmp.contains("/*")){
                	blockCommented = true;
                }
                
                //while not find another side of the comment, search through each line
                if (blockCommented){
                	if (tmp.contains("*/")){
                		blockCommented = false;
                		continue;
                	}
                	else { //make sure that if another side does not exist, print error
                		if (!sc.hasNextLine()){
                			System.err.println("Please close block comment!");
                			sc.close();
                			fw.close();
                			return ;
                		} else
                			continue;
                	}
                }
                
                //clean code from line comments
                if (tmp.contains("//"))
                	tmp = tmp.substring(0, tmp.indexOf("//") );
                
                tmp = tmp.replaceAll("\\s+"," ");   //replace all possible tabs, spaces & new lines in series, etc. with a single space
                
                //just in case check for empty lines
                if ( tmp.replaceAll("\\s+","").isEmpty() )
                	continue;
                else data = tmp.trim();		//take away spaces at the beginning and ending
                	
                String [] storedCode = data.split(" "); //split at spaces
                
                // System.out.println ("Length is " + storedCode.length);  
                
                String valueToSend = new String();  //value to be written to file
                int instructionLengthInBytes = 0;   //instructions have different lengths, update that
               
                switch (storedCode[0].toUpperCase()){   //allow both upper and lower cases
                	//load a 43
                	//load b 33
                    case "LOAD":
                        checkNumberOfOperands (storedCode.length, 3);                  //check that only 3 arguments entered
                    	valueToSend = checkWhichOperand (storedCode[1], "00000000", "00000001");    //check if reg A or reg B is used 
                    	valueToSend += hexToBi(storedCode[2]) + "\n";                   //address to hex value
                        instructionLengthInBytes = 2;                                   //update instruc length
                    break;
                    
                    //store 32 a
                    //store 52 b
                    case "STORE":
                        checkNumberOfOperands (storedCode.length, 3);
                    	valueToSend =  checkWhichOperand (storedCode[2], "00000010", "00000011");
                    	valueToSend += hexToBi(storedCode[1]) + "\n";
                        instructionLengthInBytes = 2;
                    break;
                    
                    //breq 52
                    case "BREQ":
                        checkNumberOfOperands (storedCode.length, 2);
                    	valueToSend = ("10010110" + '\n' + hexToBi(storedCode[1]) + '\n');
                        instructionLengthInBytes = 2;
                    break;
                    
                    //bgtq 35
                    case "BGTQ":
                        checkNumberOfOperands (storedCode.length, 2);
                    	valueToSend = ("10100110" + '\n' + hexToBi(storedCode[1]) + '\n');
                        instructionLengthInBytes = 2;
                    break;
                    
                    //bltq 45
                    case "BLTQ":
                        checkNumberOfOperands (storedCode.length, 2);
                    	valueToSend = ("10110110" + '\n' + hexToBi(storedCode[1]) + '\n');
                        instructionLengthInBytes = 2;
                    break;  
                     
                    //goto_idle
                    case "GOTO_IDLE":
                        checkNumberOfOperands (storedCode.length, 1);
                    	valueToSend = ("00001000" + '\n');
                        instructionLengthInBytes = 1;
                    break;
                    
                    //goto 43
                    case "GOTO":
                        checkNumberOfOperands (storedCode.length, 2);
                    	valueToSend = ("00000111" + '\n' + hexToBi(storedCode[1]) + '\n');
                        instructionLengthInBytes = 2;
                    break;
                    
                    //call 35
                    case "CALL":
                        checkNumberOfOperands (storedCode.length, 2);
                    	valueToSend = ("00001001" + '\n' + hexToBi(storedCode[1]) + '\n');
                        instructionLengthInBytes = 2;
                    break;
                    
                    //return
                    case "RETURN":
                        checkNumberOfOperands (storedCode.length, 1);
                    	valueToSend = ("00001010" + '\n');
                        instructionLengthInBytes = 1;
                    break; 
                    
                    //deref a
                    //deref b
                    case "DEREF":
                        checkNumberOfOperands (storedCode.length, 2);
                    	valueToSend = checkWhichOperand (storedCode[1], "00001011", "00001100");
                        instructionLengthInBytes = 1;
                    break;
                    
                    //add a b	//adds both and stores in a...
                    //add b a
                    case "ADD":
                        checkNumberOfOperands (storedCode.length, 3);   //check where the result will go to
                    	valueToSend = checkOperandOrder (storedCode[1], storedCode[2], "00000100", "00000101");
                        instructionLengthInBytes = 1;
                    break;
                    
                    //sub a b
                    //sub b a
                    case "SUB":
                        checkNumberOfOperands (storedCode.length, 3);
                    	valueToSend = checkOperandOrder (storedCode[1], storedCode[2], "00010100", "00010101");
                        instructionLengthInBytes = 1;
                    break; 
                    
                    //mult a b
                    //mult b a
                    case "MULT":
                        checkNumberOfOperands (storedCode.length, 3);
                    	valueToSend = checkOperandOrder (storedCode[1], storedCode[2], "00100100", "00100101");
                        instructionLengthInBytes = 1;
                    break;
                    
                    //s_l a
                    //s_l b
                    case "S_L":
                        checkNumberOfOperands (storedCode.length, 2);
                    	valueToSend = checkWhichOperand (storedCode[1], "00110100", "00110101");
                        instructionLengthInBytes = 1;
                    break;
                    
                    //s_r a
                    //s_r b
                    case "S_R":
                        checkNumberOfOperands (storedCode.length, 2);
                    	valueToSend = checkWhichOperand (storedCode[1], "01000100", "01000101");
                        instructionLengthInBytes = 1;
                    break;
                    
                    //incr a a	//incremends a and stores in a
                    //incr b a
                    case "INCR":
                        checkNumberOfOperands (storedCode.length, 3);
                    	if (storedCode[1].equalsIgnoreCase("A"))
                    		valueToSend = checkWhichOperand (storedCode[2], "01010100", "01100100");
                    	else if (storedCode[1].equalsIgnoreCase("B"))
                    		valueToSend = checkWhichOperand (storedCode[2], "01010101", "01100101");
                    	else printErrorLine();
                        instructionLengthInBytes = 1;
                    break; 
                    
                    //decr a b
                    //decr b b
                    case "DECR":
                        checkNumberOfOperands (storedCode.length, 3);
                    	if (storedCode[1].equalsIgnoreCase("A"))
                    		valueToSend = checkWhichOperand (storedCode[2], "01110100", "10000100");
                    	else if (storedCode[1].equalsIgnoreCase("B"))
                    		valueToSend = checkWhichOperand (storedCode[2], "01110101", "10000101");
                    	else printErrorLine();
                        instructionLengthInBytes = 1;
                    break;
                    
                    //equals a b
                    //equals b a
                    case "EQUALS":
                        checkNumberOfOperands (storedCode.length, 3);
                    	valueToSend = checkOperandOrder (storedCode[1], storedCode[2], "10010100", "10010101");
                        instructionLengthInBytes = 1;
                    break;
                    //greater a b
                    //greater b a
                    case "GREATER":
                        checkNumberOfOperands (storedCode.length, 3);
                    	valueToSend = checkOperandOrder (storedCode[1], storedCode[2], "10100100", "10100101");
                        instructionLengthInBytes = 1;
                    break;
                    
                    //less a b
                    //less b a
                    case "LESS":
                        checkNumberOfOperands (storedCode.length, 3);
                    	valueToSend = checkOperandOrder (storedCode[1], storedCode[2], "10110100", "10110101");
                        instructionLengthInBytes = 1;
                    break;
                    
                    //load_val a 32
                    //load_val b 01
                    //it is in the form of: to load into A reg - (xxxx1101 + value[7:0]), to B reg - (xxxx1101 + value[7:0])
                    case "LOAD_VAL":
                        checkNumberOfOperands (storedCode.length, 3);
                        valueToSend = checkWhichOperand (storedCode[1], "00001101", "00001110");
                        valueToSend += hexToBi(storedCode[2]) + "\n";
                        instructionLengthInBytes = 2;
                    break;
                    
                    default:  {
                        instructionLengthInBytes = 0;
                        checkNumberOfOperands (storedCode.length, 1);
                        if (containsErrors || !addFunctionToMap(storedCode[0])){
                        	printErrorLine();
                        	System.err.println("hint: use single word as a function name AND define functions only once");
                        }
//                    return;
                    }
                    break;
                }
                
                
                instructionAddress += instructionLengthInBytes; //gets the address
                if (instructionAddress > 253){  //make sure there is enough memory left for instructions
                    printErrorLine();
                    System.err.print("hint: you used more than allowed 253 Bytes of program ROM (254 is timer & 255 is mouse interrupt addr).\n");
                }
                
                if (containsErrors){    //if contains errors, end program
                	fw.write("Please fix your errors firstly.");
                	fw.close();
                	sc.close();
                	return;
                }
                
                fw.write(valueToSend);  //else print binary value to file
                
                instructionAddressInHex = Integer.toHexString( instructionAddress );    //good to know hex value
                if (instructionAddressInHex.length() == 1){                             //but need to make sure that it has two values as hex, i.e. C -> 0C
                    instructionAddressInHex = "0" + instructionAddressInHex;
                }
                
                System.out.print( "\n" + valueToSend + "XXXXXXXX <- This Instruction address is " + instructionAddressInHex + "\n\n");//tells the location of instruction
            }
            
            if (addressOfTimerISR == "11111110"){ //0xFE
                // printErrorLine();
                System.err.print ("Error: You didn't specify where your timer interrupt begins.\n");
            	fw.close();
            	sc.close();
                return;
            }   
            
            
            if (instructionAddress < 254){  //fill in with zeroes places where no data exists
                while (instructionAddress < 254) {
                	instructionAddress ++;  
                    fw.write("00000000\n");
                }
                fw.write (addressOfTimerISR);   //specify timer & mouse ISR addresses
                fw.write (addressOfMouseISR);
            } else {
                printErrorLine();
                System.err.print("hint: you used more than allowed 253 Bytes of program ROM.\n");
            	fw.close();
            	sc.close();
                return;
            }
            
//     close stuff
            fw.close();
            sc.close();

        } catch (IOException e) {
            e.printStackTrace();
        }
        if (addressOfMouseISR == "11111111")
            System.out.println ("Warning: You didn't use mouse interrupt anywhere.\n");
            
        System.out.println("Finished without errors!");
        return ;
    }
    
    //to check which operand, regA or regB stores the resultant value 
    public static String checkOperandOrder (String op_1, String op_2, String code_1, String code_2){
    	if (op_1.equalsIgnoreCase("A") && op_2.equalsIgnoreCase("B"))
    		return code_1 + "\n";
    	else if (op_1.equalsIgnoreCase("B") && op_2.equalsIgnoreCase("A")){
    		return code_2 + "\n";
    	} else {
    		printErrorLine();
    		System.err.print ("hint: cannot find A or B.\n");
            return "";
    	}
    	
    }
    //to check if regA or regB is used to storing & loading values
    public static String checkWhichOperand (String op, String code_1, String code_2){
    	if (op.equalsIgnoreCase("A"))
    		return code_1 + "\n";
    	else if (op.equalsIgnoreCase("B")){
    		return code_2 + "\n";
    	} else {
    		printErrorLine();
    		System.err.print ("hint: cannot find A or B.\n");
            return "";
    	}
    	
    }
    
    //prints error if one exists
   public static void printErrorLine() {
	   System.err.print("Error line number: " + lineNr + "\nLine says: " + data + "\n");
	   containsErrors = true;
   }
   
   //checks the number of operands used for the instruction
   public static void checkNumberOfOperands (int length, int requiredLength){
        if (length != requiredLength){
            printErrorLine ();
            System.err.print ("hint: wrong number of operands in a line.\n");
            return;
        }
   }
   
   //checks length of hex and binary just in case
   public static void checkLengthOfHexAndBin (int binLength, int hexLength){
       if (binLength != 8 || hexLength != 2){
           printErrorLine();
           System.err.print ("hint: entered value is a not valid hex value.\n");
       }
   }
   
   //hext to binary function for strings
     public static String hexToBi (String hex){
        int i = Integer.parseInt(hex, 16);
        String bin = Integer.toBinaryString(i);
        
        if (bin.length() < 8)
            bin = String.format("%0" + (8-bin.length()) + "d", 0).replace("0", "0") + bin; //add zeroes at the begining
        
        // System.out.print ("In hexToBi: hex=" + hex + " bin=" + bin + "\n");
        
        checkLengthOfHexAndBin(bin.length(), hex.length());
        return bin;
     }
     
     public static boolean addFunctionToMap (String functionName){
         if ( functionName.endsWith(":")) {
                 //String str = storedCode[0];
                 //str = str.substring(0, str.length()-1);
                 functionName = functionName.substring (0, functionName.length()-1);    
                    
                 switch (functionName.toUpperCase()) { 
                        //also check if it was used only once in our program
                        //timer_isr:
                        case "TIMER_ISR":
                            if (timerIntUsed){
                                printErrorLine();
                                System.err.print ("hint: You can't you timer interrupts at multiple places");
                            }
                            // System.out.print ("\n" + instructionAddressInHex + "\n");
                            addressOfTimerISR = hexToBi( instructionAddressInHex ) + "\n";
                            timerIntUsed = true;
                        break;
                    
                        //mouse_isr:
                        case "MOUSE_ISR":
                            if (mouseIntUsed){
                                printErrorLine();
                                System.err.print ("hint: You can't you mouse interrupts at multiple places");
                            }
                            addressOfMouseISR = hexToBi( instructionAddressInHex ) + "\n";
                            mouseIntUsed = true;
                        break;
                    
                        default: {
                        	System.out.println("Found: " + functionName + " at addr: " + instructionAddressInHex);
                            if (!functionTag.containsKey(functionName))
                        		functionTag.put( functionName, hexToBi(instructionAddressInHex) );
                            else
                            	return false;
                        }
                    }
        }
         return true;
     }
}
