library ieee;
	use ieee.std_logic_1164.all, ieee.numeric_std.all;
	use work.gumnut_defs.all;

entity gumnut is
	generic ( debug : boolean := false );
	port ( 	clk_i : in std_ulogic;
		rst_i : in std_ulogic;
		-- Instruction memory bus
		inst_cyc_o : out std_ulogic;
		inst_stb_o : out std_ulogic;
		inst_ack_i : in std_ulogic;
		inst_adr_o : out unsigned(11 downto 0);
		inst_dat_i : in std_ulogic_vector(17 downto 0);
		-- Data memory bus
		data_cyc_o : out std_ulogic;
		data_stb_o : out std_ulogic;
		data_we_o : out std_ulogic;
		data_ack_i : in std_ulogic;
		data_adr_o : out unsigned(7 downto 0);
		data_dat_o : out std_ulogic_vector(7 downto 0);
		data_dat_i : in std_ulogic_vector(7 downto 0);
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
end entity gumnut;
		
--library ieee; use ieee.std_logic_1164.all, ieee.numeric_std.all;


architecture rtl_unpipelined of gumnut is
	signal PC : IMem_addr;
	signal branch_taken : std_ulogic;
	signal IR : instruction;
	alias IR_alu_reg_fn : alu_fn_code is IR(2 downto 0);
	alias IR_alu_immed_fn : alu_fn_code is IR(16 downto 14);
	alias IR_shift_fn : shift_fn_code is IR(1 downto 0);
	alias IR_mem_fn : mem_fn_code is IR(15 downto 14);
	alias IR_branch_fn : branch_fn_code is IR(11 downto 10);
	alias IR_jump_fn : jump_fn_code is IR(12 downto 12);
	alias IR_misc_fn : misc_fn_code is IR(10 downto 8);
	alias IR_rd : reg_addr is IR(13 downto 11);
	alias IR_rs : reg_addr is IR(10 downto 8);
	alias IR_r2 : reg_addr is IR(7 downto 5);
	alias IR_immed : immed is IR(7 downto 0);
	alias IR_count : shift_count is IR(7 downto 5);
	alias IR_offset : disp is IR(7 downto 0);
	alias IR_disp : disp is IR(7 downto 0);
	alias IR_addr : IMem_addr is IR(11 downto 0);
	signal IR_decode_alu_immed, IR_decode_mem, IR_decode_shift, IR_decode_alu_reg, IR_decode_jump, IR_decode_branch, IR_decode_misc : std_ulogic;
	signal D_state : std_ulogic;
	signal int_PC : IMem_addr;
	signal int_Z : std_ulogic;
	signal int_C : std_ulogic;
	signal int_en : std_ulogic;
	constant SP_length : positive := 3;
	signal SP : unsigned(SP_length - 1 downto 0);
	signal stack_top : IMem_addr;
	signal GPR_rs : unsigned_byte;
	signal GPR_r2 : unsigned_byte;
	signal ALU_result : unsigned_byte;
	signal ALU_Z : std_ulogic;
	signal ALU_C : std_ulogic;
	signal ALU_out : unsigned_byte;
	signal cc_Z : std_ulogic;
	signal cc_C : std_ulogic;
	signal D : unsigned_byte;
	
	type control_state is (fetch_state, decode_state, execute_state, mem_state, write_back_state, int_state);
	signal state, next_state : control_state;

	begin
		IR_decode_alu_immed <= IR(17) ?= '0';
		IR_decode_mem <= IR(17 downto 16) ?= "10";
		IR_decode_shift <= IR(17 downto 15) ?= "110";
		IR_decode_alu_reg <= IR(17 downto 14) ?= "1110";
		IR_decode_jump <= IR(17 downto 13) ?= "11110";
		IR_decode_branch <= IR(17 downto 12) ?= "111110";
		IR_decode_misc <= IR(17 downto 11) ?= "1111110";
		-- ...
	

control : process (all)
begin
	case state is
		when fetch_state =>
			if not inst_ack_i then
				next_state <= fetch_state;
			else
				next_state <= decode_state;
			end if;
		when decode_state =>
			if IR_decode_branch or IR_decode_jump or IR_decode_misc then
				if IR_decode_misc and (IR_misc_fn ?= misc_fn_wait or IR_misc_fn ?= misc_fn_stby) and not (int_en and int_req) then
					next_state <= decode_state;
				elsif int_en and int_req then
					next_state <= int_state;
				else
					next_state <= fetch_state;
				end if;
			else
				next_state <= execute_state;
			end if;
		when execute_state =>
			if IR_decode_mem then
				if (IR_mem_fn ?= mem_fn_ldm or IR_mem_fn ?= mem_fn_stm) and not data_ack_i then
					next_state <= mem_state;
				elsif (IR_mem_fn ?= mem_fn_inp or IR_mem_fn ?= mem_fn_out) and not port_ack_i then
					next_state <= mem_state;
				elsif IR_mem_fn ?= mem_fn_ldm or IR_mem_fn ?= mem_fn_inp then
					next_state <= write_back_state;
				else
					if int_en and int_req then
						next_state <= int_state;
					else
						next_state <= fetch_state;
					end if;
				end if;
			else
				next_state <= write_back_state;
			end if;
		when mem_state =>
			if (IR_mem_fn ?= mem_fn_ldm or IR_mem_fn ?= mem_fn_stm) and not data_ack_i then
				next_state <= mem_state;
			elsif (IR_mem_fn ?= mem_fn_inp or IR_mem_fn ?= mem_fn_out) and not port_ack_i then
				next_state <= mem_state;
			elsif IR_mem_fn ?= mem_fn_ldm or IR_mem_fn ?= mem_fn_inp then
				next_state <= write_back_state;
			else
				if int_en and int_req then
					next_state <= int_state;
				else
					next_state <= fetch_state;
				end if;
			end if;
		when write_back_state =>
			if int_en and int_req then
				next_state <= int_state;
			else
				next_state <= fetch_state;
			end if;
		when int_state =>
			next_state <= fetch_state;
		end case;
end process control;

state_reg : process (clk_i)
begin
	if rising_edge(clk_i) then
		if rst_i then
			state <= fetch_state;
		else
			state <= next_state;
		end if;
	end if;
end process state_reg;

with IR_branch_fn select
	branch_taken <= cc_Z when branch_fn_bz, not cc_Z when branch_fn_bnz, cc_C when branch_fn_bc, not cc_C when branch_fn_bnc, 'X' when others;

PC_reg : process (clk_i)
begin
	if rising_edge(clk_i) then
		if rst_i then
			PC <= (others => '0');
		elsif state = fetch_state and inst_ack_i = '1' then
			PC <= PC + 1;
		elsif state = decode_state then
			if IR_decode_branch and branch_taken then
				PC <= unsigned(signed(PC) + signed(IR_disp));
			elsif IR_decode_jump then
				PC <= IR_addr;
			elsif IR_decode_misc and IR_misc_fn ?= misc_fn_ret then
				PC <= stack_top;
			elsif IR_decode_misc and IR_misc_fn ?= misc_fn_reti then
				PC <= int_PC;
			end if;
		elsif state = int_state then
			PC <= to_unsigned(1, PC'length);
		end if;
	end if;
end process PC_reg;

int_ack <= '1' when state = int_state else '0';

int_reg : process (clk_i)
begin
	if rising_edge(clk_i) then
		if rst_i then
			int_en <= '0';
		elsif state = int_state then
			int_PC <= PC;
			int_Z <= cc_Z;
			int_C <= cc_C;
			int_en <= '0';
		elsif state = decode_state and IR_decode_misc = '1' then
			case IR_misc_fn is
				when misc_fn_reti | misc_fn_enai =>
					int_en <= '1';
				when misc_fn_disi =>
					int_en <= '0';
				when others =>
					null;
			end case;
		end if;
	end if;
end process int_reg;

inst_cyc_o <= '1' when state = fetch_state else '0';
inst_stb_o <= '1' when state = fetch_state else '0';
inst_adr_o <= PC;

instr_reg : process (clk_i)
begin
	if rising_edge(clk_i) then
		if state = fetch_state and inst_ack_i = '1' then
			IR <= unsigned(to_X01(inst_dat_i));
		end if;
	end if;
end process instr_reg;

stack_mem : process (clk_i)
constant stack_depth : positive := 2**SP_length;
subtype stack_index is natural range 0 to stack_depth - 1;
type stack_array is array (stack_index) of IMem_addr;
variable stack : stack_array;
begin
	if rising_edge(clk_i) then
		if rst_i then
			SP <= (others => '0');
		elsif state = decode_state then
			if IR_decode_jump and IR_jump_fn ?= jump_fn_jsb then
				stack(to_integer(SP)) := PC;
				SP <= SP + 1;
			elsif IR_decode_misc and IR_misc_fn ?= misc_fn_ret then
				SP <= SP - 1;
			end if;
		end if;
		stack_top <= stack(to_integer(SP - 1));
	end if;
end process stack_mem;

GPR_mem : process (clk_i)
subtype reg_index is natural range 0 to 7;
variable r2_addr : reg_addr;
variable write_data : unsigned_byte;
variable GPR : unsigned_byte_array(reg_index) := (others => X"00");
begin
	if rising_edge(clk_i) then
		if rst_i then
			GPR := (others => (others => '0'));
		else
			if state = write_back_state and IR_rd /= 0 then
				if IR_decode_alu_reg or IR_decode_alu_immed or IR_decode_shift then
					write_data := ALU_out;
				elsif IR_decode_mem and (IR_mem_fn ?= mem_fn_ldm or IR_mem_fn ?= mem_fn_inp) then
					write_data := D;
				end if;
				GPR(to_integer(IR_rd)) := write_data;
			end if;
			if state = decode_state then
				if IR_decode_mem and (IR_mem_fn ?= mem_fn_stm or IR_mem_fn ?= mem_fn_out) then
					r2_addr := IR_rd;
				else
					r2_addr := IR_r2;
				end if;
				GPR_rs <= GPR(to_integer(IR_rs));
				GPR_r2 <= GPR(to_integer(r2_addr));
			end if;
		end if;
	end if;
end process GPR_mem;

ALU : process (all)
variable fn : alu_fn_code;
variable right_operand : unsigned_byte;
variable shift_result : unsigned_byte;
begin
	if IR_decode_alu_reg or IR_decode_alu_immed or IR_decode_mem then
		if IR_decode_alu_reg then
			fn := IR_alu_reg_fn;
			right_operand := GPR_r2;
		elsif IR_decode_alu_immed then
			fn := IR_alu_immed_fn;
			right_operand := IR_immed;
		else
			fn := alu_fn_add;
			right_operand := IR_offset;
		end if;
		case fn is
			when alu_fn_add =>
				(ALU_C, ALU_result) <= ('0' & GPR_rs) + ('0' & right_operand);
			when alu_fn_addc =>
				(ALU_C, ALU_result) <= ('0' & GPR_rs) + ('0' & right_operand) + cc_C;
			when alu_fn_sub => 
				(ALU_C, ALU_result) <= ('0' & GPR_rs) - ('0' & right_operand);
			when alu_fn_subc => 
				(ALU_C, ALU_result) <= ('0' & GPR_rs) - ('0' & right_operand) - cc_C;
			when alu_fn_and =>
				(ALU_C, ALU_result) <= ('0' & GPR_rs) and ('0' & right_operand);
			when alu_fn_or => 
				(ALU_C, ALU_result) <= ('0' & GPR_rs) or ('0' & right_operand);
			when alu_fn_xor =>
				(ALU_C, ALU_result) <= ('0' & GPR_rs) xor ('0' & right_operand);
			when alu_fn_mask =>
				(ALU_C, ALU_result) <= ('0' & GPR_rs) and not ('0' & right_operand);
			when others =>
				(ALU_C, ALU_result) <= 'X' & unsigned_byte'(others => 'X');
		end case;
	else
		case IR_shift_fn is
			when shift_fn_shl =>
				(ALU_C, ALU_result) <= ('0' & GPR_rs) sll to_integer(IR_count);
			when shift_fn_shr =>
				(ALU_result, ALU_C) <= (GPR_rs & '0') srl to_integer(IR_count);
			when shift_fn_rol =>
				shift_result := GPR_rs rol to_integer(IR_count);
				ALU_result <= shift_result;
				ALU_C <= shift_result(unsigned_byte'right);
			when shift_fn_ror =>
				shift_result := GPR_rs ror to_integer(IR_count);
				ALU_result <= shift_result;
				ALU_C <= shift_result(unsigned_byte'left);
			when others =>
				(ALU_C, ALU_result) <= 'X' & unsigned_byte'(others => 'X');
		end case;
	end if;
end process ALU;

ALU_Z <= ALU_result ?= unsigned_byte'(others => '0');

ALU_reg : process (clk_i)
begin
	if rising_edge(clk_i) then
		if state = execute_state then
			ALU_out <= ALU_result;
		end if;
	end if;
end process ALU_reg;

cc_reg : process (clk_i)
begin
	if rising_edge(clk_i) then
		if rst_i then
			cc_Z <= '0';
			cc_C <= '0';
		elsif state = execute_state and (IR_decode_alu_reg = '1' or IR_decode_alu_immed = '1' or IR_decode_shift = '1') then
			cc_Z <= ALU_Z;
			cc_C <= ALU_C;
		elsif state = decode_state and IR_decode_misc = '1' and IR_misc_fn = misc_fn_reti then
			cc_Z <= int_Z;
			cc_C <= int_C;
		end if;
	end if;
end process cc_reg;

D_state <= '1' when (state = execute_state or state = mem_state) and IR_decode_mem = '1' else '0';

D_reg : process (clk_i)
begin
	if rising_edge(clk_i) then
		if D_state and IR_mem_fn ?= mem_fn_ldm and data_ack_i then
			D <= unsigned(data_dat_i);
		elsif D_state and IR_mem_fn ?= mem_fn_inp and port_ack_i then
			D <= unsigned(port_dat_i);
		end if;
	end if;
end process D_reg;

data_cyc_o <= D_state and (IR_mem_fn ?= mem_fn_stm or IR_mem_fn ?= mem_fn_ldm);
data_stb_o <= D_state and (IR_mem_fn ?= mem_fn_stm or IR_mem_fn ?= mem_fn_ldm);
data_we_o <= D_state and IR_mem_fn ?= mem_fn_stm;
data_adr_o <= ALU_result;
data_dat_o <= std_ulogic_vector(GPR_r2);
port_cyc_o <= D_state and (IR_mem_fn ?= mem_fn_inp or IR_mem_fn ?= mem_fn_out);
port_stb_o <= D_state and (IR_mem_fn ?= mem_fn_inp or IR_mem_fn ?= mem_fn_out);
port_we_o <= D_state and IR_mem_fn ?= mem_fn_out;
port_adr_o <= ALU_result;
port_dat_o <= std_ulogic_vector(GPR_r2);


debug_monitor : if debug generate
	debugger : process
	use std.textio.all;
	variable disassembled_instr : disassembled_instruction;
	variable debug_line : line;
	variable PC_num : natural;
	begin
		wait until rising_edge(clk_i);
		loop
			if rst_i then
				swrite(debug_line, "Resetting");
				writeline(output, debug_line);
				wait until rising_edge(clk_i) and rst_i = '0';
				next;
			elsif state = fetch_state then
				PC_num := to_integer(PC);
			elsif state = decode_state then
				disassemble(IR, disassembled_instr);
				write(debug_line, PC_num, field => 4, justified => right);
				swrite(debug_line, ": ");
				write(debug_line, disassembled_instr);
				writeline(output, debug_line);
				wait until rising_edge(clk_i) and (rst_i ='1' or state /= decode_state);
				next;
			elsif state = int_state then
				PC_num := to_integer(PC);
				swrite(debug_line, "Interrupt acknowledged at PC = ");
				write(debug_line, PC_num, field => 4, justified => right);
				writeline(output, debug_line);
			end if;
			wait until rising_edge(clk_i);
		end loop;
	end process debugger;
end generate debug_monitor;
end architecture rtl_unpipelined;