--==============================================================================
-- File: 	processor.vhd
-- Author:	Pietro Lorefice
-- Version:	1.0
--==============================================================================
-- Description:
--   Main module of the design. It contains the processor implementation.
--   Based on http://fpgacpu.org/papers/xsoc-series-drafts.pdf
-- 
-- Instruction formats:
--
--   15      12 11       8 7        4 3        0 
--  |-------------------------------------------|
--  |  opcode  |    rd    |    ra    |    rb    |	rrr
--  |-------------------------------------------|
--  |  opcode  |    rd    |    ra    |    im    |	rri
--  |-------------------------------------------|
--  |  opcode  |    rd    |    fn    |    rb    |   rr
--  |-------------------------------------------|
--  |  opcode  |    rd    |    fn    |    im    |   ri
--  |-------------------------------------------|
--  |  opcode  |               im               |   i12
--  |-------------------------------------------|
--  |  opcode  |   cond   |        displ        |   br
--  |-------------------------------------------|
--
--  ====================================
--  |          Instruction set         |
--  ====================================
--  |   format   |      operation      |
--  ------------------------------------
--  |    0dab    |    rd = ra + rb     |
--  |    1dab    |    rd = ra - rb     |
--  |    2dai    |    rd = ra + im     |
--  |    3d*b    |    rd = rd * rb     |
--  ====================================
--
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor is
	generic (
		N : integer := 16;	-- Address width
		B : integer := 16;	-- Data bus width
		R : integer := 4	-- 2**R registers
	);
	port (
		clk		: in  std_logic;						-- Clock
		rst		: in  std_logic;						-- Synchronous reset
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
	type state_t is (fetch_0, fetch_1, 
					 decode, decode_rrr_0,
					 read,
					 execute_0, execute_1,
					 write_r,
					 halt
					);
	
	signal state_q : state_t; -- Current state
	signal state_n : state_t; -- Next state

	-- =============
	-- | Registers |
	-- =============
	type reg_t is array(2**R - 1 downto 0) of std_logic_vector(B-1 downto 0);
	
	signal regs_q, regs_n	: reg_t;							-- General register file
	signal reg_d_q, reg_d_n	: std_logic_vector(R-1 downto 0);	-- Destination register index
	
	signal op_a_q, op_a_n	: std_logic_vector(B-1 downto 0);	-- Operand A
	signal op_b_q, op_b_n	: std_logic_vector(B-1 downto 0);	-- Operand B
	
	signal pc_q, pc_n	: std_logic_vector(N-1 downto 0);	-- Program counter
	signal ir_q, ir_n	: std_logic_vector(B-1 downto 0);	-- Instruction register
	signal mar_q, mar_n	: std_logic_vector(N-1 downto 0);	-- Memory address register
	signal mdo_q, mdo_n	: std_logic_vector(B-1 downto 0);	-- Memory data out
	signal sp_q, sp_n 	: std_logic_vector(N-1 downto 0);	-- Stack Pointer
	signal st_q, st_n	: std_logic_vector(B-1 downto 0);	-- Status register
	
	signal rw_q, rw_n	: std_logic;						-- Memory read/write output reg.
	signal sel_q, sel_n : std_logic;						-- Memory selection output reg.
	
	signal alu_sel_i	: std_logic_vector(2 downto 0);		-- ALU operation selector
	signal alu_out_i	: std_logic_vector(B-1 downto 0);	-- ALU output
begin
	
	-- ==================
	-- | Instantiations |
	-- ==================
	alu_inst : entity work.alu
		generic map(W => B)
		port map(sel => alu_sel_i,
			     a   => op_a_q,
			     b   => op_b_q,
			     cf  => open,
			     zf  => open,
			     ov  => open,
			     sf  => open,
			     y   => alu_out_i);	
	
	-- =========================
	-- | Register update logic |
	-- =========================
	clk_re : process(clk) is
	begin
		if rising_edge(clk) then
			if rst = '1' then
				state_q <= fetch_0;			 
				 regs_q <= (others => (others => '0'));
				reg_d_q <= (others => '0');
				 op_a_q <= (others => '0');
				 op_b_q <= (others => '0');
				   pc_q <= (others => '0');
				   ir_q <= (others => '0');
				  mar_q <= (others => '0');
				  mdo_q <= (others => '0');
				   sp_q <= (others => '0');
				   st_q <= (others => '0');
				   rw_q <= '1';
				  sel_q <= '1';
				  
			  -- Debug values for the registers
			  regs_q(2) <= X"0001"; -- R2
			  regs_q(3) <= X"0002";	-- R3
			  
			else
				 regs_q <= regs_n;
				state_q <= state_n;
				reg_d_q <= reg_d_n;
				 op_a_q <= op_a_n;
				 op_b_q <= op_b_n;
				   pc_q <= pc_n;
				   ir_q <= ir_n;
				  mar_q <= mar_n;
				  mdo_q <= mdo_n;
				   sp_q <= sp_n;
				   st_q <= st_n;
				   rw_q <= rw_n;
				  sel_q <= sel_n;
			end if;
		end if;
	end process clk_re;
	
	-- =====================
	-- | FSM control logic |
	-- =====================
	fsm : process (ir_q, mar_q, mdo_q, pc_q, rw_q, sel_q, sp_q, st_q, state_q, r_data, alu_out_i, reg_d_q, regs_q, op_a_q, op_b_q) is
	begin
		-- =======================
		-- | Next-value defaults |
		-- =======================
		state_n <= state_q;
		 regs_n <= regs_q;
		reg_d_n <= reg_d_q;
		 op_a_n <= op_a_q;
		 op_b_n <= op_b_q;
		   pc_n <= pc_q;
		   ir_n <= ir_q;
		  mar_n <= mar_q;
		  mdo_n <= mdo_q;
		   sp_n <= sp_q;
		   st_n <= st_q;
		   rw_n <= rw_q;
		  sel_n <= sel_q;
		
		-- =======
		-- | FSM |
		-- =======
		case state_q is 
			-- Initiate read and increment program counter
			when fetch_0 =>
				pc_n <= std_logic_vector(unsigned(pc_q) + 1);
				mar_n <= pc_q;
				sel_n <= '0';
				rw_n <= '1';
				state_n <= fetch_1;
				
			-- Wait state for synchronous memory read
			when fetch_1 =>
				state_n <= decode;
				
			-- Save instruction in IR and start decoding
			when decode =>
				sel_n <= '1';
				ir_n <= r_data;
				
				case r_data(15 downto 12) is
					-- RRR instruction
					when X"0" | X"1" =>				
						state_n <= decode_rrr_0;
					
					-- ERROR!
					when others =>
						state_n <= halt;
				end case;
			
			-- Move operands from registers to OP_A and OP_B, and execute
			when decode_rrr_0 =>
				reg_d_n <= ir_q(11 downto 8);
				
				op_a_n <= regs_q(to_integer(unsigned(ir_q(7 downto 4))));
				op_b_n <= regs_q(to_integer(unsigned(ir_q(3 downto 0))));
				
				-- Execute based on OPCODE
				case ir_q(15 downto 12) is
					-- Addition
					when X"0" =>
						state_n <= execute_0;
						
					-- Subtraction
					when X"1" =>
						state_n <= execute_1;
						
					-- ERROR!
					when others =>
						state_n <= halt;
				end case;
			
			when read =>
				null;
				
			-- ADD Rd, Ra, Rb
			when execute_0 =>
				alu_sel_i <= "010";
				state_n <= write_r;
			
			-- SUB Rd, Ra, Rb
			when execute_1 =>
				alu_sel_i <= "011";
				state_n <= write_r;
			
			-- Write result to register 
			when write_r =>
				regs_n(to_integer(unsigned(reg_d_q))) <= alu_out_i;
				state_n <= fetch_0;
				
			when halt =>
				state_n <= halt;
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
