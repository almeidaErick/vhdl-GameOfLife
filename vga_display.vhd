----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/21/2016 10:42:28 PM
-- Design Name: 
-- Module Name: vga_display - Behavioral
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
use work.game.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_display is
    Port (clock_vga : in STD_LOGIC; --25 MHz clock (6Hz refresh time)
          hsync: out std_logic;
          vsync : out std_logic;
          red : out std_logic_vector(3 downto 0);
          green : out std_logic_vector(3 downto 0);
          blue : out std_logic_vector(3 downto 0);
          display_grid : game_RAM;
          faster_clock : std_logic;
          color : std_logic_vector(1 downto 0));
end vga_display;

architecture Behavioral of vga_display is
    signal h_pos : integer range 0 to 800 := 0;
    signal y_pos : integer range 0 to 521 := 0;
    signal x : integer := 0;
    signal y : integer := 0;
    signal final_color : std_logic_vector(11 downto 0) := X"000";
    signal hold_color : std_logic_vector(11 downto 0);
begin
    red <= final_color(11 downto 8);
    green <= final_color(7 downto 4);
    blue <= final_color(3 downto 0);
    
    process (faster_clock)
    begin
        
        if(rising_edge(faster_clock)) then
            if ((h_pos > 160) and (y_pos > 41)) then
                x <= 33 - 2*((h_pos - 160) / 40);
                y <= 1 + (y_pos - 41) / 30;
            else
                x <= 0;
                y <= 0;
            end if;
            
            
            if(color = "01") then   --red
                hold_color <= X"F00";
            elsif (color = "10") then  --green
                hold_color <= X"0F0";
            elsif (color = "11") then  --blue
                hold_color <= X"00F";
            end if;
        end if;
    end process;
    

    process (clock_vga)
    begin
        if(rising_edge(clock_vga)) then
            
            if((h_pos - 160)mod 40 = 0 or (y_pos - 41)mod 30 = 0) then
                final_color <= X"FFF";
            else
                if(display_grid(y)(x downto x-1) > "00") then
                    final_color <= hold_color;
                else 
                    final_color <= X"000";
                end if;
            end if;
        
            
            --add pixel position 
            if(h_pos < 800) then
                h_pos <= h_pos + 1;
            else
                h_pos <= 0;
                if(y_pos < 521) then
                    y_pos <= y_pos + 1;
                else
                    y_pos <= 0;
                end if;        
            end if;
            
            --fix signal for backporch, sync pulse and frontporch
            
            if((h_pos > 16) and (h_pos < 112)) then
                hsync <= '0';
            else
                hsync <= '1';
            end if;
            
            if ((y_pos > 1) and (y_pos < 4)) then  ---maybe is 0, first test otherwise change it to 0
                vsync <= '0';
            else
                vsync <= '1';
            end if;
            
            --fix when frontporch, backporch and sync pulse are completely black..!! no "transmission occur on those states"
            
            if((h_pos > 0 and h_pos < 160) or (y_pos > 0 and y_pos < 41)) then
                final_color <= X"000";
            end if;
            
        end if;
    end process;

end Behavioral;
