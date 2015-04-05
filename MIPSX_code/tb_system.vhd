library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
library std;
use std.textio.all;

entity tb_system is

end entity;

--sys_datain
--8bits     5bits 14bits 5bits
--operation  R1    o     R3
--pour o si le permier bit = 0 ,c'est un constant
--              sinon, c'est un registre  

--ADD 00000001
architecture RTL of tb_system is
	signal clk          :  std_logic := '0';
	signal enable       :  std_logic := '1';
	signal enable_pc    :  std_logic := '1';
	signal stop         :  boolean;

	signal sys_address  :  std_logic_vector(7 downto 0);
	signal sys_datain   :  std_logic_vector(31 downto 0);
	signal sys_dataout  :  std_logic_vector(31 downto 0);

	signal Data_Addr   :   std_logic_vector(7 downto 0);
	signal Data_datain :   std_logic_vector(31 downto 0);
	signal Data_dataout:   std_logic_vector(31 downto 0);
	
	--signal addr : integer ;
	--signal data : std_logic_vector(31 downto 0);
--period
	procedure wait_cycles(n: natural) is
	begin
		for i in 1 to n loop
			wait until rising_edge(clk);
		end loop;
	end procedure;
	
	begin
	--clock and enable
		clk <= not(clk) after 10 ns when not(stop) else '0';
		--enable <= '1';
		stop <= not(stop) after 10000 ns;
	--configure entity
		dut : entity work.system(RTL)
		port map(
			clk   => clk,
			reset_n      => enable,
			enable_pc   => enable_pc,

			address_s  => sys_address,
			sys_datain  => sys_datain,
			sys_dataout => sys_dataout,

			Data_Addr    => Data_Addr,
			Data_datain  => Data_datain,
			Data_dataout => Data_dataout
		);

	--variable r1,r2,r3:std_logic_vector(4 downto 0);
	--variable op :std_logic_vector(5 downto 0);


	--sequential stimuli read the file of instructions
	stim :process
		file F : text;
		variable l :line;
		variable status : file_open_status;
		variable addr,data :integer;
	begin
		report "running testbench for system(RTL)";
		report "waiting for asynchronous enable";
		wait until enable = '1';
		FILE_OPEN(status,F,"instructions.txt", read_mode);
		if status /=open_ok then
			report "problem to open file";
		else 
			while not ENDFILE(F) loop
				readline(F, l);
				read(l,addr);
                		read(l,data);
			    	sys_address <= std_logic_vector(to_unsigned(addr , 8 )) ;
				sys_datain <= std_logic_vector(to_unsigned(data , 32 )) ;
				wait_cycles(1);
				--sys_datain <= std_logic_vector(to_unsigned(0 , 16)) ;
				--wait_cycles(1);
			end loop;
			FILE_CLOSE(F);
		end if;
	end process;

	--sequentiel stimuli read the file of data
	stim_read_data :process
		file F : text;
		variable l :line;
		variable status : file_open_status;
		variable addr,data :integer;
	begin
		report "running testbench for system(RTL)";
		report "waiting for asynchronous enable";
		wait until enable = '1';
		FILE_OPEN(status,F,"data.txt", read_mode);
		if status /=open_ok then
			report "problem to open file";
		else 
			while not ENDFILE(F) loop
				readline(F, l);
				read(l,addr);
                		read(l,data);
			    	Data_Addr <= std_logic_vector(to_unsigned(addr , 8 )) ;
				Data_datain <= std_logic_vector(to_unsigned(data , 32 )) ;
				wait_cycles(1);
				--sys_datain <= std_logic_vector(to_unsigned(0 , 16)) ;
				--wait_cycles(1);
			end loop;
			FILE_CLOSE(F);
		end if;
	end process;
end architecture RTL;
