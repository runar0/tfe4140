-- Testbench for the input block of our liaison system
-- This test only runs a single valid input string through the input block,
-- this is done because the votes itself is tested already, and the liaison system
-- as a whole has a complete verification. So the work of this test is just to ensure
-- that everything is connected right, so we detect obvious problems before system verification

library ieee;
use ieee.std_logic_1164.all;
use work.txt_util.all;


entity input_block_tb is 
end entity;
		
architecture behaviour of input_block_tb is
     component input_block is
        port (
            clk, reset, di_ready : in std_logic;
            mc_input : in std_logic_vector(3 downto 0);
            data_out : out std_logic;	  
		    status_out : out std_logic_vector(2 downto 0);
            do_ready : out std_logic;
		    voting_done : out std_logic
        );
    end component;
	
	signal clk_period : time := 40 ns;
	
	signal clk, reset, di_ready : std_logic;
	signal mc_input : std_logic_vector(3 downto 0);
	signal status_out : std_logic_vector(2 downto 0);
	signal data_out : std_logic;
	signal do_ready, voting_done : std_logic;
begin
	
	process
	begin
	    clk <= '1';
	    wait for clk_period / 2;
	    clk <= '0';
	    wait for clk_period / 2;
	end process;
	
	uut: input_block port map(clk, reset, di_ready, mc_input, data_out, status_out, do_ready, voting_done);
	
	process
	begin
        report "Starting test of input block." severity note;
        report "=============================" severity note;
        
	    mc_input <= "0000";
	    di_ready <= '0';
	    
	    reset <= '1';
	    wait for 3*clk_period;
	    wait until falling_edge(clk);
	    
	    -- Test input of 10110010. All MCU's agree
	    reset <= '0';
	    di_ready <= '1';
	    mc_input <= "1111";
	    wait until rising_edge(clk);
	    -- no output yet
	    wait until falling_edge(clk);
	    
	    di_ready <= '0';
	    mc_input <= "0000";
	    wait until rising_edge(clk);
	    -- first output
	    assert data_out = '1' report "First output bit is " & str(data_out) & " expected 1";
	    assert (do_ready = '1') report "do_ready not one when first output bit is ready";
	    wait until falling_edge(clk);
	    
	    mc_input <= "1111";
	    wait until rising_edge(clk);
	    assert data_out = '0' report "Second output bit is " & str(data_out) & " expected 0";
	    wait until falling_edge(clk);
	    
	    mc_input <= "1111";
	    wait until rising_edge(clk);
	    assert data_out = '1' report "Third output bit is " & str(data_out) & " expected 1";
	    wait until falling_edge(clk);
	    
	    mc_input <= "0000";
	    wait until rising_edge(clk);
	    assert data_out = '1' report "Forth output bit is " & str(data_out) & " expected 1";
	    wait until falling_edge(clk);
	    
	    mc_input <= "0000";
	    wait until rising_edge(clk);
	    assert data_out = '0' report "Fift output bit is " & str(data_out) & " expected 0";
	    wait until falling_edge(clk);
	    
	    mc_input <= "1111";
	    wait until rising_edge(clk);
	    assert data_out = '0' report "Sixth output bit is " & str(data_out) & " expected 0";
	    wait until falling_edge(clk);
	    
	    mc_input <= "0000";
	    wait until rising_edge(clk);
	    assert data_out = '1' report "Seventh output bit is " & str(data_out) & " expected 1";
	    wait until falling_edge(clk);
	    
	    wait until rising_edge(clk);
	    assert data_out = '0' report "Eight output bit is " & str(data_out) & " expected 0";
	     	    
	    assert (voting_done = '1') report "voting_done not 1 while last bit is outputted";
	    assert (status_out = "000") report "Status is "&str(status_out)&" expected 000";
	    
	    
        assert false report "VERIFICATION DONE." severity warning;
	    
	    wait;
	    
	end process;
	
end architecture;
