library ieee;
use ieee.numeric_std.all;


architecture top of gumnut_system is

  signal port_cyc_o : std_logic;
  signal port_stb_o : std_logic;
  signal port_we_o  : std_logic;
  signal port_ack_i : std_logic;
  signal port_adr_o : unsigned(7 downto 0);
  signal port_dat_o : std_logic_vector(7 downto 0);
  signal port_dat_i : std_logic_vector(7 downto 0);
  -- Interrupts
  signal int_req : std_logic;
  signal int_ack : std_logic;

  -- Add signals for internal connections
  -- ...

  component gumnut_with_mem is
    generic ( IMem_file_name : string;
              DMem_file_name : string;
              debug : boolean );
    port ( clk_i : in std_logic;
           rst_i : in std_logic;
           -- I/O port bus
           port_cyc_o : out std_logic;
           port_stb_o : out std_logic;
           port_we_o : out std_logic;
           port_ack_i : in std_logic;
           port_adr_o : out unsigned(7 downto 0);
           port_dat_o : out std_logic_vector(7 downto 0);
           port_dat_i : in std_logic_vector(7 downto 0);
           -- Interrupts
           int_req : in std_logic;
           int_ack : out std_logic );
  end component gumnut_with_mem;

  -- Add component declarations for internal I/O controllers
  -- ...

begin

  core : gumnut_with_mem
    generic map ( IMem_file_name => "gasm_text.dat",
                  DMem_file_name => "gasm_data.dat",
                  debug => false )
    port map ( clk_i      => clk_i,
               rst_i      => rst_i,
               port_cyc_o => port_cyc_o,
               port_stb_o => port_stb_o,
               port_we_o  => port_we_o,
               port_ack_i => port_ack_i,
               port_adr_o => port_adr_o,
               port_dat_o => port_dat_o,
               port_dat_i => port_dat_i,
               int_req    => int_req,
               int_ack    => int_ack );

  -- Add internal I/O controller instances
  -- ...

end architecture top;
