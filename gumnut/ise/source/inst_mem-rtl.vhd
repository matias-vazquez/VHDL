library ieee;
use ieee.std_logic_1164.all, ieee.numeric_std.all;

-- use work.gumnut_defs.all;
-- use work.gasm_text.all;
-- use std.textio.all;

architecture rtl of inst_mem is

  constant IMem : IMem_array := work.gasm_text.program;

begin

  dat_o <= std_logic_vector(IMem(to_integer(adr_i)));

  ack_o <= cyc_i and stb_i;

end architecture rtl;
