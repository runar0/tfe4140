library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity PISOreg is  
	generic (
		n: integer :=15
	);
	port(
		clk : in std_logic;
		write : in std_logic;
		input : in std_logic_vector(N-1 downto 0);
		output : out std_logic
	     );
end PISOreg;

architecture arch of PISOreg is		  

begin
	process(clk)
	variable temp: std_logic_vector (N-1 downto 0);
	begin
	if rising_edge(clk)then	
		if write = '1' then
			temp := input;
			output <= temp(N-1);
		else
			temp (N-1 downto 1) := temp(N-2 downto 0);
			temp(0) := '0';
			output <= temp(N-1);
		end if;
	end if;
	end process;
end arch;
