#!/bin/python
import sys

INSTRUCTIONS = (
        'ADD',
        'ADDI',
        'BF',
        'JMP',
        'LW',
        'MOVHI',
        'MUL',
        'NOP',
        'SFEQ' ,
        'SFNE' ,
        'SFEQI',
        'SFNEI',
        'SW',
        'JFN',
        'END')

KEYWORDS = (
        'END',
        'FUNC'
            )

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

functions = []

labels = {}

class InvalidFunctionException(Exception):
    def __init__(self, message, line, line_number):
        self.message = message
        self.line = line
        self.line_number = line_number

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

class InvalidInstructionException(Exception):
    def __init__(self, message, line, line_number):
        self.message = message
        self.line = line
        self.line_number = line_number

class Function:
    """Representation of a function"""

    # TODO remove the lines making up the function
    # TODO parse functions first

    def __init__(self, start, lines):
        """Constructs a function using the line line_number
            the function starts at, and the lines of the
            raw code. Note that start = 1 means the first line"""
        self.start = start
        self.code = []
        self.labels = {}
        self._get_function_code(start, lines)
        self.name = self._get_function_name()
        self._remove_func_declaration()

    def _get_function_code(self, start, lines):
        line_number = start
        while not 'END' in lines[line_number]:
            line_number += 1
        line_number += 1
        self.end = line_number
        self.code = lines[start - 1:line_number]

    def _get_function_name(self): 
        words = tokenize(self.code[0])
        if not ':' in words[1]:
            raise InvalidFunctionException("Function name or colon in name missing",\
                    code[0], self.start)
        name_end = 0
        for i in range(len(words[1])):
            if words[1][i] == ':':
                name_end = i
                break
        return words[1][0:name_end]

    def _remove_func_declaration(self):
        line = self.code[0]
        end = 0
        for i in range(len(line)):
            if line[i] == ':':
                end = i
                break
        end += 1
        self.code[0] = line[end:]
    
    def compile(self, starting_line):
        """Compiles a function for a place in the code. Returns the compiled code."""
        find_labels(self.code, self.labels, starting_line)
        compiled = []
        line_number = starting_line
        for line in self.code:
            compiled.append(parse_line(line, line_number))
            line_number += 1
        # TODO test if labels work
        return compiled[:-1]

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
    if operand[0:2] == '0b' and \
            operand[2:].isdigit(): # binary
        res = bit_extend(operand[2:], 16)
    elif operand[0:2] == '0x' and \
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
    if operation not in INSTRUCTIONS:
        raise InvalidInstructionException("Unknown instruction {}".format(operation),\
                line, line_number)
    if OPCODES[operation] == 0x38:
        return create_add_mul_instruction(words, line, line_number)
    elif OPCODES[operation] == 0x39 or OPCODES[operation] == 0x2f:
        return create_sfeq_sfne_instruction(words, line, line_number)
    # TODO parse rest instructions

def parse_line(line, line_number):
    words = tokenize(line)
    if 'FUNC' in words:
        words = words[2:] # remove 'FUNC' and label
    elif 'END' in words: # terminated function
        return 'END'
    else:
        words = remove_label(words)
    return create_instruction(words, line, line_number)

def find_labels(lines, labels, line_number):
    for line in lines:
        if ':' in line:
            if line.count(':') != 1:
                raise LabelError(\
                        "Incorrect use of colons, use for declaring labels and functions only", \
                        line, line_number)
            end_index = 0
            for i in range(len(line)):
                if line[i] == ' ':
                    raise LabelError(\
                            "Unexpected space when parsing label", line, line_number)
                elif line[i] == ':':
                    end_index = i
                    break
            label = line[:end_index]
            if label in KEYWORDS:
                raise LabelError("\"{}\" is a reserved keyword and cannot be used as a label".format(\
                        label), line, line_number)
            labels[line_number] = label
        line_number += 1

def change_to_upper_case(lines):
    res = []
    for line in lines:
        res.append(line.upper())
    return res

def find_functions(lines):
    line_number = 1
    number_of_lines = len(lines)
    while line_number < number_of_lines:
        words = tokenize(lines[line_number - 1])
        if 'FUNC' in words:
            if not words[0] == 'FUNC':
                raise InvalidFunctionException("Invalid function declaration", line, line_number)
            function = Function(line_number, lines)
            lines = lines[:line_number - 1] + lines[function.end:]
            number_of_lines -= function.end - line_number
            functions.append(function)
        if 'FUNC:' in words:
            raise InvalidFunctionException("Missing function name", line, line_number)
        line_number += 1

def assemble(argv):
    input_file = argv[1]
    program = Program()
    lines = get_lines(input_file)
    lines = change_to_upper_case(lines)
    find_functions(lines)
    find_labels(lines, labels, 1)
    line_number = 1
    for line in lines:
        #program.add_instruction(parse_line(line, line_number))
        print(parse_line(line, line_number))
        line_number += 1

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: \npython3 assembler.py input.s output.vhd")
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
    except InvalidFunctionException as e:
        print("Invalid function (at line {}):\n{}:\n{}".format(\
                e.line_number, e.message, e.line))
        sys.exit(-1)
    except InvalidInstructionException as e:
        print("Invalid instruction (at line {}):\n{}:\n{}".format(\
                e.line_number, e.message, e.line))
        sys.exit(-1)
    sys.exit(0)


