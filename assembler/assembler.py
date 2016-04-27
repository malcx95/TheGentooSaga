#!/usr/bin/env python3
import sys

skeleton = """
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity program_memory is
    port (clk : in std_logic;
          address : in unsigned(10 downto 0);
          data : out std_logic_vector(31 downto 0));
end program_memory;

architecture Behavioral of program_memory is
    constant nop : std_logic_vector(31 downto 0) := x"54000000";
    
    type memory_type is array (0 to {}) of std_logic_vector(31 downto 0);
    signal program_memory : memory_type := ( 
{} );

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            if (address <= {}) then
                data <= program_memory(to_integer(address));
            else
                data <= nop;
            end if;
        end if;
    end process;
end Behavioral;"""

KEYS = {
        'SPACE' : 0x8002,
        'LEFT'  : 0x8000,
        'RIGHT' : 0x8001
        }

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
        'END'
        )

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

OPTIONS = ('-h', '-b', '-f')

NOP = "01010100000000000000000000000000"

TWO_POW_26 = 2**26

functions = {}

class UnknownOptionException(Exception):
    def __init__(self,  option):
        self.option = option

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

class CommandLineArgs:
    def __init__(self, argv):
        opt_index = self._get_option_index(argv)
        self.option = argv.pop(opt_index)
        if not self.option in OPTIONS:
            raise UnknownOptionException(self.option)
        self.input_file = argv[1]
        self.output_file = argv[2]
        
    def _get_option_index(self, argv):
        for i in range(len(argv)):
            if argv[i][0] == '-':
                return i

class Function:
    """Representation of a function"""

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
    
    def compile_function(self, starting_line):
        """Compiles a function for a place in the code. Returns the compiled code."""
        find_labels(self.code, self.labels, starting_line)
        compiled = []
        line_number = starting_line
        for line in self.code:
            compiled.append(Instruction(parse_line(line, line_number, self.labels, True), line))
            line_number += 1
        return compiled[:-1]

class Instruction:
    def __init__(self, code, comment):
        self.code = code
        self.comment = "\t-- " + comment

class Program:
    """Class representing a compiled program"""
    def __init__(self):
        self.instructions = []
    
    def add_instruction(self, instruction):
        if isinstance(instruction, Instruction):
            self.instructions.append(instruction)
        elif isinstance(instruction, list):
            for inst in instruction:
                if inst.code:
                    self.instructions += [inst]
        else:
            raise ValueError("Neither string nor list")

    def write_to_file(self, output_file, option):

        f = open(output_file, 'w')
        code = ""
        for i in range(len(self.instructions)):
            if i == len(self.instructions) - 1:
                code += '\tx\"' + '%08X' % int(self.instructions[i].code, 2) \
                        + '\"\t' + self.instructions[i].comment
            else:
                code += '\tx\"' + '%08X' % int(self.instructions[i].code, 2) \
                        + '\",' + self.instructions[i].comment
        f.write(skeleton.format(len(self.instructions) - 1, code, len(self.instructions) - 1))

    def __str__(self):
        string = ""
        for line in self.instructions:
            string += line + '\n'
        return string

def get_lines(input_file):
    with open(input_file) as f:
        return f.readlines()

def op_field(operation):
    return '{0:06b}'.format(OPCODES[operation])

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

def registers_to_binary(words, line, line_number, labels):
    """Masks out the registers in the words and returns a list of them in binary"""
    res = []
    for word in words:
        if word[0] == 'R' and word not in labels and word not in KEYS:
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
    elif operand[0:2] == '0x': # hex
        res = '{0:016b}'.format(int(operand, 16))
    elif operand.isdigit(): # dec
        res = '{0:016b}'.format(int(operand))
    else: # invalid operand
        raise InvalidLiteralException(\
                "Literal \"{}\" is not a number or key".format(operand))
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

def create_add_mul_instruction(words, line, line_number, labels):
    check_arg_length(words, 3, line, line_number)
    register_row = get_regiser_row(words, line, line_number, 3, labels)
    return op_field(words[0]) + register_row + ADD_MUL_I_FIELD[words[0]]

