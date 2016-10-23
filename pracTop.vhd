----------------------------------------------------------------------------------
-- Company: University of Queensland
-- Engineer: MDS
-- 
-- Create Date:    25/07/2014 
-- Design Name: 
-- Module Name:    pracTop - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use work.game.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pracTop is
    Port ( ssegAnode : out  STD_LOGIC_VECTOR (7 downto 0);
           ssegCathode : out  STD_LOGIC_VECTOR (7 downto 0);
           slideSwitches : in  STD_LOGIC_VECTOR (15 downto 0);
           pushButtons : in  STD_LOGIC_VECTOR (4 downto 0);
           pushButtonsCpuReset : in STD_LOGIC;
           LEDs : out  STD_LOGIC_VECTOR (15 downto 0);
		   clk100mhz : in STD_LOGIC;
		   logic_analyzer : out STD_LOGIC_VECTOR (7 downto 0);
		   radio_pins : out std_logic_vector (3 downto 0);
		   radio_miso : in std_logic;
		   vgaRed : out std_logic_vector(3 downto 0);
		   vgaBlue : out std_logic_vector(3 downto 0);
		   vgaGreen : out std_logic_vector(3 downto 0);
		   Hsync : out std_logic;
		   Vsync : out std_logic);
end pracTop;

architecture Behavioral of pracTop is

    component vga_display port (
        clock_vga : in STD_LOGIC; --25 MHz clock (6Hz refresh time)
        hsync: out std_logic;
        vsync : out std_logic;
        red : out std_logic_vector(3 downto 0);
        green : out std_logic_vector(3 downto 0);
        blue : out std_logic_vector(3 downto 0);
        display_grid : game_RAM;
        faster_clock : std_logic;
        color : std_logic_vector(1 downto 0));
    end component;

    component userInt port ( 
        BTNL : in STD_LOGIC;
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
        clear_grid : out std_logic; --heck here lenght of channel..!!! 
        set_index : out integer);
     end component;
     
     component ssegDriver port (
        clk : in std_logic;
        rst : in std_logic;
        cathode_p : out std_logic_vector(7 downto 0);
        anode_p : out std_logic_vector(7 downto 0);
        digit1_p : in std_logic_vector(3 downto 0);
        digit2_p : in std_logic_vector(3 downto 0);
        digit3_p : in std_logic_vector(3 downto 0);
        digit4_p : in std_logic_vector(3 downto 0);
        digit5_p : in std_logic_vector(3 downto 0);
        digit6_p : in std_logic_vector(3 downto 0);
        digit7_p : in std_logic_vector(3 downto 0);
        digit8_p : in std_logic_vector(3 downto 0)); 
     end component;
     
     component block_ram port ( 
        Address : in STD_LOGIC_VECTOR(7 downto 0);
        clock : in STD_LOGIC;
        writeControl : in STD_LOGIC;
        Input_data : in STD_LOGIC_VECTOR(35 downto 0);
        --Output_data : out game_ram;
        Output_data : out STD_LOGIC_VECTOR(35 downto 0);
        Address_radio : in std_logic_vector(7 downto 0));
     end component;
     
     
     component controller_ram port ( 
        ram_clock : in STD_LOGIC;
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
        finish_check_action : out std_logic;  --check if the command sent by the combination of swuitches has been completed
        done_clear : out std_logic
        );
     end component;
     
     
     
     component SPI_COM port ( --add ce signal after knowing the form of encoding, 
        clock : in STD_LOGIC;
        reset : in STD_LOGIC;
        write : in STD_LOGIC_VECTOR(255 downto 0);
        finish_reading : out STD_LOGIC;
        hold_cs : in STD_LOGIC; --0 when reading or writting is not done yet, 1 otherwise.
        
        --Send to accelerometer these parameters, note that miso in accelerometer is output
        --and mosi in accelerometer is input, sclk is input in acelerometeer and cs is also input 
        command : in STD_LOGIC_VECTOR(2 downto 0);
        miso : in STD_LOGIC;
        mosi : out STD_LOGIC;
        sclk : out STD_LOGIC;
        cs : out STD_LOGIC;
        byte_number : in integer;
        ce : out std_logic;
        end_writing_reg : in std_logic);
     end component;
     
     
     
     component radio_controller port ( --add signal to know when the channel is gonna change, if 1 then use the signal radio_chan as channel index for LUT 
        radio_clock : in STD_LOGIC;
        reset : in std_logic;
        type_write : out std_logic_vector(2 downto 0);
        radio_chan : in std_logic_vector(3 downto 0);
        hold_cs : out std_logic;
        write_radio : out STD_LOGIC_VECTOR(255 downto 0);
        end_writing : in std_logic;
        number_bytes : out integer;
        finish_sending : out std_logic; --signal going to controller ram (radio_finish_write)
        start_sending : in std_logic; --top_controller write omming from controller_ram
        --ce_pin : out std_logic; --going to radio
        grid_line : in std_logic_vector(35 downto 0);
        index_ram : out std_logic_vector(7 downto 0);
        encoder_clock : in std_logic;
        end_writing_reg : out std_logic;
        get_channel : in integer
        );
     end component;
     
     
     --Create "wires" to connect with seven segment display driver
     signal digit1 : std_logic_vector(3 downto 0);
     signal digit2 : std_logic_vector(3 downto 0);
     signal digit3 : std_logic_vector(3 downto 0);
     signal digit4 : std_logic_vector(3 downto 0);
     signal digit5 : std_logic_vector(3 downto 0);
     signal digit6 : std_logic_vector(3 downto 0);
     signal digit7 : std_logic_vector(3 downto 0);
     signal digit8 : std_logic_vector(3 downto 0);
     
     signal masterReset : std_logic;
     signal clockScalers : std_logic_vector (27 downto 0);
 
     
     --signal for block RAM
     signal ram_address : std_logic_vector(7 downto 0);
     signal ram_clock : std_logic;
     signal ram_control_write : std_logic;
     signal ram_input : std_logic_vector(35 downto 0);
     signal ram_output : std_logic_vector(35 downto 0);
     --signal ram_output : game_ram;
     
     --signal finish_reading : std_logic;
     signal finish_command : std_logic;
     
     signal start_stop_grid : std_logic;
     
     signal grid_functions : std_logic_vector(15 downto 0);
     
     signal radio_finish_write : std_logic; --use this signal to indicate when the signal from the radio has been completed := '1'
     
     signal top_controller_write : std_logic; --use this signal to the raio to indicate when the grid is ready to be read, and encode
     
     signal cell_color : std_logic_vector(1 downto 0);
     
     signal output_grid : game_RAM;  --used to send to radio//!!!
     
     signal done_clear : std_logic;
     
     signal clear_grid : std_logic;
     
     
     --signal for spi master and slave
     signal spi_clock : std_logic;
     
     
     signal write : STD_LOGIC_VECTOR(255 downto 0);
     
     signal spi_done : std_logic;
     
     signal hold_cs : std_logic;
     
     signal write_type : std_logic_vector(2 downto 0);
     
     signal miso : STD_LOGIC;
     signal mosi : STD_LOGIC;
     signal sclk : STD_LOGIC;
     signal cs : STD_LOGIC;
     signal byte_number : integer;
     
     signal radio_chan : std_logic_vector(3 downto 0);
     
     signal ce : std_logic; --use this signal in (radio controller or SPI not yet defined) in order to control TX state of the radio := '0'
     
     signal address_radio : std_logic_vector(7 downto 0);
     
     signal end_writing_reg : std_logic;
     
     
     signal red : std_logic_vector(3 downto 0);
     signal green : std_logic_vector(3 downto 0);
     signal blue : std_logic_vector(3 downto 0);
     
     signal control_index : integer;
     

