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
    --signal valid : std_logic;
    -- FSM inputs
    --signal data_fsm : std_logic;
    signal bit_cnt : std_logic_vector(3 downto 0) := "0000";
    signal clk_cnt : std_logic_vector(4 downto 0) := "00000";
    -- logic outputs
    signal xor_out : std_logic;
    signal and_out : std_logic;
    signal not_out : std_logic;
    signal cmp_equal : std_logic;
    
begin

    -- Instance of RX FSM
    --fsm: entity work.UART_RX_FSM
    fsm: entity work.UART_RX_FSM(behavioral)
    port map (
        CLK => CLK,
        RST => RST,
        -- INPUTS
        DATA_IN => DIN,
        BIT_CNT => bit_cnt,
        CLK_CNT => clk_cnt,
        --OUPUTS
        READ_EN => read_en,
        CLK_CNT_EN => clk_cnt_en,
        VALID => DOUT_VLD
    );

    -- Logic gates
    xor_out <= clk_cnt_en xor and_out;
    and_out <= read_en and cmp_equal;
    not_out <= not xor_out;
    cmp_equal <= '1' when clk_cnt = "10000" else '0'; -- NOT SURE IF IT WORKS

    -- CLK counter
    p_clk_cnt : process (CLK)
    begin
        if rising_edge(CLK) then
            if xor_out = '1' then
                clk_cnt <= clk_cnt + 1;
            elsif xor_out = '0' then
                clk_cnt <= "00000";
            end if;
        end if;
    end process;

    -- Bit counter
    p_bit_cnt : process (CLK)
    begin
        if rising_edge(CLK) then
            if and_out = '1' then
                bit_cnt <= bit_cnt + 1;
            elsif DOUT_VLD = '1' then
                bit_cnt <= "0000";
            end if;
        end if;
    end process;

    -- Shift register
    p_shift_register : process (CLK)
		variable shift_out : std_logic_vector(7 downto 0);
	begin
		if rising_edge(CLK) then
			if and_out = '1' then
				shift_out := DIN & shift_out(7 downto 1);
                DOUT <= shift_out;
                --shift_out <= shift_out(6 downto 0) & DIN;
			end if;
		end if;
	end process;


    --DOUT_VLD <= valid;




    

end architecture;
