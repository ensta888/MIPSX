library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
library std;
use std.textio.all;

entity ram is
	port (
	clock : in std_logic;
	we : in std_logic;
	address : in std_logic_vector(7 downto 0);
	datain : in std_logic_vector(31 downto 0);
	dataout : out std_logic_vector(31 downto 0)
);
end entity ram;

architecture RTL of ram is
	type ram_type is array (0 to (2**8-1)) of std_logic_vector(datain'range);
	signal ram : ram_type := (others => (others => '0'));
	signal read_address : std_logic_vector(address'range);

	begin
		RamProc : process(clock) is
			begin
			if rising_edge(clock) then
				if we = '1' then -- write
					ram(to_integer(unsigned(address))/4) <= datain;
				end if;
				read_address <= address;
			end if;
		end process RamProc;
	dataout <= ram(to_integer(unsigned(read_address))/4);
end architecture RTL;
