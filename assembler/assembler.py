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
        'ADD' : "00000000000",
        'MUL' : "00000000110"
        }

SFEQ_SFNE_D_FIELD = {
        'SFEQ' : "00000",
        'SFEQI' : "00000",
        'SFNE' : "00001",
        'SFNEI' : "00001"
        }

EXPECTED_NUM_REGS = {
        'ADD' : 3,
        'MUL' : 3,
        'SFEQ': 2,
        'SFNE': 2
        }

labels = {}

class LabelError(Exception):
    def __init__(self, message, line, line_number):
        self.message = message
        self.line = line
        self.line_number = line_number

class InvalidArgumentException(Exception):
    def __init__(self, message, line, line_number):
        self.message = message
        self.line = line
        self.line_number = line_number

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

def remove_label(words):
    if ':' in words[0]:
        return words[1:]
    else:
        return words

def registers_to_binary(words, line, line_number):
    """Masks out the registers in the words and returns a list of them in binary"""
    res = []
    for word in words:
        if word[0] == 'R' and word not in labels:
            try:
                register_num = int(word[1:])
                if register_num > 31 or register_num < 0:
                    raise InvalidArgumentException("\"{}\" must be from R0 up to R31".format(word), \
                            line, line_number)
            except ValueError:
                raise InvalidArgumentException("\"{}\" is not a valid register".format(word), \
                        line, line_number)
            # now we know it's a valid register
            res.append('{0:05b}'.format(register_num))
    return res

def create_add_mul_instruction(words, line, line_number):
    registers = registers_to_binary(words, line, line_number)
    if len(registers) != 3:
        raise InvalidArgumentException("Expected 3 registers, {} were provided".format( \
            expected_regs, len(registers)), line, line_number)
    register_row = ""
    for register in registers:
        register_row += register
    return '111000' + register_row + ADD_MUL_I_FIELD[words[0]]

def create_sfeq_sfne_instruction(words, line, line_number):
    registers = registers_to_binary(words, line, line_number)
    if len(registers) != 2:
        raise InvalidArgumentException("Expected 2 registers, {} were provided".format(len(registers)), \
                line, line_number)
    register_row = ""
    for register in registers:
        register_row += register
    return '111001' + SFEQ_SFNE_D_FIELD[words[0]] + register_row + "00000000000"

def create_sfeqi_sfnei_instruction(words, line, line_number):
    pass

def create_instruction(words, line, line_number):
    """Creates binary code from the parsed line"""
    operation = words[0]
    if OPCODES[operation] == 0x38:
        return create_add_mul_instruction(words, line, line_number)
    elif OPCODES[operation] == 0x39:
        return create_sfeq_sfne_instruction(words, line, line_number)
    elif OPCODES[operation] == 0x2f:
        return create_sfeqi_sfnei_instruction(words, line, line_number)
    

def parse_line(line, line_number):
    words = tokenize(line)
    words = remove_label(words)
    return create_instruction(words, line, line_number)

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

def change_to_upper_case(lines):
    res = []
    for line in lines:
        res.append(line.upper())
    return res

def assemble(argv):
    input_file = argv[1]
    program = Program()
    lines = get_lines(input_file)
    lines = change_to_upper_case(lines)
    find_labels(lines)
    line_number = 0
    for line in lines:
        #program.add_instruction(parse_line(line, line_number))
        line_number += 1
        print(parse_line(line, line_number))

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: \npython3 assembler.py input.s output")
        sys.exit(-1)
    try:
        assemble(sys.argv)
    except LabelError as e:
        print("Label error (at line {}): {}:\n{}".format(e.line_number, e.message, e.line))
    except InvalidArgumentException as e:
        print("Invalid argument (at line {}): {}:\n{}".format(e.line_number, e.message, e.line))


