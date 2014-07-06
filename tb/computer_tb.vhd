library ieee;
use ieee.std_logic_1164.all;

entity computer_tb is
end entity computer_tb;

architecture tb_arch of computer_tb is
	constant T : time := 20 ns;
	
	signal clk, arst : std_logic;
begin
	
	uut : entity work.computer(struct)
		port map(clk  => clk,
			     arst => arst);
			     
	clk_gen : process is
	begin
		clk <= '0';
		wait for T/2;
		clk <= '1';
		wait for T/2;
	end process clk_gen;
	
	arst <= '1', '0' after 3*T/4;

end architecture tb_arch;
