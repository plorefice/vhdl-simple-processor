--==============================================================================
-- File: 	reg_file.vhd
-- Author:	Pietro Lorefice
--==============================================================================
-- Description:
--   Register file used to implement general registers R0..Rn in the CPU.
-- 
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file is
	generic (
		B : integer;	-- Register size
		R : integer		-- 2**R registers
	);
	port (
		clk			: in  std_logic;						-- Clock
		rst			: in  std_logic;						-- Synch. reset
		
		we_l		: in  std_logic;						-- Write enable
		w_data		: in  std_logic_vector(B-1 downto 0);	-- Data to be written
		w_addr		: in  std_logic_vector(R-1 downto 0);	-- Write address
		
		rd_addr_1	: in  std_logic_vector(R-1 downto 0);	-- 1st read address
		rd_addr_2	: in  std_logic_vector(R-1 downto 0);	-- 2nd read address
		rd_data_1	: out std_logic_vector(B-1 downto 0);	-- 1st datum read
		rd_data_2	: out std_logic_vector(B-1 downto 0)	-- 2ns datum read
	);
end entity reg_file;

architecture RTL of reg_file is
	type reg_t is array(2**R - 1 downto 0) of std_logic_vector(B-1 downto 0);
	
	signal reg_file_q : reg_t;
begin
	
	-- =======================
	-- | Register file logic |
	-- =======================
	reg_logic : process(clk) is
	begin
		if rising_edge(clk) then
			if rst = '1' then
				reg_file_q <= (others => (others => '0'));				
			elsif we_l = '0' then
				reg_file_q(to_integer(unsigned(w_addr))) <= w_data;
			end if;
		end if;
	end process reg_logic;
	
	-- =============================
	-- | Output signal assignments |
	-- =============================
	rd_data_1 <= reg_file_q(to_integer(unsigned(rd_addr_1)));
	rd_data_2 <= reg_file_q(to_integer(unsigned(rd_addr_2)));

end architecture RTL;
