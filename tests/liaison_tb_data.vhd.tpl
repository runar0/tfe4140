library ieee;
use ieee.std_logic_1164.all;

package liaison_tb_data is

    constant count : integer := 256;

    type inputvect_t is array(0 to count-1, 0 to 4) of std_logic_vector(7 downto 0);
    type outputvect_t is array(0 to count-1) of std_logic_vector(14 downto 0);

    -- 0 => (0 => "00000000", 1 => "00000000", 2 => "00000000", 3 => "00000000", 4 => "11111111"),
    constant input : inputvect_t := (
        {inputs}
    );
	
	-- 0 => "00000000" & "000"  & "0000",
	constant output : outputvect_t := (
	    {outputs}
	);
end package;
