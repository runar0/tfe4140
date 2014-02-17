-- output part of liaison system

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity output_block is 
	generic (N : integer :=15);
	port(
		clk 		 : in std_logic;
		voted_data 	 : in std_logic_vector(10 downto 0);
		do_ready_in  : in std_logic;
		do_ready_out : out std_logic;
		data_out 	 : out std_logic
	   	);
end output_block;

architecture arch of output_block is
--signals definitions
signal ecc 		: std_logic_vector (3 downto 0);
signal piso_in 	: std_logic_vector (N-1 downto 0);

--initializing components
component PISOreg
	generic (
		N: integer :=15
	);
	port(
		clk 	: in std_logic;
		write 	: in std_logic;
		input 	: in std_logic_vector(N-1 downto 0);
		output 	: out std_logic
    );	
end component; 

component hamming_enc_11 is
	port(
		data_in  : in std_logic_vector (10 downto 0);
		data_out : out std_logic_vector	(3 downto 0)
    );	
end component;

begin 
	process(clk)
	variable int_do_ready : std_logic;
	begin
		if rising_edge(clk) then
			int_do_ready := do_ready_in;
		end if;		
		do_ready_out <= int_do_ready;
	end process;
	
	piso_in (N-1 downto 4) <= voted_data;
	piso_in (3 downto 0) <= ecc;
	
	hamm: hamming_enc_11 port map(
	data_in  => voted_data,
	data_out => ecc
	);
	
	piso: PISOreg port map(
	clk 	=> clk,
	write 	=> do_ready_in,
	input 	=> piso_in,
	output 	=> data_out
	);
end arch;