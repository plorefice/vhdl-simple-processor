library ieee;
use ieee.std_logic_1164.all;

entity reg_file_tb is
end entity reg_file_tb;

architecture tb of reg_file_tb is
	constant T : time := 20 ns;
	constant B : integer := 16;
	constant R : integer := 4;
	
	signal clk, rst, we_l : std_logic;
	signal w_data, r_data_1, r_data_2 : std_logic_vector(B-1 downto 0);
	signal w_addr, r_addr_1, r_addr_2 : std_logic_vector(R-1 downto 0);
begin
	
	uut : entity work.reg_file
		generic map(B => B,
			        R => R)
		port map(clk       => clk,
			     rst       => rst,
			     we_l      => we_l,
			     w_data    => w_data,
			     w_addr    => w_addr,
			     rd_addr_1 => r_addr_1,
			     rd_addr_2 => r_addr_2,
			     rd_data_1 => r_data_1,
			     rd_data_2 => r_data_2);
			     
	clk_gen : process is
	begin
		clk <= '0';
		wait for T/2;
		clk <= '1';
		wait for T/2;
	end process clk_gen;
	
	rst <= '1', '0' after 3*T/4;
	
	stim_gen : process is
	begin
		we_l <= '1';
		r_addr_1 <= X"2";
		r_addr_2 <= X"3";
		
		wait for 4*T;
		
		assert false report "Simulation over" severity failure;
		
	end process stim_gen;

end architecture tb;
