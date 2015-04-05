library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
library std;
use std.textio.all;

entity system is
	port (
	  clk : in std_logic;
	  reset_n : in std_logic;
	  enable_pc :in std_logic;

	  address_s   :     in std_logic_vector(7 downto 0);
	  sys_datain  :     in std_logic_vector(31 downto 0);
	  sys_dataout :     out std_logic_vector(31 downto 0);

	  Data_Addr   :     in std_logic_vector(7 downto 0);
	  Data_datain :     in std_logic_vector(31 downto 0);
	  Data_dataout:     out std_logic_vector(31 downto 0)
	);
end entity system;

architecture RTL of system is
	
   signal pc : unsigned (7 downto 0);

   type reg_type is array(0 to 31) of std_logic_vector(31 downto 0);
   signal regs,regs_comb : reg_type;

	begin
		--mémoire du system
		dut1 : entity work.ram(RTL)
		port map(
			clock   => clk,
			we      => reset_n,
			address  => address_s,
			datain  => sys_datain,
			dataout => sys_dataout
		);

		--mémoire de données
		dut2 : entity work.ram(RTL)
		port map(
			clock   => clk,
			we      => reset_n,
			address  => Data_Addr,
			datain  => Data_datain,
			dataout => Data_dataout
		);


	--creer les regs du systeme
	reg_inst :process(reset_n,clk)
	begin
		if reset_n = '0' then
			for i in 0 to 31 loop
				regs(i) <= (others => '0');
			end loop;
		elsif rising_edge(clk) then
			for i in 0 to 31 loop
				regs(i) <= regs_comb(i);
			end loop;
		end if;
	end process;

	--lire les données
	read_data :process(reset_n,clk)
	begin
		if reset_n = '0' then
			for i in 0 to 31 loop
				regs(i) <= (others => '0');
			end loop;
		elsif rising_edge(clk) then
			regs_comb(to_integer(unsigned(Data_Addr))) <= Data_datain;
		end if;
	end process;

	-- faire des operations
	stim: process
		variable a:std_logic;
		variable x: integer range 0 to 2**14-1;
		variable y :integer range 0 to 2**14-1;
		variable num_r1, num_r3 : std_logic_vector(4 downto 0);
		variable num_r2 : std_logic_vector(13 downto 0);
	begin
		case sys_datain(31 downto 24) is
			
			--add
			when  "00000001" => 
				--r1
				num_r1 :=  sys_datain(23 downto 19);
				x       := to_integer(unsigned(regs(to_integer(unsigned(num_r1) ))));
				--r2 
				-- bit 18 = 0 => constant, bit 18 = '1' => registre
				if sys_datain(18) = '0' then
					y := to_integer(unsigned(sys_datain(18 downto 5)));
				else
					num_r2    := "000000000" & sys_datain(9 downto 5);
					y := to_integer(unsigned(regs(to_integer(unsigned(num_r2)))));
				end if;
				regs(to_integer(unsigned(num_r3))) <= std_logic_vector(to_unsigned(x+y,14));			
				--r3
				num_r3    := sys_datain(4 downto 0);
				regs(to_integer(unsigned(num_r3))) <= std_logic_vector(to_unsigned(x+y,14));
		
			--multiplier
			when "00000011" => 
				--r1
				num_r1 := ('0' & sys_datain(23 downto 19));
				x       := to_integer(unsigned(regs(to_integer(unsigned(num_r1) ))));
				--r2 
				if sys_datain(18) = '0' then
					y := to_integer(unsigned(sys_datain(18 downto 5)));
				else
					num_r2    := "000000000" & sys_datain(9 downto 5);
					y := to_integer(unsigned(regs(to_integer(unsigned(num_r2)))));
				end if;
				--r3
				num_r3    := sys_datain(4 downto 0);
				regs(to_integer(unsigned(num_r3))) <= std_logic_vector(to_unsigned(x*y,14));
			when others => null;
		
		end case;
	end process;


	--pc: program counter
	pc_p : process(clk,reset_n)
	begin
		if reset_n= '0' then
			pc <= to_unsigned(0,8);
		elsif rising_edge(clk) then
			if enable_pc = '1' then
				pc <= pc+1;
			end if;
		end if;
	end process;
	
end architecture RTL;
