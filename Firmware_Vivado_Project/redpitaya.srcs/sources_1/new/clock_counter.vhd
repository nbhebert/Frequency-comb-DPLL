----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.03.2021 14:31:48
-- Design Name: 
-- Module Name: clock_counter - Behavioral
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
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;

entity clock_counter is
  port (
    clk_in : in  std_logic;
    ncycles : in std_logic_vector (24-1 downto 0);
    flag   : out std_logic);
end clock_counter;

architecture Behavioral of clock_counter is

  signal flag_i : std_logic := '0';
  
begin

  process(clk_in)
  
  variable count : unsigned(24-1 downto 0) := (others => '0');

  begin
    if rising_edge(clk_in) then   -- rising clock edge
      count := count + "1";
      if count = unsigned(ncycles) then
        count   := (others => '0');
        flag_i   <= '1';
      else
        flag_i   <= '0';
      end if;
    end if;
  end process;

flag <= flag_i;

end Behavioral;