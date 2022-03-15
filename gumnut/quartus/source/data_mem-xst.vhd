library ieee;
use std.textio.all, ieee.std_logic_textio.all;

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
          dat_o <= std_logic_vector(DMem(to_integer(adr_i)));
          read_ack <= '1';
        end if;
      else
        read_ack <= '0';
      end if;
    end if;
  end process data_mem;

  ack_o <= cyc_i and stb_i and (we_i or read_ack);

end architecture xst;
