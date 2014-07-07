library ieee;
use ieee.std_logic_1164.all;

entity processor_tb is
end entity processor_tb;

architecture tb of processor_tb is
	constant T : time := 20 ns;
	
	signal clk, rst : std_logic;
begin
	
	uut : entity work.processor
		port map(clk => clk,
			     rst => rst);
	
	clk_gen : process is
	begin
		clk <= '0';
		wait for T/2;
		clk <= '1';
		wait for T/2;
	end process clk_gen;
	
	rst <= '1', '0' after 3*T/4;

end architecture tb;
