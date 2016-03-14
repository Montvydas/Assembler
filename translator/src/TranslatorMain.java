/**
 * Created by Monte on 11/3/16.
 */

import java.io.*;
import java.util.*;

public class TranslatorMain {

	
	
    /**
     * Entrance of decoder script.
     * Input the instructions_set.txt file as the argument.
     *
     * @param args      the filename
     */
	static int lineNr = 0;
	static String data = new String ();
	static boolean containsErrors = false;
    static String addressOfTimerISR = "11111110";
    static String addressOfMouseISR = "11111111";
    
    public static void main(String args[]) {
        try {
        	
            // get the user file
          Scanner sc = new Scanner (new File (args[0]));
//          Scanner sc = new Scanner (new File ("instructions.txt"));
          
            // output file
//          File outputFile = new File("results.txt");
            File outputFile = new File(args[1]);
            FileWriter fw = new FileWriter(outputFile);
            
            boolean blockCommented = false;
            int instructionAddress = 0;
            String instructionAddressInHex = "00";
           
      //Start line scanning
            while (sc.hasNextLine()){	
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
                
                String valueToSend = new String();
                int instructionLengthInBytes = 0;
               
                switch (storedCode[0].toUpperCase()){
                	//load a 43
                	//load b 33
                    case "LOAD":
                        checkNumberOfOperands (storedCode.length, 3);
                    	valueToSend = checkWhichOperand (storedCode[1], "00000000", "00000001");
                    	valueToSend += hexToBi(storedCode[2]) + "\n";
                        instructionLengthInBytes = 2;
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
                        checkNumberOfOperands (storedCode.length, 3);
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
                    
                    //also check if it was used only once in our program
                    //timer_isr:
                    case "TIMER_ISR:":
                        checkNumberOfOperands (storedCode.length, 1);
                        // System.out.print ("\n" + instructionAddressInHex + "\n");
                        addressOfTimerISR = hexToBi( instructionAddressInHex ) + "\n";
                        instructionLengthInBytes = 0;
                    break;
                    
                    //mouse_isr:
                    case "MOUSE_ISR:":
                        checkNumberOfOperands (storedCode.length, 1);
                        addressOfMouseISR = hexToBi( instructionAddressInHex ) + "\n";
                        instructionLengthInBytes = 0;
                    break;
                    
                    default:  printErrorLine();
//                    return;
                    break;
                }
                
                
                instructionAddress += instructionLengthInBytes; //gets the address
                if (instructionAddress > 253){
                    printErrorLine();
                    System.err.print("hint: you used more than allowed 253 Bytes of program ROM (254 is timer & 255 is mouse interrupt addr).\n");
                    return;    
                }
                
                if (containsErrors){
                	fw.write("Please fix your errors firstly.");
                	fw.close();
                	sc.close();
                	return;
                }
                
                fw.write(valueToSend);
                
                instructionAddressInHex = Integer.toHexString( instructionAddress );    //good to know hex value
                if (instructionAddressInHex.length() == 1){                             //but need to make sure that it has two values as hex, i.e. C -> 0C
                    instructionAddressInHex = "0" + instructionAddressInHex;
                }
                
                System.out.print( "\n" + valueToSend + "XXXXXXXX <- This Instruction address is " + instructionAddressInHex + "\n\n");
            }
            
            if (addressOfTimerISR == "11111110"){ //0xFE
                // printErrorLine();
                System.err.print ("Error: You didn't specify where your timer interrupt begins.\n");
                return;
            }   
            
            
            if (instructionAddress < 254){
                while (instructionAddress < 253) {
                    fw.write("\n");
                    instructionAddress ++;    
                }
                fw.write (addressOfTimerISR);
                fw.write (addressOfMouseISR);
            } else {
                printErrorLine();
                System.err.print("hint: you used more than allowed 253 Bytes of program ROM.\n");
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
    
   public static void printErrorLine() {
	   System.err.print("Error line number: " + lineNr + "\nLine says: " + data + "\n");
	   containsErrors = true;
   }
   
   public static void checkNumberOfOperands (int length, int requiredLength){
        if (length != requiredLength){
            printErrorLine ();
            System.err.print ("hint: wrong number of operands in a line.\n");
            return;
        }
   }
   
   public static void checkLengthOfHexAndBin (int binLength, int hexLength){
       if (binLength != 8 || hexLength != 2){
           printErrorLine();
           System.err.print ("hint: entered value is a not valid hex value.\n");
       }
   }
   
     public static String hexToBi (String hex){
        int i = Integer.parseInt(hex, 16);
        String bin = Integer.toBinaryString(i);
        
        if (bin.length() < 8)
            bin = String.format("%0" + (8-bin.length()) + "d", 0).replace("0", "0") + bin; //add zeroes at the begining
        
        System.out.print ("In hexToBi: hex=" + hex + " bin=" + bin + "\n");
        
        checkLengthOfHexAndBin(bin.length(), hex.length());
        return bin;
     }
    
    
    
   
    /**
     * Translate a given hexadecimal number to a binary sequence.
     *
     * @param hex_str       the number to be translated
     * @return              the binary sequence
     */
    /*
    public static String hexTo_Bi(String hex_str) {
        String bi = "";
        for (int i = 0; i < hex_str.length(); i++)
            bi = bi + hexToBi_per_char(hex_str.charAt(i));
        checkLengthOfHexAndBin(bi.length(), hex_str.length());
        return bi;
    }
*/
    /**
     * Translate a single digit of hexadecimal number.
     *
     * @param hex       the digit
     * @return          the corresponding binary number
     */
     /*
    public static String hexToBi_per_char(char hex) {
        
        if (hex == '0')
            return "0000";
        else if (hex == '1')
            return "0001";
        else if (hex == '2')
            return "0010";
        else if (hex == '3')
            return "0011";
        else if (hex == '4')
            return "0100";
        else if (hex == '5')
            return "0101";
        else if (hex == '6')
            return "0110";
        else if (hex == '7')
            return "0111";
        else if (hex == '8')
            return "1000";
        else if (hex == '9')
            return "1001";
        else if (hex == 'A' || hex == 'a')
            return "1010";
        else if (hex == 'B' || hex == 'b')
            return "1011";
        else if (hex == 'C' || hex == 'c')
            return "1100";
        else if (hex == 'D' || hex == 'd')
            return "1101";
        else if (hex == 'E' || hex == 'e')
            return "1110";
        else if (hex == 'F' || hex == 'f')
            return "1111";
        else
            return "";
    }
    */
}
