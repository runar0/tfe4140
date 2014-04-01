library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


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
        -- used to calculate status output
        variable state : std_logic_vector(1 downto 0);
        -- bit vector used to mark inputs that were wrong in a cycle
        variable wrong : std_logic_vector(3 downto 0);
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                output <= '0';
                status <= "000";
                mask := "1111";
            else
                -- A(B+C+D) + B(C+D) + CD (dead mcu's contribute a 0)
                -- We define that two 1's and two 0's produce a 1
                masked := inputs and mask;
                majority := (masked(3) and (masked(2) or masked(1) or masked(0))) 
                    or (masked(2) and (masked(1) or masked(0))) 
                    or (masked(1) and masked(0));
                output <= majority;
                    
                -- Update the mask of any expected to be working mcu's to 0 if it 
                -- disagrees with the majority
                wrong := (majority & majority & majority & majority) xor masked;
                wrong := wrong and mask;
                mask  := mask xor wrong;               
                      
			    state(0) := (mask(0) xor mask(1) xor mask(2) xor mask(3)) 
			        or not (mask(0) or mask(1) or mask(2) or mask(3));
			    state(1) := (state(0) nor (mask(0) and mask(1) and mask(2) and mask(3)))
				    or (state(0) and not ((mask(0) or mask(1)) and (mask(2) or mask(3))));
			    status <= (state(1) and state(0)) & state;
            end if;                
        end if;    
    end process;
end architecture;
