#!/usr/bin/env python3
import sys

skeleton = """
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity program_memory is
    port (clk : in std_logic;
          address : in unsigned(10 downto 0);
          data : out std_logic_vector(31 downto 0);
	 uart_data : in unsigned(31 downto 0);
	 uart_write : in std_logic;
	 uart_addr : in unsigned(10 downto 0));
end program_memory;

architecture Behavioral of program_memory is
    constant nop : std_logic_vector(31 downto 0) := x"54000000";

    type memory_type is array (0 to 1023) of std_logic_vector(31 downto 0);
    signal program_memory : memory_type := (
    {}others => nop);

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            if uart_write = '1' then
                program_memory(to_integer(uart_addr)) <= std_logic_vector(uart_data);
            elsif (address >= 4 and address <= 1027) then
                data <= program_memory(to_integer(address - 4));
            else
                data <= nop;
            end if;
        end if;
    end process;
end Behavioral;
"""

KEYS = {
        'SPACE' : 0x8002,
        'LEFT'  : 0x8000,
        'RIGHT' : 0x8001
        }

LEDS = {
        'LED0' : 0x4000,
        'LED1' : 0x4001,
        'LED2' : 0x4002,
        'LED3' : 0x4003,
        'LED4' : 0x4004,
        'LED5' : 0x4005,
        'LED6' : 0x4006,
        'LED7' : 0x4007
        }

user_constants = {}

user_regs = {}

EOF = "111111111111111111111111111111" 

OTHER_ALIASES_READ_ONLY = {
        'NEW_FRAME' : 0x4008,
        'QUERY_RES' : 0x400E
        }

OTHER_ALIASES_WRITE_ONLY = {
        'SONG_CHOICE' : 0x3FFF,
        'MUSIC_MUTE' : 0x3FFD,
        'MUSIC_RESET' : 0x3FFE,
        'SCROLL_OFFSET' : 0x400B,
        'SPRITE1_X' : 0x5000,
        'SPRITE2_X' : 0x5001,
        'LOGO_BL_X' : 0x5002,
        'LOGO_BR_X' : 0x5003,
        'LOGO_TL_X' : 0x5004,
        'LOGO_TR_X' : 0x5005,
        'SPRITE1_Y' : 0x5010,
        'SPRITE2_Y' : 0x5011,
        'LOGO_BL_Y' : 0x5012,
        'LOGO_BR_Y' : 0x5013,
        'LOGO_TL_Y' : 0x5014,
        'LOGO_TR_Y' : 0x5015,
        'QUERY_X' : 0x400C,
        'QUERY_Y' : 0x400D,
        'LEVEL_CHOICE' : 0x3000
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
        'SFEQ',
        'SFNE',
        'SLLI',
        'SRLI',
        'SLL',
        'SRL',
        'SFGEU',
        'SFGEUI',
        'SFEQI',
        'SFNEI',
        'SW',
        'SUB',
        'SUBI',
        'JFN',
        'WAIT',
        'END'
        )

KEYWORDS = (
        'END',
        'REG',
        'CONST',
        'INCLUDE',
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
        'SFGEU': 0x39,
        'SFGEUI': 0x2f,
        'SFEQI' : 0x2f,
        'SFNEI' : 0x2f,
        'SLL' : 0x38,
        'SRL' : 0x38,
        'SLLI' : 0x2d,
        'SRLI' : 0x2d,
        'SUB' : 0x38,
        'SUBI' : 0x25,
        'WAIT' : 0x3F,
        'SW' : 0x35
        }

ADD_MUL_SUB_I_FIELD = {
        'SLL' : "00000001000",
        'SRL' : "00000101000",
        'ADD' : "00000000000",
        'MUL' : "00000000110",
        'SUB' : "00000000010"
        }

SLLI_SRLI_FIELD = {
        'SRLI' : "001",
        'SLLI' : "000"
        }

SFEQ_SFNE_D_FIELD = {
        'SFEQ' : "00000",
        'SFEQI' : "00000",
        'SFNE' : "00001",
        'SFNEI' : "00001",
        'SFGEU' : "00011",
        'SFGEUI': "00011"
        }

EXPECTED_NUM_REGS = {
        'SFEQ': 2,
        'SFNE': 2,
        'SFGEU' : 2,
        'SFEQI': 1,
        'SFNEI': 1,
        'SFGEUI' : 1
        }

OPTIONS = ('-h', '-b', '-f')

NOP = "01010100000000000000000000000000"
WAIT = "11111100000000000000000000000000"

