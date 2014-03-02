library ieee;
use ieee.std_logic_1164.all;

entity output_block_tb is
end output_block_tb;

architecture tb_arch of output_block_tb is
	component output_block
		generic(
		N : INTEGER := 15 );
	port(
		clk : in STD_LOGIC;
		voted_data : in STD_LOGIC_VECTOR(10 downto 0);
		do_ready_in : in STD_LOGIC;
		do_ready_out : out STD_LOGIC;
		data_out : out STD_LOGIC );
	end component;
	
	-- Stimulus signals - signals mapped to the input and inout ports of tested entity 
	signal clk_period : time := 40 ns; 
	
	signal clk : STD_LOGIC;
	signal voted_data : STD_LOGIC_VECTOR(10 downto 0);
	signal do_ready_in : STD_LOGIC;	  
	
	-- Observed signals - signals mapped to the output ports of tested entity
	signal do_ready_out : STD_LOGIC;
	signal data_out : STD_LOGIC;

begin
	process
	begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
	end process;

	UUT : output_block port map (clk, voted_data, do_ready_in, do_ready_out, data_out);
	
	process
	begin
        assert false report "Start." severity note;
		voted_data <= "10101010000";
		wait for clk_period;
		
		do_ready_in <= '1';
		wait for clk_period/2;
		assert (do_ready_out = '1') report ("do_ready not relayed");
		wait for clk_period/2;
		do_ready_in <= '0';
		
		assert (data_out = '1') report "data_out not 1 @ v(7)";
		wait for clk_period;   
		assert (data_out = '0') report "data_out not 0 @ v(6)";
		wait for clk_period;
		assert (data_out = '1') report "data_out not 1 @ v(5)";
		wait for clk_period;
		assert (data_out = '0') report "data_out not 0 @ v(4)";
		wait for clk_period;
		assert (data_out = '1') report "data_out not 1 @ v(3)";
		wait for clk_period;
		assert (data_out = '0') report "data_out not 0 @ v(2)";
		wait for clk_period;
		assert (data_out = '1') report "data_out not 1 @ v(1)";
		wait for clk_period;
		assert (data_out = '0') report "data_out not 0 @ v(0)";
		wait for clk_period;
		-- status
		assert (data_out = '0') report "data_out not 0 @ s(2)";
		wait for clk_period;
		assert (data_out = '0') report "data_out not 0 @ s(1)";
		wait for clk_period;
		assert (data_out = '0') report "data_out not 0 @ s(0)"; 
		wait for clk_period; 										
		
		--hamming code should be 0000 when v=10101010 and s=000
		assert (data_out = '0') report "data_out not 0 @ ecc(3)";
		wait for clk_period;		   
		assert (data_out = '0') report "data_out not 1 @ ecc(2)";
		wait for clk_period;								  
		assert (data_out = '0') report "data_out not 0 @ ecc(1)";
		wait for clk_period;
		assert (data_out = '0') report "data_out not 1 @ ecc(0)";
		wait for clk_period;
		
        assert false report "Done." severity note;
		wait; 
	end process;
end tb_arch;
