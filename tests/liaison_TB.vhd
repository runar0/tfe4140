library ieee;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity liaison_tb is
end liaison_tb;

architecture tb_arch of liaison_tb is
	-- Component declaration of the tested unit
	component liaison
	port(
		clk : in STD_LOGIC;
		mp_data : in STD_LOGIC_VECTOR(3 downto 0);
		reset : in STD_LOGIC;
		di_ready : in STD_LOGIC;
		do_ready : out STD_LOGIC;
		voted_data : out STD_LOGIC );
	end component;
	
	signal clk_period : time := 40 ns;
	
	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : STD_LOGIC;
	signal mp_data : STD_LOGIC_VECTOR(3 downto 0);
	signal reset : STD_LOGIC;
	signal di_ready : STD_LOGIC;   
	
	-- Observed signals - signals mapped to the output ports of tested entity
	signal do_ready : STD_LOGIC;
	signal voted_data : STD_LOGIC;

	-- Add your code here ...

begin
	process
	begin
	    clk <= '1';
	    wait for clk_period / 2;
	    clk <= '0';
	    wait for clk_period / 2;
	end process;
	-- Unit Under Test port map
	UUT : liaison
		port map (
			clk => clk,
			mp_data => mp_data,
			reset => reset,
			di_ready => di_ready,
			do_ready => do_ready,
			voted_data => voted_data
		);

	-- Add your stimulus here ...  
	process
	begin
   		mp_data <= "0000";
	    di_ready <= '0';
	    
	    reset <= '1';
	    wait for 3*clk_period; 
	    reset <= '0';
	    
	    -- Test input of 10110010. All MCU's agree
	    di_ready <= '1';
	    mp_data <= "1111";
	    wait for clk_period;
	    di_ready <= '0';
	    mp_data <= "0000";
	    wait for clk_period;
	    mp_data <= "1111";
	    wait for clk_period;
	    mp_data <= "1111";
	    wait for clk_period;
	    mp_data <= "0000";
	    wait for clk_period;
	    mp_data <= "0000";
	    wait for clk_period;
	    mp_data <= "1111";
	    wait for clk_period;
	    mp_data <= "0000";
	    
		wait until do_ready = '1';
		wait for clk_period/2;	
		assert (voted_data = '1') report "voted_data not 1 @ v(7)";
		wait for clk_period;   
		assert (voted_data = '0') report "voted_data not 0 @ v(6)";
		wait for clk_period;
		assert (voted_data = '1') report "voted_data not 1 @ v(5)";
		wait for clk_period;
		assert (voted_data = '1') report "voted_data not 0 @ v(4)";
		wait for clk_period;
		assert (voted_data = '0') report "voted_data not 1 @ v(3)";
		wait for clk_period;
		assert (voted_data = '0') report "voted_data not 0 @ v(2)";
		wait for clk_period;
		assert (voted_data = '1') report "voted_data not 1 @ v(1)";
		wait for clk_period;
		assert (voted_data = '0') report "voted_data not 0 @ v(0)";
		wait for clk_period;
		-- status
		assert (voted_data = '0') report "voted_data not 0 @ s(2)";
		wait for clk_period;
		assert (voted_data = '0') report "voted_data not 0 @ s(1)";
		wait for clk_period;
		assert (voted_data = '0') report "voted_data not 0 @ s(0)"; 
		wait for clk_period; 										
		
		--hamming code should be 0000 when v=10110010 and s=000
		assert (voted_data = '0') report "voted_data not 0 @ ecc(3)";
		wait for clk_period;		   
		assert (voted_data = '1') report "voted_data not 1 @ ecc(2)";
		wait for clk_period;								  
		assert (voted_data = '1') report "voted_data not 0 @ ecc(1)";
		wait for clk_period;
		assert (voted_data = '1') report "voted_data not 1 @ ecc(0)";
		wait for clk_period;
		
		end process;
end tb_arch;