main_file = ""

TWO_POW_26 = 2**26

functions = {}

imported_files = []

class InvalidRegisterException(Exception):
    def __init__(self, message, line, line_number):
        self.message = message
        self.line = line
        self.line_number = line_number

class InvalidFileException(Exception):
    def __init__(self, message, line, line_number):
        self.message = message
        self.line = line
        self.line_number = line_number

class InvalidConstantException(Exception):
    def __init__(self, line, line_number, message=""):
        self.line = line
        self.line_number = line_number
        self.message = message

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

class Register:
    def __init__(self, name, reg, definition_file):
        self.name = name
        self.reg = reg
        self.definition_file = definition_file
        self.used = False

class Constant:
    def __init__(self, name, value, definition_file):
        self.name = name
        self.value = value
        self.definition_file = definition_file
        self.used = False

    def __str__(self):
        return "Constant \"{}\" {} in file {}".format(self.name,\
                self.value, self.definition_file)

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

    def __init__(self, start, lines, definition_file):
        """Constructs a function using the line line_number
            the function starts at, and the lines of the
            raw code. Note that start = 1 means the first line"""
        self.start = start
        self.definition_file = definition_file
        self.code = []
        self.labels = {}
        self._get_function_code(start, lines)
        self.name = self._get_function_name()
        self._remove_func_declaration()
        self.used = False

    def _get_function_code(self, start, lines):
        line_number = start
        while not is_end(lines[line_number]):
            if line_number == len(lines) - 1:
                raise InvalidFunctionException("Missing end declaration of function" \
                        , lines[line_number], line_number)
            elif 'FUNC' in tokenize(lines[line_number]):
                raise InvalidFunctionException("Unexpected \"FUNC\", missing \"END\"?" \
                        , lines[line_number], line_number)
            line_number += 1
        line_number += 1
        self.end = line_number
        self.code = lines[start - 1:line_number]

    def number_of_non_blank_lines(self, starting_line):
        res = 0
        for inst in self.compile_function(starting_line):
            if inst.code:
                res += 1
        return res

    def _get_function_name(self):
        words = tokenize(self.code[0])
        if not ':' in words[1]:
            raise InvalidFunctionException("Function name or colon in name missing",\
                    self.code[0], self.start)
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
            compiled.append(Instruction(parse_line(line, line_number, self.labels, True, self.code), line))
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
                    self.instructions.append(inst)
        else:
            raise ValueError("Neither string nor list")

    def write_to_file(self, output_file, option):
        if option == '-f':
            self._write_binary(output_file)
        else: 
            f = open(output_file, 'w')
            code = ""
            for i in range(len(self.instructions)):
                if option == '-h':
                    code += '\tx\"' + '%08X' % int(self.instructions[i].code, 2) \
                                + '\",' + self.instructions[i].comment
                elif option == '-b':
                    code += '\t\"' + '{0:032b}'.format(int(self.instructions[i].code, 2)) \
                                + '\",' + self.instructions[i].comment
            f.write(skeleton.format(code))
            f.close()
        for function in functions.values():
            if not function.used:
                print("Warning: Function \"{}\" is never used.".format(function.name))
        for c in user_constants.values():
            if not c.used:
                print("Warning: Constant \"{}\" is never used.".format(c.name))
        for reg in user_regs.values():
            if not reg.used:
                print("Warning: Register \"{}\" is never used.".format(reg.name))

    def _write_binary(self, output_file):
        f = open(output_file, "wb")
        debug_file_bin = open("bdebug", 'w')
        debug_file_hex = open("hdebug", 'w')
        raw_instructions = []
        text_bin = ""
        text_hex = ""
        for instruction in self.instructions:
            c = instruction.code
            raw_instructions.append(int(c[0:8], 2))
            raw_instructions.append(int(c[8:16], 2))
            raw_instructions.append(int(c[16:24], 2))
            raw_instructions.append(int(c[24:32], 2))
            text_bin += c + instruction.comment
            text_hex += '%08X' % int(instruction.code, 2) + instruction.comment
        # add end of file
        raw_instructions.append(int(EOF[0:8], 2))
        raw_instructions.append(int(EOF[8:16], 2))
        raw_instructions.append(int(EOF[16:24], 2))
        raw_instructions.append(int(EOF[24:32], 2))

        byte_array = bytes(raw_instructions)
        f.write(byte_array)
        f.close()
        debug_file_bin.write(text_bin)
        debug_file_bin.close()
        debug_file_hex.write(text_hex)
        debug_file_hex.close()
        # write an empty program memory
        pmem = open("../vhdl/program_memory.vhd", 'w')
        pmem.write(skeleton.format(""))

    def __str__(self):
        string = ""
        for line in self.instructions:
            string += line + '\n'
        return string