def register_or_registers(num_regs):
    """Yes I know this is a pretty stupid thing to care
    about but deal with it"""
    if num_regs == 1:
        return 'register'
    else:
        return 'registers'

def create_sfeq_sfne_instruction(words, line, line_number, labels):
    check_arg_length(words, 2, line, line_number)
    num_regs = EXPECTED_NUM_REGS[words[0]]
    register_row = get_regiser_row(words, line, line_number, num_regs, labels)
    return op_field(words[0]) + \
            SFEQ_SFNE_D_FIELD[words[0]] + register_row + \
            sfeq_sfne_I_field(words, line, line_number)

def twos_comp(num):
    num_int = int(num, 2)
    return '{0:026b}'.format(TWO_POW_26 - num_int)
    
def create_jmp_bf_instruction(words, line, line_number, labels):
    check_arg_length(words, 1, line, line_number)
    if not words[1] in labels:
        raise LabelError("Undefined label {}".format(words[1]), line, line_number)
    length_int = labels[words[1]] - line_number
    length_bin = '{0:026b}'.format(abs(length_int))
    length = ''
    if length_int < 0:
        length = twos_comp(length_bin)
    else:
        length = length_bin
    return op_field(words[0]) + length

def create_addi_instruction(words, line, line_number, labels):
    check_arg_length(words, 3, line, line_number)
    register_row = get_regiser_row(words, line, line_number, 2, labels)
    return op_field(words[0]) + register_row + parse_literal(words[3])

def create_lw_instruction(words, line, line_number, labels):
    check_arg_length(words, 3, line, line_number)
    register_row = get_regiser_row(words, line, line_number, 2, labels)
    address = ''
    if words[3] in KEYS:
        address = '{0:016b}'.format(KEYS[words[3]])
    else:
        address = parse_literal(words[3])
    return op_field(words[0]) + register_row + address

def create_movhi_instruction(words, line, line_number, labels):
    check_arg_length(words, 2, line, line_number)
    register_row = get_regiser_row(words, line, line_number, 1, labels)
    return op_field(words[0]) + register_row + "00000" + parse_literal(words[2])

def create_sw_instruction(words, line, line_number, labels):
    check_arg_length(words, 3, line, line_number)
    register_row = get_regiser_row(words, line, line_number, 2, labels)
    i_field = parse_literal(words[3])
    return op_field(words[0]) + i_field[:5] + register_row + i_field[5:]

def get_regiser_row(words, line, line_number, exp_reg, labels):
    registers = registers_to_binary(words, line, line_number, labels)
    if len(registers) != exp_reg:
        raise InvalidArgumentException(\
                "Expected {} {}, {} were provided".format( \
                exp_reg, register_or_registers(exp_reg), len(registers)), line, line_number)
    register_row = ""
    for register in registers:
        register_row += register
    return register_row

def create_function_call(words, line, line_number, func_context):
    check_arg_length(words, 1, line, line_number)
    if func_context:
        raise InvalidFunctionException(\
                "Function calls within functions are not supported",\
                line, line_number)
    elif words[1] not in functions:
        raise InvalidArgumentException("Undefined function {}".format(words[1]), \
                line, line_number)
    return functions[words[1]].compile_function(line_number)

def check_arg_length(words, exp_num_args, line, line_number):
    if len(words) - 1 != exp_num_args:
        raise InvalidInstructionException("Expected {} argument(s), {} were provided".format( \
            exp_num_args, len(words) - 1), line, line_number)

