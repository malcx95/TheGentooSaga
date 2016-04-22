#!/usr/bin/env python3

from common_music import *

def bit_string(val, nbits):
    newc = bin(val)
    bits = newc[2:]
    return bits.zfill(nbits)

# Formatting
rising = [bit_string(3, 2) + bit_string(number, 6) for number in range(64)]
rise_and_fall = rising + list(reversed(rising))
int_data = [int(bits, 2) for bits in rise_and_fall]
hex_data = ['x"{:02x}"'.format(value) for value in int_data]

# Output
lines = [", ".join(chunk) for chunk in chunks(hex_data, 8)]
output = ",\n".join(lines)

print(output)
