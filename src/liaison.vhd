

library ieee;
use ieee.std_logic_1164.all;

entity liaison is
    port (
        clk : in std_logic;
        mp_data : in std_logic_vector(3 downto 0);
        reset : in std_logic;
        di_ready : in std_logic;
        do_ready : out std_logic;
        voted_data : out std_logic;
    );
end entity;

architecture behaviour of liaison is
    component input_block is
        port (
            clk, reset, di_ready : in std_logic;
            mc_input : in std_logic_vector(3 downto 0);
            data_out : out std_logic_vector(10 downto 0);
            do_ready : out std_logic
        );
    end component;
    
    -- output block
    
    -- 
    signal input_do_ready : std_logic;
    signal input_data_out : std_logic_vector(10 downto 0);
    
begin
    input : input_block(clk, reset, di_ready, mp_data, input_data_out, input_do_ready);
    
    -- output block
    
end architecture;
