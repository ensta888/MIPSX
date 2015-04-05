--------------------------------------------------------------------------------
-- Engineer: skycanny
-- Module Name: fulladder - Behavioral
-- Tool versions: ISE 7.1
-- Description: This module is designed to discribe a full adder with carry
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fulladder is
	port(
	reset : in std_logic;
	clk : in std_logic;
	operand1: in std_logic_vector(7 downto 0);
	operand2: in std_logic_vector(7 downto 0);
	carry : out std_logic;
	sum : out std_logic_vector(7 downto 0)
	);
end fulladder;

architecture Behavioral of fulladder is
begin
	process(reset,clk)
		variable sum_t : std_logic_vector(7 downto 0);
		variable carry_t: std_logic;
	begin
		if(reset = '0') then
			carry <= '0';
			sum <= (others => '0');
		elsif(rising_edge(clk)) then
			carry_t := '0';
			for i in 0 to 7 loop
				sum_t(i) := operand1(i) xor operand2(i) xor carry_t;
				carry_t := (operand1(i) and operand2(i)) or (carry_t and (operand1(i) or operand2(i)));
			end loop;
			carry <= carry_t;
			sum <= sum_t;
		end if;
	end process;
end Behavioral;
