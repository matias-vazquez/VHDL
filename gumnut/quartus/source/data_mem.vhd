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

library ieee;
use std.textio.all, ieee.std_logic_textio.all;
use work.gumnut_defs.all;

architecture xst of data_mem is

  impure function load_DMem (DMem_file_name : in string := "gasm_data.dat")
                            return DMem_array is
    file DMem_file : text is in DMem_file_name;
    variable L : line;
    variable data : std_logic_vector(unsigned_byte'range);
    variable DMem : DMem_array;
  begin
    for i in DMem_array'range loop
      readline(DMem_file, L);
      read(L, data);
      DMem(i) := unsigned(data);
    end loop;
    return DMem;
  end function;

  signal DMem : DMem_array := load_DMem(DMem_file_name);
  signal read_ack : std_logic;

begin

  data_mem : process (clk_i) is
  begin
    if rising_edge(clk_i) then
      if to_X01(cyc_i) = '1' and to_X01(stb_i) = '1' then
        if to_X01(we_i) = '1' then
          DMem(to_integer(adr_i)) <= unsigned(dat_i);
          dat_o <= dat_i;
          read_ack <= '0';
        else
          dat_o <= std_ulogic_vector(DMem(to_integer(adr_i)));
          read_ack <= '1';
        end if;
      else
        read_ack <= '0';
      end if;
    end if;
  end process data_mem;

  ack_o <= cyc_i and stb_i and (we_i or read_ack);

end architecture xst;