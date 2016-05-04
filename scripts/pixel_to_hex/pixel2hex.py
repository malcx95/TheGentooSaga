#!/usr/bin/env python2

import os
from PIL import Image

# Path to images folder.
# Relative to folder in which the script is in.
image_path = "images"
# Output file
openfile = open('output.txt', 'w')

def color_to_bit_string(c, nbits):
    newc = bin(int(round(c/(256//2**nbits))))
    bits = newc[2:]
    return bits.zfill(nbits)

# Check if images path exists.
def images_folder_exists():
    if os.path.exists(image_path):
        return True
    else:
        return False

def is_valid_image(f):
    try:
        file = Image.open(image_path+"/"+f)
    except IOError:
        print f + " is not an image"
        return False
    return file

def output_default_solid(amount):
    for i in range(amount):
        for j in range(16):
            for k in range(16):
                openfile.write('x"00",')
            openfile.write("\n")
        openfile.write("\n")

def output_default_transparent(amount):
    for i in range(amount):
        for j in range(16):
            for k in range(16):
                openfile.write('x"e0",')
            openfile.write("\n")
        openfile.write("\n")
        
def main():  
    # Total images converted
    total_images = 0
    solid_tiles_left = 16
    transparent_tiles_left = 16

        
    # Runs for every png in images folder.
    for f in sorted(os.listdir(os.getcwd()+"/"+image_path)): 
        img = is_valid_image(f)
        if img:
            pix = img.load()
            width, height = img.size
            file_name = f.split(".")[0]
            file_name_prefix = file_name.split("-")[0]

            if (file_name_prefix == "s"):
                solid_tiles_left-=1
                if (solid_tiles_left == -1):
                    print "Too many solid tiles! Must have maximum of 16."
                    break

            elif (file_name_prefix == "t"):
                if (solid_tiles_left > 0): # if no solid tiles in images folder left.
                    output_default_solid(solid_tiles_left) # fill rest of 16 solid tiles with default solid tile.
                transparent_tiles_left-=1
                if (transparent_tiles_left == -1):
                    print "Too many transparent tiles! Must have maximum of 16."
                    break

            else:
                print file_name + " is neither a transparent or solid tile. Add 's-' or 't-' prefix to the filename to specify a type."
                continue 

            # Loops through entire image
            for y in range(height):
                for x in range(width):
                    if (img.mode == "RGBA"):
                        r, g, b, a = pix[x, y]
                    else:
                        r, g, b = pix[x, y]
                    r_bits = color_to_bit_string(r, 3)
                    g_bits = color_to_bit_string(g, 3)
                    b_bits = color_to_bit_string(b, 2)
                    num = int(r_bits + g_bits + b_bits, 2)
                    '''
                     for filetypes that do not support transparency,
                     you will need to check for a certain color if
                     you need transparency
                    '''
                    if (img.mode == "RGBA" and a == 0): #if pixel transparent
                        openfile.write('x"TR"'+",")
                    else:
                        openfile.write('x"{0:02x}"'.format(num) + ",")
                # adds the file name as comment on row 7
                if (y == 7):
                    if (img.mode == "RGBA" and a == 0): #if pixel transparent
                        openfile.write("    -- %s" % file_name)
                    else:
                        openfile.write("    -- %s" % file_name)
                openfile.write("\n")
            openfile.write("\n") #empty line after image has been converted
            print "Successfully wrote %s to output" % f
            total_images += 1
    if(total_images == 0 and transparent_tiles_left == 16 and solid_tiles_left == 16):
        print "No images in folder. 0 Images converted."
    else:
        if (transparent_tiles_left > 0):
            output_default_transparent(transparent_tiles_left)
        print "Finished converting %s images" % total_images

if images_folder_exists():
    main()
else:
    os.makedirs(image_path)
    print '\033[91m'+"Image folder does not exist. \nAn empty folder, 'images', has been created, add your images in it and rerun the script."
