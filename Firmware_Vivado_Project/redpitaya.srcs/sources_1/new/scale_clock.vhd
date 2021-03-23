----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.03.2021 14:31:48
-- Design Name: 
-- Module Name: scale_clock - Behavioral
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

entity scale_clock is
  port (
    clk_in : in  std_logic;
    division_factor : in std_logic_vector (5-1 downto 0);
    clk_10MHz   : out std_logic);
end scale_clock;

architecture Behavioral of scale_clock is

  signal clk_10MHz_i : std_logic := '0';
  
begin

  process(clk_in)
  
  variable count : unsigned(5-1 downto 0) := (others => '0');

  begin
    if rising_edge(clk_in) then   -- rising clock edge
      count := count + "1";
      if count = unsigned(division_factor) then
        count   := (others => '0');
        clk_10MHz_i   <= not clk_10MHz_i;
      end if;
    end if;
  end process;

clk_10MHz <= clk_10MHz_i;

end Behavioral;