rm e~tb_system.o, ram.o, system.o, tb_system, tb_system.o, wave.ghw, work-obj93.cf
clear all
ghdl -a ram.vhd
ghdl -a system.vhd
ghdl -a tb_system.vhd
ghdl -e tb_system
ghdl -r tb_system --wave=wave.ghw
gtkwave wave.ghw
