#!/usr/bin/env python2

import os
from PIL import Image

# Path to images folder.
# Relative to folder in which the script is in.
image_path = "images"

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
        
def main():  
    # Output file
    openfile = open('output.txt', 'w')
    # Total images converted
    total_images = 0

        
    # Runs for every png in images folder.
    for f in sorted(os.listdir(os.getcwd()+"/"+image_path)): 
        img = is_valid_image(f)
        if img:
            pix = img.load()
            width, height = img.size
            file_name = f.split(".")[0]
            
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
    if(total_images == 0):
        print "No images in folder. 0 Images converted."
    else:
        print "Finished converting %s images" % total_images

if images_folder_exists():
    main()
else:
    os.makedirs(image_path)
    print '\033[91m'+"Image folder does not exist. \nAn empty folder, 'images', has been created, add your images in it and rerun the script."
