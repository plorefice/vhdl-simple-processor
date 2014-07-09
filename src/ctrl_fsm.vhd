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
		
		alu_op_b_en		: out std_logic;
		alu_op_b_sel	: out std_logic;					-- ALU operand B select
		alu_result_en	: out std_logic;
		alu_ctrl_op		: out std_logic_vector(1 downto 0);	-- ALU control unit operation
		
		pc_en			: out std_logic;	-- Program counter register enable
		ir_en			: out std_logic;	-- Instruction register enable
		
		reg_op_a_sel	: out std_logic;	-- Register file operand A select
		reg_op_b_sel	: out std_logic;	-- Register file operand B select
		reg_addr_a_en	: out std_logic;
		reg_addr_b_en	: out std_logic;
		reg_we_l		: out std_logic;	-- Register file write enable
		reg_wr_d_sel	: out std_logic;	-- Register file write data select
		reg_data_a_en	: out std_logic;
		reg_data_b_en	: out std_logic;
		
		mem_sel_l		: out std_logic;	-- Data memory select
		mem_we_l		: out std_logic		-- Data memory write enable
	);
end entity ctrl_fsm;

architecture RTL of ctrl_fsm is
	-- ==================
	-- | State register |
	-- ==================
	type state_t is (reset, fetch, decode, read, exec, write, hlt);
	
	signal state_q, state_n : state_t;	
begin
	
	-- ==================
	-- | State register |
	-- ==================
	state_update_logic : process(clk) is
	begin
		if rising_edge(clk) then
			if rst = '1' then
				state_q <= reset;
			else
				state_q <= state_n;
			end if;
		end if;
	end process state_update_logic;

	-- ====================
	-- | Next-state logic |
	-- ====================
	next_state_logic : process(state_q) is
	begin
		state_n <= state_q;
		
		case state_q is 
			when reset =>
				state_n <= fetch;
			
			when fetch =>
				state_n <= decode;
				
			when decode =>
				state_n <= read;
				
			when read =>
				state_n <= exec;
				
			when exec =>
				state_n <= write;
				
			when write =>
				state_n <= fetch;
				
			-- ================
			-- | !! HALTED !! |
			-- ================
			when hlt =>
				state_n <= hlt;
				
		end case;
	end process next_state_logic;
	
	-- ================
	-- | Output logic |
	-- ================
	output_logic : process(state_q, opcode) is
	begin
		alu_op_b_en   <= '0';
		alu_op_b_sel  <= '0';
		alu_result_en <= '0';
		alu_ctrl_op   <= "00";
		
		pc_en <= '0';
		ir_en <= '0';
		
		reg_op_a_sel  <= '0';
		reg_op_b_sel  <= '0';
		reg_addr_a_en <= '0';
		reg_addr_b_en <= '0';
		reg_we_l	  <= '1';
		reg_wr_d_sel  <= '0';
		reg_data_a_en <= '0';
		reg_data_b_en <= '0';
		
		mem_sel_l <= '1';
		mem_we_l  <= '1';
		
		case state_q is 
			when reset =>
				null;
			
			when fetch =>
				pc_en <= '1';
				ir_en <= '1';
				
			when decode =>
				reg_addr_a_en <= '1';
				reg_addr_b_en <= '1';
				
				case opcode is
					when X"0" | X"1" | X"2" =>
						reg_op_a_sel <= '1';
						reg_op_b_sel <= '1';
						
					when X"3" | X"4" =>
						reg_op_a_sel <= '0';
						reg_op_b_sel <= '1';
						
					when X"8" | X"9" =>
						reg_op_a_sel <= '1';
						reg_op_b_sel <= '0';
						
					when others =>
						null;
				end case;

			when read =>
				reg_data_a_en <= '1';
				reg_data_b_en <= '1';
				alu_op_b_en   <= '1';
				
				case opcode is
					when X"0" | X"1" | X"3" =>
						alu_op_b_sel <= '0';
						
					when X"2" | X"4" | X"5" | X"6" | X"8" | X"9" =>
						alu_op_b_sel <= '1';
						
					when others =>
						null;
				end case;
				
			when exec =>
				alu_result_en <= '1';
				
				case opcode is
					when X"0" | X"2" | X"8" | X"9" =>
						alu_ctrl_op <= "10";
					
					when X"1" =>
						alu_ctrl_op <= "11";
						
					when X"3" | X"4" =>
						alu_ctrl_op <= "00";
						
					when X"5" | X"6" =>
						alu_ctrl_op <= "10";
						mem_sel_l <= '0';
						
					when others =>
						null;
				end case;

			when write =>
				
				case opcode is
					when X"0" | X"1" | X"2" | X"3" | X"4" =>
						reg_wr_d_sel <= '1';
						reg_we_l <= '0';
						
					when X"8" | X"9" =>
						mem_sel_l <= '0';
						mem_we_l <= '0';
						
					when X"5" | X"6" =>
						reg_wr_d_sel <= '0';
						reg_we_l <= '0';
					
					when others =>
						null;
				end case;
				
			when hlt =>
				null;
		end case;
		
	end process output_logic;

end architecture RTL;
