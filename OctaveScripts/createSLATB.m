## Copyright (C) 2019 Benjamin
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {} {@var{retval} =} convertSLAtoVHDL (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Benjamin <Benjamin@MSI>
## Created: 2019-02-09

function  createSLATB (ENTITY_NAME, iirQuant, stimulus, expectedResponse)
	
  rangeString = '%d downto %d';
  rangeStringAlt = '%d to %d';
  
  

  
  dinRangeString = sprintf(rangeString, iirQuant.nbBitsInput-1, 0);
  doutRangeString = sprintf(rangeString, iirQuant.nbBitsOutput-1, 0);
  nbPointsSlice = sprintf(rangeStringAlt,  0, length(stimulus)-1);
  text = fileread('IIR_SLA_TEMPLATE_TB.vhd');
  fileName = [ENTITY_NAME, '_TB'];
  
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

