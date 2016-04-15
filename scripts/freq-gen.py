#!/usr/bin/env python3

# See http://www.phy.mtu.edu/~suits/NoteFreqCalcs.html for explanation of the equation used

offsets = {
    'C' : -9,
    'C#' : -8,
    'Db' : -8,
    'D' : -7,
    'D#' : -6,
    'Eb' : -6,
    'E' : -5,
    'F' : -4,
    'F#' : -3,
    'Gb' : -3,
    'G' : -2,
    'G#' : -1,
    'Ab' : -1,
    'A' : 0,
    'A#' : 1,
    'Bb' : 1,
    'B' : 2
}

# The base frequency - in this case A4
f0 = 440

a = 2 ** (1/12)
cpu_freq = 10 ** 8

def frequency_for_note(n):
    return f0 * a**n

def note_name_to_offset(note_name):
    octave = int(note_name[-1])
    note = note_name[:-1]
    return offsets[note] + (octave - 4) * 12

def chunks(l, n):
    """Yield successive n-sized chunks from l."""
    for i in range(0, len(l), n):
        yield l[i:i+n]

# Input data
# start_note = input("Note to start generate table from: ").upper()
# number_of_notes = int(input("Number of notes in table: "))
start_note = "C2"
number_of_notes = 64
steps = note_name_to_offset(start_note)

# Calculation
frequencies = [frequency_for_note(steps + i) for i in range(number_of_notes)]
cycles = [int(round(1/freq * cpu_freq)) for freq in frequencies]
hex_codes = ['x"{:06X}"'.format(c) for c in cycles]

# Formatting
lines = [", ".join(chunk) for chunk in chunks(hex_codes, 5)]
output = ",\n".join(lines)
print(output)
