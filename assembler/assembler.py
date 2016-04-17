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
        'SFEQ': 2,
        'SFNE': 2,
        'SFEQI': 1,
        'SFNEI': 1
        }

labels = {}

class InvalidLiteralException(Exception):
    def __init__(self, message):
        self.message = message

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
                    raise InvalidArgumentException(\
                            "\"{}\" must be from R0 up to R31".format(word), \
                            line, line_number)
            except ValueError:
                raise InvalidArgumentException(\
                        "\"{}\" is not a valid register".format(word), \
                        line, line_number)
            # now we know it's a valid register
            res.append('{0:05b}'.format(register_num))
    return res

def bit_extend(operand, length):
    if len(operand) >= length:
        return operand
    else:
        return '0' + bit_extend(operand, length - 1)

def parse_literal(operand):
    operand = operand.lower()
    res = ''
    if operand[0] == '0' and operand[1] == 'b' and \
            operand[2:].isdigit(): # binary
        res = bit_extend(operand[2:], 16)
    elif operand[0] == '0' and operand[1] == 'x' and \
            operand[2:].isdigit(): # hex
        res = '{0:016b}'.format(int(operand, 16))
    elif operand.isdigit(): # dec
        res = '{0:016b}'.format(int(operand))
    else: # invalid operand
        raise InvalidLiteralException(\
                "Literal \"{}\" is not a number".format(operand))
    if len(res) > 16: # overflow
        raise InvalidLiteralException(\
                "Literal \"{}\" too large, must be 16 bit".format(operand))
    return res

def sfeq_sfne_I_field(words, line, line_number):
    if OPCODES[words[0]] == 0x39:
        return "00000000000"
    else:
        try:
            return parse_literal(words[-1])
        except InvalidLiteralException as e:
            raise InvalidArgumentException(e.message, line, line_number)

def create_add_mul_instruction(words, line, line_number):
    registers = registers_to_binary(words, line, line_number)
    if len(registers) != 3:
        raise InvalidArgumentException(\
                "Expected 3 registers, {} were provided".format( \
            expected_regs, len(registers)), line, line_number)
    register_row = ""
    for register in registers:
        register_row += register
    return '111000' + register_row + ADD_MUL_I_FIELD[words[0]]

def register_or_registers(num_regs):
    """Yes I know this is a pretty stupid thing to care
    about but deal with it"""
    if num_regs == 1:
        return 'register'
    else:
        return 'registers'

def create_sfeq_sfne_instruction(words, line, line_number):
    registers = registers_to_binary(words, line, line_number)
    num_regs = EXPECTED_NUM_REGS[words[0]]
    if len(registers) != num_regs:
        raise InvalidArgumentException(\
                "Expected {} {}, {} were provided".format( \
                num_regs, register_or_registers(num_regs), len(registers)), line, line_number)
    register_row = ""
    for register in registers:
        register_row += register
    return '{0:06b}'.format(OPCODES[words[0]]) + \
            SFEQ_SFNE_D_FIELD[words[0]] + register_row + sfeq_sfne_I_field(words, line, line_number)

def create_instruction(words, line, line_number):
    """Creates binary code from the parsed line"""
    operation = words[0]
    if OPCODES[operation] == 0x38:
        return create_add_mul_instruction(words, line, line_number)
    elif OPCODES[operation] == 0x39 or OPCODES[operation] == 0x2f:
        return create_sfeq_sfne_instruction(words, line, line_number)
   # elif OPCODES[operation] == 0x2f:
   #     return create_sfeqi_sfnei_instruction(words, line, line_number)
    

def parse_line(line, line_number):
    words = tokenize(line)
    words = remove_label(words)
    return create_instruction(words, line, line_number)

def find_labels(lines):
    line_number = 1
    for line in lines:
        if ':' in line:
            if line.count(':') != 1:
                raise LabelError(\
                        "Incorrect use of colons, use for declaring labels only", \
                        line, line_number)
            end_index = 0
            for i in range(len(line)):
                if line[i] == ' ':
                    raise LabelError(\
                            "Unexpected space when parsing label", line, line_number)
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
        print("Label error (at line {}):\n{}:\n{}".format(\
                e.line_number, e.message, e.line))
        sys.exit(-1)
    except InvalidArgumentException as e:
        print("Invalid argument (at line {}):\n{}:\n{}".format(\
                e.line_number, e.message, e.line))
        sys.exit(-1)
    sys.exit(0)


