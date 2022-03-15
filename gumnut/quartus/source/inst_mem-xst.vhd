library ieee;
use std.textio.all, ieee.std_logic_textio.all;

architecture xst of inst_mem is

  impure function load_IMem (IMem_file_name : in string)
                            return IMem_array is
    file IMem_file : text is in IMem_file_name;
    variable L : line;
    variable instr : std_logic_vector(instruction'range);
    variable IMem : IMem_array;
  begin
    for i in IMem_array'range loop
      readline(IMem_file, L);
      read(L, instr);
      IMem(i) := unsigned(instr);
    end loop;
    return IMem;
  end function;

  constant IMem : IMem_array := load_IMem(IMem_file_name);

begin

  dat_o <= std_logic_vector(IMem(to_integer(adr_i)));

  ack_o <= cyc_i and stb_i;

end architecture xst;
