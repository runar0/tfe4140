-- Input block, reads serial data from 4 MCU's, and outputs
-- a 8-bit word of voted values and a voter status flag

library ieee;
use ieee.std_logic_1164.all;
entity input_block is 
	port(
        clk, reset, di_ready : in std_logic;
        mc_input : in std_logic_vector(3 downto 0);
        data_out : out std_logic;	  
		status_out : out std_logic_vector(2 downto 0);
        do_ready : out std_logic;
		voting_done : out std_logic
	);
end entity;
		
architecture behaviour of input_block is
    component voter is
        port (
            inputs : in std_logic_vector(3 downto 0);
            clk, reset : in  std_logic;            
            output : out std_logic;
            status : out std_logic_vector(2 downto 0)
        );
    end component;	 
	
	type state is (READY, BIT7, BIT6, BIT5, BIT4, BIT3, BIT2, BIT1, BIT0, FINALIZE);
	signal current_state, next_state : state;
	
	-- Voter input and outputs
	signal voter_input : std_logic_vector(3 downto 0);	 
begin

    voter_1bit : voter port map (voter_input, clk, reset, data_out, status_out);		
    									   							  	
	process(clk, reset, next_state)
	begin
	    if rising_edge(clk) then
	    	if reset = '1' then
		    	current_state <= READY;
	    	else 
		        current_state <= next_state;
	        end if;
	    end if;
    end process;
    
    process(current_state, di_ready, mc_input)
    begin	
		voting_done <= '0';
	    do_ready <= '0';
        voter_input <= mc_input;
    	case current_state is
    		when READY => 
	            if di_ready = '1' then	
	                next_state <= BIT7;
	            else
	                voter_input <= (others => '0');
	                next_state <= READY;   
	            end if;  
	        when BIT7 =>	
				do_ready <= '1';   
	            next_state <= BIT6;
	        when BIT6 =>		 
	            next_state <= BIT5;
	        when BIT5 =>	   	
	            next_state <= BIT4;
	        when BIT4 =>	   
	            next_state <= BIT3;
	        when BIT3 =>		 
	            next_state <= BIT2;
	        when BIT2 =>	   
	            next_state <= BIT1;
	        when BIT1 =>	   
	            next_state <= BIT0;
	        when BIT0 =>	   
	            voter_input <= (others => '0');
	            voting_done <= '1';
	            next_state <= FINALIZE;
			when FINALIZE =>		   		
	            voter_input <= (others => '0');
				next_state <= READY;  
	    end case;
        	    
	end process;
	
end architecture;
