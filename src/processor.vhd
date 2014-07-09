--==============================================================================
-- File: 	processor.vhd
-- Author:	Pietro Lorefice
--==============================================================================
-- Description:
--   Structural implementation of a processor based on a FSM with datapath.
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
--  ==========================================
--  |          Instruction set               |
--  ==========================================
--  |   opcode   | fmt |      operation      |
--  ------------------------------------------
--  |    0dab    | rrr |    rd = ra + rb     |
--  |    1dab    | rrr |    rd = ra - rb     |
--  |    2dai    | rri |    rd = ra + im     |
--  |    3d*b    | rr  |    rd = rd * rb     |
--  |    4d*i    | ri  |    rd = rd * im     |
--  |    5dai    | rri |   rd = *(ra + im)   |
--  |    6dai    | rri |   rd = *(ra + im)   |
--  |    8dai    | rri |   *(ra + im) = rd   |
--  |    9dai    | rri |   *(ra + im) = rd   |
--  ==========================================
--
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;

entity processor is
	generic (
		N : integer;
		B : integer;
		R : integer
	);
	port (
		clk : in std_logic;
		rst : in std_logic;
		
		i_mem_instr		: in  std_logic_vector(B-1 downto 0);
		d_mem_data_in	: in  std_logic_vector(B-1 downto 0);
		
		i_mem_addr		: out std_logic_vector(N-1 downto 0);
		d_mem_r_addr	: out std_logic_vector(N-1 downto 0);
		d_mem_w_addr	: out std_logic_vector(N-1 downto 0);
		d_mem_w_data	: out std_logic_vector(B-1 downto 0);
		
		d_mem_sel_l		: out std_logic;
		d_mem_we_l		: out std_logic
	);
end entity processor;

architecture struct of processor is	
	-- ====================
	-- | Internal signals |
	-- ====================
	signal opcode		: std_logic_vector(3 downto 0); 
	signal pc_en		: std_logic;
	signal ir_en		: std_logic;
	
	signal mem_sel_l	: std_logic;
	signal mem_we_l		: std_logic;
	
	signal reg_addr_a_en	: std_logic;
	signal reg_addr_b_en	: std_logic;
	signal reg_data_a_en	: std_logic;
	signal reg_data_b_en	: std_logic;
	signal reg_we_l			: std_logic;
	signal reg_op_a_sel		: std_logic;
	signal reg_op_b_sel		: std_logic;
	signal reg_wr_d_sel		: std_logic;
	
	
	signal alu_op_b_en		: std_logic;
	signal alu_op_b_sel		: std_logic;
	signal alu_result_en	: std_logic;
	signal alu_ctrl_op		: std_logic_vector(1 downto 0);
begin
	
	-- =============
	-- | Data path |
	-- =============
	data_path_unit : entity work.data_path
		generic map(N => N,
			        B => B,
			        R => R)
		port map(clk           => clk,
			     rst           => rst,
			     alu_op_b_en   => alu_op_b_en,
			     alu_op_b_sel  => alu_op_b_sel,
			     alu_result_en => alu_result_en,
			     alu_ctrl_op   => alu_ctrl_op,
			     pc_en         => pc_en,
			     ir_en         => ir_en,
			     reg_op_a_sel  => reg_op_a_sel,
			     reg_op_b_sel  => reg_op_b_sel,
			     reg_addr_a_en => reg_addr_a_en,
			     reg_addr_b_en => reg_addr_b_en,
			     reg_we_l      => reg_we_l,
			     reg_wr_d_sel  => reg_wr_d_sel,
			     reg_data_a_en => reg_data_a_en,
			     reg_data_b_en => reg_data_b_en,
			     mem_sel_l     => mem_sel_l,
			     mem_we_l      => mem_we_l,
			     i_mem_instr   => i_mem_instr,
			     d_mem_data_in => d_mem_data_in,
			     opcode        => opcode,
			     i_mem_addr    => i_mem_addr,
			     d_mem_sel_l   => d_mem_sel_l,
			     d_mem_we_l    => d_mem_we_l,
			     d_mem_r_addr  => d_mem_r_addr,
			     d_mem_w_addr  => d_mem_w_addr,
			     d_mem_w_data  => d_mem_w_data);
			     
	-- =======
	-- | FSM |
	-- =======
	ctrl_fsm_unit : entity work.ctrl_fsm
		port map(clk           => clk,
			     rst           => rst,
			     opcode        => opcode,
			     alu_op_b_en   => alu_op_b_en,
			     alu_op_b_sel  => alu_op_b_sel,
			     alu_result_en => alu_result_en,
			     alu_ctrl_op   => alu_ctrl_op,
			     pc_en         => pc_en,
			     ir_en         => ir_en,
			     reg_op_a_sel  => reg_op_a_sel,
			     reg_op_b_sel  => reg_op_b_sel,
			     reg_addr_a_en => reg_addr_a_en,
			     reg_addr_b_en => reg_addr_b_en,
			     reg_we_l      => reg_we_l,
			     reg_wr_d_sel  => reg_wr_d_sel,
			     reg_data_a_en => reg_data_a_en,
			     reg_data_b_en => reg_data_b_en,
			     mem_sel_l     => mem_sel_l,
			     mem_we_l      => mem_we_l);

end architecture struct;
