library ieee;
use ieee.std_logic_1164.all;

entity processor_tb is
end entity processor_tb;

architecture tb of processor_tb is
	-- =============
	-- | Constants |
	-- =============
	constant N : integer := 16; -- Memory size ( = data width for simplicity)
	constant B : integer := 16; -- Data width
	constant R : integer := 4;	-- Register file dimension
	constant T : time 	 := 20 ns;
	
	signal clk, rst : std_logic;
	
	signal d_mem_sel_l, d_mem_we_l : std_logic;
	signal i_mem_instr, d_mem_data_in, d_mem_w_data : std_logic_vector(B-1 downto 0);
	signal i_mem_addr, d_mem_r_addr, d_mem_w_addr : std_logic_vector(N-1 downto 0); 
begin
	
	uut : entity work.processor
		generic map(N => N,
			        B => B,
			        R => R)
		port map(clk           => clk,
			     rst           => rst,
			     i_mem_instr   => i_mem_instr,
			     d_mem_data_in => d_mem_data_in,
			     i_mem_addr    => i_mem_addr,
			     d_mem_r_addr  => d_mem_r_addr,
			     d_mem_w_addr  => d_mem_w_addr,
			     d_mem_w_data  => d_mem_w_data,
			     d_mem_sel_l   => d_mem_sel_l,
			     d_mem_we_l    => d_mem_we_l);
			     
	imem_unit : entity work.i_mem
		generic map(N => N,
			        B => B)
		port map(clk   => clk,
			     rst   => rst,
			     addr  => i_mem_addr,
			     instr => i_mem_instr);
			     
	dmem_unit : entity work.d_mem
		generic map(N => N,
			        B => B)
		port map(clk    => clk,
			     rst    => rst,
			     we_l   => d_mem_we_l,
			     sel_l  => d_mem_sel_l,
			     r_addr => d_mem_r_addr,
			     w_addr => d_mem_w_addr,
			     w_data => d_mem_w_data,
			     r_data => d_mem_data_in);
	
	clk_gen : process is
	begin
		clk <= '0';
		wait for T/2;
		clk <= '1';
		wait for T/2;
	end process clk_gen;
	
	rst <= '1', '0' after 3*T/4;

end architecture tb;
