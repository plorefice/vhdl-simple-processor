--==============================================================================
-- File: 	ctrl_fsm.vhd
-- Author:	Pietro Lorefice
--==============================================================================
-- Description:
--   FSM portion of the FSMD processor architecture. It keeps track of the 
--   internal state and provides the datapath with the correct signals.
--
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;

entity ctrl_fsm is
	port (
		clk				: in  std_logic;					-- Clock
		rst				: in  std_logic;					-- Reset
		opcode			: in  std_logic_vector(3 downto 0);	-- Instruction opcode
		
		alu_op_b_sel	: out std_logic;					-- ALU operand B select
		alu_ctrl_op		: out std_logic_vector(1 downto 0);	-- ALU control unit operation
		
		pc_en			: out std_logic;	-- Program counter register enable
		ir_en			: out std_logic;	-- Instruction register enable
		
		reg_we_l		: out std_logic;	-- Register file write enable
		reg_op_a_sel	: out std_logic;	-- Register file operand A select
		reg_op_b_sel	: out std_logic;	-- Register file operand B select
		reg_wr_d_sel	: out std_logic;	-- Register file write data select
		
		mem_sel_l		: out std_logic;	-- Data memory select
		mem_we_l		: out std_logic		-- Data memory write enable
	);
end entity ctrl_fsm;

architecture RTL of ctrl_fsm is
	-- ==================
	-- | State register |
	-- ==================
	type state_t is (fetch, fetch_w,
					 decode,
					 read_dab, read_dai, read_d_b, read_d_i,
					 exec_0, exec_1, exec_2, exec_3, exec_4,
					 write_reg,
					 hlt
					);
	
	signal state_q, state_n : state_t;
	
	-- ====================
	-- | Output registers |
	-- ====================
	signal alu_op_b_sel_q, alu_op_b_sel_n	: std_logic;
	signal alu_ctrl_op_q,  alu_ctrl_op_n	: std_logic_vector(1 downto 0);
	
	signal pc_en_q, pc_en_n	: std_logic;
	signal ir_en_q, ir_en_n	: std_logic;
	
	signal reg_we_l_q, reg_we_l_n			: std_logic;
	signal reg_op_a_sel_q, reg_op_a_sel_n	: std_logic;
	signal reg_op_b_sel_q, reg_op_b_sel_n	: std_logic;
	signal reg_wr_d_sel_q, reg_wr_d_sel_n	: std_logic;
	
	signal mem_sel_l_q, mem_sel_l_n	: std_logic;
	signal mem_we_l_q,  mem_we_l_n	: std_logic;
	