def is_end(line):
    words = tokenize(line)
    if not words:
        return False
    return words[-1] == 'END'

def get_lines(input_file):
    with open(input_file) as f:
        lines = f.readlines()
        f.close()
        return lines

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
        reg_name = word
        user_reg = False
        if reg_name in user_regs:
            reg_name = user_regs[word].reg
            user_regs[word].used = True
            user_reg = True
        if user_reg or (reg_name[0] == 'R' and \
                reg_name not in labels and \
                reg_name not in KEYS and \
                reg_name not in user_constants):
            try:
                register_num = int(reg_name[1:])
                if register_num > 31 or register_num < 0:
                    raise InvalidArgumentException(\
                            "\"{}\" must be from R0 up to R31".format(reg_name), \
                            line, line_number)
            except ValueError:
                raise InvalidArgumentException(\
                        "\"{}\" is not a valid register".format(reg_name), \
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
    if operand in user_constants:
        c = user_constants[operand]
        c.used = True
        return c.value
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
                "Literal \"{}\" is not a number, key, led or defined constant".format(operand))
    if len(res) > 16: # overflow
        raise InvalidLiteralException(\
                "Number \"{}\" too large, must be 16 bit".format(operand))
    return res

def sfeq_sfne_I_field(words, line, line_number):
    if OPCODES[words[0]] == 0x39:
        return "00000000000"
    else:
        try:
            return parse_literal(words[-1])
        except InvalidLiteralException as e:
            raise InvalidArgumentException(e.message, line, line_number)

def create_add_mul_sub_instruction(words, line, line_number, labels):
    check_arg_length(words, 3, line, line_number)
    register_row = get_regiser_row(words, line, line_number, 3, labels)
    return op_field(words[0]) + register_row + ADD_MUL_SUB_I_FIELD[words[0]]

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

def get_real_distance(start_line, target_line, lines, func_context):
    if func_context:
        return start_line - target_line
    else:
        distance = 0
        for i in range(start_line - 1, target_line - 1):
            words = tokenize(lines[i])
            if 'JFN' in words:
                function = functions[words[-1]]
                function_length = function.number_of_non_blank_lines(i + 1)
                distance += function_length
            elif words:
                distance += 1
        return distance

def num_blank_lines(label, lines):
    i = 0
    res = 0
    while not label in lines[i]:
        i += 1
    words = tokenize(lines[i])
    i += 1
    while not label in lines[i]:
       # if 'FUNC' in lines[i] or 'END' in lines[i]:
       #     res += 1
       #     continue
        temp = ""
        for c in lines[i]:
            if c == '#' or c == ';' or c == '\n':
                break
            elif not (c == ' ' or c == ',' or c == '\t'):
                temp += c
        if not temp:
            res += 1
        i += 1
    return res


def create_jmp_bf_instruction(words, line, line_number, labels, lines, func_context):
    check_arg_length(words, 1, line, line_number)
    if not words[1] in labels:
        raise LabelError("Undefined label {}".format(words[1]), line, line_number)
    length_int = 0
    if not func_context:
        if labels[words[1]] < line_number:
            length_int = -1 * get_real_distance(labels[words[1]], line_number, lines, func_context)
        elif line_number < labels[words[1]]:
            length_int = get_real_distance(line_number, labels[words[1]], lines, func_context)
    else:
        length_int = labels[words[1]] - line_number
        if length_int > 0:
            length_int -= num_blank_lines(words[1], lines)
        else:
            length_int += num_blank_lines(words[1], lines)
    length_bin = '{0:026b}'.format(abs(length_int))
    length = ''
    if length_int < 0:
        length = twos_comp(length_bin)
    else:
        length = length_bin
    return op_field(words[0]) + length

def create_addi_subi_instruction(words, line, line_number, labels):
    check_arg_length(words, 3, line, line_number)
    register_row = get_regiser_row(words, line, line_number, 2, labels)
    return op_field(words[0]) + register_row + parse_literal(words[3])

