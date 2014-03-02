library ieee;
use ieee.std_logic_1164.all;

package liaison_tb_data is

    constant count : integer := 2;

    type inputvect_t is array(0 to count-1, 0 to 3) of std_logic_vector(7 downto 0);
    type outputvect_t is array(0 to count-1) of std_logic_vector(14 downto 0);

    constant input : inputvect_t := (
        0 => (0 => "00000000", 1 => "00000000", 2 => "00000000", 3 => "00000000"),
        1 => (0 => "10101010", 1 => "10101010", 2 => "10101010", 3 => "10101010")
    );
	
	constant output : outputvect_t := (
		--   voted data & status & ecc
		0 => "00000000" & "000"  & "0000",
		1 => "10101010" & "000"  & "0110" 
	);
	
	
	
		
	
end package;
