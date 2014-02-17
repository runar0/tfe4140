library ieee ;
use ieee.std_logic_1164.all ;

entity voter_tb is
end voter_tb;

-- 

architecture arch of voter_tb is

    component voter is
        port (
            inputs : in std_logic_vector(3 downto 0);
            clk, reset : in  std_logic;
            
            output : out std_logic;
            status : out std_logic_vector(2 downto 0)
        );
    end component;

    signal inputs : std_logic_vector(3 downto 0);
    signal clk, reset, output : std_logic;
    signal status : std_logic_vector(2 downto 0);
    
    signal clk_period : time := 40 ns;
begin
    uut: voter port map (inputs, clk, reset, output, status);

    clk_proc : process
    begin
        clk <= '1';
        wait for clk_period / 2;
        clk <= '0';
        wait for clk_period / 2;
    end process;

    stim_proc: process
    begin
        -- Hold reset
        reset <= '1';
        wait for clk_period*2;
        reset <= '0';
        
            
        inputs <= "1111";
        wait for clk_period;
        assert (output = '1') report "Output not 1 after input seq 1111";
        assert (status = "000") report "Status not 000 after input seq 1111";
            
        inputs <= "0000";
        wait for clk_period;
        assert (output = '0') report "Output not 0 after input seq 0000";
        assert (status = "000") report "Status not 000 after input seq 0000";
        
        -- First failuire
        inputs <= "0001";
        wait for clk_period;
        assert (output = '0') report "Output not 0 after input seq 0001";
        assert (status = "001") report "Status not 001 after input seq 0001";

        -- Second failure
        inputs <= "0010";
        wait for clk_period;
        assert (output = '0') report "Output not 0 after input seq 0001, 0010";
        assert (status = "010") report "Status not 011 after input seq 0001, 0010";
        
        -- OK
        inputs <= "1110";
        wait for clk_period;
        assert (output = '1') report "Output not 1 after input seq 0001, 0010, 1110";
        assert (status = "010") report "Status not 011 after input seq 0001, 0010, 1110";
        
        -- Third failure
        inputs <= "0110";
        wait for clk_period;
        assert (output = '0') report "Output not 1 after input seq 0001, 0010, 1110, 0110";
        assert (status = "111") report "Status not 011 after input seq 0001, 0010, 1110, 0110";
    
        wait;
    end process;
end architecture;
