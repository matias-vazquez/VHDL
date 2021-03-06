entity test is
end test;

library ieee;
use ieee.std_logic_1164.all, ieee.numeric_std.all;
use work.gumnut_defs.all;
use std.textio.all;

architecture gumnut of test is
signal syscon_clk_o : std_ulogic;
signal syscon_rst_o : std_ulogic;
-- I/O port bus
signal gumnut_port_cyc_o : std_ulogic;
signal gumnut_port_stb_o : std_ulogic;
signal gumnut_port_we_o : std_ulogic;
signal gumnut_port_ack_i : std_ulogic;
signal gumnut_port_adr_o : unsigned(7 downto 0);
signal gumnut_port_dat_o : std_ulogic_vector(7 downto 0);
signal gumnut_port_dat_i : std_ulogic_vector(7 downto 0);
-- Interrupts
signal gumnut_int_req : std_ulogic;
signal gumnut_int_ack : std_ulogic;

component gumnut_with_mem is
	port ( clk_i : in std_ulogic;
	rst_i : in std_ulogic;
	-- I/O port bus
	port_cyc_o : out std_ulogic;
	port_stb_o : out std_ulogic;
	port_we_o : out std_ulogic;
	port_ack_i : in std_ulogic;
	port_adr_o : out unsigned(7 downto 0);
	port_dat_o : out std_ulogic_vector(7 downto 0);
	port_dat_i : in std_ulogic_vector(7 downto 0);
	-- Interrupts
	int_req : in std_ulogic;
	int_ack : out std_ulogic );
end component gumnut_with_mem;

begin
	reset_gen : syscon_rst_o <= '0', '1' after 5 ns, '0' after 25 ns;
	clk_gen : process
	begin
		syscon_clk_o <= '0';
		wait for 10 ns;
		loop
			syscon_clk_o <= '1', '0' after 5 ns;
			wait for 10 ns;
		end loop;
	end process clk_gen;

	int_gen : process
	begin
		gumnut_int_req <= '0';
		for int_count in 1 to 10 loop
			for cycle_count in 1 to 25 loop
				wait until falling_edge(syscon_clk_o);
			end loop;
			gumnut_int_req <= '1';
			wait until falling_edge(syscon_clk_o) and gumnut_int_ack = '1';
			gumnut_int_req <= '0';
		end loop;
		wait;
	end process int_gen;

	io_control : process
	-- Hard-wired input stream
	constant input_data : unsigned_byte_array
	:= ( 	X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07",
		X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"10", X"11", X"12", X"13", X"14", X"15", X"16", X"17",
		X"18", X"19", X"1A", X"1B", X"1C", X"1D", X"1E", X"1F" );
	variable next_input : integer := 0;
	variable debug_line : line;
	constant show_actions : boolean := true;
	begin
		gumnut_port_ack_i <= '0';
		loop
			wait until falling_edge(syscon_clk_o);
			if gumnut_port_cyc_o and gumnut_port_stb_o then
				if to_X01(gumnut_port_we_o) = '0' then
					if show_actions then
						swrite(debug_line, "IO: port read; address = ");
						hwrite(debug_line, gumnut_port_adr_o);
						swrite(debug_line, ", data = ");
						hwrite(debug_line, input_data(next_input) );
						writeline(output, debug_line);
					end if;
					gumnut_port_dat_i <= std_ulogic_vector(input_data(next_input));
					next_input := (next_input + 1) mod input_data'length;
					gumnut_port_ack_i <= '1';
				else
					if show_actions then
						swrite(debug_line, "IO: port write; address = ");
						hwrite(debug_line, gumnut_port_adr_o );
						swrite(debug_line, ", data = ");
						hwrite(debug_line, gumnut_port_dat_o );
						writeline(output, debug_line);
					end if;
					gumnut_port_ack_i <= '1';
				end if;
			else
				gumnut_port_ack_i <= '0';
			end if;
		end loop;
end process io_control;

dut : component gumnut_with_mem
port map ( clk_i => syscon_clk_o,
	rst_i => syscon_rst_o,
	port_cyc_o => gumnut_port_cyc_o,
	port_stb_o => gumnut_port_stb_o,
	port_we_o => gumnut_port_we_o,
	port_ack_i => gumnut_port_ack_i,
	port_adr_o => gumnut_port_adr_o,
	port_dat_o => gumnut_port_dat_o,
	port_dat_i => gumnut_port_dat_i,
	int_req => gumnut_int_req,
	int_ack => gumnut_int_ack );

end architecture gumnut;

configuration test_gumnut_rtl_unpipelined of test is
	for gumnut
		for dut : gumnut_with_mem
			use entity work.gumnut_with_mem(struct);
			for struct
				for core : gumnut
					use entity work.gumnut(rtl_unpipelined)
					generic map ( debug => true );
				end for;
			end for;
		end for;
	end for;
end configuration test_gumnut_rtl_unpipelined;