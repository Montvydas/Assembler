// Test program, Theo Scott s1231174

end_check:
  LOAD A 0C             // load FF into A
  LOAD B 0D             // load val of 0D into B
  BREQ end              // end if 0D == FF

timer_interrupt:
  LOAD A 08             // load val of 08 into A
  INCR A A              // increment
  STORE 08 A            // store in 08
  LOAD B 09             // load 0A into B
  BREQ ten_interrupts   // go to ten_interrupts if A == 0A
GOTO_IDLE

ten_interrupts:
  LOAD A 0B             // load 00 into A
  STORE 08 A            // store 00 into 08
  LOAD A 00             // load PC into A
  INCR A A              // increment
  STORE 00 A            // store new PC in 00
  DEREF A               // deref register, now has instruction
  STORE 90 A            // write inst to address 90
  LOAD B 06             // load last inst of program
  BREQ end              // if last inst, end program
GOTO_IDLE

end:
  LOAD A 0C             // load FF into A
  STORE 0D A            // store FF into 0D
GOTO_IDLE
