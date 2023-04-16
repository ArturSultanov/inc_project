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



-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is

    -- Signals
    signal BIT_CNT          : std_logic_vector(3 downto 0) := (others => '0');
    signal CLK_CNT          : std_logic_vector(4 downto 0) := (others => '0');
    signal READ_EN          : std_logic;
    signal CLK_CNT_EN       : std_logic;
    signal DOUT_VLD         : std_logic;
    signal SHIFT_REG_OUT    : std_logic_vector(7 downto 0) := (others => '0');
    signal AND_OUT          : std_logic;
    signal XOR_OUT          : std_logic;
    signal NOT_OUT1         : std_logic;
    signal NOT_OUT2         : std_logic;
    signal CMP_EQUAL        : std_logic;

begin

    -- Instance of RX FSM
    fsm : entity work.UART_RX_FSM
    port map (
        CLK => CLK,
        RST => RST
        DIN       => DIN,
        BIT_CNT   => BIT_CNT,
        CLK_CNT   => CLK_CNT,
        READ_EN   => READ_EN,
        CLK_CNT_EN => CLK_CNT_EN,
        DOUT_VLD  => DOUT_VLD
    );

    -- Default DOUT and DOUT_VLD values.
    DOUT <= (others => '0');
    DOUT_VLD <= '0';

    -- CLK_CNT counter of of clock cycles.
    p_clk_cnt : process (CLK, RST)
    begin
        if RST = '1' then
            CLK_CNT <= (others => '0');
        elsif rising_edge(CLK) and XOR_OUT = '1' then
            CLK_CNT <= CLK_CNT + 1;
        end if;
    end process;
    
    -- BIT_CNT counter of bits received.
    p_bit_cnt : process (CLK, RST)
    begin
        if RST = '1' then
            BIT_CNT <= (others => '0');
        elsif rising_edge(CLK) and READ_EN = '1' then
            BIT_CNT <= BIT_CNT + 1;
        end if;
    end process;

    -- CMP comparator
    CMP_EQUAL <= '1' when CLK_CNT = "01111" else '0';

    -- SHIFT_REGISTER
    p_shift_register : process (CLK, RST)
    begin
        if RST = '1' then
            SHIFT_REG_OUT <= (others => '0');
        elsif rising_edge(CLK) and AND_OUT = '1' then
            SHIFT_REG_OUT <= SHIFT_REG_OUT(6 downto 0) & DIN;
        end if;
    end process;

    -- Logic gates
    AND_OUT <= READ_EN and CMP_EQUAL;
    XOR_OUT <= AND_OUT xor CLK_CNT_EN;
    NOT_OUT1 <= not READ_EN;
    NOT_OUT2 <= not XOR_OUT;

    -- Assigning the output of the shift register to the DOUT pin
    DOUT <= SHIFT_REG_OUT;

end architecture;
