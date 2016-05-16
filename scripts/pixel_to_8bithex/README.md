# pixel_to_8bithex
A python script to convert a png image to 8 bit hex code.

## Instructions
1. "Download ZIP".
2. Extract anywhere
3. Navigate to where the script is and run `chmod +x pixel2hex.py`.
4. Add your .png images in the 'images' folder.
5. Run the script: `./pixel2hex.py`.
6. The results can be found in 'output.txt' in the same folder as the script.

## Info
The results will be overwritten if you run the script again. By removing an image from the images folder you will also remove it from the output.

## Example input & output
###Input
![Alt text](http://i.imgur.com/1afoW3A.png "16x16 penguin sprite")

###Output
`x"e0",x"e0",x"e0",x"e0",x"e0",x"49",x"49",x"49",x"49",x"49",x"49",x"e0",x"e0",x"e0",x"e0",x"e0",
x"e0",x"e0",x"e0",x"e0",x"49",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"49",x"e0",x"e0",x"e0",x"e0",
x"e0",x"e0",x"e0",x"49",x"49",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"49",x"49",x"e0",x"e0",x"e0",
x"e0",x"e0",x"e0",x"49",x"b6",x"ff",x"db",x"ff",x"ff",x"db",x"ff",x"b6",x"49",x"e0",x"e0",x"e0",
x"e0",x"e0",x"e0",x"49",x"b6",x"ff",x"00",x"ff",x"ff",x"00",x"ff",x"b6",x"49",x"e0",x"e0",x"e0",
x"e0",x"e0",x"e0",x"49",x"ff",x"ff",x"ff",x"f9",x"f9",x"ff",x"ff",x"ff",x"49",x"e0",x"e0",x"e0",
x"e0",x"e0",x"49",x"b6",x"ff",x"ff",x"ff",x"f4",x"f4",x"ff",x"ff",x"ff",x"b6",x"49",x"e0",x"e0",
x"e0",x"e0",x"49",x"b6",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"b6",x"49",x"e0",x"e0",    -- pengu
x"e0",x"e0",x"49",x"b6",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"b6",x"49",x"e0",x"e0",
x"e0",x"e0",x"49",x"b6",x"ff",x"b6",x"ff",x"ff",x"ff",x"ff",x"b6",x"ff",x"b6",x"49",x"e0",x"e0",
x"e0",x"e0",x"49",x"b6",x"ff",x"b6",x"ff",x"ff",x"ff",x"ff",x"b6",x"ff",x"b6",x"49",x"e0",x"e0",
x"e0",x"e0",x"49",x"49",x"b6",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"b6",x"49",x"49",x"e0",x"e0",
x"e0",x"e0",x"e0",x"49",x"49",x"b6",x"ff",x"ff",x"ff",x"ff",x"b6",x"49",x"49",x"e0",x"e0",x"e0",
x"e0",x"e0",x"e0",x"e0",x"49",x"49",x"b6",x"b6",x"b6",x"b6",x"49",x"49",x"e0",x"e0",x"e0",x"e0",
x"e0",x"e0",x"e0",x"e0",x"f0",x"49",x"49",x"49",x"49",x"49",x"49",x"f0",x"e0",x"e0",x"e0",x"e0",
x"e0",x"e0",x"e0",x"f0",x"f0",x"f0",x"e0",x"e0",x"e0",x"e0",x"f0",x"f0",x"f0",x"e0",x"e0",x"e0",`


## Requirements
Python 2
