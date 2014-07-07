--==============================================================================
-- File: 	alu.vhd
-- Author:	Pietro Lorefice
--==============================================================================
-- Description:
--   Arithmetic logic unit inside the processor. Asynchronous interface with 
--   multiple output flags.
--
--  =====================
--  |   ALU operations  |     
--  =====================
--  |  sel  |     Y     | 
--  --------------------- 
--  |  000  |     0     | 
--  |  001  |     A     | 
--  |  010  |   A + B   | 
--  |  011  |   A - B   | 
--  |  100  |    !A     | 	
--  |  101  |   A & B   | 
--  |  110  |   A | B   | 
--  |  111  |   A x B   | 
--  =====================
-- 
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
	generic (
		W : integer   -- Data width
	);
	port (
		sel	: in  std_logic_vector(2 downto 0);		-- Operation selector
		a 	: in  std_logic_vector(W-1 downto 0);	-- First operand
		b	: in  std_logic_vector(W-1 downto 0);	-- Second operang
		
		cf	: out std_logic;						-- Carry flag
		zf	: out std_logic;						-- Zero flag
		ov	: out std_logic;						-- Overflow flag
		sf	: out std_logic;						-- Sign flag
		
		y	: out std_logic_vector(W-1 downto 0)	-- Result
	);
end entity alu;

architecture RTL of alu is
	signal a_us			: unsigned(W-1 downto 0);			-- Arith. unit 1st operand
	signal b_us			: unsigned(W-1 downto 0);			-- Arith. unit 2nd operand
	signal arith_out	: unsigned(W downto 0);				-- Arith. unit result
	signal logic_out	: std_logic_vector(W-1 downto 0);	-- Logic  unit result
	signal y_i			: std_logic_vector(W-1 downto 0);	-- Global result
begin
	
	-- ================================
	-- | Internal signals assignments |
	-- ================================
	
	-- Sign extension
	a_us <= unsigned(a);
	b_us <= unsigned(b);
	
	-- OpCode(2) discriminates logic vs. arithmetic operation
	y_i <= logic_out when sel(2) = '1' else
		 	 std_logic_vector(arith_out(W-1 downto 0));
		 
	-- =============
	-- | ALU logic |
	-- =============
		 
	-- Arithmetic operations logic
	arith_op : process(sel(1 downto 0), a_us, b_us) is
	begin
		case sel(1 downto 0) is
			when "00" =>
				arith_out <= (arith_out'range => '0');
			when "01" =>
				arith_out <= ('0' & a_us);
			when "10" =>
				arith_out <= ('0' & a_us) + b_us;
			when "11" =>
				arith_out <= ('0' & a_us) - b_us;
			when others => 
				null;
		end case;
	end process arith_op;
	
	-- Logic operations logic
	logic_op : process(sel(1 downto 0), a, b) is
	begin
		case sel(1 downto 0) is
			when "00" =>
				logic_out <= not a;
			when "01" =>
				logic_out <= a and b;
			when "10" =>
				logic_out <= a or b;
			when "11" =>
				logic_out <= a xor b;
			when others => 
				null;
		end case;
	end process logic_op;
	
	-- ================
	-- | Output logic |
	-- ================
	
	-- Result
	y <= y_i;
		 
	-- Carry lag
	cf <= arith_out(W);
		 
	-- Overflow flag
	with sel select
		ov <=
			((a_us(W-1) nor b_us(W-1)) and arith_out(W-1)) or
			(a_us(W-1) and b_us(W-1) and not arith_out(W-1)) when "010",
			
			(not a_us(W-1) and b_us(W-1) and arith_out(W-1)) or 
			(a_us(W-1) and not b_us(W-1) and not arith_out(W-1)) when "011",
			
			'0' when others;
	
	-- Sign flag
	sf <= arith_out(W-1);
	
	-- Zero flag
	zf <= '1' when y_i = (y_i'range => '0') else
		  '0';

end architecture RTL;