def create_lw_instruction(words, line, line_number, labels):
    check_arg_length(words, 3, line, line_number)
    register_row = get_regiser_row(words, line, line_number, 2, labels)
    address = ''
    if words[3] in KEYS:
        address = '{0:016b}'.format(KEYS[words[3]])
    elif words[3] in LEDS:
        raise InvalidArgumentException("LEDs cannot be read from", line, line_number)
    elif words[3] in OTHER_ALIASES_READ_ONLY:
        address = '{0:016b}'.format(OTHER_ALIASES_READ_ONLY[words[3]])
    elif words[3] in OTHER_ALIASES_WRITE_ONLY:
        raise InvalidArgumentException("\"{}\" cannot be read from".format(words[3]), line, line_number)
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
    if words[3] in LEDS:
        i_field = '{0:016b}'.format(LEDS[words[3]])
    elif words[3] in KEYS:
        raise InvalidArgumentException("Keys cannot be written to", line, line_number)
    elif words[3] in OTHER_ALIASES_WRITE_ONLY:
        i_field = '{0:016b}'.format(OTHER_ALIASES_WRITE_ONLY[words[3]])
    elif words[3] in OTHER_ALIASES_READ_ONLY:
        raise InvalidArgumentException("\"{}\" cannot be written to".format(words[3]), line, line_number)
    else:
        i_field = parse_literal(words[3])
    return op_field(words[0]) + i_field[:5] + register_row + i_field[5:]

def create_slli_srli_instruction(words, line, line_number, labels):
    check_arg_length(words, 3, line, line_number)
    register_row = get_regiser_row(words, line, line_number, 2, labels)
    i_field = parse_literal(words[3])
    return op_field(words[0]) + register_row + "00000000" + SLLI_SRLI_FIELD[words[0]] + i_field[11:]

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
    function = functions[words[1]]
    function.used = True
    return function.compile_function(line_number)

def check_arg_length(words, exp_num_args, line, line_number):
    if len(words) - 1 != exp_num_args:
        raise InvalidInstructionException("Expected {} argument(s), {} were provided".format( \
            exp_num_args, len(words) - 1), line, line_number)

def create_instruction(words, line, line_number, labels, func_context, lines):
    """Creates binary code from the parsed line"""
    try:
        operation = words[0]
        if operation not in INSTRUCTIONS:
            raise InvalidInstructionException("Unknown instruction \"{}\"".format(operation),\
                    line, line_number)
        if operation == 'JFN':
            return create_function_call(words, line, line_number, func_context)
        instruction = None
        if OPCODES[operation] == 0x38:
            instruction = create_add_mul_sub_instruction(words, line, line_number, labels)
        elif OPCODES[operation] == 0x39 or OPCODES[operation] == 0x2f:
            instruction = create_sfeq_sfne_instruction(words, line, line_number, labels)
        elif operation == 'JMP' or operation == 'BF':
            instruction = create_jmp_bf_instruction(words, line, line_number, labels, lines, func_context)
        elif operation == 'ADDI' or operation == 'SUBI':
            instruction = create_addi_subi_instruction(words, line, line_number, labels)
        elif operation == 'LW':
            instruction = create_lw_instruction(words, line, line_number, labels)
        elif operation == 'MOVHI':
            instruction = create_movhi_instruction(words, line, line_number, labels)
        elif operation == 'NOP':
            instruction = NOP
        elif operation == 'WAIT':
            instruction = WAIT
        elif operation == 'SW':
            instruction = create_sw_instruction(words, line, line_number, labels)
        elif operation == 'SUBI':
            instruction == create_subi_instruction(words, line, line_number, labels)
        elif OPCODES[operation] == 0x2d:
            instruction = create_slli_srli_instruction(words, line, line_number, labels)

        if func_context:
            # this is because the function class creates an instance of Instruction itself
            return instruction
        else:
            return Instruction(instruction, line)

    except InvalidLiteralException as e:
        raise InvalidArgumentException(e.message, line, line_number)

#def remove_comments(words):
#    for word in words:
#        if ';' in word or '#' in word:
#            while True:
#                if ';' in words[-1] or '#' in words[-1]:
#                    return words[:-1]
#                else:
#                    words.pop()
#    return words

def parse_line(line, line_number, labels, func_context, lines):
    words = tokenize(line)
    if not words:
        return []
    if 'FUNC' in words:
        if words[0] != 'FUNC':
            raise InvalidFunctionException(\
                    "I have no idea what you're trying to do here. Put FUNC at the beginning, idiot.", \
                    line, line_number)
        words = words[2:] # remove 'FUNC' and label
    elif words[-1] == 'END': # terminated function
        return 'END'
    words = remove_label(words)
    if not words:
        return []
    return create_instruction(words, line, line_number, labels, func_context, lines)