begin

    vgaRed <= red;
    vgaGreen <= green;
    vgaBlue <= blue;

    masterReset <= not pushButtonsCpuReset;
    --logic_analyzer(0) <= finish_command;
    
    logic_analyzer(0) <= cs;
    logic_analyzer(1) <= sclk;
    logic_analyzer(2) <= mosi;
    logic_analyzer(3) <= miso; 
    logic_analyzer(4) <= ce;
    logic_analyzer(5) <= end_writing_reg;
    
    miso <= radio_miso;
    radio_pins(0) <= mosi;
    radio_pins(1) <= sclk;
    radio_pins(2) <= cs;
    radio_pins(3) <= ce;
     
    
    
    ram_clock <= clockScalers(13);

    --Use "wires" to connect seven segment display driver
    g1: ssegDriver PORT MAP (
        clk => clockScalers(11),
        rst => masterReset,
        cathode_p => ssegCathode,
        digit1_p => digit1,
        anode_p => ssegAnode,
        digit2_p => digit2,
        digit3_p => digit3,
        digit4_p => digit4,
        digit5_p => digit5,
        digit6_p => digit6,
        digit7_p => digit7,
        digit8_p => digit8
     );
     
     g2 : userInt PORT MAP (pushButtons(3), pushButtons(0), pushButtons(2), pushButtons(1), pushButtons(4), masterReset, clockScalers(11),
          slideSwitches(7 downto 4), slideSwitches(3 downto 0), slideSwitches(9 downto 8), digit2, digit1, digit4, digit3, LEDs(1 downto 0),
          slideSwitches(15 downto 10), finish_command, start_stop_grid, cell_color, grid_functions, done_clear, clear_grid, control_index);
          
     g3 : block_ram PORT MAP (ram_address, ram_clock, ram_control_write, ram_input, ram_output, address_radio);
     
     g4 : controller_ram PORT MAP (ram_clock, grid_functions, masterReset, cell_color, output_grid, radio_finish_write, top_controller_write, 
          start_stop_grid, clear_grid, ram_output, ram_input, ram_control_write, ram_address, finish_command, done_clear);
          
     g5 : SPI_COM PORT MAP (clockScalers(12), masterReset, write, spi_done, hold_cs, write_type, miso, mosi, sclk, cs, byte_number, ce, end_writing_reg);
     
     g6 : radio_controller PORT MAP (clockScalers(15), masterReset, write_type, radio_chan, hold_cs, write, spi_done, byte_number, radio_finish_write, 
            top_controller_write, ram_output, address_radio, clockScalers(8), end_writing_reg, control_index);
            
     g7 : vga_display PORT MAP (clockScalers(1), Hsync, Vsync, red, green, blue, output_grid, clockScalers(0), cell_color);
     
    -- process (clockScalers(19))
    -- variable index : integer := 1;
    -- begin
    --     if (rising_edge(clockScalers(19)))then
    --         --clockScalers <= clockScalers + '1';
    --         IF((slideSwitches(14) = '0')) then
    --             logic_analyzer(0) <= output_grid(1)(index);
    --             logic_analyzer(1) <= output_grid(2)(35 - index);
    --             logic_analyzer(2) <= output_grid(3)(35 - index);
    --             logic_analyzer(3) <= output_grid(4)(35 - index);
    --             logic_analyzer(4) <= output_grid(5)(35 - index);
    --             logic_analyzer(5) <= output_grid(6)(35 - index);
    --             logic_analyzer(6) <= output_grid(7)(35 - index);
    --             logic_analyzer(7) <= output_grid(8)(35 - index);
    --         else
    --              logic_analyzer(0) <= output_grid(9)(index);
    --              logic_analyzer(1) <= output_grid(10)(35 - index);
    --              logic_analyzer(2) <= output_grid(11)(35 - index);
    --              logic_analyzer(3) <= output_grid(12)(35 - index);
    --              logic_analyzer(4) <= output_grid(13)(35 - index);
    --              logic_analyzer(5) <= output_grid(14)(35 - index);
    --              logic_analyzer(6) <= output_grid(15)(35 - index);
    --              logic_analyzer(7) <= output_grid(16)(35 - index);
    --        end if;
    --         if(index < 35) then
    --             index := index + 2;
    --         else
    --             index := 1;
    --         end if;
    --             
    --     end if;
    -- end process;
     
     process (clk100mhz, masterReset)
     begin
        if (masterReset = '1') then
            clockScalers <= "0000000000000000000000000000";
        elsif (clk100mhz'event and clk100mhz = '1')then
            clockScalers <= clockScalers + '1';
        end if;
     end process;

end Behavioral;

