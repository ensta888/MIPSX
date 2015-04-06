			case Inst_datain(31 downto 24) is
				--add
				when  "00000001" => 
					report "entering in add";
					--r1
					num_r1 :=  Inst_datain(23 downto 19);
					--x       := to_integer(unsigned(regs(to_integer(unsigned(num_r1) ))));
					x := regs(to_integer(unsigned(num_r1)));

					--r2 
					-- bit 18 = 0 => constant, bit 18 = '1' => registre
					if Inst_datain(18) = '0' then
						--y := to_integer(unsigned(Inst_datain(18 downto 5)));
						y := "000000000000000000" & Inst_datain(18 downto 5);
					else
						num_r2    := "000000000" & Inst_datain(9 downto 5);
						--y := to_integer(unsigned(regs(to_integer(unsigned(num_r2)))));
						y := regs(to_integer(unsigned(num_r2)));
					end if;
		
					--r3
					num_r3    := Inst_datain(4 downto 0);
					carry_t := '0';
					for i in 0 to 31 loop
						sum_t(i) := x(i) xor y(i) xor carry_t;
						carry_t := (x(i) and y(i)) or (carry_t and (x(i) or y(i)));
					end loop;
					--carry <= carry_t;
					regs(to_integer(unsigned(num_r3))) <= sum_t;
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
					--r3
	--				num_r3    := Inst_datain(4 downto 0);
	--				regs(to_integer(unsigned(num_r3))) <= std_logic_vector(to_unsigned(x*y,14));
				when others => report "entered operations";
		
			end case;
