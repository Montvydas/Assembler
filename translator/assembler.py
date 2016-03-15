# Assembler, Theo Scott s1231174
import sys

src_file = sys.argv[1]
out_file = sys.argv[2]

default_fill = "F"

end_check_addr = "end_check"
timer_interrupt_addr = "timer_interrupt"
ten_interrupts_addr = "ten_interrupts"
end_addr = "end"

line_count = -1 # account for line nos starting at 1, not 0
labels = {}

# write functions
def empty(fill, number_command):
    out.write(fill + str(number_command) + "\n")

def labelAddr(addr):
    out.write(addr + "\n")

def alu(op, reg):
    id = "4" if reg == "A" else "5"
    out.write(op + id + "\n")

def memLine(fill, cmd, mem):
    out.write(fill + str(cmd) + "\n")
    out.write(mem + "\n")

# first pass for labels
with open(src_file, 'r') as src:
    with open(out_file, 'w') as out:
        for line in src:
            line_count += 1
            line = line.strip()
            tokens = line.split()
            # first check for comments, i.e. starting '#'
            if "#" in tokens: # if comment in line, delete it and following tokens
                idx = tokens.index("#")
                # print str(-1*(len(tokens)-idx))
                del tokens[-1*(len(tokens)-idx):]
                line_count -= 1
            # check for blank lines or comment lines after deletion
            # print tokens
            if len(tokens) == 0:
                inst = ""
            else:
                inst = tokens[0]
            # next check if line is a label
            if(':' in line and '#' not in line):
                label = tokens[0][:-1] # label is token without colon
                labels[label] = hex(line_count)[2:] # value of label is its line in hex without '0h'
                line_count -= 1 # don't count label as an instruction
            elif inst == "LOAD":
                line_count += 1 # LD/ST need extra byte
            elif inst == "STORE":
                line_count += 1
            elif inst == "ADD":
                pass
            elif inst == "SUB":
                pass
            elif inst == "MUL":
                pass
            elif inst == "SHIFTL":
                pass
            elif inst == "SHIFTR":
                pass
            elif inst == "INCA":
                pass
            elif inst == "INCB":
                pass
            elif inst == "DECA":
                pass
            elif inst == "DECB":
                pass
            elif inst == "AND":
                pass
            elif inst == "OR":
                pass
            elif inst == "XOR":
                pass
            elif inst == "BREQ":
                line_count += 1
            elif inst == "BGTE":
                line_count += 1
            elif inst == "BLTE":
                line_count += 1
            elif inst == "GOTO":
                line_count += 1
            elif inst == "GOTO_IDLE":
                pass
            elif inst == "FUNC":
                line_count += 1
            elif inst == "RETURN":
                pass
            elif inst == "DEREF":
                pass
            else:
                pass

        # return to start of file now that labels and lines have been counted
        line_count = -1
        src.seek(0)

        # now translate instructions
        for line in src:
            line_count += 1
            line = line.strip()
            tokens = line.split()
            if len(tokens) == 0:
                line_count -= 1
                inst = ""
            else:
                inst = tokens[0]
            # first check for comments, i.e. starting '#'
            if "#" in tokens: # if comment in line, delete it and following tokens
                idx = tokens.index("#")
                del tokens[-1*(len(tokens)-idx):]
                line_count -= 1
            # next check if line is a label
            if ':' in line and '#' not in line:
                line_count -= 1 # don't count label as an instruction
            elif inst == "LOAD":
                line_count += 1 # LD/ST need extra byte
                reg = 0 if tokens[1] == "A" else 1
                memLine(default_fill, reg, tokens[2])
            elif inst == "STORE":
                line_count += 1
                reg = 2 if tokens[1] == "A" else 3
                memLine(default_fill, reg, tokens[2])
            elif inst == "ADD":
                alu("0", tokens[1])
            elif inst == "SUB":
                alu("1", tokens[1])
            elif inst == "MUL":
                alu("2", tokens[1])
            elif inst == "SHIFTL":
                alu("3", tokens[1])
            elif inst == "SHIFTR":
                alu("4", tokens[1])
            elif inst == "INCA":
                alu("5", tokens[1])
            elif inst == "INCB":
                alu("6", tokens[1])
            elif inst == "DECA":
                alu("7", tokens[1])
            elif inst == "DECB":
                alu("8", tokens[1])
            elif inst == "AND":
                alu("C", tokens[1])
            elif inst == "OR":
                alu("D", tokens[1])
            elif inst == "XOR":
                alu("E", tokens[1])
            elif inst == "BREQ":
                line_count += 1
                label = tokens[1]
                memLine("B", 6, labels[label])
            elif inst == "BGTE":
                line_count += 1
                label = tokens[1]
                memLine("B", 6, labels[label])
            elif inst == "BLTE":
                line_count += 1
                label = tokens[1]
                memLine("B", 6, labels[label])
            elif inst == "GOTO":
                line_count += 1
                label = tokens[1]
                memLine(default_fill, 7, labels[label])
            elif inst == "GOTO_IDLE":
                empty(default_fill, 8)
            elif inst == "FUNC":
                line_count += 1
                label = tokens[1]
                memLine(default_fill, 9, labels[label])
            elif inst == "RETURN":
                empty(default_fill)
            elif inst == "DEREF":
                deref = "B" if tokens[1] == "A" else "C"
            elif inst == "":
                pass
            elif inst == "#":
                pass
            else:
                print "INVALID COMMAND: [" + str(line_count) + "] " + line

        while line_count < 253:
            empty(default_fill, default_fill)
            line_count += 1

        if end_check_addr in labels:
            labelAddr(labels[end_check_addr])
        if timer_interrupt_addr in labels:
            labelAddr(labels[timer_interrupt_addr])
        if ten_interrupts_addr in labels:
            labelAddr(labels[ten_interrupts_addr])
        if end_addr in labels:
            labelAddr(labels[end_addr])
