LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.HMACSHA384_ISMAIL.all;



entity hmac_sha384_TB is
end entity;
architecture behavioral of hmac_sha384_TB is
-- component
component hmac_sha384
  port (clk: in std_logic;
       salt : in std_logic_vector(383 downto 0);
       pepper : in std_logic_vector(1023 downto 0); 
       small_msg: in std_logic_vector((6*4)-1 downto 0);
       medium_msg: in std_logic_vector((46*4)-1 downto 0);
       big_msg: in std_logic_vector((126*4)-1 downto 0);
       hashed_code: out std_logic_vector(383 downto 0)); 
end component; 
-- wires 
signal clk : std_logic := '1';
signal salt : std_logic_vector(383 downto 0);
signal pepper : std_logic_vector(1023 downto 0); 
signal small_msg : std_logic_vector((6*4)-1 downto 0);
signal medium_msg : std_logic_vector((46*4)-1 downto 0);
signal big_msg : std_logic_vector((126*4)-1 downto 0);
signal hashed_code : std_logic_vector(383 downto 0); 
begin
  uut : hmac_sha384 PORT MAP (
    clk => clk,
    salt => salt,
    pepper => pepper,
    small_msg => small_msg,
    medium_msg => medium_msg,
    big_msg => big_msg,
    hashed_code => hashed_code
  );
    salt   <= x"6a09a667f3bcc908bb67ae8584"
            &x"caa73b3c6ef372fe94f82ba54f53"
            &x"fa5f1d36f1510e527fade682d19b0"
            &x"5688c2b3e6c1f";
    pepper <= x"E67FF540BA6F5C5B9FEFC68B395EC32843C4FA76355D8183146B0F7B531F2DCE810B3226EFCE3D6BE3F90F0298DBE6AF2FD41AD0B7847D8F8F0E7526CE7A85129EA6B45C3BFB9272B25CD24958C7856DF3A57A6BF748CA22D842EC5C82E09E8FF16EEB2D58DF82B9B73B452BA14D2DBF19016A21BA2E5EB5DADAFC3F921B3F11";
    small_msg <= x"616263";
    medium_msg <=x"746869732069732074657374696e67206d657373616765";
    big_msg <= x"69736d61696c616c6d616" 
          &x"864695468656562616e4166697"
          &x"14472617673696e746573747465"
          &x"7374746573747465737474657374"
          &x"746573747465737474657374";
			 
  clk <= not clk after 16.66666667 ps;
end;

