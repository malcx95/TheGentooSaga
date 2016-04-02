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
   def __init__(self, op, args):
       self.args = args
       self.op = op

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

def parse_line(line):
    pass

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
