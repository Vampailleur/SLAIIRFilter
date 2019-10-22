

-- THIS FILE WAS AUTOMATICALLY GENERERATED. DO NOT MODIY BY HAND
-- GENERERATED BY ... 
-- Date

--------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use std.env.all;


entity %ENTITY_NAME%_TB is
end %ENTITY_NAME%_TB;

architecture TB of %ENTITY_NAME%_TB is

component %ENTITY_NAME% is
port (
  DATA_IN : signed(DIN_RANGE);
  DATA_IN_VAL : std_logic;
  CLK : in std_logic;
  SRST : in std_logic;
  DATA_OUT : out signed(DOUT_RANGE);
  DATA_OUT_VAL : out std_logic
);
end component;


signal CLK : std_logic := '0';
constant CLK_PERIOD : time := 10.0 ns;

signal DATA_IN : signed(DIN_RANGE);
signal DATA_IN_VAL : std_logic := '0';
signal DATA_OUT_VAL : std_logic;
signal DATA_OUT : signed(DOUT_RANGE);
signal SRST : std_logic := '0';


type DATA_IN_ARRAY_T is array (natural range <>) of signed(DIN_RANGE);

constant DATA_IN_ARRAY : DATA_IN_ARRAY_T(NB_POINTS_SLICE) :=
INIT_DATA_IN_ARRAY;

type DATA_OUT_ARRAY_T is array (natural range <>) of signed(DOUT_RANGE);
constant DATA_OUT_ARRAY : DATA_OUT_ARRAY_T(NB_POINTS_SLICE) :=
INIT_DATA_OUT_ARRAY;

begin

DUT : %ENTITY_NAME%
port map (
	CLK => CLK,
	DATA_IN => DATA_IN,
	DATA_IN_VAL => DATA_IN_VAL,
	SRST => SRST,
	DATA_OUT => DATA_OUT,
	DATA_OUT_VAL => DATA_OUT_VAL
	);

CLK <= not CLK after CLK_PERIOD/2;

STIMULUS_DATA_IN_PROCESS : process
procedure tic (nb_cycles : natural := 1) is
begin
	for I in 1 to nb_cycles loop
		wait until rising_edge(CLK);
	end loop;
end procedure;

begin
	DATA_IN_VAL <= '0';
	DATA_IN <= to_signed(0, DATA_IN'length);
	tic;
	SRST <= '1';
	tic;
	SRST <= '0';
	tic;
	assert DATA_OUT = 0 report "DATA_OUT must be 0 after a reset";
	assert DATA_OUT_VAL = '0' report "DATA_OUT_VAL must be 0 after a reset";
	tic;
	for I in DATA_IN_ARRAY'range loop
		DATA_IN_VAL <= '1';
		DATA_IN <= DATA_IN_ARRAY(I);
		tic;
	end loop;
	DATA_IN_VAL <= '0';
	tic(20); -- Make sure all data has been processed
	SRST <= '1';
	tic;
	SRST <= '0';
	tic;
	assert DATA_OUT = 0 report "DATA_OUT must be 0 after a reset";
	assert DATA_OUT_VAL = '0' report "DATA_OUT_VAL must be 0 after a reset";
	tic;	
	for I in DATA_IN_ARRAY'range loop
		DATA_IN_VAL <= '1';
		DATA_IN <= DATA_IN_ARRAY(I);
		tic;
		DATA_IN_VAL <= '0'; -- Now we simulate, new data on every other clock cycle
		tic;
	end loop;
	tic(20);
	std.env.finish;
end process;

STIMULUS_DATA_OUT_PROCESS : process
variable cnt : natural := 0;
procedure tic (nb_cycles : natural := 1) is
begin
	for I in 1 to nb_cycles loop
		wait until rising_edge(CLK);
	end loop;
end procedure;

begin
	wait until rising_edge(CLK);
	if (DATA_OUT_VAL = '1') then
		assert (DATA_OUT = DATA_OUT_ARRAY(cnt)) report "Error data out = " & integer'image(to_integer(DATA_OUT)) & "Should be " & integer'image(to_integer(DATA_OUT_ARRAY(cnt))) & " on sample " & integer'image(cnt) severity error;
		cnt := cnt + 1;
	elsif (SRST = '1') then
		cnt := 0;
	end if;
			
	
	
end process;

	
end architecture TB;

