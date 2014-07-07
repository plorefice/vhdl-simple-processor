--==============================================================================
-- File: 	reg_en.vhd
-- Author:	Pietro Lorefice
--==============================================================================
-- Description:
--   N-bit register with enable and synchronous reset.
-- 
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;

entity reg_en is
	generic (
		N : integer
	);	
	port (
		clk : in  std_logic;
		rst : in  std_logic;
		en	: in  std_logic;
		
		d	: in  std_logic_vector(N-1 downto 0);
		
		q	: out std_logic_vector(N-1 downto 0)
	);
end entity reg_en;

architecture RTL of reg_en is
begin

	reg_update : process(clk) is
	begin
		if rising_edge(clk) then
			if rst = '1' then
				q <= (others => '0');
			elsif en = '1' then
				q <= d;
			end if;
		end if;
	end process reg_update;

end architecture RTL;
