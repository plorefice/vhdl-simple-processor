--==============================================================================
-- File: 	processor.vhd
-- Author:	Pietro Lorefice
-- Version:	1.0
--==============================================================================
-- Description:
--   Main module of the design. It contains the processor implementation.
-- 
-- Instruction formats:
--
--  |<------ 8 ------>|<-- 4 -->|<-- 4 -->|<-------------- 16 --------------->|

--  | 31           24 | 23   20 | 19   16 | 15                              0 |
--  |-------------------------------------------------------------------------|
--  |     opcode      |   op1   |   op2   |	            not used              |
--  |-------------------------------------------------------------------------|
--  |     opcode      |   op1   |    -    |             constant              |
--  |-------------------------------------------------------------------------|
--  |     opcode      |   op1   |                    addr                     |
--  |-------------------------------------------------------------------------|
--  |     opcode      |    -    |                    addr                     |
--  ---------------------------------------------------------------------------
--
--  ==================================================
--  |               Instruction set                  |
--  ==================================================
--  |   opcode   |   op1   |   op2   |   operation   |
--  --------------------------------------------------
--  |  00000000  |    -    |    -    |      HLT      |
--  |            |         |         |               |
--  ==================================================
--
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor is
	generic (
		N : integer := 20;	-- Address width
		B : integer := 32;	-- Data bus width
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
	type state_t is (fetch0, fetch1, decode, read, execute, write, halt);
	
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
	signal mdo_q, mdo_n : std_logic_vector(B-1 downto 0);	-- Memory data out
	signal sp_q, sp_n : std_logic_vector(N-1 downto 0);		-- Stack Pointer
	signal st_q, st_n : std_logic_vector(B-1 downto 0);		-- Status register
	
	signal rw_q, rw_n : std_logic;		-- Memory read/write output reg.
	signal sel_q, sel_n : std_logic;	-- Memory selection output reg.
begin
	
	-- ====================
	-- | Registers update |
	-- ====================
	clk_re : process(clk, arst) is
	begin
		if arst = '1' then
			state_q <= fetch0;
			regs_q <= (others => (others => '0'));
			pc_q <= (others => '0');
			ir_q <= (others => '0');
			mar_q <= (others => '0');
			mdo_q <= (others => '0');
			sp_q <= (others => '0');
			st_q <= (others => '0');
			rw_q <= '1';
			sel_q <= '1';
		elsif rising_edge(clk) then
			state_q <= state_n;
			pc_q <= pc_n;
			ir_q <= ir_n;
			mar_q <= mar_n;
			mdo_q <= mdo_n;
			sp_q <= sp_n;
			st_q <= st_n;
			rw_q <= rw_n;
			sel_q <= sel_n;
		end if;
	end process clk_re;
	
	-- =====================
	-- | FSM control logic |
	-- =====================
	fsm : process (ir_q, mar_q, mdo_q, pc_q, rw_q, sel_q, sp_q, st_q, state_q) is
	begin
		state_n <= state_q;
		pc_n <= pc_q;
		ir_n <= ir_q;
		mar_n <= mar_q;
		mdo_n <= mdo_q;
		sp_n <= sp_q;
		st_n <= st_q;
		rw_n <= rw_q;
		sel_n <= sel_q;
		
		case state_q is 
			when fetch0 =>
				pc_n <= std_logic_vector(unsigned(pc_q) + 1);
				mar_n <= pc_q;
				sel_n <= '0';
				rw_n <= '1';
				state_n <= fetch1;
			when fetch1 =>	
				state_n <= decode;
			when decode =>
				null;
			when read =>
				null;
			when execute =>
				null;
			when write =>
				null;
			when halt =>
				null;
		end case;
	end process fsm;
	
	-- ======================
	-- | Signal assignments |
	-- ======================
	rw_l <= rw_q;
	sel_l <= sel_q;
	addr <= mar_q;
	w_data <= mdo_q;	

end architecture RTL;
