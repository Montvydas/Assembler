/**
 * Created by Monte (Montvydas Klumbys) on 11/3/16, The University of Edinburgh
 * This is an Assembler code for 8 bit microprocessor 
 */

import java.io.*;
import java.util.*;

public class TranslatorMain {
	
	//constants defyning operations for machine code
    static final String LOAD_A_CODE 	= "00";
	static final String LOAD_B_CODE 	= "01";
	
	static final String STORE_A_CODE 	= "02";
	static final String STORE_B_CODE 	= "03";
	
    static final String BREQ_CODE 		= "96";
    static final String BGTQ_CODE 		= "A6";
    static final String BLTQ_CODE 		= "B6";
    static final String GOTO_IDLE_CODE 	= "08"; 
    static final String GOTO_CODE 		= "07";
    static final String CALL_CODE 		= "09";
    static final String RETURN_CODE 	= "0A";
    
	static final String DEREF_A_CODE 	= "0B";                    
    static final String DEREF_B_CODE 	= "0C";
    
    static final String ADD_A_CODE 		= "04";
    static final String ADD_B_CODE 		= "05";
    
    static final String SUB_A_CODE 		= "14";
    static final String SUB_B_CODE 		= "15";		

    
    static final String MULT_A_CODE 	= "24";
    static final String MULT_B_CODE 	= "25";
    
    static final String S_L_A_CODE 		= "34";
    static final String S_L_B_CODE 		= "35";
    
    static final String S_R_A_CODE 		= "44";  
    static final String S_R_B_CODE 		= "45";    
     
    static final String EQUALS_A_CODE 	= "94";  
    static final String EQUALS_B_CODE 	= "95";
    
    static final String GREATER_A_CODE 	= "A4";  
    static final String GREATER_B_CODE 	= "A5";     
    
    static final String LESS_A_CODE 	= "B4";  
    static final String LESS_B_CODE 	= "B5";
    
    static final String AND_A_CODE = "C4";
    static final String AND_B_CODE = "C5";
    
    static final String OR_A_CODE = "D4";
    static final String OR_B_CODE = "D5";    
    
    static final String XOR_A_CODE = "E4";
    static final String XOR_B_CODE = "E5";    

    static final String NOT_A_CODE = "F4";
    static final String NOT_B_CODE = "F5";
    
    static final String LOAD_VAL_A_CODE = "0D";
    static final String LOAD_VAL_B_CODE = "0E";
    		
	static final String INCR_A_A_CODE 	= "54";
    static final String INCR_A_B_CODE 	= "64";
    static final String INCR_B_B_CODE 	= "55";
    static final String INCR_B_A_CODE 	= "65";
    
    static final String DECR_A_A_CODE 	= "74";
    static final String DECR_A_B_CODE	= "84";
    static final String DECR_B_B_CODE 	= "75";
    static final String DECR_B_A_CODE 	= "85";
		
	static int lineNr = 0;                  
	static String data = new String ();     //data line to be read from the file
	static boolean containsErrors = false;  //error flag
    
    static String addressOfTimerISR = "FE";
    static String addressOfMouseISR = "FF";
    
    static boolean timerIntUsed = false;
    static boolean mouseIntUsed = false;   //to make sure they were only used once
    static boolean useBinNotHex = false;
    
    static String instructionAddressInHex = "00";  //instruction addr in hex
    
    static Map<String, String> functionTag = new HashMap<String, String>();	//Dictionary to store functions and their addresses
    static List<String> storedValues = new ArrayList<String>();				//list to store bin values to send to the file
    
