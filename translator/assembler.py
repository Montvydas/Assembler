# Assembler, Theo Scott s1231174
import sys

src_file = sys.argv[1]
out_file = sys.argv[2]

default_fill = "F"
timer_interrupt_addr = "timer_interrupt"

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
    out.write(fill + cmd + "\n")
    out.write(mem + "\n")

# first pass for labels
with open(src_file, 'r') as src:
    with open(out_file, 'w') as out:
        for line in src:
            line_count += 1
            line = line.strip()
            tokens = line.split()
            inst = tokens[0]
            # first check for comments, i.e. starting '#'
            if "#" in tokens: # if comment in line, delete it and following tokens
                idx = tokens.index("#")
                tokens = tokens[:idx-1]
            # next check if line is a label
            if ':' in line and '#' not in line:
                label = tokens[0][:-1] # label is token without colon
                labels[label] = hex(line_count)[2:] # value of label is its line in hex without '0h'
                line_count -= 1 # don't count label as an instruction
            elif inst = "LOAD":
                line_count += 1 # LD/ST need extra byte
            elif inst = "STORE":
                line_count += 1
            elif inst = "ADD":
                pass
            elif inst = "SUB":
                pass
            elif inst = "MUL":
                pass
            elif inst = "SHIFTL":
                pass
            elif inst = "SHIFTR":
                pass
            elif inst = "INCA":
                pass
            elif inst = "INCB":
                pass
            elif inst = "DECA":
                pass
            elif inst = "DECB":
                pass
            elif inst = "AND":
                pass
            elif inst = "OR":
                pass
            elif inst = "XOR":
                pass
            elif inst = "BREQ":
                line_count += 1
            elif inst = "BGTE":
                line_count += 1
            elif inst = "BLTE":
                line_count += 1
            elif inst = "GOTO":
                line_count += 1
            elif inst = "GOTO_IDLE":
                pass
            elif inst = "FUNC":
                line_count += 1
            elif inst = "RETURN":
                pass
            elif inst = "DEREF":
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
            inst = tokens[0]
            # first check for comments, i.e. starting '#'
            if "#" in tokens: # if comment in line, delete it and following tokens
                idx = tokens.index("#")
                tokens = tokens[:idx-1]
            # next check if line is a label
            if ':' in line and '#' not in line:
                line_count -= 1 # don't count label as an instruction
            elif inst = "LOAD":
                line_count += 1 # LD/ST need extra byte
                reg = 0 if tokens[1] == "A" else 1
                memLine(default_fill, reg, tokens[2])
            elif inst = "STORE":
                line_count += 1
                reg = 2 if tokens[1] == "A" else 3
                memLine(default_fill, reg, tokens[2])
            elif inst = "ADD":
                alu("0", tokens[1])
            elif inst = "SUB":
                alu("1", tokens[1])
            elif inst = "MUL":
                alu("2", tokens[1])
            elif inst = "SHIFTL":
                alu("3", tokens[1])
            elif inst = "SHIFTR":
                alu("4", tokens[1])
            elif inst = "INCA":
                alu("5", tokens[1])
            elif inst = "INCB":
                alu("6", tokens[1])
            elif inst = "DECA":
                alu("7", tokens[1])
            elif inst = "DECB":
                alu("8", tokens[1])
            elif inst = "AND":
                alu("C", tokens[1])
            elif inst = "OR":
                alu("D", tokens[1])
            elif inst = "XOR":
                alu("E", tokens[1])
            elif inst = "BREQ":
                line_count += 1
                label = tokens[1]
                memLine("B", 6, labels[label])
            elif inst = "BGTE":
                line_count += 1
                label = tokens[1]
                memLine("B", 6, labels[label])
            elif inst = "BLTE":
                line_count += 1
                label = tokens[1]
                memLine("B", 6, labels[label])
            elif inst = "GOTO":
                line_count += 1
                label = tokens[1]
                memLine(default_fill, 7, labels[label])
            elif inst = "GOTO_IDLE":
                label = tokens[1]
                memLine(default_fill, 8)
            elif inst = "FUNC":
                line_count += 1
                label = tokens[1]
                memLine(default_fill, 9, labels[label])
            elif inst = "RETURN":
                empty(default_fill)
            elif inst = "DEREF":
                deref = "B" if tokens[1] == "A" else "C"
            else:
                print "INVALID COMMAND: [" + line_count + "] " + line

        while line_count < 253:
            empty(default_fill, default_fill)
            line_count += 1

        if timer_interrupt in labels:
            labelAddr(labels[timer_interrupt])
