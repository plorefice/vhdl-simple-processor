--==============================================================================
-- File: 	alu_ctrl.vhd
-- Author:	Pietro Lorefice
--==============================================================================
-- Description:
--   ALU control circuitry, driven by control signals coming from FSM.
-- 
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;

entity alu_ctrl is
	port (
		op		: in  std_logic_vector(1 downto 0);	-- Type of operation
		log 	: in  std_logic_vector(1 downto 0); -- Logic operator
		
		ctrl	: out std_logic_vector(2 downto 0)	-- Control signal
	);
end entity alu_ctrl;

architecture RTL of alu_ctrl is
begin
	
	ctrl_2 : with op select
		ctrl(2) <=
			'1' when "00",	
			'0' when others;
	
	ctrl_1_0 : with op select
		ctrl(1 downto 0) <=
			log when "00",
			op when others;

end architecture RTL;
