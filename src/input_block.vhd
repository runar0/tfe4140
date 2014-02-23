-- Input block, reads serial data from 4 MCU's, and outputs
-- a 8-bit word of voted values and a voter status flag

library ieee;
use ieee.std_logic_1164.all;

entity input_block is 
	port(
        clk, reset, di_ready : in std_logic;
        mc_input : in std_logic_vector(3 downto 0);
        data_out : out std_logic_vector(10 downto 0);
        do_ready : out std_logic
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
    component SIPOreg is
        generic(N : integer := 8);
	    port(
            clk, data_in, shift : in std_logic;
            data_out : out std_logic_vector(N-1 downto 0)		
	    );
	end component;
	
	type state is (READY, RUNNING, FINALIZE);
	signal current_state, next_state : state;
	
	-- Voter input and outputs
	signal voter_input : std_logic_vector(3 downto 0);
	signal voted_result : std_logic;
	signal voter_status : std_logic_vector(2 downto 0);
	
	-- Shift register control signal and word output
	signal shift : std_logic;	
	signal voted_word : std_logic_vector(7 downto 0);
	
	signal counter : integer;
begin

    voter_1bit : voter port map (voter_input, clk, reset, voted_result, voter_status);
    voted_reg : SIPOreg port map(clk, voted_result, shift, voted_word);
    
    data_out <= voted_word & voter_status;
	
	process(clk, reset, next_state)
	begin
	    if reset = '1' then
	        current_state <= READY;
	        counter <= 0;
	    elsif rising_edge(clk) then
	        current_state <= next_state;
            if next_state = RUNNING then
                counter <= counter + 1;
            else 
                counter <= 0;
            end if;
	    end if;
    end process;
    
    process(current_state, di_ready, mc_input, counter)
    begin
    	case current_state is
    		when READY =>
	    		shift <= '0';
	            do_ready <= '0';
	            if di_ready = '1' then            
	                voter_input <= mc_input;
	                next_state <= RUNNING;
	            else
	                voter_input <= (others => '0');
	                next_state <= READY;
	            end if;  
	        when RUNNING =>
	            do_ready <= '0';
	            shift <= '1';
	            if counter = 8 then
	            voter_input <= (others => '0');
	                next_state <= FINALIZE;
	            else 
	                voter_input <= mc_input;
	                next_state <= RUNNING;
	            end if;       
	        when others => -- FINALIZE
	            shift <= '0';
	            do_ready <= '1';
	            voter_input <= (others => '0');
	            next_state <= READY;
	    end case;
        	    
	end process;
	
end architecture;