-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Artur Sultanov (xsulta01)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



entity UART_RX_FSM is
    port(
       CLK : in std_logic;
       RST : in std_logic;
       -- INPUTS
       DIN : in std_logic;
       BIT_CNT : in std_logic_vector(3 downto 0);
       CLK_CNT : in std_logic_vector(3 downto 0);
       --OUPUTS
       READ_EN : out std_logic;
       CLK_CNT_EN : out std_logic;
       VALID : out std_logic
    );
end entity;



architecture behavioral of UART_RX_FSM is
    type state_type is (WAIT_FOR_START, WAIT_FOR_MID_BIT, CLK_CNT_RST, READING_DATA, WAIT_FOR_STOP, VALIDATING);
    signal current_state, next_state : state_type;
begin

    -- State switching logic
    p_state_switch : process (CLK, RST)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                current_state <= WAIT_FOR_START;
            else 
                current_state <= next_state;
            end if;
        end if;
    end process;

    p_next_state_selecor : process (current_state, DIN, BIT_CNT, CLK_CNT)
    begin
        case current_state is
            when WAIT_FOR_START => -- waiting for start-bit.
                READ_EN <= '0';
                CLK_CNT_EN <= '0';
                VALID <= '0';
                if DIN = '0' then -- start-bit is logic '0'.
                    next_state <= WAIT_FOR_MID_BIT;
                end if;

            when WAIT_FOR_MID_BIT =>
                READ_EN <= '0';
                CLK_CNT_EN <= '1'; -- CLK counter in unlimited mode.
                VALID <= '0';
                if CLK_CNT = "0111" then -- waiting 7 clk to get a mid-bit of start-bit.
                    next_state <= CLK_CNT_RST;
                end if;

            when CLK_CNT_RST => -- restart CLK counter.  
                READ_EN <= '0';
                CLK_CNT_EN <= '0';
                VALID <= '0';
                next_state <= READING_DATA;

            when READING_DATA => -- here is the mid-bit of start-bit. Start reading data each 16 CLK.
                READ_EN <= '1';
                CLK_CNT_EN <= '1'; -- when READ_EN = '1' & CLK_CNT_EN = '1', CLK counter is limited by 16 CLK, then is restarted. 
                VALID <= '0';              
                if BIT_CNT = "1000" then -- have read 8 data-bits.
                    next_state <= WAIT_FOR_STOP;
                end if;

            when WAIT_FOR_STOP =>
                READ_EN <= '0';
                CLK_CNT_EN <= '1';
                VALID <= '0';
                if CLK_CNT = "1111" then
                    if DIN = '1' then
                        next_state <= VALIDATING;
                    else
                        next_state <= WAIT_FOR_START;
                    end if;
                end if;

            when VALIDATING =>
                READ_EN <= '0';
                CLK_CNT_EN <= '0';
                VALID <= '1';
                next_state <= WAIT_FOR_START;
            when others => 
                next_state <= WAIT_FOR_START;
        end case; 
    end process;
end architecture;
