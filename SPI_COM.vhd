----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/19/2016 11:13:35 AM
-- Design Name: 
-- Module Name: SPI_COM - Behavioral
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

entity SPI_COM is
    Port ( 
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
end SPI_COM;

architecture Behavioral of SPI_COM is

    signal cs_sig : std_logic := '1'; -- start transmission of bits 
    signal ce_sig : std_logic := '0';
    signal end_process_writing : std_logic := '0'; --finish reading
    signal next_cycle_write : std_logic; -- set rising edge ok sclk when writting
    --signal start_writing : std_logic := '1';
    TYPE State_type IS (A, B);
    SIGNAL W: State_type := A;
    
    TYPE State_type_2 IS (C, D, M, P);
    SIGNAL X: State_type_2 := C;
    
    TYPE State_type_4 IS (G, H, I, R, Y); -- set bits vector to transmit
    SIGNAL Z: State_type_4 := G;
    
    signal write_spi : std_logic_vector(263 downto 0); -- bit vector to transmit through spi com
    signal out_write_spi : std_logic_vector(263 downto 0);
    signal spi_clock : std_logic;
    signal start_mosi_miso : std_logic := '0';
    

begin

    cs <= cs_sig;
    ce <= ce_sig;
    sclk <= spi_clock;
    
    --sclk
    process (reset, clock)
    begin
        if (reset = '1') then
            W <= A;
            spi_clock <= '0'; --added reset for sclk 
        elsif (rising_edge(clock)) then
            case W is
                when A =>
                    if ((next_cycle_write = '1')) then
                        W <= B;
                        spi_clock <= '1';
                    end if;    
                    
                when B =>
                    W <= A;
                    spi_clock <= '0';
            end case;
        end if;
    end process;
    
    --mosi
    process (reset, clock)
    variable number_bits : integer := 0;
    variable count_bits : integer := 0;
    begin
        if(reset = '1') then 
            X <= C;
            end_process_writing <= '0';
            number_bits := 0;
            count_bits := 0;
            next_cycle_write <= '0'; -- make clock 0 when pressing reset
        elsif (rising_edge(clock)) then
            case X is
                when C =>
                    if (cs_sig = '0') and (start_mosi_miso = '1') then     --  and (start_reading = '0')
                        out_write_spi <= write_spi;
                        number_bits := (byte_number + 1)*8;
                        X <= D;
                    end if;
                    
                when D =>
                    next_cycle_write <= '1';
                    mosi <= out_write_spi(263);
                    out_write_spi <= out_write_spi(262 downto 0)&'0';
                    count_bits := count_bits + 1;
                    X <= M;
                when M =>
                    next_cycle_write <= '0';
                    if(count_bits < number_bits) then
                        X <= D;
                    else 
                       -- send end cs      
                       end_process_writing <= '1';
                       --start_writing <= '0';
                       count_bits := 0;
                       X <= P;
                    end if;
                    
                 when P =>
                    end_process_writing <= '0';
                    X <= C;
            end case;
        end if;
    end process;

    
    --load variables
    process (reset, clock)
    variable write_byte : std_logic_vector (7 downto 0) := "10100000";
    variable wake_up : std_logic_vector(7 downto 0) := "00100000";
    variable no_ack : std_logic_vector(7 downto 0) := "00111101";
    variable set_ch : std_logic_vector(7 downto 0) := "00100101";
    variable rf_set : std_logic_vector(7 downto 0) := "00100110";
    variable shockBurst : std_logic_vector(7 downto 0) := "00100001";

    begin
        if (reset = '1') then
            Z <= G;
            finish_reading <= '0'; ----If restart is detected then start the process from the beginning 
            cs_sig <= '1';  ---CS signla is again putted as a '1'.
            ce_sig <= '0';
            write_spi<= X"000000000000000000000000000000000000000000000000000000000000000000"; --clear the variable that is going to be transmitted 
        elsif (rising_edge(clock)) then 
            case Z is
                when G =>
                    ce_sig <= '0';
                    finish_reading <= '0';
                    if(hold_cs = '1')then
                        Z <= H;
                    end if;
                    
                when H =>
                    
                    if(command = "000") then    --set wake up and tx mode
                        write_spi <= wake_up & Write;   
                    elsif (command = "001") then  -- deactivate ack
                        write_spi <= no_ack & Write;
                    elsif (command = "010") then
                        write_spi <= rf_set & Write;
                    elsif (command = "011") then
                       write_spi <= shockBurst & Write;
                    elsif (command = "100") then -- set channel
                        write_spi <= set_ch & Write;   
                    else      --load to tx buffer
                        write_spi <= write_byte & Write;   
                    end if;         
                    
                    Z <= I;
                    cs_sig <= '0';
                    --ce_sig <= '0';
                    --finish_reading <= '0';
                    start_mosi_miso <= '1';
                when I =>
                    if (end_process_writing = '1') then
                        finish_reading <= '1';
                        start_mosi_miso <= '0';
                        Z <= R;
                    end if;
                when R =>
                    -- Create a period of delay after finishing reading or writting
                    if(end_writing_reg = '1') then
                        cs_sig <= '1';
                        if(command = "111") then
                            ce_sig <= '1';
                        end if;
                        Z <= Y;
                    end if;
               when Y =>
                    if(end_writing_reg = '0') then
                        Z <= G;
                    end if;
            end case;
        end if;
    
    end process;


end Behavioral;
