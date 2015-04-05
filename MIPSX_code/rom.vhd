library IEEE;
use std.textio.ALL;
use ieee.std_logic_textio.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


 
 entity ROM is
port ( REMM: OUT STD_logic_vector(31 downto 0);
       H:in std_logic;
       eremm: IN std_logic;
  
       address: in std_logic_vector(2 downto 0));
   
end ROM ;

architecture behavioral of ROM is
 
     type blocrom is array(0 to 255) of bit_vector(31 downto 0);
     impure function Norm (FichierToto : in string) return blocrom is      
       FILE Fichrom : text is in FichierToto
       variable ls : line;                                
       variable RAMM : blocrom;
        
begin
       Boucle : for I in blocrom'range loop 
           readline (Fichrom, ls); 
           read (ls, RAMM(I)); 
         end loop Boucle;
          return RAMM;   
           end function;
           signal RAMM : blocrom := Norm(B"00011010001111000010111110111101");
     
            
   process(h)
      begin
   
       if h'event and h = '1' then 
          if eRemm = '1' then
             REMM <= to_stdlogicvector(RAMM(conv_integer(<address>))); 
          end if;  
       end if;   
   
   
 end process;                      
    
end Behavioral;
