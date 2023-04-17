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
    signal read_en : std_logic;
    signal clk_cnt_en : std_logic;
    signal valid : std_logic;
    -- FSM inputs
    signal data_fsm : std_logic;
    signal bit_cnt : std_logic_vector(3 downto 0) := "0000";
    signal clk_cnt : std_logic_vector(4 downto 0) := "00000";
    -- logic outputs
    signal xor_out : std_logic;
    signal and_out : std_logic;
    signal not_out : std_logic;
    signal cmp_equal : std_logic;
    
begin

    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    --fsm: entity work.UART_RX_FSM(behavioral)
    port map (
        CLK => CLK,
        RST => RST,
        -- INPUTS
        DATA_IN => data_fsm,
        BIT_CNT => bit_cnt,
        CLK_CNT => clk_cnt,
        --OUPUTS
        READ_EN => read_en,
        CLK_CNT_EN => clk_cnt_en,
        VALID => valid
    );

    
    -- Logic gates
    xor_out <= clk_cnt_en xor and_out;
    and_out <= read_en and cmp_equal;
    not_out <= not xor_out;
    cmp_equal <= '1' when clk_cnt = "10000" else '0';


end architecture;
