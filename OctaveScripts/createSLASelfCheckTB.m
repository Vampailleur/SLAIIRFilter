## Copyright (C) 2019 Benjamin
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.

%% -*- texinfo -*- 
%% @deftypefn {} {@var{retval} =} createSLASelfCheckTB (@var{input1}, @var{input2})
%% This function creates a self-checking test-bench
%% The stimulus and expected response are hard-coded
%% For example, the user would provide the step response, or impulse response
%% along with the step itself (or impulse)
%% @seealso{}
%% @end deftypefn
%%
%% Author: Benjamin <Benjamin@MSI>
%% Created: 2019-02-09

function  createSLASelfCheckTB (ENTITY_NAME, path, iirQuant, stimulus, expectedResponse)
	
  rangeString = '%d downto %d';
  rangeStringAlt = '%d to %d';
  
  


  
  dinRangeString = sprintf(rangeString, iirQuant.nbBitsInput-1, 0);
  doutRangeString = sprintf(rangeString, iirQuant.nbBitsOutput-1, 0);
  nbPointsSlice = sprintf(rangeStringAlt,  0, length(stimulus)-1);
  text = fileread('..\VHDLTemplates\IIR_SLA_TEMPLATE_SELF_CHECK_TB.vhd');
  TB_NAME = [ENTITY_NAME, '_SELF_CHECK_TB']
  fileName = [path,'\',TB_NAME];
  
  fidOut = fopen([fileName, '.vhd'], 'w+');  
 % disp(text)
  patterns = {'DIN_RANGE','DOUT_RANGE', 'NB_POINTS_SLICE', ...
 };
  outPatterns = {,dinRangeString, doutRangeString,  nbPointsSlice};
  

    for ii = 1 : length(patterns)
      text = regexprep(text,patterns{ii},outPatterns{ii},'freespacing');
    end  

    for ii = 1 : length(patterns)
      text = regexprep(text,'%ENTITY_NAME%',ENTITY_NAME,'freespacing');
    end  



    
    text = regexprep(text, 'INIT_DATA_IN_ARRAY', formatInitArray(stimulus, iirQuant.nbBitsInput ));
    text = regexprep(text, 'INIT_DATA_OUT_ARRAY', formatInitArray(expectedResponse, iirQuant.nbBitsOutput ));
   % text = regexprep(text, 'ALL_POLE_COEF_ARRAY_INIT', firCoefArrayInitString);    
       fprintf(fidOut, '%s', text);
  fclose(fidOut);
  disp([fileName, '.vhd', ' generated']);
  createDoFile('runSelfCheckTB', path, ENTITY_NAME , TB_NAME);
  createBatFile('runSelfCheckTB', path);
  


endfunction

function arrayInitString = formatInitArray(array, nb_bits)


    arrayInitString = '(';
    for ii = 1 : length(array)
      arrayInitString = [arrayInitString, sprintf('%d => to_signed(%d, %d)', ii-1, array(ii), nb_bits)];
      if (ii < length(array))
        arrayInitString = [arrayInitString, ',\n '];
      else
        arrayInitString = [arrayInitString, ')'];
      end
    end  
   % disp(arrayInitString);
endfunction

