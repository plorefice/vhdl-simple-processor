--==============================================================================
-- File: 	memory_tb.vhd
-- Author:	Pietro Lorefice
-- Version:	1.0
--==============================================================================
-- Description:
--   Testbench for the data memory module.
-- 
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;

entity memory_tb is
end entity memory_tb;

architecture tb_arch of memory_tb is
	constant T : time := 20 ns;
	constant N : integer := 20;
	constant B : integer := 8;
	
	signal clk, rst, we_l, sel_l : std_logic;
	signal r_addr, w_addr : std_logic_vector(N-1 downto 0);
	signal d_in, d_out : std_logic_vector(B-1 downto 0);
begin

	uut : entity work.d_mem(RTL)
		generic map(N => N,
			        B => B)
		port map(clk    => clk,
			     rst    => rst,
			     we_l   => we_l,
			     sel_l  => sel_l,
			     r_addr => r_addr,
			     w_addr => w_addr, 
			     w_data => d_in,
			     r_data => d_out);
			     
	clk_gen : process
	begin
		clk <= '0';
		wait for T/2;
		clk <= '1';
		wait for T/2;
	end process clk_gen;
	
	rst <= '1', '0' after 3*T/4;
	
	stim_gen : process is
	begin
		-- init signals
		we_l <= '1';
		sel_l <= '1';
		r_addr <= (others => '0');
		w_addr <= (others => '0');
		d_in <= (others => '0');
		
		-- wait
		wait until falling_edge(clk);
		assert d_out = X"00";
		wait until falling_edge(clk);
		
		-- write bunch of stuff
		we_l <= '0';
		sel_l <= '0';
		w_addr <= X"012AE";
		d_in <= X"04";
		wait until falling_edge(clk);
		
		assert d_out = X"00";
		
		w_addr <= X"142B2";
		d_in <= X"08";
		wait until falling_edge(clk);
		
		w_addr <= X"41523";
		d_in <= X"0F";
		wait until falling_edge(clk);
		
		w_addr <= X"00000";
		d_in <= X"10";
		wait until falling_edge(clk);
		
		w_addr <= X"11111";
		d_in <= X"17";
		wait until falling_edge(clk);
		
		w_addr <= X"FFFFF";
		d_in <= X"2A";
		wait until falling_edge(clk);
		
		-- wait a sec
		we_l <= '1';
		sel_l <= '1';
		wait for 4*T;
		wait until falling_edge(clk);
		
		assert d_out = X"00";
		
		-- read stuff
		sel_l <= '0';
		r_addr <= X"11111";
		wait until falling_edge(clk);
		assert d_out = X"17";
		
		r_addr <= X"12351";
		wait until falling_edge(clk);
		assert d_out = X"00";

		r_addr <= X"00000";
		wait until falling_edge(clk);
		assert d_out = X"10";

		r_addr <= X"FFFFF";
		wait until falling_edge(clk);
		assert d_out = X"2A";

		r_addr <= X"69696";
		wait until falling_edge(clk);
		assert d_out = X"00";

		-- change one element and verify
		we_l <= '0';
		w_addr <= X"69696";
		r_addr <= X"69696";
		d_in <= X"99";
		wait until falling_edge(clk);
		
		we_l <= '1';
		wait until falling_edge(clk);
		assert d_out = X"99";
		
		wait until falling_edge(clk);
		
		assert false report "Simulation over" severity failure;
		
	end process stim_gen;
	

end architecture tb_arch;
