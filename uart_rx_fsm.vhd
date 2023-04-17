-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Artur Sultanov (xsulta01)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-----------------------------------

entity UART_RX_FSM is
    port(
       CLK : in std_logic;
       RST : in std_logic;
       -- INPUTS
       DATA_IN : in std_logic;
       BIT_CNT : in std_logic_vector(3 downto 0);
       CLK_CNT : in std_logic_vector(4 downto 0);
       --OUPUTS
       READ_EN : out std_logic;
       CLK_CNT_EN : out std_logic;
       VALID : out std_logic
    );
end entity;

-----------------------------------

architecture behavioral of UART_RX_FSM is
    type state_type is (WAIT_FOR_START, WAIT_FOR_DATA, CLK_CNT_RST, READING_DATA, WAIT_FOR_STOP, VALIDATING);
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

    p_next_state_selecor : process (current_state, DATA_IN, BIT_CNT, CLK_CNT)
    begin
        case current_state is
            when WAIT_FOR_START =>
                READ_EN <= '0';
                CLK_CNT_EN <= '0';
                VALID <= '0';
                if DATA_IN = '0' then
                    next_state <= WAIT_FOR_DATA;
                end if;

            when WAIT_FOR_DATA =>
                READ_EN <= '0';
                CLK_CNT_EN <= '1';
                VALID <= '0';
                if CLK_CNT = "10111" then -- get 23 CLK
                    next_state <= CLK_CNT_RST;
                end if;

            when CLK_CNT_RST =>
                READ_EN <= '0';
                CLK_CNT_EN <= '0';
                VALID <= '0';
                next_state <= READING_DATA;

            when READING_DATA =>  
                READ_EN <= '1';
                CLK_CNT_EN <= '1';
                VALID <= '0';              
                if BIT_CNT = "1000" then -- get 8 bits
                    next_state <= WAIT_FOR_STOP;
                end if;

            when WAIT_FOR_STOP =>
                READ_EN <= '0';
                CLK_CNT_EN <= '1';
                VALID <= '0';
                if CLK_CNT = "10000" then
                    if DATA_IN = '1' then
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
