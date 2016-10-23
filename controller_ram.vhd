----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/08/2016 10:20:07 PM
-- Design Name: 
-- Module Name: controller_ram - Behavioral
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
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.game.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller_ram is
    Port ( ram_clock : in STD_LOGIC;
           check_action : in STD_LOGIC_VECTOR(15 downto 0);
           ram_reset : in STD_LOGIC;
           --radio_completed : in STD_LOGIC;
           cell_color : in std_logic_vector(1 downto 0);
           --get_grid : in game_RAM;
           output_grid : out game_RAM; --GRID THAT IS GOING TO BE SENT TO TOP_CONTROLER, AND FROM TOP_CONTROLER TO RADIO CONTROLER/.
           radio_finish_write : in std_logic; --radio has finished sending the entire grid THIS SIGNAL WILL COME FROM TOP_CONTROLER, NOT FROM RADIO
           top_controller_write : out std_logic; --the grid is ready to be sent to the top controller, and then send it to the radio
           start_stop_grid : in std_logic; --check for signal if it is 1, then the grid will evolve, if 0, then the grid will not evolve.
           clear_grid : in std_logic; --check if the command clear grid has been executed, if son then clear the entire grid
           ram_input : in std_logic_vector(35 downto 0);
           ram_output : out std_logic_vector(35 downto 0);
           --activate_ram_func : out std_logic;
           ram_start_writing : out std_logic; -- PORT LINKED TO SIGNAL CONTROL_WRITING, WHICH WILL CONTROL READ AND WRITE FUNCTIONS FROM RAM.
           ram_address : out std_logic_vector(7 downto 0); --ADDRESS OR INDEX WHERE A SPECIFIC LINE IS STORED IN THE BLOCK RAM.
           finish_check_action : out std_logic;
           done_clear : out std_logic  --check if the command sent by the combination of swuitches has been completed
           );
end controller_ram;

architecture Behavioral of controller_ram is

    component rowCheck port ( row1 : in STD_LOGIC_VECTOR(0 to 35);
           row2 : in STD_LOGIC_VECTOR(0 to 35);
           row3 : in STD_LOGIC_VECTOR(0 to 35);
           out_row : out STD_LOGIC_VECTOR(0 to 35);
           color_cell : in STD_LOGIC_VECTOR(0 to 1);
           start_modification : in STD_LOGIC;
           row_clock : in STD_LOGIC;
           row_reset : in STD_LOGIC;
           finish_modification : out STD_LOGIC);
    end component;

    TYPE State_type IS (read_ram, read_ram_next, set_top_grid, send_radio, add_form, modify_grid, send_ram, evolve_state);
    SIGNAL ram_control: State_type := read_ram;
    
    signal new_display : game_RAM := (others => (others => '0'));
    signal input_grid : game_RAM; --complete grid that is gonna be continiously updated
    signal empty_grid : game_RAM := (others => (others => '0')); --EMPTY GRID, WHEN THE COMMAND CLEAR GRID IS DETECTED
    
    signal evolve_cells : std_logic_vector(15 downto 0) := "0000000000000000";
    signal finish_evolve : std_logic_vector(15 downto 0) := "0000000000000000";
    
    signal index_ram : std_logic_vector(7 downto 0) := "00000000";
    
    signal control_writing : std_logic := '0'; -- USE TO CONTROL THE READING AND WRITING FUNCTIONS FROM THE BLOCK RAM (start reading)
    --signal ram_activate : std_logic := '0';  --use to activate the process of writing and reading from ram
    
    
    signal not_evolve : std_logic := '0';
    signal ram_write_signal : std_logic := '0';  --- not used delete later
    
    --signal get_ad : std_logic_vector(7 downto 0);

