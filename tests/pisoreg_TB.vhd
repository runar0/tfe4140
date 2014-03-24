library ieee;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity PISOreg_tb is
end PISOreg_tb;

architecture tb_arch of PISOreg_tb is
	-- Component declaration of the tested unit
	component PISOreg
		generic(
		N : integer := 15 );
	port(
		clk : in std_logic;
		write : in std_logic;
		input : in std_logic_vector(N-1 downto 0);
		output : out std_logic );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity 
	signal clk_period : time := 40 ns; 
	
	signal clk : std_logic;
	signal write : std_logic;
	signal input : std_logic_vector (15-1 downto 0); 
	
	-- Observed signals - signals mapped to the output ports of tested entity
	signal output : std_logic;

begin
	process
	begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
	end process;

	uut: PISOreg port map(clk, write, input, output);

	process
	begin
		
		input <= "101010100000101";
		wait for clk_period;
		
		write <= '1';
		wait for clk_period;
		write <= '0';
		
		assert (output = '1') report "output not 1 @ v(7)";
		wait for clk_period;   
		assert (output = '0') report "output not 0 @ v(6)";
		wait for clk_period;
		assert (output = '1') report "output not 1 @ v(5)";
		wait for clk_period;
		assert (output = '0') report "output not 0 @ v(4)";
		wait for clk_period;
		assert (output = '1') report "output not 1 @ v(3)";
		wait for clk_period;
		assert (output = '0') report "output not 0 @ v(2)";
		wait for clk_period;
		assert (output = '1') report "output not 1 @ v(1)";
		wait for clk_period;
		assert (output = '0') report "output not 0 @ v(0)";
		wait for clk_period;
		assert (output = '0') report "output not 0 @ s(2)";
		wait for clk_period;
		assert (output = '0') report "output not 0 @ s(1)";
		wait for clk_period;
		assert (output = '0') report "output not 0 @ s(0)"; 
		wait for clk_period;								  
		assert (output = '0') report "output not 0 @ ecc(3)";
		wait for clk_period;		   
		assert (output = '1') report "output not 1 @ ecc(2)";
		wait for clk_period;								  
		assert (output = '0') report "output not 0 @ ecc(1)";
		wait for clk_period;
		assert (output = '1') report "output not 1 @ ecc(0)";
		wait for clk_period;
		wait;
	end process;
end tb_arch;