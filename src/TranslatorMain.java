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
    public static void main(String args[]) {
        try {
        	
            // get the user file
//          Scanner sc = new Scanner (new File (args[0]));
          Scanner sc = new Scanner (new File ("instructions"));
            
            // output file
            File outputFile = new File("userProgram.txt");
            FileWriter fw = new FileWriter(outputFile);
            
            while (sc.hasNextLine()){	
                String tmp = sc.nextLine();
                String data = new String ();
                
                //clean code from comments
                if (tmp.contains(";"))
                	tmp = tmp.substring(0, tmp.indexOf(";") );

//                System.out.println(tmp);
                
                //just in case check for empty lines
                if ( tmp.replaceAll("\\s+","").isEmpty() )
                	continue;
                else data = tmp;
                	
                String [] storedCode = data.split(" ");
                
                String valueToSend = new String();
                switch (storedCode[0].toUpperCase()){
                
                	//load a 43
                	//load b 33
                    case "LOAD":
                    	valueToSend = checkWhichOperand (storedCode[1], "00000000", "00000001");
                    	valueToSend += hexToBi(storedCode[2]) + "\n";
                    break;
                    
                    //store 32 a
                    //store 52 b
                    case "STORE":
                    	valueToSend =  checkWhichOperand (storedCode[2], "00000010", "00000011");
                    	valueToSend += hexToBi(storedCode[1]) + "\n";
                    break;
                    
                    //breq 52
                    case "BREQ":
                    	valueToSend = ("10010110" + '\n' + hexToBi(storedCode[1]) + '\n');
                    break;
                    
                    //bgtq 35
                    case "BGTQ":
                    	valueToSend = ("10100110" + '\n' + hexToBi(storedCode[1]) + '\n');
                    break;
                    
                    //bltq 45
                    case "BLTQ":
                    	valueToSend = ("10110110" + '\n' + hexToBi(storedCode[1]) + '\n');
                    break;  
                     
                    //goto_idle
                    case "GOTO_IDLE":
                    	valueToSend = ("00001000" + '\n');
                    break;
                    
                    //goto 43
                    case "GOTO":
                    	valueToSend = ("00000111" + '\n' + hexToBi(storedCode[1]) + '\n');
                    break;
                    
                    //call 35
                    case "CALL":
                    	valueToSend = ("00001001" + '\n' + hexToBi(storedCode[1]) + '\n');
                    break;
                    
                    //return
                    case "RETURN":
                    	valueToSend = ("00001010" + '\n');
                    break; 
                    
                    //deref a
                    //deref b
                    case "DEREF":
                    	valueToSend = checkWhichOperand (storedCode[1], "00001011", "00001100");
                    break;
                    
                    //add a b	//adds both and stores in a...
                    //add b a
                    case "ADD":
                    	valueToSend = checkOperandOrder (storedCode[1], storedCode[2], "00000100", "00000101");
                    break;
                    
                    //sub a b
                    //sub b a
                    case "SUB":
                    	valueToSend = checkOperandOrder (storedCode[1], storedCode[2], "00010100", "00010101");
                    break; 
                    
                    //mult a b
                    //mult b a
                    case "MULT":
                    	valueToSend = checkOperandOrder (storedCode[1], storedCode[2], "00100100", "00100101");
                    break;
                    
                    //s_l a
                    //s_l b
                    case "S_L":
                    	valueToSend = checkWhichOperand (storedCode[1], "00110100", "00110101");
                    break;
                    
                    //s_r a
                    //s_r b
                    case "S_R":
                    	valueToSend = checkWhichOperand (storedCode[1], "01000100", "01000101");
                    break;
                    
                    //incr a
                    //incr b
                    case "INCR":
                    	valueToSend = checkWhichOperand (storedCode[1], "01010100", "01100100");
                    break; 
                    
                    //decr a
                    //decr b
                    case "DECR":
                    	valueToSend = checkWhichOperand (storedCode[1], "01110100", "10000100");
                    break;
                    
                    //equals a b
                    //equals b a
                    case "EQUALS":
                    	valueToSend = checkOperandOrder (storedCode[1], storedCode[2], "10010100", "10010101");
                    break;
                    //greater a b
                    //greater b a
                    case "GREATER":
                    	valueToSend = checkOperandOrder (storedCode[1], storedCode[2], "10100100", "10100101");
                    break;
                    
                    //less a b
                    //less b a
                    case "LESS":
                    	valueToSend = checkOperandOrder (storedCode[1], storedCode[2], "10110100", "10110101");
                    break;
                    
                    case " ":
                    	break;
                    default: valueToSend = "sorry bro, smth is wrong with ur code...\n";
                    break;
                }
                
                System.out.print(valueToSend);
                
            }
//            
            fw.close();

        } catch (IOException e) {
            e.printStackTrace();
        }

    }
    
    public static String checkOperandOrder (String op_1, String op_2, String code_1, String code_2){
    	if (op_1.equalsIgnoreCase("A") && op_2.equalsIgnoreCase("B"))
    		return code_1 + "\n";
    	else if (op_1.equalsIgnoreCase("B") && op_2.equalsIgnoreCase("A")){
    		return code_2 + "\n";
    	} else return "Value is not A or B! (in checkOperandOrder)";
    	
    }
    
    public static String checkWhichOperand (String op, String code_1, String code_2){
    	if (op.equalsIgnoreCase("A"))
    		return code_1 + "\n";
    	else if (op.equalsIgnoreCase("B")){
    		return code_2 + "\n";
    	} else return "Value is not A or B! (in checkWhichOperand)";
    	
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