def find_labels(lines, labels, line_number):
    # removes comments
    lnc = lines # lines no comments
    for i in range(len(lnc)):
        if '#' in lnc[i] or ';' in lnc[i]:
            for j in range(len(lnc[i])):
                if lnc[i][j] == '#' or lnc[i][j] == ';':
                    lnc[i] = lnc[i][:j] + '\n'
                    break

    offset = 0
    for i in range(len(lnc)):
        if ':' in lnc[i + offset]:
            if lnc[i + offset].count(':') != 1:
                raise LabelError(\
                        "Incorrect use of colons, use for declaring labels and functions only", \
                        lnc[i + offset], line_number)
            end_index = 0
            for j in range(len(lnc[i + offset])):
                if lnc[i + offset][j] == ' ':
                    raise LabelError(\
                            "Unexpected space when parsing label", lnc[i + offset], line_number + offset)
                elif lnc[i + offset][j] == ':':
                    end_index = j
                    break
            label = lnc[i + offset][:end_index]
            rest_words = tokenize(lnc[i + offset][end_index + 1:])
            while not rest_words:
                offset += 1
                rest_words = tokenize(lnc[i + offset][end_index + 1:])
            if label in KEYWORDS:
                raise LabelError("\"{}\" is a reserved keyword and cannot be used as a label".format(\
                        label), lnc[i + offset], line_number + offset)
            labels[label] = line_number + offset
        line_number += 1
        if i + 1 + offset >= len(lnc):
            break

def change_to_upper_case(lines):
    res = []
    for line in lines:
        res.append(line.upper())
    return res

def find_functions(lines, file_name):
    line_number = 1
    number_of_lines = len(lines)
    while line_number < number_of_lines:
        words = tokenize(lines[line_number - 1])
        if 'FUNC' in words:
            if not words[0] == 'FUNC':
                raise InvalidFunctionException("Invalid function declaration",\
                        lines[line_number - 1], line_number)
            function = Function(line_number, lines, file_name)
            #number_of_lines -= function.end - line_number
            if function.name in functions:
                existing_fn = functions[function.name]
                raise InvalidFunctionException("In {}: Function {} is already defined in file {}".format(\
                        file_name, existing_fn.name, existing_fn.definition_file), lines[line_number - 1], line_number)
            elif function.name in KEYWORDS:
                raise InvalidFunctionException("In {}: \"{}\" is a reserved keyword and cannot be used as a name".format(\
                        file_name, function.name), lines[line_number - 1], line_number)
            for i in range(line_number - 1, function.end):
                # literally comment out lines. If we merely delete them,
                # line numbers will not be correct
                lines[i] = '; ' +  lines[i]
            functions[function.name] = function
        line_number += 1
    return remove_all_comments_and_blank_lines(lines)

def find_constants(lines, file_name):
    line_number = 1
    for line in lines:
        words = tokenize(line)
        if words: # if the entire row wasnt a comment
            if words[0] == 'CONST':
                if len(words) != 3 or not ':' in words[1]:
                    raise InvalidConstantException(line, line_number)
                try:
                    name = words[1][:-1]
                    if name in user_constants:
                        existing_const = user_constants[name]
                        raise InvalidArgumentException("In {}: Constant {} is already defined in {}".format(\
                                file_name, existing_const.name, existing_const.definition_file), line, line_number)
                    elif name in KEYWORDS:
                        raise InvalidConstantException(line, line_number,\
                                message="In {}: \"{}\" is a reserved keyword and cannot be used as a name".format(\
                                file_name, name))
                    user_constants[name] = Constant(name, parse_literal(words[2]), file_name)
                except InvalidLiteralException as e:
                    raise InvalidArgumentException(e.message, line, line_number)
                # comment out
                lines[line_number - 1] = '; ' + lines[line_number - 1]
        line_number += 1
    return remove_all_comments_and_blank_lines(lines)

def import_file(file_name, line, line_number):
    file_name = file_name.lower()
    if not file_name.endswith('.s'):
        if '.' in file_name:
            raise InvalidFileException("Only .s files can be imported", \
                    line, line_number)
        file_name = file_name + '.s'
    try:
        lines = get_lines(file_name)
    except FileNotFoundError:
        raise InvalidFileException("File {} not found".format(file_name), \
                line, line_number)
    lines = change_to_upper_case(lines)
    lines = remove_all_comments_and_blank_lines(lines)
    check_use_of_labels(lines, file_name)
    lines = find_imports(lines)
    lines = find_functions(lines, file_name)
    lines = find_constants(lines, file_name)
    find_regs(lines, file_name)