    public static void main(String args[]) {
        try {
          String instructionFileName = new String();
          String resultFileName = new String();
          
          	if (args.length == 2) {				//check if enough arguments given
          		instructionFileName = args[0];
          		resultFileName = args[1];
          	} else if (args.length == 3) {		//check which format to give out. default is hex
          		instructionFileName = args[0];
          		resultFileName = args[1];
          		if (args[2].equals("bin") )
          			useBinNotHex = true;
          		else if (args[2].equals("hex") )
          			useBinNotHex = false;
          		else {
          			System.err.println("for hex use 'hex' & for binary use 'bin' as the third argument.");
          			return;
          		}
          	} else {
          		System.err.println("You didn't specify instructions.txt and/or results.txt!");
          		return;	
          	}
          
          	Scanner sc = new Scanner (new File (instructionFileName));

          	File outputFile = new File(resultFileName);
          	FileWriter fw = new FileWriter(outputFile);
            
            boolean blockCommented = false;         //for detecting block comments
            int previousStoredValueSize = 0; 
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

                switch (storedCode[0].toUpperCase()){   //allow both upper and lower cases
                	//load a 43
                	//load b 33
                    case "LOAD":
                        checkNumberOfOperands (storedCode.length, 3);                  //check that only 3 arguments entered
                        
                    	storedValues.add (checkWhichOperand (storedCode[1], LOAD_A_CODE, LOAD_B_CODE));
                    	storedValues.add(storedCode[2]);                                  //update instruc length
                    break;
                    
                    //store 32 a
                    //store 52 b
                    case "STORE":
                        checkNumberOfOperands (storedCode.length, 3);
                        storedValues.add(checkWhichOperand (storedCode[2], STORE_A_CODE, STORE_B_CODE )); // "00000010", "00000011"));
                    	storedValues.add(storedCode[1]);
                    break;
                    
                    //breq 52
                    case "BREQ":
                        checkNumberOfOperands (storedCode.length, 2);
                        checkJumpOperation (storedCode[1], BREQ_CODE);	//"10010110"
                    break;
                    
                    //bgtq 35
                    case "BGTQ":
                        checkNumberOfOperands (storedCode.length, 2);
                        checkJumpOperation (storedCode[1], BGTQ_CODE);	//10100110
                    break;
                    
                    //bltq 45
                    case "BLTQ":
                        checkNumberOfOperands (storedCode.length, 2);
                        checkJumpOperation (storedCode[1], BLTQ_CODE);	//"10110110"
                    break;  
                     
                    //goto_idle
                    case "GOTO_IDLE":
                        checkNumberOfOperands (storedCode.length, 1);
                    	storedValues.add(GOTO_IDLE_CODE);//("00001000");
                    break;
                    
                    //goto 43
                    case "GOTO":
                        checkNumberOfOperands (storedCode.length, 2);
                        checkJumpOperation (storedCode[1], GOTO_CODE );// "00000111");
                    break;
                    
                    //call 35
                    case "CALL":
                        checkNumberOfOperands (storedCode.length, 2);
                        checkJumpOperation (storedCode[1], CALL_CODE );//"00001001");
                    break;
                    
                    //return
                    case "RETURN":
                        checkNumberOfOperands (storedCode.length, 1);
                    	storedValues.add(RETURN_CODE );//"00001010");
                    break; 
                                     
                    //deref a
                    //deref b
                    case "DEREF":
                        checkNumberOfOperands (storedCode.length, 2);
                        storedValues.add(checkWhichOperand (storedCode[1], DEREF_A_CODE, DEREF_B_CODE));//"00001011", "00001100"));
                    break;
                    
                    //add a b	//adds both and stores in a...
                    //add b a
                    case "ADD":
                        checkNumberOfOperands (storedCode.length, 3);   //check where the result will go to
                        storedValues.add(checkOperandOrder (storedCode[1], storedCode[2], ADD_A_CODE, ADD_B_CODE ));//"00000100", "00000101"));                    
                    break;
                    
                    //sub a b
                    //sub b a
                    case "SUB":
                        checkNumberOfOperands (storedCode.length, 3);
                        storedValues.add(checkOperandOrder (storedCode[1], storedCode[2], SUB_A_CODE, SUB_B_CODE));//"00010100", "00010101"));
                    break; 
                    
                    //mult a b
                    //mult b a
                    case "MULT":
                        checkNumberOfOperands (storedCode.length, 3);
                        storedValues.add(checkOperandOrder (storedCode[1], storedCode[2], MULT_A_CODE, MULT_B_CODE));//"00100100", "00100101"));
                    break;
                    
                    //s_l a
                    //s_l b
                    case "S_L":
                        checkNumberOfOperands (storedCode.length, 2);
                        storedValues.add(checkWhichOperand (storedCode[1], S_L_A_CODE, S_L_B_CODE));//"00110100", "00110101"));
                    break;
                    
                    //s_r a
                    //s_r b
                    case "S_R":
                        checkNumberOfOperands (storedCode.length, 2);
                        storedValues.add(checkWhichOperand (storedCode[1], S_R_A_CODE, S_R_B_CODE));//"01000100", "01000101"));
                    break;
    
                    //incr a a	//incremends a and stores in a
                    //incr b a
                    case "INCR":
                        checkNumberOfOperands (storedCode.length, 3);
                    	if (storedCode[1].equalsIgnoreCase("A"))
                    		storedValues.add(checkWhichOperand (storedCode[2], INCR_A_A_CODE, INCR_A_B_CODE)); //"01010100", "01100100"));
                    	else if (storedCode[1].equalsIgnoreCase("B"))
                    		storedValues.add(checkWhichOperand (storedCode[2], INCR_B_A_CODE, INCR_B_B_CODE ));//"01010101", "01100101"));
                    	else printErrorLine();
                    break; 
                    
                    //decr a b
                    //decr b b
                    case "DECR":
                        checkNumberOfOperands (storedCode.length, 3);
                    	if (storedCode[1].equalsIgnoreCase("A"))
                    		storedValues.add(checkWhichOperand (storedCode[2], DECR_A_A_CODE, DECR_A_B_CODE ));// "01110100", "10000100"));
                    	else if (storedCode[1].equalsIgnoreCase("B"))
                    		storedValues.add(checkWhichOperand (storedCode[2], DECR_B_A_CODE, DECR_B_B_CODE )); //"01110101", "10000101"));
                    	else printErrorLine();
                    break;
                    
                    //equals a b
                    //equals b a
                    case "EQUALS":
                        checkNumberOfOperands (storedCode.length, 3);
                        storedValues.add(checkOperandOrder (storedCode[1], storedCode[2], EQUALS_A_CODE, EQUALS_B_CODE ));//"10010100", "10010101"));
                    break;
                    //greater a b
                    //greater b a
                    case "GREATER":
                        checkNumberOfOperands (storedCode.length, 3);
                        storedValues.add(checkOperandOrder (storedCode[1], storedCode[2], GREATER_A_CODE, GREATER_B_CODE ));//"10100100", "10100101"));
                    break;
                    
                    //less a b
                    //less b a
                    case "LESS":
                        checkNumberOfOperands (storedCode.length, 3);
                        storedValues.add(checkOperandOrder (storedCode[1], storedCode[2], LESS_A_CODE, LESS_B_CODE ));//"10110100", "10110101"));
                    break;
                    
                    //load_val a 32
                    //load_val b 01
                    //it is in the form of: to load into A reg - (xxxx1101 + value[7:0]), to B reg - (xxxx1101 + value[7:0])
                    case "LOAD_VAL":
                        checkNumberOfOperands (storedCode.length, 3);
                        storedValues.add(checkWhichOperand (storedCode[1], LOAD_VAL_A_CODE, LOAD_VAL_B_CODE ));//"00001101", "00001110"));
                        storedValues.add(storedCode[2]);
                    break;
                    //and a b
                    //and b a
                    case "AND":
                        checkNumberOfOperands (storedCode.length, 3);
                        storedValues.add(checkWhichOperand (storedCode[1], AND_A_CODE, AND_B_CODE));
                    break;
                    
                    //or a b
                    //or b a
                    case "OR":
                        checkNumberOfOperands (storedCode.length, 3);
                        storedValues.add(checkWhichOperand (storedCode[1], OR_A_CODE, OR_B_CODE));
                    break;
                    
                    //xor a b
                    //xor b a
                    case "XOR":
                        checkNumberOfOperands (storedCode.length, 3);
                        storedValues.add(checkWhichOperand (storedCode[1], XOR_A_CODE, XOR_B_CODE));
                    break;
                    
                    //not a
                    //not b
                    case "NOT":
                        checkNumberOfOperands (storedCode.length, 2);
                        storedValues.add(checkWhichOperand (storedCode[1], NOT_A_CODE, NOT_B_CODE));
                    break;                    
                    
                    default:  {
                        checkNumberOfOperands (storedCode.length, 1);
                        if (containsErrors || !addFunctionToMap(storedCode[0])){
                        	printErrorLine();
                        	System.err.println("hint: use single word for function names, define functions only once, i.e. START:");
                        }
//                    return;
                    }
                    break;
                }
                
                if (storedValues.size() > 253){  //make sure there is enough memory left for instructions
                    printErrorLine();
                    System.err.print("hint: you used more than allowed 253 Bytes of program ROM (254 is timer & 255 is mouse interrupt addr).\n");
                }
                
                if (containsErrors){    //if contains errors, end program
                	fw.close();
                	sc.close();
                	return;
                }
                
                
                instructionAddressInHex = Integer.toHexString( storedValues.size() );    //good to know hex value
                if (instructionAddressInHex.length() == 1){                             //but need to make sure that it has two values as hex, i.e. C -> 0C
                    instructionAddressInHex = "0" + instructionAddressInHex;
                }
                
                // print out values for your own good - debugging
                if (storedValues.size() > 0){              	
                	if (storedValues.size() == previousStoredValueSize + 1)
                		if (storedValues.get(storedValues.size()-1).length() == 2)	//hex values have length of 2
                			System.out.print ("\n" + useBinOrHex(storedValues.get(storedValues.size()-1)) );
                		else 
                			System.out.print ("\n" + storedValues.get(storedValues.size()-1) );
                	else if (storedValues.size() == previousStoredValueSize + 2){
                		if (storedValues.get(storedValues.size()-1).length() == 2){
                			System.out.print ("\n" + useBinOrHex(storedValues.get(storedValues.size()-2)) );
                			System.out.print ("\n" + useBinOrHex(storedValues.get(storedValues.size()-1)) );
                		} else {
                			System.out.print ("\n" + storedValues.get(storedValues.size()-2) );
                			System.out.print ("\n" + storedValues.get(storedValues.size()-1) );
                		}
             		}
                	System.out.print("\n" + "XX <- This Instruction address is " + instructionAddressInHex + "\n\n");//tells the location of instruction
                }
                else
                	System.out.println("ADDR: 00");
                	
               	previousStoredValueSize = storedValues.size();
            }
            
            if (addressOfTimerISR == "FE"){ //0xFE
                // printErrorLine();
                System.err.print ("Error: You didn't specify where your timer interrupt begins.\n");
            	fw.close();
            	sc.close();
                return;
            }  
            
            while (storedValues.size() < 254) {
            	storedValues.add("00");
            }
            storedValues.add(addressOfTimerISR);
            storedValues.add(addressOfMouseISR);
            
            for (String tmp : storedValues){
            	if (functionTag.containsKey(tmp))
            		tmp = functionTag.get(tmp);
            	
            	fw.write(useBinOrHex(tmp));
            	fw.write("\n");
            }
            
//     close stuff
            fw.close();
            sc.close();

        } catch (IOException e) {
            e.printStackTrace();
        }
        if (addressOfMouseISR == "FF")
            System.out.println ("Warning: You didn't use mouse interrupt anywhere.\n");
            
