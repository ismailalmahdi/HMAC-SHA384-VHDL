library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.HMACSHA384_ISMAIL.all;

entity hmac_sha384 is
  port ( clk: in std_logic;
  		 salt : in std_logic_vector(383 downto 0);
  		 pepper : in std_logic_vector(1023 downto 0); 
  		 small_msg: in std_logic_vector((6*4)-1 downto 0);
  		 medium_msg: in std_logic_vector((46*4)-1 downto 0);
  		 big_msg: in std_logic_vector((126*4)-1 downto 0);
  		 hashed_code: out std_logic_vector(383 downto 0));
end entity ; -- main

architecture sha_behaviour of hmac_sha384 is
type msg is (small, medium, big);
signal cur_state, next_state : msg := small;
begin

p0: process(clk) is
	begin
   		if (rising_edge(clk)) then
   			cur_state <= next_state;
    	end if;
end process;

p1: process (small_msg,medium_msg,big_msg,cur_state) is
	begin

	case (cur_state) is
		 when small => 
				next_state <= medium; 
		 	hashed_code <= hmacsha384(salt,pepper,small_msg);
			
		 when medium =>
				next_state <= big;
		 	hashed_code <= hmacsha384(salt,pepper,medium_msg);

		 when big =>
				next_state <= small;
		 	hashed_code <= hmacsha384(salt,pepper,big_msg);
	end case;
 end process;
end architecture;
