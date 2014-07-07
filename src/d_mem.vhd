--==============================================================================
-- File: 	d_mem.vhd
-- Author:	Pietro Lorefice
--==============================================================================
-- Description:
--   Data memory for the processor. Synchronous dual-port interface with two
--   unidirectional data buses and memory selection.
-- 
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity d_mem is
	generic (
		N : integer; -- # of addresses
		B : integer   -- Word size
	);
	port (
		clk		: in  std_logic;						-- Clock
		rst		: in  std_logic;						-- Synch reset
		
		we_l	: in  std_logic;						-- Write enable
		sel_l	: in  std_logic; 						-- Select
		
		r_addr	: in  std_logic_vector(N-1 downto 0);	-- Read address
		w_addr	: in  std_logic_vector(N-1 downto 0);	-- Write address
		
		w_data	: in  std_logic_vector(B-1 downto 0);	-- Data input
		r_data	: out std_logic_vector(B-1 downto 0)	-- Data output
	);
end entity d_mem;

architecture RTL of d_mem is
	type mem_t is array(2**N - 1 downto 0) of std_logic_vector(B-1 downto 0);
	
	signal mem_i : mem_t; -- Storage element
	
	signal r_data_q : std_logic_vector(B-1 downto 0);	-- Data output register
begin

	-- =================
	-- | Storage logic |
	-- =================
	ram_reg : process(clk) is
	begin
		if rising_edge(clk) then
			if rst = '1' then
				mem_i <= (others => (others => '0'));
				r_data_q <= (others => '0');
			else
				if (sel_l = '1') then
					r_data_q <= (others => '0');
				else
					r_data_q <= mem_i(to_integer(unsigned(r_addr)));
					
					if we_l = '0' then
						mem_i(to_integer(unsigned(w_addr))) <= w_data;
					end if;
				end if;
			end if;
		end if;
	end process ram_reg;

	-- ================
	-- | Output logic |
	-- ================
	r_data <= r_data_q;

end architecture RTL;
