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
	


    type reg_type      is array(0 to 31) of std_logic_vector(31 downto 0);
	type reg_addr_type is array(0 to 31) of std_logic_vector(7 downto 0);
    signal regs_Data,      regs_Inst    	 : reg_type;
	signal regs_Data_addr, regs_Inst_addr    : reg_addr_type;
    signal pc                                : unsigned (7 downto 0);
	signal sys_reset                         : std_logic := '0' ;

	signal operation                         : std_logic_vector (7 downto 0);
	signal op1,op3                           : std_logic_vector (4 downto 0);
	signal op2                               : std_logic_vector (13 downto 0);
	signal result                            : std_logic_vector (31 downto 0);
	signal count_Inst						 : integer :=0;
	signal count_Data                        : integer :=0;
	

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
		pc_p : process(clk,sys_reset)
		begin
			if sys_reset= '1' then
				pc <= to_unsigned(0,8);
			elsif rising_edge(clk) then
				if enable_pc = '1' then
					pc <= pc+1;
				end if;
			end if;
		end process;
	
	--creer les regs du systeme
--	reg_inst :process(sys_reset,clk)
--	begin
--		if sys_reset = '1' then
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
	read_data :process(Data_reset,clk)
	begin
		if Data_reset = '0' then
			for i in 0 to 31 loop
				regs_Data(i)       <= (others => '0');
				regs_Data_addr(i)  <= (others => '0');
			end loop;
		elsif rising_edge(clk) then
			regs_Data(to_integer(unsigned(Data_addr))) <= Data_datain;
			regs_Data_addr(count_Data)                          <= Data_addr;
			count_Data <= count_Data+1;
		end if;
	end process;

	read_instructions :process(Inst_reset,clk)
	begin
		if Inst_reset = '0' then
			for i in 0 to 31 loop
				regs_Inst(i) 	  <= (others => '0');
				regs_Inst_addr(i) <= (others => '0');
			end loop;
		elsif rising_edge(clk) then
			regs_Inst(to_integer(unsigned(Inst_addr))) <= Inst_datain;
			regs_Inst_addr(count_Inst) <= Inst_addr;
			count_Inst <= count_Inst+1;
		end if;
	end process;

	-- idenetifier les operations et registres
	stim_ALU_identifier: process(clk)
	begin
			operation <= Inst_datain(31 downto 24);
			op1 	  <= Inst_datain(23 downto 19);
			op2		  <= Inst_datain(18 downto 5);
			op3		  <= Inst_datain(4 downto 0);
	end process;
	
	stim_ALU_calcul: process(clk,operation,op1,op2,op3)
		variable x,y     : std_logic_vector (31 downto 0);
		variable carry_t : std_logic;
		variable sum_t   : std_logic_vector (31 downto 0);
	begin
		if rising_edge(clk) then
			case operation is
				when  "00000001" => 
					report "entering in add";	
					x := regs_Data(to_integer(unsigned(op1)));
				--op2(13) = '0' -> constant '1' -> registre
					if op2(13) = '0' then
						y := "000000000000000000" & op2;
					else
						y := regs_Data(to_integer(unsigned(op2)));
					end if;
					carry_t := '0';
					for i in 0 to 31 loop
						sum_t(i) := x(i) xor y(i) xor carry_t;
						carry_t := (x(i) and y(i)) or (carry_t and (x(i) or y(i)));
					end loop;
					result <= sum_t;
				--	regs_Data(to_integer(unsigned(op3))) <= sum_t;
				when others => report "entered operations";
			end case;
		end if;
	end process;

end architecture RTL;
