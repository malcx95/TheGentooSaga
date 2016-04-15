#!/usr/dev/env python3

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

note_and_octave = input()
octave = int(note_and_octave[-1])
note = note_and_octave[:-1]
