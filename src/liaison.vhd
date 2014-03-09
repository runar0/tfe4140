

library ieee;
use ieee.std_logic_1164.all;

entity liaison is
    port (
        clk : in std_logic;
        mp_data : in std_logic_vector(3 downto 0);
        reset : in std_logic;
        di_ready : in std_logic;
        do_ready : out std_logic;
        voted_data : out std_logic
    );
end entity;

architecture behaviour of liaison is
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
    
    -- output block
    component output_block is	  
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
    -- 
    signal voter_do_ready : std_logic;
    signal voter_data_out : std_logic;	
	signal voting_done : std_logic;
	signal voter_status : std_logic_vector(2 downto 0);
	signal output_block_do_ready : std_logic;
    
begin
    input : input_block port map(clk, reset, di_ready, mp_data, voter_data_out, voter_status, voter_do_ready, voting_done);
	
	do_ready <= output_block_do_ready;
	
    -- output block
    output : output_block port map(clk, reset, voter_data_out, voter_status, voting_done, voter_do_ready, output_block_do_ready, voted_data);
	
end architecture;
