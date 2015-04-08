
rm *.o, *.cf, *.ghw
clear all
ghdl -a ram.vhd
ghdl -a system.vhd
ghdl -a tb_system.vhd
ghdl -e tb_system
ghdl -r tb_system --wave=wave.ghw
gtkwave wave.ghw
