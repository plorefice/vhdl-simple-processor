library ieee;
use ieee.std_logic_1164.all;

entity computer is
	port (
		clk		: in std_logic;
		arst	: in std_logic
	);
end entity computer;

architecture struct of computer is
	constant N : integer := 20;
	constant B : integer := 32;
	
	signal rw_l_i		: std_logic;
	signal sel_l_i		: std_logic;
	signal addr_i		: std_logic_vector(N-1 downto 0);
	signal data_p2m_i	: std_logic_vector(B-1 downto 0);
	signal data_m2p_i 	: std_logic_vector(B-1 downto 0);
begin
	
	proc_0 : entity work.processor(RTL)
		generic map(N => N,
			        B => B)
		port map(clk    => clk,
			     arst   => arst,
			     r_data => data_m2p_i,
			     rw_l   => rw_l_i,
			     sel_l  => sel_l_i,
			     addr   => addr_i,
			     w_data => data_p2m_i);
			     
	mem_0 : entity work.memory(RTL)
		generic map(N => N,
			        B => B)
		port map(clk    => clk,
			     arst   => arst,
			     rw_l   => rw_l_i,
			     sel_l  => sel_l_i,
			     addr   => addr_i,
			     w_data => data_p2m_i,
			     r_data => data_m2p_i);

end architecture struct;
