#!/usr/bin/env python3

import sys

offsets = {
    'C'  : 0,
    'C#' : 1,
    'Db' : 1,
    'D'  : 2,
    'D#' : 3,
    'Eb' : 3,
    'E'  : 4,
    'F'  : 5,
    'F#' : 6,
    'Gb' : 6,
    'G'  : 7,
    'G#' : 8,
    'Ab' : 8,
    'A'  : 9,
    'A#' : 10,
    'Bb' : 10,
    'B'  : 11
}

def note_number(note_name):
    octave = int(note_name[-1])
    note = note_name[:-1]
    return offsets[note] + octave*12

def chunks(l, n):
    """Yield successive n-sized chunks from l."""
    for i in range(0, len(l), n):
        yield l[i:i+n]

def bit_string(val, nbits):
    newc = bin(val)
    bits = newc[2:]
    return bits.zfill(nbits)

# Calculation
input_data = sys.stdin.read().split()
chunkified_data = chunks(input_data, 2)
parsed_data = [(int(length) - 1, note_number(name)) for length, name in chunkified_data]

# Formatting
bin_data = [bit_string(length, 2) + bit_string(number, 6) for length, number in parsed_data]
int_data = [int(bits, 2) for bits in bin_data]
hex_data = ['x"{:02x}"'.format(value) for value in int_data]

# Output
lines = [", ".join(chunk) for chunk in chunks(hex_data, 8)]
output = ",\n".join(lines)
print(output)
