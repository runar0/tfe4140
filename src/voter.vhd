library ieee;
use ieee.std_logic_1164.all;

-- 4 to 1 bit majority voter
entity Voter is
    port (
        inputs : in std_logic_vector(3 downto 0);
        clk : in std_logic;
        reset : in std_logic;
        
        output : out std_logic;
        status : out std_logic_vector(2 downto 0)
    );
end entity;

architecture arch of Voter is    
begin
    
    process(clk, reset) is
        variable mask : std_logic_vector(3 downto 0);
        variable majority : std_logic := '0';
        -- masked input
        variable masked : std_logic_vector(3 downto 0);
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                output <= '0';
                status <= "000";
                mask := "1111";
            else
            
                -- A(B+C+D) + B(C+D) + CD (dead mcu's contribute a 0)
                --  We define that two 1's and two 0's produce a 1
                masked := inputs and mask;
                majority := (masked(3) and (masked(2) or masked(1) or masked(0))) 
                    or (masked(2) and (masked(1) or masked(0))) 
                    or (masked(1) and masked(0));
                output <= majority;
                    
                -- Update the mask of any expected to be working mcu's to 0 if it 
                -- disagrees with the majority
                for i in 3 downto 0 loop
                    if mask(i) = '1' then
                        mask(i) := majority xnor inputs(i);
                    end if;
                end loop;
                
                -- Set output status based on the mask
                case mask is 
                    when "1111" => status <= "000";
                    when "0111"|"1011"|"1101"|"1110" => status <= "001";
                    when "0011"|"0101"|"1001"|"1010"|"1100"|"0110" => status <= "010";
                    when others => status <= "111";
                end case;       
            end if;                
        end if;    
    end process;
end architecture;
