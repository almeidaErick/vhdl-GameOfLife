----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/08/2016 11:00:54 PM
-- Design Name: 
-- Module Name: rowCheck - Behavioral
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

entity rowCheck is
    Port ( row1 : in STD_LOGIC_VECTOR(0 to 35);
           row2 : in STD_LOGIC_VECTOR(0 to 35);
           row3 : in STD_LOGIC_VECTOR(0 to 35);
           out_row : out STD_LOGIC_VECTOR(0 to 35);
           color_cell : in STD_LOGIC_VECTOR(0 to 1);
           start_modification : in STD_LOGIC;
           row_clock : in STD_LOGIC;
           row_reset : in STD_LOGIC;
           finish_modification : out STD_LOGIC);
end rowCheck;

architecture Behavioral of rowCheck is


begin

    process(row_clock, row_reset)
    variable row_index : integer := 0;
    variable sum : std_logic_vector(3 downto 0) := "0000";
    variable hold_row : std_logic_vector(0 to 35) := "000000000000000000000000000000000000";
    begin
        if(row_reset = '1') then
            out_row <= "000000000000000000000000000000000000";
            sum := "0000";
            row_index := 0;
        elsif (rising_edge(row_clock)) then
            --row1 (index 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34) note in index 34 will check in living cells in index 34 and 35
            --row2 (index    2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32) note in index 34 will check in living cells in index 34 and 35
            --row3 (index 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34) note in index 34 will check in living cells in index 34 and 35
            
            --sum number of zeroes
            if(start_modification = '1') then
                sum := "0000";
                if(row1(row_index to row_index + 1) = "00") then sum := sum + 1; end if;   
                if(row1(row_index + 2 to row_index + 3) = "00") then sum := sum + 1; end if; 
                if(row1(row_index + 4 to row_index + 5) = "00") then sum := sum + 1; end if;
                if(row2(row_index to row_index + 1) = "00") then sum := sum + 1; end if;
                if(row2(row_index + 4 to row_index + 5) = "00") then sum := sum + 1; end if;
                if(row3(row_index to row_index + 1) = "00") then sum := sum + 1; end if;
                if(row3(row_index + 2 to row_index + 3) = "00") then sum := sum + 1; end if;
                if(row3(row_index + 4 to row_index + 5) = "00") then sum := sum + 1; end if;       
                
                
                    
                if(sum = 5) then
                    hold_row(row_index + 2 to row_index + 3) := color_cell;
                elsif (sum = 6) then
                    if(row2(row_index + 2 to row_index + 3) = "00") then
                        hold_row(row_index + 2 to row_index + 3) := "00";
                    else 
                        hold_row(row_index + 2 to row_index + 3) := color_cell;
                    end  if;
                elsif (sum < 5) or (sum > 6) then
                    hold_row(row_index + 2 to row_index + 3) := "00";
                end if;
                
                if(row_index < 30) then
                    row_index := row_index + 2;
                    finish_modification <= '0';
                else
                    row_index := 0;
                    finish_modification <= '1';
                    out_row <= hold_row;
                end if; 
             else
                row_index := 0;
                sum := "0000";
                hold_row := "000000000000000000000000000000000000";
             end if;
            
        end if;
    end process;
end Behavioral;