        System.out.println("Finished without errors!");
        return ;
    }
    
    //to check which operand, regA or regB stores the resultant value 
    public static String checkOperandOrder (String op_1, String op_2, String code_1, String code_2){
    	if (op_1.equalsIgnoreCase("A") && op_2.equalsIgnoreCase("B"))
    		return code_1;
    	else if (op_1.equalsIgnoreCase("B") && op_2.equalsIgnoreCase("A")){
    		return code_2;
    	} else {
    		printErrorLine();
    		System.err.print ("hint: cannot find A or B.\n");
            return "";
    	}
    }
    //to check if regA or regB is used to storing & loading values
    public static String checkWhichOperand (String op, String code_1, String code_2){
    	if (op.equalsIgnoreCase("A"))
    		return code_1;
    	else if (op.equalsIgnoreCase("B")){
    		return code_2;
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
        
        checkLengthOfHexAndBin(bin.length(), hex.length());	//for error detection
        return bin;
     }
     
     public static String useBinOrHex (String hexVal){
    	 if (useBinNotHex)
    		 return hexToBi(hexVal);
    	 else	
    		 return hexVal;
     }
     
     //
     public static void checkJumpOperation (String AddrOrVal, String instruction){
         storedValues.add(instruction);
         if (AddrOrVal.length() > 2){
         	storedValues.add(AddrOrVal);
         } else {
         	storedValues.add(AddrOrVal);
         }
     }
     
     public static boolean addFunctionToMap (String functionName){
         if ( functionName.endsWith(":")) {
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
                            addressOfTimerISR = instructionAddressInHex;
                            timerIntUsed = true;
                        break;
                    
                        //mouse_isr:
                        case "MOUSE_ISR":
                            if (mouseIntUsed){
                                printErrorLine();
                                System.err.print ("hint: You can't you mouse interrupts at multiple places");
                            }
                            addressOfMouseISR = instructionAddressInHex;
                            mouseIntUsed = true;
                        break;
                    
                        default: {
                        	System.out.println("Found: " + functionName + " at addr: " + instructionAddressInHex);
                            if (!functionTag.containsKey(functionName))
                        		functionTag.put( functionName, instructionAddressInHex );
                            else
                            	return false;
                        }
                    }
        } else return false;
         return true;
     }
}
