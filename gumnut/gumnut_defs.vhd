library ieee;
	use ieee.std_logic_1164.all, ieee.numeric_std.all;

package gumnut_defs is
	constant IMem_addr_width : positive := 12;
	constant IMem_size : positive := 2**IMem_addr_width;
	subtype IMem_addr is unsigned(IMem_addr_width - 1 downto 0);

	subtype instruction is unsigned(17 downto 0);
	type instruction_array is array (natural range <>) of instruction;

	subtype IMem_array is instruction_array(0 to IMem_size - 1);

	constant DMem_size : positive := 256;

	subtype unsigned_byte is unsigned(7 downto 0);
	type unsigned_byte_array is array (natural range <>) of unsigned_byte;
	
	subtype DMem_array is unsigned_byte_array(0 to DMem_size - 1);
	
	subtype signed_byte is signed(7 downto 0);
	type signed_byte_array is array (natural range <>) of signed_byte;

	subtype reg_addr is unsigned(2 downto 0);
	subtype immed is unsigned(7 downto 0);
	subtype offset is unsigned(7 downto 0);
	subtype disp is unsigned(7 downto 0);
	subtype shift_count is unsigned(2 downto 0);

	subtype alu_fn_code is unsigned(2 downto 0);
	subtype shift_fn_code is unsigned(1 downto 0);
	subtype mem_fn_code is unsigned(1 downto 0);
	subtype branch_fn_code is unsigned(1 downto 0);
	subtype jump_fn_code is unsigned(0 downto 0);
	subtype misc_fn_code is unsigned(2 downto 0);

	constant alu_fn_add : alu_fn_code := "000";
	constant alu_fn_addc : alu_fn_code := "001";
	constant alu_fn_sub : alu_fn_code := "010";
	constant alu_fn_subc : alu_fn_code := "011";
	constant alu_fn_and : alu_fn_code := "100";
	constant alu_fn_or : alu_fn_code := "101";
	constant alu_fn_xor : alu_fn_code := "110";
	constant alu_fn_mask : alu_fn_code := "111";

	constant shift_fn_shl : shift_fn_code := "00";
	constant shift_fn_shr : shift_fn_code := "01";
	constant shift_fn_rol : shift_fn_code := "10";
	constant shift_fn_ror : shift_fn_code := "11";

	constant mem_fn_ldm : mem_fn_code := "00";
	constant mem_fn_stm : mem_fn_code := "01";
	constant mem_fn_inp : mem_fn_code := "10";
	constant mem_fn_out : mem_fn_code := "11";

	constant branch_fn_bz : branch_fn_code := "00";
	constant branch_fn_bnz : branch_fn_code := "01";
	constant branch_fn_bc : branch_fn_code := "10";
	constant branch_fn_bnc : branch_fn_code := "11";

	constant jump_fn_jmp : jump_fn_code := "0";
	constant jump_fn_jsb : jump_fn_code := "1";

	constant misc_fn_ret : misc_fn_code := "000";
	constant misc_fn_reti : misc_fn_code := "001";
	constant misc_fn_enai : misc_fn_code := "010";
	constant misc_fn_disi : misc_fn_code := "011";
	constant misc_fn_wait : misc_fn_code := "100";
	constant misc_fn_stby : misc_fn_code := "101";
	constant misc_fn_undef_6 : misc_fn_code := "110";
	constant misc_fn_undef_7 : misc_fn_code := "111";

	subtype disassembled_instruction is string(1 to 30);

	procedure disassemble ( instr : instruction;
		  result : out disassembled_instruction );
end package gumnut_defs;
