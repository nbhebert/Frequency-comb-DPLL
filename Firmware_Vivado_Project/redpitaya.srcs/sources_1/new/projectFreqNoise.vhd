----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.01.2021 11:48:21
-- Design Name: 
-- Module Name: projectFreqNoise - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity projectFreqNoise is
    Port ( clk : in STD_LOGIC;
           freqCEO     : in STD_LOGIC_VECTOR (9 downto 0);
           freqOptical : in STD_LOGIC_VECTOR (9 downto 0);
           scale_up     : in STD_LOGIC_VECTOR (18-1 downto 0);
           freqOut     : out STD_LOGIC_VECTOR (9 downto 0));
end projectFreqNoise;

architecture Behavioral of projectFreqNoise is

constant NDATA : integer := freqCEO'length;
constant NSCALE : integer := scale_up'length;

constant bit_shift_scale_down : integer := 16;--2**16 = 65536
signal freqSum_scaleUp : signed(NDATA+NSCALE-1 downto 0) := (others => '0');


begin

    -- Scales input 1 abd input 2 and sums them
    process (clk) is
    begin
        if rising_edge(clk) then
            --Scale the CEO freq noise (by factor 1-nu2/nu1), scale the optical freq noise (by factor nu2/nu1), and sum together
            freqSum_scaleUp <= signed(freqOptical)*signed(scale_up) + signed(freqCEO)*(to_signed(2**bit_shift_scale_down,scale_up'length)-signed(scale_up));
            -- Scale down the result. When dividing by 2**bit_shift_scale_down, we add 1/2 LSB to perform round instead of floor.
            freqOut <= std_logic_vector(resize(shift_right(freqSum_scaleUp + to_signed(2**(bit_shift_scale_down-1),freqSum_scaleUp'length),bit_shift_scale_down),freqOut'length));
        end if;
    end process;

end Behavioral;
