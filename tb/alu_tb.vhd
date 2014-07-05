--==============================================================================
-- File: 	alu_tb.vhd
-- Author:	Pietro Lorefice
-- Version:	1.0
--==============================================================================
-- Description:
--   Testbench for the ALU module.
-- 
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
end entity alu_tb;

architecture tb_arch of alu_tb is
	constant T : time := 20 ns;
	constant W : integer := 8;
	
	signal A, B, Y : std_logic_vector(W-1 downto 0);
	signal opcode : std_logic_vector(2 downto 0);
	signal cf, sf, ov, zf : std_logic;
begin
	
	uut : entity work.alu(RTL)
		generic map(W => W)
		port map(sel => opcode,
			     a      => A,
			     b      => B,
			     cf     => cf,
			     zf     => zf,
			     ov     => ov,
			     sf     => sf,
			     y      => Y);
			     
	stim_gen : process is
	begin
		A <= (others => '0');
		B <= (others => '0');
		opcode <= (others => '0');
		
		-- NOP
		opcode <= "000";
		wait for T/2;
		assert Y = (Y'range => '0');
		wait for T/2;
		
		-- TRANSFER
		opcode <= "001";
		A <= X"52";
		wait for T/2;
		assert Y = A;
		wait for T/2;
		
		-- NOT
		opcode <= "100";
		A <= X"31";
		wait for T/2;
		assert Y = (not A);
		wait for T/2;
		
		-- AND
		opcode <= "101";
		A <= X"43";
		B <= X"C5";
		wait for T/2;
		assert Y = (A and B);
		wait for T/2;
		
		-- OR
		opcode <= "110";
		A <= X"F4";
		B <= X"C1";
		wait for T/2;
		assert Y = (A or B);
		wait for T/2;
		
		-- XOR
		opcode <= "111";
		A <= X"34";
		B <= X"76";
		wait for T/2;
		assert Y = (A xor B);
		wait for T/2;
		
		-- SUM
		opcode <= "010";
		A <= "01110010";
		B <= "01000101";
		wait for T/2;
		assert (unsigned(Y) = (unsigned(A) + unsigned(B)));
		assert (  signed(Y) = (  signed(A) +   signed(B)));
		assert cf = '0';
		assert ov = '1';
		wait for T/2;
		
		A <= "00111010";
		B <= "00010101";
		wait for T/2;
		assert (unsigned(Y) = (unsigned(A) + unsigned(B)));
		assert (  signed(Y) = (  signed(A) +   signed(B)));
		assert cf = '0';
		assert ov = '0';
		wait for T/2;
		
		A <= "11110010";
		B <= "01000101";
		wait for T/2;
		assert (unsigned(Y) = (unsigned(A) + unsigned(B)));
		assert (  signed(Y) = (  signed(A) +   signed(B)));
		assert cf = '1';
		assert ov = '0';
		wait for T/2;
		
		assert false report "Simulation over" severity failure;
		
	end process stim_gen;
	

end architecture tb_arch;
