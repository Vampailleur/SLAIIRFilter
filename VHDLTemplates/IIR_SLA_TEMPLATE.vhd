

-- THIS FILE WAS AUTOMATICALLY GENERERATED. DO NOT MODIY BY HAND
-- GENERERATED BY ... 
-- Date

--------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;


entity %ENTITY_NAME% is
port (
  DATA_IN : signed(DIN_RANGE);
  DATA_IN_VAL : std_logic;
  CLK : in std_logic;
  SRST : in std_logic;
  DATA_OUT : out signed(DOUT_RANGE);
  DATA_OUT_VAL : out std_logic
);
end %ENTITY_NAME%;

architecture RTL of %ENTITY_NAME% is

signal data_in_buf : signed(DIN_RANGE);
signal data_in_buf_val : std_logic;


type COEF_ARRAY_T is array (natural range <>) of signed(COEF_RANGE);
constant FIR_COEF_ARRAY : COEF_ARRAY_T (0 to 4) := FIR_COEF_ARRAY_INIT;

-- Only coeffs 2 and 4 will really be used. a0 is 1 * 2**(nbFracCoefBits)
constant ALL_POLE_COEF_ARRAY : COEF_ARRAY_T (0 to 4) := ALL_POLE_COEF_ARRAY_INIT;

type TEMP_RES_T is array(natural range <>) of signed(DIN_PLUS_COEF_RANGE);
signal temp_res : TEMP_RES_T( 0 to 4);
signal temp_res2 : TEMP_RES_T(0 to 2);
signal FIR_SUM : signed(FIR_SUM_RANGE);
signal DATA_IN_VAL_SR : std_logic_vector(1 to 3);

type DATA_IN_ARRAY_T is array (natural range <>) of signed(DIN_RANGE);
signal DATA_IN_SR : DATA_IN_ARRAY_T(4 downto 0);


signal FIR_SUM_VAL : std_logic;

signal fractionSaved : signed(ACC_FRAC_RANGE);

signal a2_fir_sum_z2 : signed(ACC_RANGE);
signal a4_fir_sum_z4 : signed(ACC_RANGE);

type output_array_t is array (natural range <>) of signed(DOUT_PLUS_GUARD_RANGE);
signal output_sr : output_array_t(1 to 4);

signal ALL_POLE_OUT_VAL : std_logic := '0';

function roundSat (signal input : signed; MSB : natural; LSB : natural) return signed is
constant roundFactor : signed(LSB  downto 0) := to_signed(2**(LSB-1), LSB+1);
variable tempSum : signed(input'left+1 downto 0);
begin
	tempSum := resize(input,tempSum'length) + roundFactor;
	if (tempSum >= (2**(MSB))) then
		return to_signed(2**(MSB- LSB)-1, MSB-LSB+1);
	elsif (tempSum < -(2**(MSB))) then
		return to_signed(-2**(MSB- LSB), MSB-LSB+1);
	else
		return tempSum(MSB downto LSB);
	end if;
end function;
		


begin

-- Add one pipeline cycle at the beginning for better timing closure
PIPE_PROCESS : process(CLK)
begin
	if rising_edge(CLK) then
		data_in_buf <= DATA_IN;
		data_in_buf_val <= DATA_IN_VAL;
	end if;
end process;

FIR_PROCESS: process(CLK)
variable temp_fir_sum_v : signed(DIN_PLUS_COEF_RANGE);
begin
	if rising_edge(CLK) then
		
		if (SRST = '1') then
			 DATA_IN_SR <= (others => (others => '0'));
			FIR_SUM <= (others => '0');
			DATA_IN_VAL_SR <= (others => '0');
		else
			if (data_in_buf_val = '1') then
				DATA_IN_SR <=   DATA_IN_SR(3 downto 0) & data_in_buf;
			end if;
			DATA_IN_VAL_SR <= data_in_buf_val & DATA_IN_VAL_SR(1 to 2);

			for iCoef in 0 to 4 loop
				temp_res(iCoef) <= DATA_IN_SR(iCoef) * FIR_COEF_ARRAY(iCoef);
			end loop;
			temp_res2(0) <= temp_res(0) + temp_res(1);
			temp_res2(1) <= temp_res(2);
			temp_res2(2) <= temp_res(3) + temp_res(4);
			temp_fir_sum_v := to_signed(0,temp_fir_sum_v'length);
			for iCoef in 0 to 2 loop
				temp_fir_sum_v := temp_fir_sum_v + temp_res2(iCoef);
			end loop;
			FIR_SUM_VAL <= DATA_IN_VAL_SR(3);
			-- Up to the designer that this slice will not result in underflow
			-- Should not happen if nbBitsFIRGain is properly set
			if (DATA_IN_VAL_SR(3) = '1') then
				FIR_SUM <= temp_fir_sum_v(FIR_SUM'range); 
			end if;
		end if;
	end if;
end process;



ALL_POLE_PROCESS : process(CLK)
variable fractionSaved_v : signed(FULL_SUM_RANGE);
variable full_sum_v : signed(FULL_SUM_RANGE);
variable a2_fir_sum_temp_v : signed(a2_fir_sum_z2'left+ 1 downto 0);
variable a4_fir_sum_temp_v : signed(a4_fir_sum_z4'left+ 1 downto 0);
begin
	if rising_edge(CLK) then
		
		if (SRST = '1') then
			output_sr <= (others => (others => '0'));
			fractionSaved <= (others => '0');
			ALL_POLE_OUT_VAL <= '0';
			a2_fir_sum_z2 <= (others => '0');
			a4_fir_sum_z4 <= (others => '0');
		else
			ALL_POLE_OUT_VAL <= '0';
			if (FIR_SUM_VAL = '1') then
				full_sum_v := (FIR_SUM & to_signed(0, NB_GUARD_BITS)) -a2_fir_sum_z2 - a4_fir_sum_z4 - fractionSaved;
				output_sr <= full_sum_v(OUTPUT_PLUS_GUARD_SLICE) & output_sr(1 to 3);
				fractionSaved_v := (full_sum_v(OUTPUT_PLUS_GUARD_SLICE) & to_signed(0,NB_COEF_FRAC_BITS)) - full_sum_v;
				fractionSaved <= fractionSaved_v(fractionSaved'range);
				
				ALL_POLE_OUT_VAL <= '1';
				-- Multiply 2 signed numbers together yield 2 sign bits, we can safely flush one bit
				a2_fir_sum_temp_v := ALL_POLE_COEF_ARRAY(2)*output_sr(1);
				a2_fir_sum_z2 <= a2_fir_sum_temp_v(a2_fir_sum_temp_v'left-1 downto 0);
				a4_fir_sum_temp_v := ALL_POLE_COEF_ARRAY(4)*output_sr(3);
				a4_fir_sum_z4 <= a4_fir_sum_temp_v(a4_fir_sum_temp_v'left-1 downto 0);
			end if;

		end if;
	end if;
end process;


OUTPUT_ROUNDING_PROCESS : process(CLK)
begin
	if rising_edge(CLK) then
		DATA_OUT_VAL <= '0';
		if (SRST = '1') then
			DATA_OUT <= to_signed(0,DATA_OUT'length);
		elsif (ALL_POLE_OUT_VAL = '1') then
			DATA_OUT <= roundSat(output_sr(1), %OUTPUT_MSB%, %OUTPUT_LSB%);
			DATA_OUT_VAL <= '1';
		end if;
	end if;
end process;

	
end architecture RTL;