begin
	
	-- ==================
	-- | State register |
	-- ==================
	star : process(clk) is
	begin
		if rising_edge(clk) then
			if rst = '1' then
				state_q <= fetch;
				
				alu_ctrl_op_q  <= "00";
				alu_op_b_sel_q <= '0';
				
				pc_en_q <= '0';
				ir_en_q <= '0';
				   
				reg_we_l_q	   <= '1';
				reg_op_a_sel_q <= '0';
				reg_op_b_sel_q <= '0';
				reg_wr_d_sel_q <= '0';
				
				mem_sel_l_q <= '1';
				mem_we_l_q  <= '1';
			else
				state_q <= state_n;
				
				alu_ctrl_op_q  <= alu_ctrl_op_n;
				alu_op_b_sel_q <= alu_op_b_sel_n;
				
				pc_en_q <= pc_en_n;
				ir_en_q <= ir_en_n;
				   
				reg_we_l_q	   <= reg_we_l_n;
				reg_op_a_sel_q <= reg_op_a_sel_n;
				reg_op_b_sel_q <= reg_op_b_sel_n;
				reg_wr_d_sel_q <= reg_wr_d_sel_n;
				
				mem_sel_l_q <= mem_sel_l_n;
				mem_we_l_q  <= mem_we_l_n;
			end if;
		end if;
	end process star;
	
	-- =============
	-- | FSM logic |
	-- =============
	fsm : process(state_q, opcode, 
				  alu_ctrl_op_q, alu_op_b_sel_q,
				  ir_en_q, pc_en_q,
				  mem_sel_l_q, mem_we_l_q,
				  reg_op_a_sel_q, reg_op_b_sel_q, reg_we_l_q, reg_wr_d_sel_q
				 ) is
	begin
		state_n <= state_q;
		
		alu_ctrl_op_n  <= alu_ctrl_op_q;
		alu_op_b_sel_n <= alu_op_b_sel_q;
		
		pc_en_n <= pc_en_q;
		ir_en_n <= ir_en_q;
		   
		reg_we_l_n	   <= reg_we_l_q;
		reg_op_a_sel_n <= reg_op_a_sel_q;
		reg_op_b_sel_n <= reg_op_b_sel_q;
		reg_wr_d_sel_n <= reg_wr_d_sel_q;
		
		mem_sel_l_n <= mem_sel_l_q;
		mem_we_l_n  <= mem_we_l_q;
		
		case state_q is 
			
			-- ===============
			-- | Fetch phase |
			-- ===============
			when fetch =>
				reg_we_l_n  <= '1';
				mem_sel_l_n <= '1';
				mem_we_l_n  <= '1';
				
				pc_en_n <= '1';
				ir_en_n <= '1';
				
				state_n <= fetch_w;

			when fetch_w =>
				pc_en_n <= '0';
				
				state_n <= decode;
						
			-- ================
			-- | Decode phase |			
			-- ================
			when decode =>
				ir_en_n <= '0';
				
				case opcode is
					when X"0" | X"1" =>
						state_n <= read_dab;
						
					when X"2" =>
						state_n <= read_dai;
						
					when X"3" =>
						state_n <= read_d_b;
						
					when X"4" =>
						state_n <= read_d_i;
						
					when others =>
						null;
				end case;
				
			-- ==============
			-- | Read phase |
			-- ==============
			when read_dab =>
				reg_op_a_sel_n <= '1'; -- 1st operand = Ra
				reg_op_b_sel_n <= '1'; -- 2nd operand = Rb
				reg_wr_d_sel_n <= '1'; -- Result = ALU
				
				alu_op_b_sel_n <= '0'; -- 2nd ALU operand = Rb
				
				case opcode is
					when X"0" =>
						state_n <= exec_0;
					when X"1" =>
						state_n <= exec_1;
					when others =>
						null;
				end case;
				
			when read_dai =>
				reg_op_a_sel_n <= '1'; -- 1st operand = Ra
				reg_op_b_sel_n <= '0'; -- 2nd operand = Don't care
				reg_wr_d_sel_n <= '1'; -- Result = ALU
				
				alu_op_b_sel_n <= '1'; -- 2nd ALU operand = Immediate
				
				state_n <= exec_2;
				
			when read_d_b =>
				reg_op_a_sel_n <= '0'; -- 1st operand = Rd
				reg_op_b_sel_n <= '1'; -- 2nd operand = Rb
				reg_wr_d_sel_n <= '1'; -- Result = ALU
				
				alu_op_b_sel_n <= '0'; -- 2nd ALU operand = Rb
				
				state_n <= exec_3;
				
			when read_d_i =>
				reg_op_a_sel_n <= '0'; -- 1st operand = Rd
				reg_op_b_sel_n <= '0'; -- 2nd operand = Don't care
				reg_wr_d_sel_n <= '1'; -- Result = ALU
				
				alu_op_b_sel_n <= '1'; -- 2nd ALU operand = Immediate
				
				state_n <= exec_4;
				
			-- ===================
			-- | Execution phase |
			-- ===================
			when exec_0 =>
				alu_ctrl_op_n <= "10"; -- Ra + Rb
				
				state_n <= write_reg;
				
			when exec_1 =>
				alu_ctrl_op_n <= "11"; -- Ra - Rb
				
				state_n <= write_reg;
				
			when exec_2 =>
				alu_ctrl_op_n <= "10"; -- Ra + imm
				
				state_n <= write_reg;
				
			when exec_3 =>
				alu_ctrl_op_n <= "00"; -- Rd {&|!x} Rb
				
				state_n <= write_reg;
				
			when exec_4 =>
				alu_ctrl_op_n <= "00"; -- Rd {&|!x} imm
				
				state_n <= write_reg;
				
			-- ===============
			-- | Write phase |
			-- ===============
			when write_reg =>
				reg_we_l_n <= '0';
				
				state_n <= fetch;
			
			-- ================
			-- | !! HALTED !! |
			-- ================
			when hlt =>
				state_n <= hlt;
				
		end case;
	end process fsm;
	
	-- ======================
	-- | Output assignments |
	-- ======================
	alu_op_b_sel <= alu_op_b_sel_q;
	alu_ctrl_op	 <= alu_ctrl_op_q;
	pc_en		 <= pc_en_q;
	ir_en		 <= ir_en_q;
	reg_we_l	 <= reg_we_l_q;
	reg_op_a_sel <= reg_op_a_sel_q;
	reg_op_b_sel <= reg_op_b_sel_q;
	reg_wr_d_sel <= reg_wr_d_sel_q;
	mem_sel_l	 <= mem_sel_l_q;
	mem_we_l	 <= mem_we_l_q;
	

end architecture RTL;
