#!/usr/bin/env python2

import os
from PIL import Image

openfile = open('pixeloutput.txt', 'w')
total_images = 0

def color_to_bit_string(c, nbits):
    newc = bin(int(round(c/(256//2**nbits))))
    bits = newc[2:]
    return bits.zfill(nbits)

for f in sorted(os.listdir(os.getcwd())): 
    if f.endswith(".png"): # only for .png files
        img = Image.open(f)
        pix = img.load()
        width, height = img.size
        file_name = f.split(".")[0]

        for y in range(height):
            for x in range(width):
                r, g, b, a = pix[x, y]
                r_bits = color_to_bit_string(r, 3)
                g_bits = color_to_bit_string(g, 3)
                b_bits = color_to_bit_string(b, 2)
                num = int(r_bits + g_bits + b_bits, 2)
                #TODO: Add code for transparent pixel
                if (a == 0): #if pixel transparent
                    openfile.write('x"TR"'+",")
                else:
                    openfile.write('x"{:02x}"'.format(num) + ",")
            if (y == 7):
                if (a == 0): #if pixel transparent
                    openfile.write("    -- %s" % file_name)
                else:
                    openfile.write("    -- %s" % file_name)
            openfile.write("\n")
        openfile.write("\n") #empty line after image has been converted
        print "Successfully wrote %s to file" % f
        total_images += 1
print "Finished converting %s images" % total_images