def create_instruction(words, line, line_number, labels, func_context):
    """Creates binary code from the parsed line"""
    try:
        operation = words[0]
        if operation not in INSTRUCTIONS:
            raise InvalidInstructionException("Unknown instruction \"{}\"".format(operation),\
                    line, line_number)
        if operation == 'JFN':
            return create_function_call(words, line, line_number, func_context)
        if func_context:
            if OPCODES[operation] == 0x38:
                return create_add_mul_instruction(words, line, line_number, labels)
            elif OPCODES[operation] == 0x39 or OPCODES[operation] == 0x2f:
                return create_sfeq_sfne_instruction(words, line, line_number, labels)
            elif operation == 'JMP' or operation == 'BF':
                return create_jmp_bf_instruction(words, line, line_number, labels)
            elif operation == 'ADDI':
                return create_addi_instruction(words, line, line_number, labels)
            elif operation == 'LW':
                return create_lw_instruction(words, line, line_number, labels)
            elif operation == 'MOVHI':
                return create_movhi_instruction(words, line, line_number, labels)
            elif operation == 'NOP':
                return NOP
            elif operation == 'SW':
                return create_sw_instruction(words, line, line_number, labels)
        else:
            if OPCODES[operation] == 0x38:
                return Instruction(create_add_mul_instruction(words, line, line_number, labels), line)
            elif OPCODES[operation] == 0x39 or OPCODES[operation] == 0x2f:
                return Instruction(create_sfeq_sfne_instruction(words, line, line_number, labels), line)
            elif operation == 'JMP' or operation == 'BF':
                return Instruction(create_jmp_bf_instruction(words, line, line_number, labels), line)
            elif operation == 'ADDI':
                return Instruction(create_addi_instruction(words, line, line_number, labels), line)
            elif operation == 'LW':
                return Instruction(create_lw_instruction(words, line, line_number, labels), line)
            elif operation == 'MOVHI':
                return Instruction(create_movhi_instruction(words, line, line_number, labels), line)
            elif operation == 'NOP':
                return Instruction(NOP, line)
            elif operation == 'SW':
                return Instruction(create_sw_instruction(words, line, line_number, labels), line)
    except InvalidLiteralException as e:
        raise InvalidArgumentException(e.message, line, line_number)

def remove_comments(words):
    for word in words:
        if ';' in word or '#' in word:
            while True:
                if ';' in words[-1] or '#' in words[-1]:
                    return words[:-1]
                else:
                    words.pop()
    return words

def parse_line(line, line_number, labels, func_context):
    words = tokenize(line)
    if 'FUNC' in words:
        words = words[2:] # remove 'FUNC' and label
    elif 'END' in words: # terminated function
        return 'END'
    words = remove_comments(words)
    if not words:
        return []
    words = remove_label(words)
    return create_instruction(words, line, line_number, labels, func_context)

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
            labels[label] = line_number
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
                raise InvalidFunctionException("Invalid function declaration",\
                        line, line_number)
            function = Function(line_number, lines)
            lines = lines[:line_number - 1] + lines[function.end:]
            number_of_lines -= function.end - line_number
            functions[function.name] = function
        if 'FUNC:' in words:
            raise InvalidFunctionException("Missing function name", line, line_number)
        line_number += 1
    return lines

def assemble(argv):
    args = CommandLineArgs(argv)
    input_file = args.input_file
    program = Program()
    labels = {}
    lines = get_lines(input_file)
    lines = change_to_upper_case(lines)
    lines = find_functions(lines)
    find_labels(lines, labels, 1)
    line_number = 1
    for line in lines:
        program.add_instruction(parse_line(line, line_number, labels, False))
        line_number += 1
    program.write_to_file(args.output_file, args.option)

if __name__ == "__main__":
    if len(sys.argv) != 4 or sys.argv[1] == '--help':
        print("Usage: \npython3 assembler.py <options> input.s output.vhd\n\n" + \
                "Options:\t-f\tas binary file\n\t\t-b\tas .vhd file in binary\n\t\t" +\
                "-h\tas .vhd file in hexadecimal\n\t\t--help\tto show this helpful shit")
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
    except UnknownOptionException as e:
        print("Unknown option \"{}\" (use --help for help)".format(e.option))
        sys.exit(-1)
    except FileNotFoundError as e:
        print("Input file does not exist")
        sys.exit(-1)
    sys.exit(0)
