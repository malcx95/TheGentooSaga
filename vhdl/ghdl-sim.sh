#!/bin/bash
#./script_name entity_name <time><unit>
#./script_name gpu_tb 1ms

WAVE_PATH=wave.ghw

ghdl -m --workdir=work $1
ghdl -r --workdir=work $1 --stop-time=$2 --wave=$WAVE_PATH
#gtkwave $WAVE_PATH
