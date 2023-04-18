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


	-- FSM outputs
    signal read_en : std_logic;
    signal clk_cnt_en : std_logic;
    signal valid : std_logic := '0';
    -- FSM inputs
    signal bit_cnt : std_logic_vector(3 downto 0) := "0000";
    signal clk_cnt : std_logic_vector(3 downto 0) := "0000";
    -- logic outputs
    signal xor_out : std_logic;
    signal and_out : std_logic := '0';
    signal not_out : std_logic;
    signal cmp_equal : std_logic;
    -- shift register output
    signal shift_out : std_logic_vector(7 downto 0);

begin

    -- Logic gates
    and_out <= read_en and cmp_equal;
    xor_out <= clk_cnt_en xor and_out;
    not_out <= not xor_out;

    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
        CLK => CLK,
        RST => RST,
        -- INPUTS
        DIN => DIN,
        BIT_CNT => bit_cnt,
        CLK_CNT => clk_cnt,
        --OUPUTS
        READ_EN => read_en,
        CLK_CNT_EN => clk_cnt_en,
        VALID => valid
    );
       
    -- CLK counter
    p_clk_cnt : process (CLK)
    begin
        if rising_edge(CLK) then
            if xor_out = '1' then
                clk_cnt <= clk_cnt + 1;
            else
                clk_cnt <= "0000";
            end if;
        end if;
    end process;

    -- CMP equal (finding mid-bit)
    p_cmp_equal : process (clk_cnt)
    begin
        if clk_cnt = "1111" then
            cmp_equal <= '1';
        else
            cmp_equal <= '0';
        end if;
    end process;

    -- Bit counter
	p_clk_bits : process (CLK)
	begin
		if rising_edge(CLK) then
			if valid = '1' then
				bit_cnt <= "0000";
			else
				if and_out = '1' then
					bit_cnt <= bit_cnt + 1;
				end if;
			end if;
		end if;
	end process;

    -- Shift register
    p_shift_register : process (CLK)
	begin
		if rising_edge(CLK) then
			if and_out = '1' then
                shift_out <= DIN & shift_out(7 downto 1);
			end if;
		end if;
	end process;

    -- Outputs            
    DOUT <= shift_out;
    DOUT_VLD <= valid;
end architecture;
