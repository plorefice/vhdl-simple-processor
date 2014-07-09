--==============================================================================
-- File: 	i_mem.vhd
-- Author:	Pietro Lorefice
--==============================================================================
-- Description:
--   Instruction memory for the processor. Synchronous read-only interface.
-- 
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i_mem is
	generic (
		N : integer;
		B : integer
	);
	port (
		clk 	: in std_logic;							-- Clock
		rst		: in std_logic;							-- Synch reset
		
		addr	: in  std_logic_vector(N-1 downto 0);	-- Address
		instr	: out std_logic_vector(B-1 downto 0)	-- Instruction
	);
end entity i_mem;

architecture RTL of i_mem is
	type mem_t is array(2**N - 1 downto 0) of std_logic_vector(B-1 downto 0);
	
	signal mem : mem_t;	-- Storage element
	signal instr_q : std_logic_vector(B-1 downto 0);	-- Instr. out register
begin
	
	-- =================
	-- | Storage logic |
	-- =================
	fetch : process(clk) is
	begin
		if rising_edge(clk) then
			if rst = '1' then
				mem <= (others => (others => '0'));
				
				-- Debug instructions
				mem(0) <= X"210F";	-- ADDI R1,  R0, $15
				mem(1) <= X"2207";	-- ADDI R2,  R0, $7
				mem(2) <= X"0312";	-- ADD  R3,  R1, R2
				mem(3) <= X"1412";	-- SUB  R4,  R1, R2
				mem(4) <= X"1521";  -- SUB  R5,  R2, R1
				mem(5) <= X"261F";  -- ADDI R6,  R1, $15
				mem(6) <= X"3726";  -- OR   R7,  R6	
				mem(7) <= X"8700";  -- ST   R7,	 R0, $0
				mem(8) <= X"5F00";  -- LD   R15, R0, $0
				
			else
				instr_q <= mem(to_integer(unsigned(addr)));
			end if;
		end if;
	end process fetch;
	
	-- ================
	-- | Output logic |
	-- ================
	instr <= instr_q;

end architecture RTL;
