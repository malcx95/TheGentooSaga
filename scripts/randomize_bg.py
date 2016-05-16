#!/usr/bin/env python2

import random
import itertools

openfile = open('output.txt', 'w')

def random_star():
    if random.randint(0, 14) == 0:
        return random.randint(0, 3)
    return 0

def set_tile(sky, x, y, val):
    sky[x*15 + (14 - y)] = val

# Randomize stars
night_sky = [random_star() for i in range(2250)]

# Mountain generation
left_middle = 5
left_side_top = 6
left_side = 7
right_middle = 8
right_side_top = 9
right_side = 10

def create_slice(y, height):
    if y == height - 1:
        return [
            [y, y, left_side_top],
            [y + 1, y, right_side_top]
        ]

    half_middle_length = height - y - 1

    left_part = [y, y, left_side]
    right_part = [height*2 - y - 1, y, right_side]

    middle_left_part = [[y + 1 + i, y, left_middle] for i in range(half_middle_length)]
    middle_right_part = [[height + i, y, right_middle] for i in range(half_middle_length)]

    return [left_part] + middle_left_part + middle_right_part + [right_part]


def create_mountain(height):
    slices = [create_slice(y, height) for y in range(height)]
    return itertools.chain(*slices)


# Create some mountains
level_width = 150
mountain_start = 0
while mountain_start < level_width:
    offset = random.randint(0, 4)
    mountain_height = random.randint(4, 7)

    if mountain_start + offset + mountain_height*2 < level_width:
        mountain_start += offset
        for x, y, t in create_mountain(mountain_height):
            set_tile(night_sky, x + mountain_start, y, t)
        mountain_start += mountain_height*2
    else:
        break


for i in range(2250):
    if (i%5 == 0):
        openfile.write("\n")
    openfile.write('"'+"{0:05b}".format(night_sky[i])+'",' )
