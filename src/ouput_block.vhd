-- output part of liaison system

library IEEE;
use IEEE.STD_LOGIC_1164.all;		   
use work.txt_util.all;

entity output_block is 
	generic (N : integer :=15);
	port(
		clk, reset	 : in std_logic;
		voted_data 	 : in std_logic;
		voter_status : in std_logic_vector(2 downto 0);
		voting_done  : in std_logic;
		do_ready_in  : in std_logic;
		do_ready_out : out std_logic;
		data_out 	 : out std_logic
	   	);
end output_block;

architecture arch of output_block is
	--signals definitions
	signal ecc 		: std_logic_vector (3 downto 0);
	signal ecc_in 	: std_logic_vector (10 downto 0);	   
	
	signal muxed_data_out : std_logic;
	signal sipo_data_out : std_logic_vector(7 downto 0);
	
	component hamming_enc_11 is
		port(
			data_in  : in std_logic_vector (10 downto 0);
			data_out : out std_logic_vector	(3 downto 0)
	    );	
	end component;				   
	component SIPOreg is 
	    generic(N : integer := 8);
		port(
	        clk, data_in, shift : in std_logic;
	        data_out : out std_logic_vector(N-1 downto 0)
		);
	end component; 
											 
	type state is (VOTING, STATUS2, STATUS1, STATUS0, ECC3, ECC2, ECC1, ECC0);
	signal current_state, next_state : state;  			
	
	signal shift : std_logic;
	
begin			
	do_ready_out <= do_ready_in;   	
	data_out <= muxed_data_out;
	
	sipo: SIPOreg port map(clk, muxed_data_out, shift, sipo_data_out);
	
	ecc_in <= sipo_data_out & voter_status;
	
	hamm: hamming_enc_11 port map(
		data_in  => ecc_in,
		data_out => ecc
	); 				  		
	
	process(clk, reset, next_state)
	begin
	    if rising_edge(clk) then   			
	    	if reset = '1' then
		    	current_state <= VOTING; 	   	 	
	    	else 	  		   			 
		        current_state <= next_state;
	        end if;
	    end if;
    end process;
    
    process(current_state, voting_done, voted_data, voter_status, ecc)			   
    begin 						
		shift <= '0';
		case current_state is
    		when VOTING => 				
				shift <= '1';
				muxed_data_out <= voted_data;
				if voting_done = '1' then
					next_state <= STATUS2;	
	            else							   
	                next_state <= VOTING;  
	            end if;  
	        when STATUS2 =>	
				next_state <= STATUS1;	 				 
				muxed_data_out <= voter_status(2);
	        when STATUS1 =>	
				next_state <= STATUS0;
				muxed_data_out <= voter_status(1);
	        when STATUS0 =>		   		 	
				next_state <= ECC3;
				muxed_data_out <= voter_status(0);
	        when ECC3 =>	
				next_state <= ECC2;
				muxed_data_out <= ecc(3);
	        when ECC2 =>	
				next_state <= ECC1;
				muxed_data_out <= ecc(2);
	        when ECC1 =>	
				next_state <= ECC0;
				muxed_data_out <= ecc(1);
	        when ECC0 =>	
				next_state <= VOTING;
				muxed_data_out <= ecc(0);	
	    end case;
	end process;
	
end arch;