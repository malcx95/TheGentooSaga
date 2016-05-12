#!/usr/bin/env python2

import random
openfile = open('output.txt', 'w')

lel = ["00001", "00010", "00011", "00100"]

for i in range(2250):
    if (i%5 == 0):
        openfile.write("\n")
    if random.randint(0,14) == 0:
        openfile.write('"'+lel[random.randint(0,3)]+'",' )
    else:
        openfile.write('"00000",')
