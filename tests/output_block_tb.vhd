library ieee;
use ieee.std_logic_1164.all;

entity output_block_tb is
end output_block_tb;

architecture tb_arch of output_block_tb is
	component output_block
	port(		
		clk, reset	 : in std_logic;
		voted_data 	 : in std_logic;
		voter_status : in std_logic_vector(2 downto 0);
		voting_done  : in std_logic;
		do_ready_in  : in std_logic;
		do_ready_out : out std_logic;
		data_out 	 : out std_logic
		
	);
	end component;
	
	-- Stimulus signals - signals mapped to the input and inout ports of tested entity 
	signal clk_period : time := 40 ns; 
	
	signal clk, reset, voted_data : std_logic;
	signal voter_status : std_logic_vector(2 downto 0);
	signal voting_done, do_ready_in : std_logic;	  
	
	-- Observed signals - signals mapped to the output ports of tested entity
	signal do_ready_out : std_logic;
	signal data_out : std_logic;

begin
	process
	begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
	end process;

	UUT: output_block port map (clk, reset, voted_data, voter_status, voting_done, do_ready_in, do_ready_out, data_out);
	
	process
	begin
        report "Starting test of output block." severity note;
        report "==============================" severity note;
		--voted_data <= "10101010000";
		--wait for clk_period;
		
		reset <= '1';
		do_ready_in <= '0';
		voter_status <= "000";
		wait for clk_period*2;
		reset <= '0';
		wait until rising_edge(clk);
		
		-- Test by feeding bit by bit into the input and oberve them unchanged on the output
		-- Test word is 10101010 with status 000
		do_ready_in <= '1';
		voted_data <= '1';
		wait until rising_edge(clk);	
		assert (do_ready_out = '1') report "do_ready not relayed";
		assert (data_out = '1') report "1. output bit not 1";
		
		do_ready_in <= '0';
		voted_data <= '0';
		wait until rising_edge(clk);	
		assert (do_ready_out = '0') report "do_ready not relayed";
		assert (data_out = '0') report "2. output bit not 0";
		
		voted_data <= '1';
		wait until rising_edge(clk);
		assert (data_out = '1') report "3. output bit not 1";
				
		voted_data <= '0';
		wait until rising_edge(clk);
		assert (data_out = '0') report "4. output bit not 1";
				
		voted_data <= '1';
		wait until rising_edge(clk);
		assert (data_out = '1') report "5. output bit not 1";
				
		voted_data <= '0';
		wait until rising_edge(clk);
		assert (data_out = '0') report "6. output bit not 0";
				
		voted_data <= '1';
		wait until rising_edge(clk);
		assert (data_out = '1') report "7. output bit not 1";
				
		voted_data <= '0';
		voting_done <= '1';
		wait until rising_edge(clk);
		assert (data_out = '0') report "8. output bit not 0";
		voting_done <= '0';								
		
		wait until rising_edge(clk);
		assert (data_out = '0') report "data_out not 0 @ s(2)";	 
		wait until rising_edge(clk);
		assert (data_out = '0') report "data_out not 0 @ s(1)";
		wait until rising_edge(clk);
		assert (data_out = '0') report "data_out not 0 @ s(0)"; 	
		wait for clk_period; 										
		
		--hamming code should be 0000 when v=10101010 and s=000
		wait until rising_edge(clk);
		assert (data_out = '0') report "data_out not 0 @ ecc(3)";
		wait until rising_edge(clk);
		assert (data_out = '0') report "data_out not 1 @ ecc(2)";	 
		wait until rising_edge(clk);
		assert (data_out = '0') report "data_out not 0 @ ecc(1)";
		wait until rising_edge(clk);
		assert (data_out = '0') report "data_out not 1 @ ecc(0)";
		
        report "VERIFICATION DONE." severity warning;
		wait; 
	end process;
end tb_arch;
