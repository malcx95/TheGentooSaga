#!/bin/python
import sys

OPCODES = {
        'ADD' : 0x38,
        'ADDI': 0x27,
        'BF' : 0x4,
        'JMP' : 0x0,
        'LW': 0x21,
        'MOVHI' : 0x6,
        'MUL' : 0x38,
        'NOP' : 0x15,
        'SFEQ' : 0x39,
        'SFNE' : 0x39,
        'SFEQI' : 0x2f,
        'SFNEI' : 0x2f,
        'SW' : 0x35,
        'TRAP' : 0x2100
        }

class Instruction:
    """A single instruction""" 
    # Sets of instructions that can be
    # compiled identically
    INSTR_TYPE_1 = ('ADD', 'MUL')
    # TODO add more

    def __init__(self, line):
        self.args = line[1:]
        self.op = line[0]

    # TODO def compile(...): ...

class Program:
    """Class representing a compiled program"""
    def __init__(self):
        self.instructions = []
    
    def add_instruction(self, instruction):
        self.instructions.append(instruction)

    def write_to_file(self, output_file):
        # TODO implement
        pass

def get_lines(input_file):
    with open(input_file) as f:
        return f.readlines()

def tokenize(line):
    """Returns a list of each word in the line"""
    res = []
    if not line:
        # blank line
        return []
    
    index = 0
    # skip spaces
    for i in range(len(line)):
        if line[i] != ' ' and line[i] != '\t':
            if line[i] == '\n':
                # all spaces or tabs - blank line
                return []
            else:       
                # we found a meaningful character at position i
                index = i
                break
    # start tokenizing
    word = ""
    while True:
        if line[index] == ' ' or line[index] == '\t' or line[index] == ',':
            if word:
                res.append(word)
            word = ""
        elif line[index] == '\n':
            if word:
                res.append(word)
            return res
        else:
            word += line[index]
        index += 1

def parse_line(line):
    words = tokenize(line)
    inst = Instruction(line)
    #print(words)
    # TODO DO SOMETHING WITH THE TOKENIZED STRINGS

def assemble(argv):
    input_file = argv[1]
    program = Program()
    lines = get_lines(input_file)
    for line in lines:
        program.add_instruction(parse_line(line))

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: \npython3 assembler.py input.s output")
        sys.exit(-1)
    assemble(sys.argv)
