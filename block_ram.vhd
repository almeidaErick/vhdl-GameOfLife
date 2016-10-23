----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/04/2016 11:51:11 PM
-- Design Name: 
-- Module Name: block_ram - Behavioral
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
use work.game.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity block_ram is
    Port ( Address : in STD_LOGIC_VECTOR(7 downto 0);
           clock : in STD_LOGIC;
           writeControl : in STD_LOGIC;
           Input_data : in STD_LOGIC_VECTOR(35 downto 0);
           Output_data : out STD_LOGIC_VECTOR(35 downto 0);
           Address_radio : in std_logic_vector(7 downto 0)
           );
end block_ram;

architecture Behavioral of block_ram is
type RAM is array (0 to 17) of std_logic_vector(35 downto 0);
--signal DataMEM: RAM :=((X"000000000"), 
--                       (X"000000000"),
--                       (X"00fc00000"),
--                       (X"000000000"),
--                       (X"000000000"),
--                       (X"00fc00000"),
--                       (X"000000000"),
--                       (X"000000000"),
--                       (X"000000000"),
--                       (X"000000000"),
--                       (X"000000000"),
--                       (X"000000000"),
--                       (X"000000000"),
--                       (X"000000000"),
--                       (X"000000000"),
--                       (X"000000000"),
--                       (X"000000000"),
--                       (X"000000000")); -- no initial values

signal DataMEM: RAM := (others => (others => '0'));

begin

    process(clock)
    begin
        if rising_edge(clock) then
            if writeControl = '1' then 
                DataMEM(to_integer(unsigned(Address))) <= Input_data;  -- Synchronous Write
                output_data <= DataMEM(to_integer(unsigned(Address_radio)));  -- Synchronous Read
            else
                 output_data <= DataMEM(to_integer(unsigned(Address)));  -- Synchronous Read
            end if;
        end if;
    end process;

end Behavioral;
