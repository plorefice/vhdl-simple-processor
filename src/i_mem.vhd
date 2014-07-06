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
		N : integer := 16;
		B : integer := 16
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
