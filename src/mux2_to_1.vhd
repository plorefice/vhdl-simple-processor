--==============================================================================
-- File: 	mux2_to_1.vhd
-- Author:	Pietro Lorefice
--==============================================================================
-- Description:
--   2-to-1 multiplexer
-- 
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;

entity mux2_to_1 is
	generic (
		W : integer
	);
	port (
		a	: in  std_logic_vector(W-1 downto 0);
		b	: in  std_logic_vector(W-1 downto 0);
		sel	: in  std_logic;
		
		q	: out std_logic_vector(W-1 downto 0)
	);
end entity mux2_to_1;

architecture comb of mux2_to_1 is
begin
	
	q <= a when sel = '0' else
		 b;

end architecture comb;
