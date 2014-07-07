--==============================================================================
-- File: 	data_path.vhd
-- Author:	Pietro Lorefice
--==============================================================================
-- Description:
--   Datapath portion of the FSMD processor architecture. It's the core of the
--	 processor design, containing all the units necessary for code execution.
--
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_path is
	generic (
		N : integer;
		B : integer;
		R : integer
	);
	port (
		clk 			: in std_logic;	-- Clock
		rst 			: in std_logic;	-- Reset
		
		alu_op_b_sel	: in std_logic;						-- ALU operand B select
		alu_ctrl_op		: in std_logic_vector(1 downto 0);	-- ALU control unit operation
		
		pc_en			: in std_logic;	-- Program counter register enable
		ir_en			: in std_logic;	-- Instruction register enable
		
		reg_we_l		: in std_logic;	-- Register file write enable
		reg_op_a_sel	: in std_logic;	-- Register file operand A select
		reg_op_b_sel	: in std_logic;	-- Register file operand B select
		reg_wr_d_sel	: in std_logic;	-- Register file write data select
		
		mem_sel_l		: in std_logic;	-- Data memory select
		mem_we_l		: in std_logic;	-- Data memory write enable
		
		opcode			: out std_logic_vector(3 downto 0)
	);
end entity data_path;

architecture struct of data_path is
	-- ========================
	-- | Internal connections |
	-- ========================
	signal pc_q, pc_n	: std_logic_vector(N-1 downto 0);
	signal ir_q, ir_n	: std_logic_vector(B-1 downto 0);
	
	signal reg_addr_a 	: std_logic_vector(R-1 downto 0);
	signal reg_addr_b 	: std_logic_vector(R-1 downto 0);
	signal reg_data_w 	: std_logic_vector(B-1 downto 0);
	
	signal reg_data_a 	: std_logic_vector(B-1 downto 0);
	signal reg_data_b 	: std_logic_vector(B-1 downto 0);
	
	signal imm_op_i	  	: std_logic_vector(B-1 downto 0);
	
	signal alu_op_b		: std_logic_vector(B-1 downto 0);
	signal alu_result	: std_logic_vector(B-1 downto 0);
	signal alu_ctrl		: std_logic_vector(2 downto 0);
	
	signal mem_data_out	: std_logic_vector(B-1 downto 0);
begin
	
	-- =========================
	-- | Program counter logic |
	-- =========================
	pc_unit	: entity work.reg_en
		generic map(N => N)
		port map(clk => clk,
			     rst => rst,
			     en  => pc_en,
			     d   => pc_n,
			     q   => pc_q);
			     
	pc_n <= std_logic_vector(unsigned(pc_q) + 1);
	
	-- ===========================
	-- | Instruction fetch logic |
	-- ===========================
	i_mem_unit : entity work.i_mem
		generic map(N => N,
			        B => B)
		port map(clk   => clk,
			     rst   => rst,
			     addr  => pc_q,
			     instr => ir_n);
			     
	ir_unit : entity work.reg_en
		generic map(N => B)
		port map(clk => clk,
			     rst => rst,
			     en  => ir_en,
			     d   => ir_n,
			     q   => ir_q);
			     
	-- =======================
	-- | Register file logic |  
	-- =======================
	reg_addr_a_mux_unit : entity work.mux2_to_1
		generic map(W => 4)
		port map(a   => ir_q(11 downto 8),
			     b   => ir_q(7 downto 4),
			     sel => reg_op_a_sel,
			     q   => reg_addr_a);
			     
	reg_addr_b_mux_unit : entity work.mux2_to_1
		generic map(W => 4)
		port map(a   => ir_q(11 downto 8),
			     b   => ir_q(3 downto 0),
			     sel => reg_op_b_sel,
			     q   => reg_addr_b);
			     
	reg_addr_w_mux_unit : entity work.mux2_to_1
		generic map(W => B)
		port map(a   => mem_data_out,
			     b   => alu_result,
			     sel => reg_wr_d_sel,
			     q   => reg_data_w);
			     
	reg_file_unit : entity work.reg_file
		generic map(B => B,
			        R => R)
		port map(clk       => clk,
			     rst       => rst,
			     we_l      => reg_we_l,
			     w_data    => reg_data_w,
			     w_addr    => ir_q(11 downto 8),
			     rd_addr_1 => reg_addr_a,
			     rd_addr_2 => reg_addr_b,
			     rd_data_1 => reg_data_a,
			     rd_data_2 => reg_data_b);
			     
	-- =============
	-- | ALU logic |
	-- =============
	alu_ctrl_unit : entity work.alu_ctrl
		port map(op   => alu_ctrl_op,
			     log  => ir_q(5 downto 4),
			     ctrl => alu_ctrl);
			     
	alu_op_b_mux : entity work.mux2_to_1
		generic map(W => B)
		port map(a   => reg_data_b,
			     b   => imm_op_i,
			     sel => alu_op_b_sel,
			     q   => alu_op_b);
	
	imm_op_i <= (B-1 downto 4 => '0') & ir_q(3 downto 0);
	
	alu_unit : entity work.alu
		generic map(W => B)
		port map(sel => alu_ctrl,
			     a   => reg_data_a,
			     b   => alu_op_b,
			     cf  => open,
			     zf  => open,
			     ov  => open,
			     sf  => open,
			     y   => alu_result);
			     
	-- =====================
	-- | Data memory logic |
	-- =====================
	d_mem_unit : entity work.d_mem
		generic map(N => N,
			        B => B)
		port map(clk    => clk,
			     rst    => rst,
			     we_l   => mem_we_l,
			     sel_l  => mem_sel_l,
			     r_addr => alu_result,
			     w_addr => alu_result,
			     w_data => reg_data_b,
			     r_data => mem_data_out);
			     
	-- ================
	-- | Output logic |
	-- ================
	opcode <= ir_q(15 downto 12);
	
end architecture struct;
