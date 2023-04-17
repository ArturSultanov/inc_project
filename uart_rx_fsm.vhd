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
    signal current_state : state_type := WAIT_FOR_START;
    signal next_state : state_type := WAIT_FOR_START;
begin

    -- State switching logic
    p_state_switch : process (CLK, RST)
    begin
        if RST = '1' then
            current_state <= WAIT_FOR_START;
        elsif rising_edge(CLK) then
            current_state <= next_state;
        end if;
    end process;

    p_next_state_selecor : process (current_state, DATA_IN, BIT_CNT, CLK_CNT)
    begin
        next_state <= current_state;
        case current_state is
            when WAIT_FOR_START =>
                if DATA_IN = '0' then
                    next_state <= WAIT_FOR_START;
                end if;

            when WAIT_FOR_DATA =>
                if CLK_CNT = "10111" then -- get 23 CLK
                    next_state <= CLK_CNT_RST;
                end if;

            when CLK_CNT_RST =>
                next_state <= READING_DATA;

            when READING_DATA =>                
                if BIT_CNT = "1000" then -- get 8 bits
                    next_state <= READING_DATA;
                end if;

            when WAIT_FOR_STOP =>
                if CLK_CNT = "10000" then
                    if DATA_IN = '1' then
                        next_state <= VALIDATING;
                    else
                        next_state <= WAIT_FOR_START;
                    end if;
                end if;

            when VALIDATING =>
                next_state <= WAIT_FOR_START;
            when others => null;
        end case; 
    end process;



    p_state_outputs : process (current_state)
    begin

        case current_state is
            when WAIT_FOR_START =>
            READ_EN <= '0';
            CLK_CNT_EN <= '0';
            VALID <= '0';

            when WAIT_FOR_DATA =>
            READ_EN <= '0';
            CLK_CNT_EN <= '1';
            VALID <= '0';


            when CLK_CNT_RST =>
            READ_EN <= '0';
            CLK_CNT_EN <= '0';
            VALID <= '0';


            when READING_DATA =>
            READ_EN <= '1';
            CLK_CNT_EN <= '1';
            VALID <= '0';


            when WAIT_FOR_STOP =>
            READ_EN <= '0';
            CLK_CNT_EN <= '1';
            VALID <= '0';

            when VALIDATING =>
            READ_EN <= '0';
            CLK_CNT_EN <= '0';
            VALID <= '1';
            when others => null;
        end case; 
    end process;
end architecture;
