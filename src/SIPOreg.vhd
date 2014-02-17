-- Serial input parallel output register

library ieee;
use ieee.std_logic_1164.all;

entity SIPOreg is 
    generic(N : integer := 8);
	port(
        clk, data_in, shift : in std_logic;
        data_out : out std_logic_vector(N-1 downto 0)		
	);
end entity;
		
architecture behaviour of SIPOreg is
begin
	
	process(clk) 
        variable value : std_logic_vector(N-1 downto 0) := (others => '0');
	begin
	    if rising_edge(clk) and shift = '1' then
	        value := value(N-2 downto 0) & data_in;
	        data_out <= value;
	    end if;
	end process;
	
end architecture;
