from PIL import Image

input_img =  raw_input("input file: ")
img = Image.open(input_img)
openfile = open('output.txt', 'a')

pix = img.load()
width, height = img.size

def color_to_bit_string(c, nbits):
    newc = bin(int(round(c/(256//2**nbits))))
    bits = newc[2:]
    return bits.zfill(nbits)

for y in range(height):
    for x in range(width):
        r, g, b, a = pix[x, y]
        r_bits = color_to_bit_string(r, 3)
        g_bits = color_to_bit_string(g, 3)
        b_bits = color_to_bit_string(b, 2)
        num = int(r_bits + g_bits + b_bits, 2)
        if (a == 0): #if pixel transparent
            openfile.write('x"TR"'+" ")
        else:
            openfile.write('x"{:02x}"'.format(num) + " ")
    openfile.write("\n")
openfile.write("\n") #empty line after image has been converted
print "Successfully wrote to file!"