def find_imports(lines):
    line_number = 1
    for line in lines:
        if 'INCLUDE' in line:
            words = tokenize(line)
            if words:
                for word in words[1:]:
                    if not word in imported_files:
                        imported_files.append(word)
                        import_file(word, line, line_number)
                lines[line_number - 1] = '; ' + lines[line_number - 1]
        line_number += 1
    return remove_all_comments_and_blank_lines(lines)

def check_use_of_labels(lines, file_name):
    line_number = 1
    for line in lines:
        if ':' and not 'FUNC' in line:
            words = tokenize(line)
            if words:
                if ':' in words[-1]:
                    raise LabelError("Labels, constants and registers can't be line broken", \
                            line, "{} in file \"{}\"".format(line_number, file_name))
        line_number += 1

def reg_already_used(register):
    for r in user_regs.values():
        if r.reg == register.reg:
            return True
    return False

def find_regs(lines, file_name):
    line_number = 1
    for line in lines:
        words = tokenize(line)
        if words: # if the entire row wasnt a comment
            if words[0] == 'REG':
                if len(words) != 3 or not ':' in words[1]:
                    raise InvalidRegisterException("In {}: Invalid register declaration".format(\
                            file_name), line, line_number)
                name = words[1][:-1]
                if name in user_regs:
                    existing_reg = user_regs[name]
                    raise InvalidRegisterException("In {}: Constant {} is already defined in {}".format(\
                            file_name, existing_reg.name, existing_reg.definition_file), line, line_number)
                elif name in KEYWORDS:
                    raise InvalidRegisterException("In {}: \"{}\" is a reserved keyword and cannot be used as a name".format(\
                            file_name, name), line, line_number)
                register = Register(name, words[2], file_name)
                if reg_already_used(register):
                    print("Warning: Register {} referenced by more than one name".format(register.reg))
                user_regs[name] = register
                # comment out
                lines[line_number - 1] = '; ' + lines[line_number - 1]
        line_number += 1
    return remove_all_comments_and_blank_lines(lines)

def remove_all_comments_and_blank_lines(lines):
    res = []
    for line in lines:
        index = 0
        if not tokenize(line):
            continue
        elif '#' in line or ';' in line:
            while line[index] != '#' and line[index] != ';':
                index += 1
            new_line = line[:index] + "\n"
            if tokenize(new_line):
                res.append(new_line)
        else:
            res.append(line)
    return res
        

def assemble(argv):
    args = CommandLineArgs(argv)
    main_file = args.input_file
    program = Program()
    labels = {}
    lines = get_lines(main_file)
    lines = change_to_upper_case(lines)
    lines = remove_all_comments_and_blank_lines(lines)
    check_use_of_labels(lines, main_file)
    lines = find_imports(lines)
    lines = find_constants(lines, main_file)
    lines = find_regs(lines, main_file)
    lines = find_functions(lines, main_file)
    find_labels(lines, labels, 1)
    line_number = 1
    for line in lines:
        program.add_instruction(parse_line(line, line_number, labels, False, lines))
        line_number += 1
    program.write_to_file(args.output_file, args.option)

if __name__ == "__main__":
    if len(sys.argv) != 4 or sys.argv[1] == '--help':
        print("Usage: \n./assembler.py <options> input.s output.vhd\n\n" + \
                "Options:\t-f\tas binary file\n\t\t-b\tas .vhd file in binary\n\t\t" +\
                "-h\tas .vhd file in hexadecimal\n\t\t--help (or no option)\tto show this helpful shit")
        sys.exit(-1)
    try:
        assemble(sys.argv)
        print("Assembly done.")
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
    except InvalidConstantException as e:
        if not e.message:
            print("Invalid constant declaration (at line {}):\n{}".format(e.line_number, e.line))
        else:
            print("Invalid constant declaration (at line {}):\n{}\n{}".format(e.line_number, e.message, e.line))
        sys.exit(-1)
    except InvalidFileException as e:
        print("Invalid file name (at line {}):\n{}:\n{}".format(\
                e.line_number, e.message, e.line))
        sys.exit(-1)
    except InvalidRegisterException as e:
        print("Invalid register (at line {}):\n{}:\n{}".format(\
                e.line_number, e.message, e.line))
        sys.exit(-1)
    sys.exit(0)
