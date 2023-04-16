-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Artur Sultanov (xsulta01)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



entity UART_RX_FSM is
    port(
        -- Default Inputs 
        CLK                 : in    std_logic;
        RST                 : in    std_logic;
        -- User Inputs
        DIN                 : in    std_logic;
        BIT_CNT             : in    std_logic_vector(3 downto 0);
        CLK_CNT             : in    std_logic_vector(4 downto 0);
        -- Moore outputs
        READ_EN             : out   std_logic;
        CLK_CNT_EN          : out   std_logic;
        DOUT_VLD            : out   std_logic
    );
end entity;

architecture behavioral of UART_RX_FSM is
    type State_Type is (WAIT_FOR_START, WAIT_FOR_DATA, READING_DATA, WAIT_FOR_STOP, VALIDATING);
    signal Current_State, Next_State : State_Type;

begin
    -- Restart and logic 
    process (CLK, RST)
    begin
        if RST = '1' then
            Current_State <= WAIT_FOR_START;
        elsif rising_edge(CLK) then
            Current_State <= Next_State;
        end if;
    end process;

    -- FSM logic
    process (Current_State, DIN, CLK_CNT, BIT_CNT)
    begin
        Next_State <= WAIT_FOR_START;
        READ_EN <= '0';
        CLK_CNT_EN <= '0';
        DOUT_VLD <= '0';

        case Current_State is
            when WAIT_FOR_START =>
                if DIN = '1' then
                    Next_State <= WAIT_FOR_DATA;
                    CLK_CNT_EN <= '1';
                end if;

            when WAIT_FOR_DATA =>
                if CLK_CNT = "10111" then
                    Next_State <= READING_DATA;
                    READ_EN <= '1';
                    CLK_CNT_EN <= '1';
                end if;

            when READING_DATA =>
                if BIT_CNT = "1000" then
                    Next_State <= WAIT_FOR_STOP;
                    CLK_CNT_EN <= '1';
                end if;

            when WAIT_FOR_STOP =>
                if CLK_CNT = "10000" and DIN = '1' then
                    Next_State <= VALIDATING;
                    DOUT_VLD <= '1';
                end if;

            when VALIDATING =>
                Next_State <= WAIT_FOR_START;

            when others =>
                Next_State <= WAIT_FOR_START;
        end case;
    end process;

end architecture;
