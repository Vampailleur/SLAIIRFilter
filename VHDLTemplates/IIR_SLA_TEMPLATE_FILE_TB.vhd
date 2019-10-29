library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_textio.all;
use STD.textio.all;

use STD.env.all;

entity %ENTITY_NAME%_FILE_TB is
end %ENTITY_NAME%_FILE_TB;

architecture TB of %ENTITY_NAME%_FILE_TB is

signal data_in : signed(15 downto 0);
signal data_in_val : std_logic;
signal CLK : std_logic := '0';
signal SRST : std_logic;
signal DATA_OUT : signed(17 downto 0);
signal data_out_val : std_logic;

constant CLK_PERIOD : time := 10.0 ns;

begin 

CLK <= not CLK after CLK_PERIOD/2.0;

DUT: entity work.TEST_IIR
port map (
	DATA_IN => data_in,
	DATA_IN_VAL => data_in_val,
	CLK => CLK,
	SRST => SRST,
	DATA_OUT => DATA_OUT,
	DATA_OUT_VAL => DATA_OUT_VAL

);

PROCESS
	
	variable inLine  : LINE;
	variable a       : integer;
	file inFile  : text;
	
BEGIN
	 file_open(inFile, "input_vectors.txt",  read_mode);
	 SRST <= '0';
	 DATA_IN_VAL <= '0';
	 wait until rising_edge(CLK);
	 SRST <= '1';
	 wait until rising_edge(CLK);
	 SRST <= '0';
	 wait until rising_edge(CLK);
	 
	 while not endfile(inFile) loop
		READLINE(inFile, inLine);
		READ(inLine, a );
		DATA_IN <= to_signed(a, DATA_IN'length);
		DATA_IN_VAL <= '1';
		wait until rising_edge(CLK);
	 end loop;

	DATA_IN <= (others => '0');
	DATA_IN_VAL <= '0';
	wait;
END PROCESS;


DATA_IN_PROCESS : process
file outFile     : TEXT;
variable outLine : LINE; 
variable outputHasStarted : boolean := false;

begin
	file_open(outFile, "output_vectors.txt",  write_mode);
	while true loop
		wait until rising_edge(CLK);
		if (DATA_OUT_VAL = '1') then
			write(outLine,to_integer(DATA_OUT));
			writeline( outFile, outLine);
			outputHasStarted := true;
		elsif (outputHasStarted) then
			std.env.finish;
		end if;
	end loop;

end process;



end;