end_check:
  LOAD A 0C             # load FF into A
  LOAD B 0D             # load val of 0D into B
  BREQ end              # end if 0D == FF
timer_interrupt:
  LOAD A 09             # load val of 09 into A
  INCA A                # increment
  STORE A 09            # store in 09
  LOAD B 01             # load 0A into B
  BREQ ten_interrupts   # go to ten_interrupts if A == 0A
GOTO_IDLE
ten_interrupts:
  LOAD A 0B             # load 00 into A
  STORE A 09            # store 00 into 09
  LOAD A 00             # load PC into A
  INCA A                # increment
  STORE A 00            # store new PC in 00
  DEREF A               # deref register, now has instruction
  STORE A 90            # write inst to address 90
  LOAD B 08             # load last inst of program
  BREQ end              # if last inst, end program
GOTO_IDLE
end:
  LOAD A 0C             # load FF into A
  STORE A 0D            # store FF into 0D
GOTO_IDLE
