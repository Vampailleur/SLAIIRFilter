## Copyright (C) 2019 Benjamin
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.

%% -*- texinfo -*- 
%% @deftypefn {} {@var{retval} =} createSLASelfCheckTB (@var{input1}, @var{input2})
%% This function creates a file test-bench
%% The stimulus is read from a file
%% and the output response is written into another file
%% @seealso{}
%% @end deftypefn
%%
%% Author: Benjamin <Benjamin@MSI>
%% Created: 2019-02-09

function  createSLAFileTB (ENTITY_NAME, path, iirQuant, stimulus, expectedResponse)
	
  rangeString = '%d downto %d';
  rangeStringAlt = '%d to %d';
  
  

  
  dinRangeString = sprintf(rangeString, iirQuant.nbBitsInput-1, 0);
  doutRangeString = sprintf(rangeString, iirQuant.nbBitsOutput-1, 0);
  text = fileread('..\VHDLTemplates\IIR_SLA_TEMPLATE_FILE_TB.vhd');
  fileName = [path, '\',ENTITY_NAME, '_FILE_TB'];
  
  fidOut = fopen([fileName, '.vhd'], 'w+');  
 % disp(text)
  patterns = {'DIN_RANGE','DOUT_RANGE', ...
 };
  outPatterns = {dinRangeString, doutRangeString};
  

    for ii = 1 : length(patterns)
      text = regexprep(text,patterns{ii},outPatterns{ii},'freespacing');
    end  

    for ii = 1 : length(patterns)
      text = regexprep(text,'%ENTITY_NAME%',ENTITY_NAME,'freespacing');
    end  



  fclose(fidOut);
  createDoFile('runFileTB',path,  ENTITY_NAME, fileName);
  createBatFile('runFileTB', path);

endfunction


