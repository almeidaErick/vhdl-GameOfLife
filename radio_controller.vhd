----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/14/2016 09:25:20 PM
-- Design Name: 
-- Module Name: radio_controller - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity radio_controller is
    Port ( radio_clock : in STD_LOGIC;
           reset : in std_logic;
           type_write : out std_logic_vector(2 downto 0);
           radio_chan : in std_logic_vector(3 downto 0); --this signal is to notify when we want to chnge the channel
           hold_cs : out std_logic;
           write_radio : out STD_LOGIC_VECTOR(255 downto 0);
           end_writing : in std_logic; -- send by SPI
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
end radio_controller;

architecture Behavioral of radio_controller is

    component single_line_encoder port ( 
           grid_line : in STD_LOGIC_VECTOR(31 downto 0); --4 bytes 
           line_number : in STD_LOGIC_VECTOR(15 downto 0); -- 2 bytes
           start_encoding : in STD_LOGIC;
           clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           finish_encoding : out STD_LOGIC;
           encoded_line : out STD_LOGIC_VECTOR(111 downto 0)
           );
    end component;


    TYPE radio_setup IS (hold_on, wake_up, no_ack, no_ack_next, rf_set, rf_set_next, shockBurst, shockBurst_next, set_chan, set_chan_next, write_grid, send, pass,
                        pass_next, finish);
    SIGNAL config: radio_setup := hold_on;
    
    TYPE radio_transfer IS (send, pass, finish); 
    SIGNAL transfer: radio_transfer := send;
    
    type CHANNELS is array (0 to 9) of std_logic_vector(7 downto 0);
    signal list_chan: CHANNELS := ((X"28"),
                 (X"29"),
                 (X"2a"),
                 (X"2b"),
                 (X"2c"),
                 (X"2d"),
                 (X"2e"),
                 (X"2f"),
                 (X"30"),
                 (X"31")
                 ); 
                 
    signal first_setup : std_logic := '1';
    signal address_ram : std_logic_vector(7 downto 0) := "00000001"; --always start at 1..!!!!!
    signal row_number : std_logic_vector(15 downto 0) := X"0000"; --always start at 0...!!!!
    signal control_encoder : std_logic := '0';   --control when the encoder should work
    signal end_encoding : std_logic;  ---when encoder has finished encoding grid line
    signal encoded_line : STD_LOGIC_VECTOR(111 downto 0);
    
    signal init_index : integer := 6;
    
begin
    index_ram <= address_ram;
    
    
    u1 : single_line_encoder port map (grid_line(33 downto 2), row_number, control_encoder, encoder_clock, reset, end_encoding, encoded_line);
    
    
    process (radio_clock, reset) 
    variable get_chan : std_logic_vector(7 DOWNTO 0);
    variable encoding_type : std_logic_vector(15 downto 0) := X"aa99";
    variable address_send : std_logic_vector(63 downto 0) := X"a9969aaa9a9aa59a";
    begin
        if (reset = '1') then
            config <= hold_on;
            address_ram <= X"01";
            row_number <= X"0000";
            control_encoder <= '0';
            first_setup <= '1';
        elsif (rising_edge(radio_clock)) then
            case config is
                when hold_on =>
                    if (first_setup = '1') then
                        config <= wake_up;
                        get_chan := list_chan(init_index);
                        number_bytes <= 1;
                    end if;
                when wake_up =>
                    hold_cs <= '1';
                    type_write <= "000";
                    write_radio <= X"0200000000000000000000000000000000000000000000000000000000000000";
                    number_bytes <= 1;
                    config <= no_ack;
                    
                when no_ack =>
                    if (end_writing = '1') then
                        config <= no_ack_next;
                        hold_cs <= '0';
                        end_writing_reg <= '1';
                    end if;
                when no_ack_next =>
                    end_writing_reg <= '0';
                    hold_cs <= '1';
                    type_write <= "001";
                    write_radio <= X"0000000000000000000000000000000000000000000000000000000000000000";
                    config <= rf_set;
                    number_bytes <= 1;
                when rf_set =>
                    if (end_writing = '1') then
                        end_writing_reg <= '1';
                        config <= rf_set_next;
                        hold_cs <= '0';
                    end if;
                when rf_set_next =>
                    end_writing_reg <= '0';
                    hold_cs <= '1';
                    type_write <= "010";
                    write_radio <= X"0600000000000000000000000000000000000000000000000000000000000000";
                    config <= shockBurst;
                    number_bytes <= 1;
                when shockBurst =>
                    if (end_writing = '1') then
                        end_writing_reg <= '1';
                        config <= shockBurst_next;
                        hold_cs <= '0';
                    end if;
                when shockBurst_next =>
                    end_writing_reg <= '0';
                    hold_cs <= '1';
                    type_write <= "011";
                    write_radio <= X"0000000000000000000000000000000000000000000000000000000000000000";
                    config <= set_chan;
                    number_bytes <= 1;
                when set_chan =>
                    if (end_writing = '1') then
                        end_writing_reg <= '1';
                        config <= set_chan_next;
                        hold_cs <= '0';
                    end if;
                when set_chan_next =>
                    end_writing_reg <= '0';
                    hold_cs <= '1';
                    type_write <= "100";
                    write_radio <= get_chan&X"00000000000000000000000000000000000000000000000000000000000000";
                    config <= write_grid;
                    number_bytes <= 1;
                when write_grid =>
                    if(end_writing = '1') then
                        end_writing_reg <= '1';
                        --set number of bytes here
                        --type_write <= "111";
                        number_bytes <= 32;
                        hold_cs <= '0';
                        first_setup <= '0';
                        config <= send;
                        control_encoder <= '1';
                    end if;
                when send =>
                    end_writing_reg <= '0';
                    if(start_sending = '1') and (end_encoding = '1')then
                        hold_cs <= '1';
                        type_write <= "111";
                        --number_bytes <= 32;
                        --write_radio <= X"aa9969696969696969696969696969696969a6aaaaaaaaaa5a5aa5aa5555a5aa";
                                       --aa9969696969696969696969696969696969a6aaaaaaaaaa5a5aa5aa5555a5aa
                        write_radio <= encoding_type&address_send&address_send&encoded_line;
                        control_encoder <= '0';
                        config <= pass;
                       -- address_ram <= address_ram + 1;
                       -- row_number <= row_number + 1;
                    end if;
                when pass =>
                    if(end_writing = '1') then  -----spi
                        end_writing_reg <= '1';
                        hold_cs <= '0';
                        --ce_pin <= '1';
                        config <= pass_next;
                        --finish_sending <= '1';  ----indicates to ram_comtroller when it should moves to configure the grid again
                        address_ram <= address_ram + 1;
                        row_number <= row_number + 1;
                        --control_encoder <= '1'; ------here..!!!!
                        
                    end if;
                when pass_next =>
                    end_writing_reg <= '0';
                    --ce_pin <= '0';
                    if(row_number < 16) then
                        config <= send;
                        control_encoder <= '1'; -----here.>!!!
                    else
                        address_ram <= "00000001";
                        row_number <= X"0000";
                        finish_sending <= '1';  ----indicates to ram_comtroller when it should moves to configure the grid again
                        config <= finish;
                        control_encoder <= '0'; -----here.>!!!
                    end if;
                    
                when finish =>
                    if(start_sending = '0')then
                        control_encoder <= '1'; -----here.>!!!
                       -- config <= send;
                        finish_sending <= '0';   ----indicates to ram_comtroller when it should moves to configure the grid again
                        --control_encoder <= '0';
                        
                        
                        ---here add change channel and also moves to set chan state next
                        if(get_channel /= init_index) then
                            get_chan := list_chan(get_channel);
                            init_index <= get_channel;
                            config <= set_chan_next;
                        else
                             config <= send;
                        end if;
                        
                        
                    end if;
            end case;
        end if;
    end process;
    
    
   

---make another process in order to continiourly send packets through rad

end Behavioral;
