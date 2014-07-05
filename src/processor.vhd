library ieee;
use ieee.std_logic_1164.all;

entity processor is
	generic (
		N : integer := 10;	-- Address width
		B : integer := 16;	-- Data bus width
		R : integer := 4	-- 2**R registers
	);
	port (
		clk		: in  std_logic;						-- Clock
		arst	: in  std_logic;						-- Asynch reset
		r_data	: in  std_logic_vector(B-1 downto 0);	-- Data in
		rw_l	: out std_logic;						-- Read/write
		sel_l	: out std_logic;						-- Memory select
		addr	: out std_logic_vector(N-1 downto 0);	-- Address
		w_data	: out std_logic_vector(B-1 downto 0)	-- Data out
	);
end entity processor;

architecture RTL of processor is
	-- ==============
	-- | FSM states |
	-- ==============
	type state_t is (fetch, decode, read, execute, write);
	
	signal state_q : state_t; -- Current state
	signal state_n : state_t; -- Next state

	-- =============
	-- | Registers |
	-- =============
	type reg_t is array(2**R - 1 downto 0) of std_logic_vector(B-1 downto 0);
	
	signal regs_q : reg_t;								-- General register file
	signal src_reg_i : std_logic_vector(R-1 downto 0);	-- Source register index
	signal dst_reg_i : std_logic_vector(R-1 downto 0);	-- Destination register index
	
	signal pc_q, pc_n : std_logic_vector(N-1 downto 0);		-- Program counter
	signal ir_q, ir_n : std_logic_vector(B-1 downto 0);		-- Instruction register
	signal mar_q, mar_n : std_logic_vector(N-1 downto 0);	-- Memory address register
	signal mdi_q, mdi_n : std_logic_vector(B-1 downto 0);	-- Memory data in
	signal mdo_q, mdo_n : std_logic_vector(B-1 downto 0);	-- Memory data out
	signal sp_q, sp_n : std_logic_vector(N-1 downto 0);		-- Stack Pointer
	signal st_q, st_n : std_logic_vector(B-1 downto 0);		-- Status register
begin

end architecture RTL;
