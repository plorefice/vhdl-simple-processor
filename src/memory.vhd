--==============================================================================
-- File: 	memory.vhd
-- Author:	Pietro Lorefice
-- Version:	1.0
--==============================================================================
-- Description:
--   Memory module for the processor. Synchronous interface with two
--   unidirectional data buses, single address port, memory selection and
--   read/write command.
--
--  ============================
--  |    Memory operations     | 
--  ============================
--	| sel_l | rw_l  |    op    |
--  ----------------------------
--  |   H   |   -   |  disable |
--  |   L   |   H   |   read   |
--  |   L   |   L   |   write  |
--  ============================	
-- 
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
	generic (
		N : integer := 20; -- # of addresses
		B : integer := 8   -- Word size
	);
	port (
		clk		: in  std_logic;						-- Clock
		arst	: in  std_logic;						-- Asynch reset
		rw_l	: in  std_logic;						-- Read/Write
		sel_l	: in  std_logic; 						-- Select
		addr	: in  std_logic_vector(N-1 downto 0);	-- Address
		w_data	: in  std_logic_vector(B-1 downto 0);	-- Data input
		r_data	: out std_logic_vector(B-1 downto 0)	-- Data output
	);
end entity memory;

architecture RTL of memory is
	type mem_t is array(2**N - 1 downto 0) of std_logic_vector(B-1 downto 0);
	
	signal mem_i : mem_t; -- Storage element
begin

	-- =================
	-- | Storage logic |
	-- =================
	
	ram_reg : process(clk, arst) is
	begin
		if arst = '1' then
			mem_i <= (others => (others => '0'));
			mem_i(0) <= (others => '1'); -- Debug
		elsif rising_edge(clk) then
			if (sel_l = '0' and rw_l = '0') then
				mem_i(to_integer(unsigned(addr))) <= w_data;
			end if;
		end if;
	end process ram_reg;

	-- ================
	-- | Output logic |
	-- ================
	
	r_data <= mem_i(to_integer(unsigned(addr))) when (sel_l = '0' and rw_l = '1') else
			(others => '0');

end architecture RTL;