begin

    ram_start_writing <= control_writing;
    --activate_ram_func <= ram_activate;
    ram_address <= index_ram;
    
    ram_output <= input_grid(to_integer(unsigned(index_ram))); --cintuniously send grid to output, when block ram is activated in read mode, then this values will be included there.
    
   
    u1 : rowCheck port map (input_grid(0), input_grid(1), input_grid(2), new_display(1), cell_color, evolve_cells(0), ram_clock, ram_reset, finish_evolve(0));
    u2 : rowCheck port map (input_grid(1), input_grid(2), input_grid(3), new_display(2), cell_color, evolve_cells(1), ram_clock, ram_reset, finish_evolve(1));
    u3 : rowCheck port map (input_grid(2), input_grid(3), input_grid(4), new_display(3), cell_color, evolve_cells(2), ram_clock, ram_reset, finish_evolve(2));
    u4 : rowCheck port map (input_grid(3), input_grid(4), input_grid(5), new_display(4), cell_color, evolve_cells(3), ram_clock, ram_reset, finish_evolve(3));
    u5 : rowCheck port map (input_grid(4), input_grid(5), input_grid(6), new_display(5), cell_color, evolve_cells(4), ram_clock, ram_reset, finish_evolve(4));
    u6 : rowCheck port map (input_grid(5), input_grid(6), input_grid(7), new_display(6), cell_color, evolve_cells(5), ram_clock, ram_reset, finish_evolve(5));
    u7 : rowCheck port map (input_grid(6), input_grid(7), input_grid(8), new_display(7), cell_color, evolve_cells(6), ram_clock, ram_reset, finish_evolve(6));
    u8 : rowCheck port map (input_grid(7), input_grid(8), input_grid(9), new_display(8), cell_color, evolve_cells(7), ram_clock, ram_reset, finish_evolve(7));
    u9 : rowCheck port map (input_grid(8), input_grid(9), input_grid(10), new_display(9), cell_color, evolve_cells(8), ram_clock, ram_reset, finish_evolve(8));
    u10 : rowCheck port map (input_grid(9), input_grid(10), input_grid(11), new_display(10), cell_color, evolve_cells(9), ram_clock, ram_reset, finish_evolve(9));
    u11 : rowCheck port map (input_grid(10), input_grid(11), input_grid(12), new_display(11), cell_color, evolve_cells(10), ram_clock, ram_reset, finish_evolve(10));
    u12 : rowCheck port map (input_grid(11), input_grid(12), input_grid(13), new_display(12), cell_color, evolve_cells(11), ram_clock, ram_reset, finish_evolve(11));
    u13 : rowCheck port map (input_grid(12), input_grid(13), input_grid(14), new_display(13), cell_color, evolve_cells(12), ram_clock, ram_reset, finish_evolve(12));
    u14 : rowCheck port map (input_grid(13), input_grid(14), input_grid(15), new_display(14), cell_color, evolve_cells(13), ram_clock, ram_reset, finish_evolve(13));
    u15 : rowCheck port map (input_grid(14), input_grid(15), input_grid(16), new_display(15), cell_color, evolve_cells(14), ram_clock, ram_reset, finish_evolve(14));
    u16 : rowCheck port map (input_grid(15), input_grid(16), input_grid(17), new_display(16), cell_color, evolve_cells(15), ram_clock, ram_reset, finish_evolve(15));
    
    

    process (ram_reset, ram_clock)
    variable index_int : integer := 0;
    variable x_pos : integer := 0;
    variable y_pos : integer := 0;
    begin
        if (ram_reset = '1') then
           index_ram <= "00000000"; --reset index counter (address)
           
           control_writing <= '0'; --set reading mode in block ram
           --ram_activate <= '1'; --activate ram functions (reading and writing)
           done_clear <= '0';
        elsif (rising_edge(ram_clock)) then
            case ram_control is
                when read_ram =>
                    done_clear <= '0';
                   --input_grid <= get_grid;
                    --ram_activate <= '1'; --desactivate reading and writing functions from RAM. 000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
                    finish_check_action <= '0'; --if a command is sent then, the fsm of main controller has to wait until the command has finished executing
                    
                    ram_control <= read_ram_next;
                    
                    
                    
                    
                    
                when read_ram_next =>
                    if(index_ram < 17) then
                        
                        ram_control <= read_ram; --change state FSM (in this case stay in the sAme sate read)
                        index_ram <= index_ram + '1'; --increase index as a bit_vector
 
                    else
  
                        index_ram <= "00000000"; --reset address variable
                        ram_control <= set_top_grid; --NEXT STATE WILL BE WAITING FOR THE RADIO TO SENT EVERY LINE OF THE GRID.
                        
                        control_writing <= '1'; --SET THAT THE NEXT OPERATION IN RAM WILL BE WRITING
                        
                        --ram_activate <= '1'; --desactivate reading and writing functions from RAM. 
                        
   
                    end if;
                    input_grid(to_integer(unsigned(index_ram))) <= ram_input; --read from RAM to input grid (input grid to be modified by evolution of cells)
                when set_top_grid =>    
                   top_controller_write <= '1'; --grid is ready to be sent to the main controller, and from there to the radio RADIOOOO!!!
                   output_grid <= input_grid; --send to the output the complete grid TO THE TOP CONTROLER, WHICH LATER IS GONNA BE SENT TO THE RADIO CONTROLER
                   ram_control <= send_radio; --NEXT STATE WILL BE WAITING FOR THE RADIO TO SENT EVERY LINE OF THE GRID.
                   
                when send_radio =>
                
                    if(radio_finish_write = '1') then
                        if(check_action(15 downto 12) < 5) then
                            ram_control <= add_form;  
                        else
                            ram_control <= modify_grid;
                        end if;
                        top_controller_write <= '0'; --grid is ready to be sent to the main controller, and from there to the radio RADIOOOO!!!
                    else
                        ram_control <= send_radio;
                    end if;
                
                when add_form =>
                    evolve_cells <= "0000000000000000"; --stop cell evolution, no cell evolution before adding the new life form
                    
                    y_pos := 1 + to_integer(unsigned(check_action(3 downto 0))); --get integer values for coordinates for easier form to add different figures. (adding 1 because we have an empty row at the beginning and end)
                    x_pos := 33 - 2*(to_integer(unsigned(check_action(7 downto 4)))); -- (-35_ bcause we want to check from top left corner which means msbit with respect with x for each row.
                    
                    
                    if(check_action(15 downto 12) = 1) then  --cell
                        input_grid(y_pos)(x_pos downto x_pos -1) <= cell_color;
                    elsif (check_action(15 downto 12) = 2) then  -- still
                        if(check_action(11 downto 8) = 0) then --block
                            input_grid(y_pos)(x_pos downto x_pos -3) <= cell_color&cell_color;  --first line               OO
                            input_grid(y_pos + 1)(x_pos downto x_pos -3) <= cell_color&cell_color; -- second line          OO
                           
                        elsif (check_action(11 downto 8) = 1) then --beehive
                            input_grid(y_pos)(x_pos - 2 downto x_pos - 5) <= cell_color & cell_color; --first line
                            input_grid(Y_pos + 1)(x_pos downto x_pos -1) <= cell_color; --second line                       OO
                            input_grid(y_pos + 1)(x_pos - 6 downto x_pos - 7) <= cell_color; --second line                 O  O
                            input_grid(y_pos + 2)(x_pos - 2 downto x_pos - 5) <= cell_color&cell_color; --third line        OO

                        elsif (check_action(11 downto 8) = 2) then --loaf
                            input_grid(y_pos)(x_pos - 2 downto x_pos - 3) <= cell_color; --first line
                            input_grid(y_pos + 1)(x_pos downto x_pos - 1) <= cell_color; --second line
                            input_grid(y_pos + 1)(x_pos - 4 downto x_pos - 5) <= cell_color; --second line                      O
                            input_grid(y_pos + 2)(x_pos downto x_pos - 1) <= cell_color; --third line                          O O
                            input_grid(y_pos + 2)(x_pos - 6 downto x_pos - 7) <= cell_color; --third line                      O  O
                            input_grid(y_pos + 3)(x_pos - 2 downto x_pos - 5) <= cell_color&cell_color; --fourth line           OO
                            
                        elsif (check_action(11 downto 8) = 3) then --boat
                            input_grid(y_pos)(x_pos - 2 downto x_pos - 3) <= cell_color; --first line
                            input_grid(y_pos + 1)(x_pos downto x_pos - 1) <= cell_color; --second line                      O
                            input_grid(y_pos + 1)(x_pos - 4 downto x_pos - 5) <= cell_color; --second line                 O O
                            input_grid(y_pos + 2)(x_pos - 2 downto x_pos - 5) <= cell_color&cell_color; --third line        OO
                        end if;
                        
                    elsif (check_action(15 downto 12) = 3) then --osc
                        if(check_action(11 downto 8) = 0) then --blinker
                            input_grid(y_pos)(x_pos downto x_pos - 5) <= cell_color&cell_color&cell_color; --first line         OOO
                        elsif (check_action(11 downto 8) = 1) then --toad
                            input_grid(y_pos)(x_pos - 2 downto x_pos - 7) <= cell_color&cell_color&cell_color; --first line     OOO
                            input_grid(y_pos + 1)(x_pos downto x_pos - 5) <= cell_color&cell_color&cell_color; --second line   OOO
                        elsif (check_action(11 downto 8) = 2) then  --beacon
                            input_grid(y_pos)(x_pos downto x_pos - 3) <= cell_color&cell_color; --first line                OO
                            input_grid(y_pos + 1)(x_pos downto x_pos - 3) <= cell_color&cell_color; --second line           OO    
                            input_grid(y_pos + 2)(x_pos - 4 downto x_pos - 7) <= cell_color&cell_color; --third line          OO
                            input_grid(y_pos + 3)(x_pos - 4 downto x_pos - 7) <= cell_color&cell_color; --fourth line         OO
                        end if;
                        
                    elsif (check_action(15 downto 12) = 4) then --ship
                        if(check_action(11 downto 8) = 0) then --glider
                            input_grid(y_pos)(x_pos - 2 downto x_pos - 3) <= cell_color; --first line                               O
                            input_grid(y_pos + 1)(x_pos - 4 downto x_pos - 5) <= cell_color; --second line                           O
                            input_grid(y_pos + 2)(x_pos downto x_pos - 5) <= cell_color&cell_color&cell_color; --third line        OOO
                        end if;
                    
                    end if;
                    finish_check_action <= '1'; --if a command is sent then, the fsm of main controller has to wait until the command has finished executing
                    --ram_activate <= '1'; --after adding a life form, send the entire grid, the update process will be executed in the next modify_grid.
                    ram_control <= send_ram;
                    not_evolve <= '1'; --just send grid with new figure included, not evolve
                    
                
                when modify_grid => --add here the signal that starts automation or stop, also for clear grid
                    if(start_stop_grid = '1') and (clear_grid = '0')then
                        evolve_cells <= "1111111111111111"; --start evolving grid
                        ram_control <= evolve_state;
                        --ram_activate <= '1';
                    elsif (start_stop_grid = '0') and (clear_grid = '0')then
                        evolve_cells <= "0000000000000000"; --stop cell evolution
                        --ram_control <= modify_grid; with this line if the evolution is stopped I cannot add new forms into the grid
                        ram_control <= send_ram; 
                    else 
                        evolve_cells <= "1111111111111111"; --start cell evolution
                        input_grid <= empty_grid;
                        ram_control <= evolve_state;
                        done_clear <= '1';
                        --ram_activate <= '1';
                    end if;
                    
                when evolve_state =>
                    if(finish_evolve > 0) then
                        index_ram <= "00000000";
                        ram_write_signal <= '1';
                        ram_control <= send_ram;
                        evolve_cells <= "0000000000000000";
                        input_grid <= new_display;
                        
                    else 
                        ram_control <= evolve_state;
                    end if;
                    
                
                when send_ram =>      
                                            
                     if(index_ram < 17) then
                       
                        ram_control <= send_ram;
                        index_ram <= index_ram + '1'; --increase index as a bit_vector
                     else
                        --top_controller_write <= '0'; --grid is ready to be sent to the main controller, and from there to the radio
                        index_ram <= "00000000";
                        ram_control <= read_ram;
                        not_evolve <= '0';
                        ram_write_signal <= '0';
    
                        control_writing <= '0'; --SET THAT THE NEXT OPERATION IN RAM WILL BE READING..!!!!
                     end if;
                     finish_check_action <= '0'; --if a command is sent then, the fsm of main controller has to wait until the command has finished executing

            end case;
        end if;
    end process;


end Behavioral;
