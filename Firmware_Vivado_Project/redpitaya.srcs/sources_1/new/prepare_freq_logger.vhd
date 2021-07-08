----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.07.2021 15:37:37
-- Design Name: 
-- Module Name: prepare_freq_logger - Behavioral
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

entity prepare_freq_logger is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           freq0     : in STD_LOGIC_VECTOR (20-1 downto 0);
           freq1     : in STD_LOGIC_VECTOR (20-1 downto 0);
           freq0_out     : out STD_LOGIC_VECTOR (16-1 downto 0);
           freq1_out     : out STD_LOGIC_VECTOR (16-1 downto 0);
           decim8x_clkEn     : out STD_LOGIC);
end prepare_freq_logger;

architecture Behavioral of prepare_freq_logger is

constant LOG2_MAXIMUM_SIZE : integer := 4;
constant N_8_PTS : std_logic_vector(LOG2_MAXIMUM_SIZE-1 downto 0) := std_logic_vector(to_unsigned(8, LOG2_MAXIMUM_SIZE));
constant N_CYCLES : std_logic_vector(24-1 downto 0) := std_logic_vector(to_unsigned(8, 24));
constant NDATA_IN : integer := freq0'length;
constant bit_shift_scale_down : integer := NDATA_IN-2+LOG2_MAXIMUM_SIZE-1+LOG2_MAXIMUM_SIZE-1-freq0_out'length;--8 (the -2 accounts for the 2 extra bits used in the noise projection module) 

signal freq0_filt : std_logic_vector(NDATA_IN+LOG2_MAXIMUM_SIZE-1 downto 0) := (others => '0');
signal freq1_filt : std_logic_vector(NDATA_IN+LOG2_MAXIMUM_SIZE-1 downto 0) := (others => '0');
signal freq0_filtfilt : std_logic_vector(NDATA_IN+LOG2_MAXIMUM_SIZE+LOG2_MAXIMUM_SIZE-1 downto 0) := (others => '0');
signal freq1_filtfilt : std_logic_vector(NDATA_IN+LOG2_MAXIMUM_SIZE+LOG2_MAXIMUM_SIZE-1 downto 0) := (others => '0');
signal phase0 : signed(NDATA_IN-2+LOG2_MAXIMUM_SIZE-1+LOG2_MAXIMUM_SIZE-1-1 downto 0) := (others => '0');
signal phase1 : signed(NDATA_IN-2+LOG2_MAXIMUM_SIZE-1+LOG2_MAXIMUM_SIZE-1-1 downto 0) := (others => '0');
signal phase0_rescaled : signed(freq0_out'length-1 downto 0) := (others => '0');
signal phase1_rescaled : signed(freq1_out'length-1 downto 0) := (others => '0');
signal phase0_rescaled_last : signed(freq0_out'length-1 downto 0) := (others => '0');
signal phase1_rescaled_last : signed(freq1_out'length-1 downto 0) := (others => '0');


begin
   --Filter freq0 twice with an 8-point boxcar filter
   adjustable_boxcar_filter_freq0_0 : entity work.adjustable_boxcar_filter_v2
	generic map (
		LOG2_MAXIMUM_SIZE => LOG2_MAXIMUM_SIZE,
		DATA_WIDTH => freq0'length
	) port map (
		rst => rst,
		clk => clk,
		input_data => freq0,
		filter_size => N_8_PTS,
		output_data => freq0_filt
	);
	
   adjustable_boxcar_filter_freq0_1 : entity work.adjustable_boxcar_filter_v2
     generic map (
         LOG2_MAXIMUM_SIZE => LOG2_MAXIMUM_SIZE,
         DATA_WIDTH => freq0_filt'length
     ) port map (
         rst => rst,
         clk => clk,
         input_data => freq0_filt,
         filter_size => N_8_PTS,
         output_data => freq0_filtfilt
     );


   --Filter freq1 twice with an 8-point boxcar filter
   adjustable_boxcar_filter_freq1_0 : entity work.adjustable_boxcar_filter_v2
	generic map (
		LOG2_MAXIMUM_SIZE => LOG2_MAXIMUM_SIZE,
		DATA_WIDTH => freq1'length
	) port map (
		rst => rst,
		clk => clk,
		input_data => freq1,
		filter_size => N_8_PTS,
		output_data => freq1_filt
	);
	
   adjustable_boxcar_filter_freq1_1 : entity work.adjustable_boxcar_filter_v2
     generic map (
         LOG2_MAXIMUM_SIZE => LOG2_MAXIMUM_SIZE,
         DATA_WIDTH => freq1_filt'length
     ) port map (
         rst => rst,
         clk => clk,
         input_data => freq1_filt,
         filter_size => N_8_PTS,
         output_data => freq1_filtfilt
     );

    --Divide clock by 8 for downsampling (will go to the data logger as a clock enable)
   clock_counter_inst : entity work.clock_counter
       port map (
          clk_in => clk,
          ncycles => N_CYCLES,
          flag => decim8x_clkEn
      );
    
    
    
    -- Cancel filter gain and resize to 16 bits.  We add half an LSB before dividing in order to round the result instead of truncating:
    process (clk) is
    begin
        if rising_edge(clk) then
            --Round frequency data, which should give white frequency noise?
            freq0_out <= std_logic_vector(resize(shift_right(signed(freq0_filtfilt) + to_signed(2**(bit_shift_scale_down-1),freq0_filtfilt'length),bit_shift_scale_down),freq0_out'length));
            freq1_out <= std_logic_vector(resize(shift_right(signed(freq1_filtfilt) + to_signed(2**(bit_shift_scale_down-1),freq1_filtfilt'length),bit_shift_scale_down),freq1_out'length));
            
              --Create phase, round phase data, and go back to frequency, which should give white phase noise?
              --ACTUALLY, there is a problem with this, since the phase is wrapped and therefore dividing by bit_shift_scale_down will produce the wront thing.
--            phase0 <= resize(signed(freq0_filtfilt),phase0'length) + phase0;
--            phase1 <= resize(signed(freq1_filtfilt),phase1'length) + phase1;
--            phase0_rescaled <= resize(shift_right(phase0 + to_signed(2**(bit_shift_scale_down-1),phase0'length),bit_shift_scale_down),phase0_rescaled'length);
--            phase1_rescaled <= resize(shift_right(phase1 + to_signed(2**(bit_shift_scale_down-1),phase1'length),bit_shift_scale_down),phase1_rescaled'length);
--            freq0_out <= std_logic_vector(phase0_rescaled - phase0_rescaled_last);
--            freq1_out <= std_logic_vector(phase1_rescaled - phase1_rescaled_last);
--            phase0_rescaled_last <= phase0_rescaled;
--            phase1_rescaled_last <= phase1_rescaled;
        end if;
    end process;

end Behavioral;
