--Generates the parity bits for hamming code
--Input: 11 bits data vector
--Output: 4 bit parity vector

library ieee;
use ieee.std_logic_1164.all;

entity hamming_enc_11 is 
	port(
		data_in	: in std_logic_vector (10 downto 0);
		data_out : out std_logic_vector (3 downto 0)
		);
end entity;
		
Architecture behaviour of hamming_enc_11 is
	begin
		data_out(0) <= data_in(0) xor data_in(1) xor data_in(3) xor data_in(4) xor data_in(6) xor data_in(8) xor data_in(10); --parity1
		data_out(1) <= data_in(0) xor data_in(2) xor data_in(3) xor data_in(5) xor data_in(6) xor data_in(9) xor data_in(10); --parity2
		data_out(2) <= data_in(1) xor data_in(2) xor data_in(3) xor data_in(7) xor data_in(8) xor data_in(9) xor data_in(10); --parity3
		data_out(3) <= data_in(4) xor data_in(5) xor data_in(6) xor data_in(7) xor data_in(8) xor data_in(9) xor data_in(10); --parity4
end architecture;
