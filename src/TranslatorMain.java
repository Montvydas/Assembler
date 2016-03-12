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
                
                switch (storedCode[0].toUpperCase()){
                	//load a 43
                	//load b 33
                    case "LOAD":
                        checkNumberOfOperands (storedCode.length, 3);
                    	valueToSend = checkWhichOperand (storedCode[1], "00000000", "00000001");
                    	valueToSend += hexToBi(storedCode[2]) + "\n";
                    break;
                    
                    //store 32 a
                    //store 52 b
                    case "STORE":
                        checkNumberOfOperands (storedCode.length, 3);
                    	valueToSend =  checkWhichOperand (storedCode[2], "00000010", "00000011");
                    	valueToSend += hexToBi(storedCode[1]) + "\n";
                    break;
                    
                    //breq 52
                    case "BREQ":
                        checkNumberOfOperands (storedCode.length, 2);
                    	valueToSend = ("10010110" + '\n' + hexToBi(storedCode[1]) + '\n');
                    break;
                    
                    //bgtq 35
                    case "BGTQ":
                        checkNumberOfOperands (storedCode.length, 2);
                    	valueToSend = ("10100110" + '\n' + hexToBi(storedCode[1]) + '\n');
                    break;
                    
                    //bltq 45
                    case "BLTQ":
                        checkNumberOfOperands (storedCode.length, 2);
                    	valueToSend = ("10110110" + '\n' + hexToBi(storedCode[1]) + '\n');
                    break;  
                     
                    //goto_idle
                    case "GOTO_IDLE":
                        checkNumberOfOperands (storedCode.length, 1);
                    	valueToSend = ("00001000" + '\n');
                    break;
                    
                    //goto 43
                    case "GOTO":
                        checkNumberOfOperands (storedCode.length, 2);
                    	valueToSend = ("00000111" + '\n' + hexToBi(storedCode[1]) + '\n');
                    break;
                    
                    //call 35
                    case "CALL":
                        checkNumberOfOperands (storedCode.length, 2);
                    	valueToSend = ("00001001" + '\n' + hexToBi(storedCode[1]) + '\n');
                    break;
                    
                    //return
                    case "RETURN":
                        checkNumberOfOperands (storedCode.length, 1);
                    	valueToSend = ("00001010" + '\n');
                    break; 
                    
                    //deref a
                    //deref b
                    case "DEREF":
                        checkNumberOfOperands (storedCode.length, 2);
                    	valueToSend = checkWhichOperand (storedCode[1], "00001011", "00001100");
                    break;
                    
                    //add a b	//adds both and stores in a...
                    //add b a
                    case "ADD":
                        checkNumberOfOperands (storedCode.length, 3);
                    	valueToSend = checkOperandOrder (storedCode[1], storedCode[2], "00000100", "00000101");
                    break;
                    
                    //sub a b
                    //sub b a
                    case "SUB":
                        checkNumberOfOperands (storedCode.length, 3);
                    	valueToSend = checkOperandOrder (storedCode[1], storedCode[2], "00010100", "00010101");
                    break; 
                    
                    //mult a b
                    //mult b a
                    case "MULT":
                        checkNumberOfOperands (storedCode.length, 3);
                    	valueToSend = checkOperandOrder (storedCode[1], storedCode[2], "00100100", "00100101");
                    break;
                    
                    //s_l a
                    //s_l b
                    case "S_L":
                        checkNumberOfOperands (storedCode.length, 2);
                    	valueToSend = checkWhichOperand (storedCode[1], "00110100", "00110101");
                    break;
                    
                    //s_r a
                    //s_r b
                    case "S_R":
                        checkNumberOfOperands (storedCode.length, 2);
                    	valueToSend = checkWhichOperand (storedCode[1], "01000100", "01000101");
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
                    break;
                    
                    //equals a b
                    //equals b a
                    case "EQUALS":
                        checkNumberOfOperands (storedCode.length, 3);
                    	valueToSend = checkOperandOrder (storedCode[1], storedCode[2], "10010100", "10010101");
                    break;
                    //greater a b
                    //greater b a
                    case "GREATER":
                        checkNumberOfOperands (storedCode.length, 3);
                    	valueToSend = checkOperandOrder (storedCode[1], storedCode[2], "10100100", "10100101");
                    break;
                    
                    //less a b
                    //less b a
                    case "LESS":
                        checkNumberOfOperands (storedCode.length, 3);
                    	valueToSend = checkOperandOrder (storedCode[1], storedCode[2], "10110100", "10110101");
                    break;
                    
                    default:  printErrorLine();
//                    return;
                    break;
                }
                
                fw.write(valueToSend);
                
                if (containsErrors){
                	fw.write("Please fix your errors firstly.");
                	fw.close();
                	sc.close();
                	return;
                }
                
                System.out.print("\n" + valueToSend + "\n");
            }
//     close stuff
            fw.close();
            sc.close();

        } catch (IOException e) {
            e.printStackTrace();
        }
        
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
    /**
     * Translate a given hexadecimal number to a binary sequence.
     *
     * @param hex_str       the number to be translated
     * @return              the binary sequence
     */
    public static String hexToBi(String hex_str) {
        String bi = "";
        for (int i = 0; i < hex_str.length(); i++)
            bi = bi + hexToBi_per_char(hex_str.charAt(i));
        // if (bi.length() > 8)
           // return "error: incorrect address.";
        return bi;
    }

    /**
     * Translate a single digit of hexadecimal number.
     *
     * @param hex       the digit
     * @return          the corresponding binary number
     */
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
        else if (hex == 'A')
            return "1010";
        else if (hex == 'B')
            return "1011";
        else if (hex == 'C')
            return "1100";
        else if (hex == 'D')
            return "1101";
        else if (hex == 'E')
            return "1110";
        else if (hex == 'F')
            return "1111";
        else
            return "";
    }
}
