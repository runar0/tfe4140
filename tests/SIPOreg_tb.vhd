-- Serial input parallel output register

library ieee;
use ieee.std_logic_1164.all;

entity SIPOreg_tb is 
end entity;
		
architecture behaviour of SIPOreg_tb is
    component SIPOreg is
        generic(N : integer := 8);
	    port(
            clk, data_in, shift : in std_logic;
            data_out : out std_logic_vector(N-1 downto 0)		
	    );
	end component;
	
	signal clk_period : time := 40 ns;
	
	signal clk, shift, data_in : std_logic;
	signal data_out : std_logic_vector(7 downto 0);
begin
	
	process
	begin
	    clk <= '1';
	    wait for clk_period / 2;
	    clk <= '0';
	    wait for clk_period / 2;
	end process;
	
	uut: SIPOreg port map(clk, data_in, shift, data_out);
	
	process
	begin
	    data_in <= '0';
	    shift <= '1';
	    
	    wait for 10*clk_period;
	    
	    assert (data_out = "00000000") report "Invalid initial state";
	    
	    data_in <= '1';
	    wait for clk_period;
	    assert (data_out = "00000001") report "1 not shfited in at LSB";
	    
	    shift <= '0';
	    data_in <= '0';
	    wait for clk_period;
	    assert (data_out = "00000001") report "1 not stationary when shift is 0";
	    
	    shift <= '1';
	    wait for clk_period;
	    assert (data_out = "00000010") report "00000010";
	    wait for clk_period;
	    assert (data_out = "00000100") report "00000100";
	    wait for clk_period;
	    assert (data_out = "00001000") report "00001000";
	    wait for clk_period;
	    assert (data_out = "00010000") report "00010000";
	    wait for clk_period;
	    assert (data_out = "00100000") report "00100000";
	    wait for clk_period;
	    assert (data_out = "01000000") report "01000000";
	    wait for clk_period;
	    assert (data_out = "10000000") report "10000000";
	    wait for clk_period;
	    assert (data_out = "00000000") report "00000000";
	    
	    wait;
	    
	end process;
	
end architecture;
