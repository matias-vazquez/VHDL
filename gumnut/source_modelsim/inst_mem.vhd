library ieee;
use ieee.std_logic_1164.all, ieee.numeric_std.all;
entity inst_mem is
	generic (IMem_file_name : string := "gasm_text.dat" );
	port	(clk_i : in std_ulogic;
		cyc_i : in std_ulogic;
		stb_i : in std_ulogic;
		ack_o : out std_ulogic;
		adr_i : in unsigned(11 downto 0);
		dat_o : out std_ulogic_vector(17 downto 0) );
end entity inst_mem;