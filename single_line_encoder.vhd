----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/18/2016 06:32:38 PM
-- Design Name: 
-- Module Name: single_line_encoder - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity single_line_encoder is
    Port ( grid_line : in STD_LOGIC_VECTOR(31 downto 0); --4 bytes 
           line_number : in STD_LOGIC_VECTOR(15 downto 0); -- 2 bytes
           start_encoding : in STD_LOGIC;
           clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           finish_encoding : out STD_LOGIC;
           encoded_line : out STD_LOGIC_VECTOR(111 downto 0)
           );
end single_line_encoder;

architecture Behavioral of single_line_encoder is
    TYPE State_type IS (start, encode, order, finish, transfer);
    SIGNAL row_control: State_type := start;
    
    TYPE State_type2 IS (start, encode, order, finish, transfer);
    SIGNAL payload_control: State_type2 := start;
    
    TYPE State_type3 IS (idle, merge, finish);
    SIGNAL encode_control: State_type3 := idle;
    
    signal row_encoding : std_logic_vector(31 downto 0); --4 bytes
    signal payload_encoding : std_logic_vector(63 downto 0); --8 bytes
    
    signal row_complete : std_logic;
    signal payload_complete : std_logic;
    signal merge_complete : std_logic;
begin

    process(reset, clock) --2 bytes encoding row number
    variable parity_bits : std_logic_vector(15 downto 0);
    variable index : integer := 0; --add by 1
    variable new_row : std_logic_vector (31 downto 0);
    begin
        if(reset = '1') then
            row_complete <= '0';  --set to '0' the signal that shows when the row number has finished encoding
            row_control <= start;  -- go back to initial state
            index := 0;
            
        elsif (rising_edge(clock)) then
            case row_control is
                when start =>
                    if(start_encoding = '1') then
                        row_control <= encode;
                        parity_bits := line_number xor "1111111111111111";
                    end if;
                when encode =>
                    if(index < 16) then
                        new_row(31 - 2*index) := parity_bits(15 - index);
                        new_row(30 - 2*index) := line_number(15 - index);
                        index := index + 1;
                    else
                        index := 0;
                        row_control <= order;
                    end if;
                when order =>
                    row_encoding <= new_row(7 downto 0)&new_row(15 downto 8)&new_row(23 downto 16)&new_row(31 downto 24);
                    row_control <= finish;
                    row_complete <= '1';
                when finish =>
                    if(merge_complete = '1') then
                        row_control <= transfer;
                        row_complete <= '0';
                    end if;
                when transfer =>
                    if(start_encoding = '0') then
                        row_control <= start;
                    end if;
            end case;
        end if;
    end process;
    
    
    process(reset, clock) --4 byte encoding payload
    variable parity_bits : std_logic_vector(31 downto 0);
    variable index : integer := 0; --add by 1
    variable new_row : std_logic_vector (63 downto 0);
    --variable row_numb : std_logic_vector (16 downto 0);
    begin
        if(reset = '1') then
            payload_complete <= '0';  --set to '0' the signal that shows when the payload has finished encoding.
            payload_control <= start; --go back to initial state
            index := 0;
        elsif (rising_edge(clock)) then
            case payload_control is
                when start =>
                    if(start_encoding = '1') then
                        payload_control <= encode;
                        parity_bits := grid_line xor "11111111111111111111111111111111";
                    end if;
                when encode =>
                    if(index < 32) then
                        new_row(63 - 2*index) := parity_bits(31 - index);
                        new_row(62 - 2*index) := grid_line(31 - index);
                        index := index + 1;
                    else
                        index := 0;
                        payload_control <= order;
                    end if;
                when order =>
                    payload_encoding <= new_row(7 downto 0)&new_row(15 downto 8)&new_row(23 downto 16)&new_row(31 downto 24)&new_row(39 downto 32)&new_row(47 downto 40)&new_row(55 downto 48)&new_row(63 downto 56);
                    payload_control <= finish;
                    payload_complete <= '1';
                when finish =>
                    if(merge_complete = '1') then
                        payload_control <= transfer;
                        payload_complete <= '0';
                    end if;
                when transfer =>
                    if(start_encoding = '0') then
                        payload_control <= start;
                    end if;
            end case;
        end if;
    end process;
    
    
    process(reset, clock)  --merge encodings set output
    begin
        if(reset = '1') then
            merge_complete <= '0';  --set to '0' the signal thats shows the final output has been completed and sent to the output
            encode_control <= idle;  --go back to initial state
        elsif (rising_edge(clock)) then
            case encode_control is
                when idle =>
                    if((payload_complete = '1')and(row_complete = '1')) then
                        encode_control <= merge;
                    end if;
                when merge =>
                    encoded_line <= row_encoding & X"aaaa" & payload_encoding;
                    encode_control <= finish;
                    finish_encoding <= '1';
                    merge_complete <= '1';
                when finish =>
                    if(start_encoding = '0') then
                        finish_encoding <= '0';
                        encode_control <= idle;
                        merge_complete <= '0';
                    end if;
            end case;
        end if;
    end process;

end Behavioral;
