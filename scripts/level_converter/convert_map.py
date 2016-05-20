#!/usr/bin/env python2

import os
import json

save_path = '../../vhdl/'
name_of_file = 'level_mem'
completeName = os.path.join(save_path, name_of_file+".vhd")  
open_file = open(completeName, 'w')
tile = 0

skeleton_top = """library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity level_mem is
    port (
        clk      : in std_logic;
        data_out : out std_logic_vector(4 downto 0);
        addr    : in unsigned(11 downto 0);
		level_choice : in std_logic;
        query_addr : in unsigned(11 downto 0);
        query_result : out std_logic
         );
end level_mem;

architecture Behavioral of level_mem is
    type ram_t is array (0 to 2249) of std_logic_vector(4 downto 0);
    signal pictMem : ram_t := (
"""
end_of_code = ");"
start_of_you_win_level = """

signal you_win : ram_t := (
"""
skeleton_bottom = """

	signal query_help : unsigned(4 downto 0);
	signal data_main : std_logic_vector(4 downto 0);
	signal data_win : std_logic_vector(4 downto 0);

begin
    process(clk)
    begin
        if rising_edge(clk) then
            data_main <= pictMem(to_integer(addr));
            data_win <= you_win(to_integer(addr));
            query_help <= unsigned(pictMem(to_integer(query_addr)));
        end if;
    end process;

    query_result <= '0' when query_help > 15 else '1';

	with level_choice select data_out <=
		data_main when '0',
		data_win when others;

end Behavioral;
"""

open_file.write(skeleton_top)
with open('testmap.json') as data_file:
    json_data = json.load(data_file)
map_data = json_data["layers"][0]["data"]

with open('you-win.json') as win_data_file:
    win_json_data = json.load(win_data_file)
win_map_data = win_json_data["layers"][0]["data"]

transformed_data = [
        [map_data[y*150+x] for x in range(150)] for y in range(15)
]

win_transformed_data = [
        [win_map_data[y*150+x] for x in range(150)] for y in range(15)
]

for x in range(150):
    for y in range(15):
        if (transformed_data[y][x]-1 > 31):
            print "Number too big at y:"+str(y)+" x: "+str(x)
        if (tile%5 == 0):
            if (not tile == 0):
                open_file.write("\n")
            open_file.write("           ")
        if (tile == 2249):
            open_file.write('"'+"{0:05b}".format(transformed_data[y][x]-1)+'"')
        else:
            open_file.write('"'+"{0:05b}".format(transformed_data[y][x]-1)+'"'+", ")
        tile+=1
open_file.write(end_of_code)
open_file.write(start_of_you_win_level)
tile = 0
for x in range(150):
    for y in range(15):
        if (tile%5 == 0):
            if (not tile == 0):
                open_file.write("\n")
            open_file.write("           ")
        if (tile == 2249):
            open_file.write('"'+"{0:05b}".format(win_transformed_data[y][x]-1)+'"')
        else:
            open_file.write('"'+"{0:05b}".format(win_transformed_data[y][x]-1)+'"'+", ")
        tile+=1
open_file.write(end_of_code)
open_file.write(skeleton_bottom)
print "File successfully written!"

