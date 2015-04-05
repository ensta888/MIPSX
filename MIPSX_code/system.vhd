library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
library std;
use std.textio.all;

entity system is
	port (
	  clk          :     in std_logic;
	  enable_pc    :     in std_logic;

	  Inst_reset   :     in std_logic;
	  Inst_addr    :     in std_logic_vector(7 downto 0);
	  Inst_datain  :     in std_logic_vector(31 downto 0);
	  Inst_dataout :     out std_logic_vector(31 downto 0);

	  Data_reset   :     in std_logic;
	  Data_addr    :     in std_logic_vector(7 downto 0);
	  Data_datain  :     in std_logic_vector(31 downto 0);
	  Data_dataout :     out std_logic_vector(31 downto 0)
	);
end entity system;

architecture RTL of system is
	


    type reg_type is array(0 to 31) of std_logic_vector(31 downto 0);
    signal regs,regs_comb : reg_type;
	
    signal pc : unsigned (7 downto 0);
	signal reset_sys : std_logic := '0' ;
	

	begin
		--mémoire du instruction
		RAM_INST_instancier : entity work.ram(RTL)
		port map(
			clock   => clk,
			we      => Inst_reset,
			address => Inst_addr,
			datain  => Inst_datain,
			dataout => Inst_dataout
		);

		--mémoire de données
		RAM_DATA_instancier : entity work.ram(RTL)
		port map(
			clock      => clk,
			we         => Data_reset,
			address    => Data_addr,
			datain     => Data_datain,
			dataout    => Data_dataout
		);

		--pc: program counter
		pc_p : process(clk,reset_sys)
		begin
			if reset_sys= '1' then
				pc <= to_unsigned(0,8);
			elsif rising_edge(clk) then
				if enable_pc = '1' then
					pc <= pc+1;
				end if;
			end if;
		end process;
	
	--creer les regs du systeme
--	reg_inst :process(reset_n,clk)
--	begin
--		if reset_n = '0' then
--			for i in 0 to 31 loop
--				regs(i) <= (others => '0');
--			end loop;
--		elsif rising_edge(clk) then
--			for i in 0 to 31 loop
--				regs(i) <= regs_comb(i);
--			end loop;
--		end if;
--	end process;

	--lire les données
--	read_data :process(reset_n,clk)
--	begin
--		if reset_n = '0' then
--			for i in 0 to 31 loop
--				regs(i) <= (others => '0');
--			end loop;
--		elsif rising_edge(clk) then
--			regs_comb(to_integer(unsigned(Data_addr))) <= Data_datain;
--		end if;
--	end process;

	-- faire des operations
--	stim: process
--		variable a              : std_logic;
--		variable x,y            : std_logic_vector(13 downto 0);
--		variable num_r1, num_r3 : std_logic_vector(4 downto 0);
--		variable num_r2         : std_logic_vector(13 downto 0);
--		variable carry_t        : std_logic;
--		variable sum_t          : std_logic_vector(13 downto 0);
--	begin
--		case Inst_datain(31 downto 24) is
			
			--add
--			when  "00000001" => 
				--r1
--				num_r1 :=  Inst_datain(23 downto 19);
				--x       := to_integer(unsigned(regs(to_integer(unsigned(num_r1) ))));
--				x := regs(to_integer(unsigned(num_r1)));

				--r2 
				-- bit 18 = 0 => constant, bit 18 = '1' => registre
--				if Inst_datain(18) = '0' then
					--y := to_integer(unsigned(Inst_datain(18 downto 5)));
--					y := Inst_datain(18 downto 5);
--				else
--					num_r2    := "000000000" & Inst_datain(9 downto 5);
					--y := to_integer(unsigned(regs(to_integer(unsigned(num_r2)))));
--					y := regs(to_integer(unsigned(num_r2)));
--				end if;
		
				--r3
--				num_r3    := Inst_datain(4 downto 0);
--				carry_t := '0';
--				for i in 0 to 13 loop
--					sum_t(i) := x(i) xor y(i) xor carry_t;
--					carry_t := (x(i) and y(i)) or (carry_t and (x(i) or y(i)));
--				end loop;
--				carry <= carry_t;
--				regs(to_integer(unsigned(num_r3))) <= sum_t;
				--regs(to_integer(unsigned(num_r3))) <= std_logic_vector(to_unsigned(x+y,14));
		
			--multiplier
--			when "00000011" => 
				--r1
--				num_r1 := ('0' & Inst_datain(23 downto 19));
--				x       := to_integer(unsigned(regs(to_integer(unsigned(num_r1) ))));
				--r2 
--				if Inst_datain(18) = '0' then
--					y := to_integer(unsigned(Inst_datain(18 downto 5)));
--				else
--					num_r2    := "000000000" & Inst_datain(9 downto 5);
--					y := to_integer(unsigned(regs(to_integer(unsigned(num_r2)))));
--				end if;
--				--r3
--				num_r3    := Inst_datain(4 downto 0);
---				regs(to_integer(unsigned(num_r3))) <= std_logic_vector(to_unsigned(x*y,14));
--			when others => null;
		
---		end case;
--	end process;

end architecture RTL;
