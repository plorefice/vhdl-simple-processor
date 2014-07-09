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
		
		alu_op_b_en		: in std_logic;						-- ALU operand B register enable
		alu_op_b_sel	: in std_logic;						-- ALU operand B select
		alu_result_en	: in std_logic;						-- ALU result register enable
		alu_ctrl_op		: in std_logic_vector(1 downto 0);	-- ALU control unit operation
		
		pc_en			: in std_logic;	-- Program counter register enable
		ir_en			: in std_logic;	-- Instruction register enable
		
		reg_op_a_sel	: in std_logic;	-- Register file operand A select
		reg_op_b_sel	: in std_logic;	-- Register file operand B select
		reg_addr_a_en	: in std_logic;	-- Regfile address A register enable
		reg_addr_b_en	: in std_logic;	-- Regfile address B register enable
		reg_we_l		: in std_logic;	-- Register file write enable
		reg_wr_d_sel	: in std_logic;	-- Register file write data select
		reg_data_a_en	: in std_logic;
		reg_data_b_en	: in std_logic;
		
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
	
	signal imm_op_i	  	: std_logic_vector(B-1 downto 0);
	signal mem_data_out	: std_logic_vector(B-1 downto 0);
	
	signal reg_addr_a_q, reg_addr_a_n 	: std_logic_vector(R-1 downto 0);
	signal reg_addr_b_q, reg_addr_b_n 	: std_logic_vector(R-1 downto 0);
	signal reg_data_w 					: std_logic_vector(B-1 downto 0);
	
	signal reg_data_a_q, reg_data_a_n 	: std_logic_vector(B-1 downto 0);
	signal reg_data_b_q, reg_data_b_n 	: std_logic_vector(B-1 downto 0);
	
	signal alu_op_b_q, alu_op_b_n		: std_logic_vector(B-1 downto 0);
	signal alu_result_q, alu_result_n	: std_logic_vector(B-1 downto 0);
	signal alu_ctrl						: std_logic_vector(2 downto 0);
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
	reg_addr_a_reg_unit : entity work.reg_en
		generic map(N => R)
		port map(clk => clk,
			     rst => rst,
			     en  => reg_addr_a_en,
			     d   => reg_addr_a_n,
			     q   => reg_addr_a_q);
			     
	reg_addr_b_reg_unit : entity work.reg_en
		generic map(N => R)
		port map(clk => clk,
			     rst => rst,
			     en  => reg_addr_b_en,
			     d   => reg_addr_b_n,
			     q   => reg_addr_b_q);
	
	reg_addr_a_mux_unit : entity work.mux2_to_1
		generic map(W => R)
		port map(a   => ir_q(11 downto 8),
			     b   => ir_q(7 downto 4),
			     sel => reg_op_a_sel,
			     q   => reg_addr_a_n);
			     
	reg_addr_b_mux_unit : entity work.mux2_to_1
		generic map(W => R)
		port map(a   => ir_q(11 downto 8),
			     b   => ir_q(3 downto 0),
			     sel => reg_op_b_sel,
			     q   => reg_addr_b_n);
			     
	reg_addr_w_mux_unit : entity work.mux2_to_1
		generic map(W => B)
		port map(a   => mem_data_out,
			     b   => alu_result_q,
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
			     rd_addr_1 => reg_addr_a_q,
			     rd_addr_2 => reg_addr_b_q,
			     rd_data_1 => reg_data_a_n,
			     rd_data_2 => reg_data_b_n);
			     
	reg_data_a_reg_unit : entity work.reg_en
		generic map(N => B)
		port map(clk => clk,
			     rst => rst,
			     en  => reg_data_a_en,
			     d   => reg_data_a_n,
			     q   => reg_data_a_q);
			     
	reg_data_b_reg_unit : entity work.reg_en
		generic map(N => B)
		port map(clk => clk,
			     rst => rst,
			     en  => reg_data_b_en,
			     d   => reg_data_b_n,
			     q   => reg_data_b_q);
			     
	-- =============
	-- | ALU logic |
	-- =============
	alu_op_b_reg_unit : entity work.reg_en
		generic map(N => B)
		port map(clk => clk,
			     rst => rst,
			     en  => alu_op_b_en,
			     d   => alu_op_b_n,
			     q   => alu_op_b_q);
	
	alu_ctrl_unit : entity work.alu_ctrl
		port map(op   => alu_ctrl_op,
			     log  => ir_q(5 downto 4),
			     ctrl => alu_ctrl);
			     
	alu_op_b_mux : entity work.mux2_to_1
		generic map(W => B)
		port map(a   => reg_data_b_n,
			     b   => imm_op_i,
			     sel => alu_op_b_sel,
			     q   => alu_op_b_n);
	
	imm_op_i <= (B-1 downto 4 => '0') & ir_q(3 downto 0);
	
	alu_unit : entity work.alu
		generic map(W => B)
		port map(sel => alu_ctrl,
			     a   => reg_data_a_q,
			     b   => alu_op_b_q,
			     cf  => open,
			     zf  => open,
			     ov  => open,
			     sf  => open,
			     y   => alu_result_n);
			     
	alu_result_reg_unit : entity work.reg_en
		generic map(N => B)
		port map(clk => clk,
			     rst => rst,
			     en  => alu_result_en,
			     d   => alu_result_n,
			     q   => alu_result_q);
			     
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
			     r_addr => alu_result_n,
			     w_addr => alu_result_q,
			     w_data => reg_data_b_q,
			     r_data => mem_data_out);
			     
	-- ================
	-- | Output logic |
	-- ================
	opcode <= ir_q(15 downto 12);
	
end architecture struct;
