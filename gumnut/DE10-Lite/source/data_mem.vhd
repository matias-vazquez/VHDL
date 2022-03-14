library ieee;
use ieee.std_logic_1164.all, ieee.numeric_std.all;
	entity data_mem is
	generic(DMem_file_name : string := "gasm_data.dat" );
	port(	clk_i : in std_ulogic;
		cyc_i : in std_ulogic;
		stb_i : in std_ulogic;
		we_i : in std_ulogic;
		ack_o : out std_ulogic;
		adr_i : in unsigned(7 downto 0);
		dat_i : in std_ulogic_vector(7 downto 0);
		dat_o : out std_ulogic_vector(7 downto 0) );
end entity data_mem;
