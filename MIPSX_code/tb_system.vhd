library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
library std;
use std.textio.all;

entity tb_system is

end entity;

--Inst_datain
--8bits     5bits 14bits 5bits
--operation  R1    o     R3
--pour o si le permier bit = 0 ,c'est un constant
--              sinon, c'est un registre  

--ADD 00000001
architecture RTL of tb_system is
	constant HALF_PERIOD :  time      := 10 ns;
	signal running       :  boolean   := true;
	signal running_Inst  :  boolean   ;
	signal running_Data  :  boolean   ;
	signal clk           :  std_logic := '0';
	signal enable_pc     :  std_logic := '1';

	signal Inst_we       :  std_logic := '0';
	signal Inst_addr     :  std_logic_vector(7 downto 0);
	signal Inst_datain   :  std_logic_vector(31 downto 0);
	signal Inst_dataout  :  std_logic_vector(31 downto 0);

	signal Data_we     :   std_logic;
	signal Data_sel    :   std_logic;
	signal Data_addr   :   std_logic_vector(7 downto 0);
	signal Data_datain :   std_logic_vector(31 downto 0);
	signal Data_dataout:   std_logic_vector(31 downto 0);

	signal reset_n       : std_logic := '0';
--period
	procedure wait_cycles(n: natural) is
	begin
		for i in 1 to n loop
			wait until rising_edge(clk);
		end loop;
	end procedure;
	
	begin
	--clock and enable
		clk <= not(clk) after HALF_PERIOD when running else '0';
		reset_n <= '0', '1' after 150 ns; 
		Inst_we <= '0', '1' after 200 ns;
--		Data_we <= '0', '1' after 50 ns;
		running <= running_Data or running_Inst;
	
--		running <= false after 600 ns;
	
	--configure entity
		dut : entity work.system(RTL)
		port map(
			clk          => clk,
			enable_pc    => enable_pc,

			Inst_we   => Inst_we,
			Inst_addr    => Inst_addr,
			Inst_datain  => Inst_datain,
			Inst_dataout => Inst_dataout,

			Data_we      => Data_we,
			Data_sel	 => Data_sel,
			Data_addr    => Data_addr,
			Data_datain  => Data_datain,
			Data_dataout => Data_dataout
		);

	--sequentiel stimuli read the file of data
	stim_read_instructions :process
		file F : text open read_mode is "instructions.txt";
		variable l :line;
		variable i :natural :=0;
		variable addr,data :integer;
	begin
		Inst_datain <= std_logic_vector (to_unsigned(0,32));
		running_Inst <= true;
		--Inst_we  <= '0';
		report "waiting for reading data";
		report "waiting for reset instructions";
	--	wait until reset_n='1';
		wait until Inst_we='1';
		report "reset instructions ok";
		
		for i in 0 to 9 loop
			wait until rising_edge(clk);
		end loop;

		report "reading Instructions";
		while not ENDFILE(F) loop
			wait until rising_edge(clk);
			readline(F, l);
			read(l,addr);
            read(l,data);
		    Inst_addr <= std_logic_vector(to_unsigned(addr , 8 )) ;
			Inst_datain <= std_logic_vector(to_unsigned(data , 32 )) ;
			--Inst_we   <= '1';
			i:=i+1;
		end loop;
		--Inst_we   <= '0';
		wait until rising_edge(clk);
		report "reading" & integer'image(i) & "stim_read_instructions / Done";
		for i in 0 to 9 loop
			wait until rising_edge(clk);
		end loop;
		FILE_CLOSE(F);
		report "end of reading";
		report "end of game from Inst";
		running_Inst <= false ;
	   	wait;
		
	end process;

	--sequential stimuli read the file of instructions

	stim_read_data :process
		file F : text open read_mode is "data.txt";
		variable l :line;
		variable i :natural :=0;
		variable addr,data :integer;
begin
		running_Data <= true;
		Data_datain <= std_logic_vector (to_unsigned(0,32));
		Data_sel <= '0';
		Data_we  <= '0';
		report "waiting for reset data";	
		wait until reset_n='1';
		report "reset data ok";
		
		for i in 0 to 9 loop
			wait until rising_edge(clk);
		end loop;

		report "reading data";
		Data_sel <= '1';
		while not ENDFILE(F) loop
			wait until rising_edge(clk);
			readline(F, l);
			read(l,addr);
            read(l,data);
		    Data_addr <= std_logic_vector(to_unsigned(addr , 8 )) ;
			Data_datain <= std_logic_vector(to_unsigned(data , 32 )) ;
			Data_we <= '1';
			i:=i+1;
		end loop;
		wait until rising_edge(clk);
		report "reading " & integer'image(i) & " stim_read_data / Done";
		for i in 0 to 9 loop
			wait until rising_edge(clk);
		end loop;
		Data_sel <= '0';
		report "end of reading data";
		FILE_CLOSE(F);
		report "end of game from data";
		running_Data <= false ;
	   	wait;
		
	end process;
	

end architecture RTL;
