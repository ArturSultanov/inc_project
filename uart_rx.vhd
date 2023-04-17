-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Artur Sultanov (xsulta01)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        DOUT_VLD : out std_logic
    );
end entity;

-----------------------------------

-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is


	-- FSM outputs
    signal read_en_fsm : std_logic;
    signal clk_cnt_en_fsm : std_logic;
    signal valid_fsm : std_logic;
    -- FSM inputs
    signal data_fsm : std_logic;
    signal bit_cnt : std_logic_vector(3 downto 0) := "0000";
    signal clk_cnt : std_logic_vector(4 downto 0) := "00000";
    -- logic outputs
    signal xor_out : std_logic;
    signal not_out : std_logic;
    signal cmp_equal : std_logic;
    signal and_out : std_logic;


begin

    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
        CLK => CLK,
        RST => RST
    );


end architecture;
