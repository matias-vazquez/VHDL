library ieee;
use ieee.std_logic_1164.all, ieee.numeric_std.all;
use std.textio.all, ieee.std_logic_textio.all;
use work.gumnut_defs.all;

entity inst_mem is
	generic (IMem_file_name : string := "gasm_text.dat" );
	port	(clk_i : in std_ulogic;
		cyc_i : in std_ulogic;
		stb_i : in std_ulogic;
		ack_o : out std_ulogic;
		adr_i : in unsigned(11 downto 0);
		dat_o : out std_ulogic_vector(17 downto 0) );
end entity inst_mem;

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

  dat_o <= std_ulogic_vector(IMem(to_integer(adr_i)));

  ack_o <= cyc_i and stb_i;

end architecture xst;
