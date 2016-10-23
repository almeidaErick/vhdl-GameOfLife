----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/04/2016 06:29:39 PM
-- Design Name: 
-- Module Name: userInt - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use work.game.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity userInt is
    Port ( BTNL : in STD_LOGIC;
           BTNR : in STD_LOGIC;
           BTNU : in STD_LOGIC;
           BTND : in STD_LOGIC;
           BTNE : in STD_LOGIC;
           BTNRESET : in STD_LOGIC;
           userClk : in STD_LOGIC;
           OpCode : in STD_LOGIC_VECTOR(3 downto 0);
           Parameter : in STD_LOGIC_VECTOR(3 downto 0);
           controlOut : in STD_LOGIC_VECTOR(1 downto 0);
           opDisplay : out STD_LOGIC_VECTOR(3 downto 0);
           paraDisplay : out STD_LOGIC_VECTOR(3 downto 0);
           xCoord : out STD_LOGIC_VECTOR(3 downto 0);
           yCoord : out STD_LOGIC_VECTOR(3 downto 0);
           coordExc : out STD_LOGIC_VECTOR(1 downto 0);
           radio_address : in std_logic_vector(5 downto 0);
           finish_action : in std_logic;
           start_stop_grid : out std_logic;
           cell_color : out std_logic_vector(1 downto 0);
           grid_functions : out std_logic_vector (15 downto 0);
           done_clear : in std_logic;
           clear_grid : out std_logic;
           set_index : out integer); -- check here lenght of rADIO CHANNEL..!!! --------
end userInt;

architecture Behavioral of userInt is

    component bcd_counter port (
        reset: in STD_LOGIC;
        clk: in STD_LOGIC;
        count_enable_up: in STD_LOGIC;
        count_enable_down: in STD_LOGIC;
        carry_out: out STD_LOGIC;
        digit_out: out STD_LOGIC_VECTOR (3 downto 0)
    );
    end component;
    
    signal color : std_logic_vector(1 downto 0) := "11";
    
    signal grid_control : std_logic_vector(15 downto 0) := "1111111111111111";
    signal op_type : std_logic_vector(7 downto 0);
    signal command_ready : std_logic := '0';
    
    TYPE State_type IS (send_command, end_command);
    SIGNAL command_control: State_type := send_command;
    
    signal coord_x : std_logic_vector(3 downto 0);
    signal coord_y : std_logic_vector(3 downto 0);
    
    signal clean_grid : std_logic;
    
    signal command_done : std_logic;
    
    signal init_index : integer := 6; ---------

begin
    opDisplay <= opCode;
    paraDisplay <= Parameter;
    xCoord <= coord_x;
    yCoord <= coord_y;
    cell_color <= color;
    grid_functions <= grid_control; 
    
    set_index <= init_index; -------
    
    g1 : bcd_counter PORT MAP(BTNRESET, userClk, BTNU, BTND, coordExc(0), coord_y);
    
    g2 : bcd_counter PORT MAP(BTNRESET, userClk, BTNR, BTNL, coordExc(1), coord_x);
    
    process (userClk , BTNRESET)
    begin
        if(BTNRESET = '1') then
            command_control <= send_command;
        elsif (rising_edge(userClk)) then
            case command_control is
                when send_command =>
                    if(command_ready = '1') then
                        command_control <= end_command;
                        grid_control <= op_type&coord_x&coord_y;
                    end if;
                when end_command =>
                    if(finish_action = '1') then
                        command_control <= send_command;
                        grid_control <= "1111111111111111";
                        command_done <= '1';
                    end if;
            end case;
        end if;
    end process;
    
    process (userClk, BTNRESET)
    variable last_state : std_logic := '0';
    begin
        if(BTNRESET = '1') then
            color <= "01";
        elsif rising_edge(userClk) then
            if(command_done = '1') then
                command_ready <= '0';
            end if;
            
            if(BTNE = '1') and (BTNE /= last_state) then
                if(opCode < 5) then
                    op_type <= opCode&Parameter;
                    command_ready <= '1';
                --elsif (opCode = x"1") then
                    --Draw a cell at x and y coordinates. (x and y are at the top left edge of the figure)
                    
                    
                --elsif (opCode = x"2") then
                    --Draw a still life at x and y coordinates. (x and y are at the top left edge of the figure)
                    
                --elsif (opCode = x"3") then
                    --Draw an oscillator at x and y coordinates. (x and y are at the top left edge of the figure)
                    --type: blinker(0), toad(1) and beacon(2).
                    
                --elsif (opCode = x"4") then
                    --Draw a spaceship at x and y coordinates. (x and y are at the top left edge of the figure)
                    --glider(0)
                elsif (opCode = x"5") then
                    --Start or restart all cellular automation.
                    --signal
                    start_stop_grid <= '1';
                    
                elsif (opCode = x"6") then
                    --Stop all cellular automation.
                    --signal
                    start_stop_grid <= '0';
                    
                elsif (opCode = x"7") then
                    --Clear all visual cellular automation.
                    --signal
                    clear_grid <= '1';
                    
                elsif (opCode = x"a") then
                    --Time in 0.2s increase - e.g value of 15 would mean 3s.
                    --not yet defined
                elsif (opCode = x"b") then
                    --Set color
                    color <= parameter(1 downto 0);
                elsif (opCode = x"c") then
                    init_index <= conv_integer(parameter);
                end if;
            elsif (done_clear = '1') then
                clear_grid <= '0';
            end if;
            last_state := BTNE;
        end if;
    
    end process;
    
    

end Behavioral;
