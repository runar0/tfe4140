-- Input part of liaison system

library ieee;
use ieee.std_logic_1164.all;

entity input_block_tb is 
end entity;
		
architecture behaviour of input_block_tb is
     component input_block is
        port (
            clk, reset, di_ready : in std_logic;
            mc_input : in std_logic_vector(3 downto 0);
            data_out : out std_logic_vector(10 downto 0);
            do_ready : out std_logic
        );
    end component;
	
	signal clk_period : time := 40 ns;
	
	signal clk, reset, di_ready, do_ready : std_logic;
	signal mc_input : std_logic_vector(3 downto 0);
	signal data_out : std_logic_vector(10 downto 0);
begin
	
	process
	begin
	    clk <= '1';
	    wait for clk_period / 2;
	    clk <= '0';
	    wait for clk_period / 2;
	end process;
	
	uut: input_block port map(clk, reset, di_ready, mc_input, data_out, do_ready);
	
	process
	begin
        assert false report "Start." severity note;
        
	    mc_input <= "0000";
	    di_ready <= '0';
	    
	    reset <= '1';
	    wait for 3*clk_period;
	    
	    -- Test input of 10110010. All MCU's agree
	    reset <= '0';
	    di_ready <= '1';
	    mc_input <= "1111";
	    wait for clk_period;
	    di_ready <= '0';
	    mc_input <= "0000";
	    wait for clk_period;
	    mc_input <= "1111";
	    wait for clk_period;
	    mc_input <= "1111";
	    wait for clk_period;
	    mc_input <= "0000";
	    wait for clk_period;
	    mc_input <= "0000";
	    wait for clk_period;
	    mc_input <= "1111";
	    wait for clk_period;
	    mc_input <= "0000";
	    wait for clk_period;
	    
	    wait for clk_period*1.5;
	    	    
	    assert (do_ready = '1') report "do_ready not one after 9 clock periods";
	    assert (data_out(10 downto 3) = "10110010") report "Voted data not as expected";
	    assert (data_out(2 downto 0) = "000") report "Status not 0 as expected";
	    
	    
        assert false report "Done." severity note;
	    
	    wait;
	    
	end process;
	
end architecture;
