library ieee ;
use ieee.std_logic_1164.all ;

entity voter_tb is
end voter_tb;

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
    
        report "Starting test of 1bit voter." severity note;
        report "============================" severity note;
    
        -- Hold reset
        reset <= '1';
        wait for clk_period*2;
        reset <= '0';
        
            
        report "1. Testing valid inputs" severity note;
        inputs <= "1111";
        wait for clk_period;
        assert (output = '1') report "Output not 1 after input 1111";
        assert (status = "000") report "Status not 000 after input 1111";
            
        inputs <= "0000";
        wait for clk_period;
        assert (output = '0') report "Output not 0 after input 0000";
        assert (status = "000") report "Status not 000 after input 0000";
        

        -- One bit errors
        report "2. Testing 1 bit errors";

        reset <= '1';
        wait for clk_period;
        reset <= '0';

        inputs <= "0001";
        wait for clk_period;
        assert (output = '0') report "Output not 0 after input 0001";
        assert (status = "001") report "Status not 001 after input seq 0001";

        reset <= '1';
        wait for clk_period;
        reset <= '0';

        inputs <= "0010";
        wait for clk_period;
        assert (output = '0') report "Output not 0 after input 0010";
        assert (status = "001") report "Status not 001 after input 0001";


        reset <= '1';
        wait for clk_period;
        reset <= '0';

        inputs <= "0100";
        wait for clk_period;
        assert (output = '0') report "Output not 0 after input 0100";
        assert (status = "001") report "Status not 001 after input 0100";


        reset <= '1';
        wait for clk_period;
        reset <= '0';

        inputs <= "1000";
        wait for clk_period;
        assert (output = '0') report "Output not 0 after input 1000";
        assert (status = "001") report "Status not 001 after input 1000";

        reset <= '1';
        wait for clk_period;
        reset <= '0';

        inputs <= "1110";
        wait for clk_period;
        assert (output = '1') report "Output not 1 after input 1110";
        assert (status = "001") report "Status not 001 after input seq 1110";

        reset <= '1';
        wait for clk_period;
        reset <= '0';

        inputs <= "1101";
        wait for clk_period;
        assert (output = '1') report "Output not 1 after input 1101";
        assert (status = "001") report "Status not 001 after input 1101";


        reset <= '1';
        wait for clk_period;
        reset <= '0';

        inputs <= "1011";
        wait for clk_period;
        assert (output = '1') report "Output not 1 after input 1011";
        assert (status = "001") report "Status not 001 after input 1011";


        reset <= '1';
        wait for clk_period;
        reset <= '0';

        inputs <= "0111";
        wait for clk_period;
        assert (output = '1') report "Output not 1 after input 0111";
        assert (status = "001") report "Status not 001 after input 0111";

        -- Two failures
        report "2. Testing 2 1 bit errors";

        reset <= '1';
        wait for clk_period;
        reset <= '0';
        inputs <= "1000";
        wait for clk_period;

        inputs <= "0010";
        wait for clk_period;
        assert (output = '0') report "Output not 0 after input seq 1000, 0010";
        assert (status = "010") report "Status not 011 after input seq 1000, 0010";
        
        -- OK
        report "3. Testing good data with two existing errors.";
        inputs <= "0101";
        wait for clk_period;
        assert (output = '1') report "Output not 1 after input seq 1000, 0010, 0101";
        assert (status = "010") report "Status not 011 after input seq 1000, 0010, 0101";
        
        -- Third failure
        report "3. Testing third failure.";
        inputs <= "0110";
        wait for clk_period;
        assert (output = '0') report "Output not 1 after input seq 0001, 0010, 0101, 0110";
        assert (status = "111") report "Status not 011 after input seq 0001, 0010, 0101, 0110";
    
        assert false report "VERIFICATION DONE." severity warning;
    
        wait;
    end process;
end architecture;
