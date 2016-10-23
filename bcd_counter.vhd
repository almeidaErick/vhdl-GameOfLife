library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


entity bcd_counter is
    port (
        reset: in STD_LOGIC;
        clk: in STD_LOGIC;
        count_enable_up: in STD_LOGIC;
        count_enable_down: in STD_LOGIC;
        carry_out: out STD_LOGIC;
        digit_out: out STD_LOGIC_VECTOR (3 downto 0)
    );
end bcd_counter;

architecture bcd_counter_arch of bcd_counter is

	signal counter_value: STD_LOGIC_VECTOR (3 downto 0) := "0000";
	signal send_carry : STD_LOGIC := '0';
begin

	process(clk, reset, counter_value, count_enable_up, count_enable_down)
        variable prevUp : std_logic := '0';
        variable prevDown : std_logic := '0';
        begin
            if reset = '1' then
                counter_value <= "0000";
                send_carry <= '0';
                
            elsif clk'EVENT and clk = '1' then
               if (count_enable_up = '1') and (prevUp /= count_enable_up) then 
                if counter_value < 15 then
                   
                    counter_value <= counter_value + '1';
                    send_carry <= '0';
                else 
                    
                    counter_value <= "0000";
                    send_carry <= '1';
                            
                end if;
               elsif (count_enable_down = '1') and (prevDown /= count_enable_down) then 
                if counter_value > 0 then
                   
                    counter_value <= counter_value - '1';
                    send_carry <= '0';
                else 
                           
                    counter_value <= "1111";
                    send_carry <= '1';
                                           
                end if;
               else 
                  carry_out <= send_carry;
                 -- and here -- remember that carry_out needs to get a value here 
                         -- otherwise the compiler will infer a latch (which yo do not want !!)  
               end if ; 
               prevUp := count_enable_up;
               prevDown := count_enable_down;
            end if;
            
        end process;
        
        digit_out <= counter_value;

 end bcd_counter_arch;
