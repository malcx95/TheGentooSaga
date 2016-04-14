#!/bin/python
import sys

OPCODES = {
        'ADD' : 0x38,
        'ADDI': 0x27,
        'BF' : 0x4,
        'J' : 0x0,
        'LW': 0x21,
        'MOVHI' : 0x6,
        'MUL' : 0x38,
        'NOP' : 0x15,
        'SFEQ' : 0x39,
        'SFNE' : 0x39,
        'SFEQI' : 0x2f,
        'SFNEI' : 0x2f,
        'SW' : 0x35
#        'TRAP' : 0x2100
        }

ADD_MUL_I_FIELD = {
        'ADD' : 0x000,
        'MUL' : 0x006
        }

SFEQ_SFNE_D_FIELD = {
        'SFEQ' : 0b00000,
        'SFEQI' : 0b00000,
        'SFNE' : 0b00001,
        'SFNEI' : 0b00001
        }

labels = {}

class LabelError(Exception):
    def __init__(self, message, line, line_number):
        self.message = message
        self.line = line
        self.line_number = line_number

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
        self.labels = []
    
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

def parse_line(line, line_number):
    words = tokenize(line)
    inst = Instruction(line)
    # print(words)
    # TODO DO SOMETHING WITH THE TOKENIZED STRINGS

def find_labels(lines):
    line_number = 1
    for line in lines:
        if ':' in line:
            if line.count(':') != 1:
                raise LabelError("Too many colons", line, line_number)
            end_index = 0
            for i in range(len(line)):
                if line[i] == ' ':
                    raise LabelError("Unexpected space when parsing label", line, line_number)
                elif line[i] == ':':
                    end_index = i
                    break
            labels[line_number] = line[:end_index]
        line_number += 1

def assemble(argv):
    input_file = argv[1]
    program = Program()
    lines = get_lines(input_file)
    find_labels(lines)
    line_number = 0
    for line in lines:
        program.add_instruction(parse_line(line, line_number))
        line_number += 1

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: \npython3 assembler.py input.s output")
        sys.exit(-1)
    try:
        assemble(sys.argv)
    except LabelError as e:
        print("Error (at line {}): {}:\n{}".format(e.line_number, e.message, e.line))
