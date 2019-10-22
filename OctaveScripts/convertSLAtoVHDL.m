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

function  convertSLAtoVHDL (ENTITY_NAME, numQuant, denQuant, iirQuant)
	
  %fid =fopen('IIR_SLA_TEMPLATE.vhd');
  rangeString = '%d downto %d';

  
  
  nbAccBits = iirQuant.nbBitsInput + iirQuant.nbBitsFIRGain + iirQuant.nbBitsIIRGain + iirQuant.nbBitsCoef + iirQuant.nbAddPrecisionBits;
  nbAccFracBits = iirQuant.nbFracBitsCoef  + iirQuant.nbAddPrecisionBits;
  nbBitsFir = iirQuant.nbBitsInput + iirQuant.nbFracBitsCoef +  iirQuant.nbBitsFIRGain;
  nbFullSumBits = iirQuant.nbBitsCoef + iirQuant.nbBitsInput  + iirQuant.nbAddPrecisionBits + iirQuant.nbBitsFIRGain + iirQuant.nbBitsIIRGain;
  
  dinRangeString = sprintf(rangeString, iirQuant.nbBitsInput-1, 0);
  doutRangeString = sprintf(rangeString, iirQuant.nbBitsOutput-1, 0);
  coefRangeString = sprintf(rangeString, iirQuant.nbBitsCoef - 1, 0);
  firSumRangeString = sprintf(rangeString, nbBitsFir - 1, 0);
  dinPlusCoefRange = sprintf(rangeString, iirQuant.nbBitsInput + iirQuant.nbBitsCoef -1, 0);
  outputSliceRangeString = sprintf(rangeString, iirQuant.nbBitsOutput +  iirQuant.nbAddPrecisionBits - 1, iirQuant.nbAddPrecisionBits);
  outputPlusGuardSliceRangeString = sprintf(rangeString, iirQuant.nbFracBitsCoef + iirQuant.nbBitsOutput + iirQuant.nbAddPrecisionBits - 1 , iirQuant.nbFracBitsCoef);
  accFullRangeString = sprintf(rangeString, nbAccBits - 1, 0);
  accFracRangeString = sprintf(rangeString, nbAccFracBits - 1, 0);
  fullSumRangeString = sprintf(rangeString, nbFullSumBits - 1, 0);
  nbGuardBitsString =  sprintf('%d', iirQuant.nbAddPrecisionBits);
  nbAccFracBitsString =  sprintf('%d', nbAccFracBits);
  doutPlusGuardBitsRangeString = sprintf(rangeString, iirQuant.nbBitsOutput + iirQuant.nbAddPrecisionBits -1, 0);
  outputMSBString = sprintf('%d', iirQuant.nbBitsOutput +  iirQuant.nbAddPrecisionBits - 1);
  outputLSBString = sprintf('%d', iirQuant.nbAddPrecisionBits); 
  nbCoefFracBitsString = sprintf('%d', iirQuant.nbFracBitsCoef);
  text = fileread('IIR_SLA_TEMPLATE.vhd');
  fidOut = fopen([ENTITY_NAME, '.vhd'], 'w+');  
 % disp(text)
  patterns = {'DIN_PLUS_COEF_RANGE','DIN_RANGE','DOUT_RANGE', ...
  'COEF_RANGE','FIR_SUM_RANGE', 'OUTPUT_SLICE', 'ACC_RANGE',  ...
  'NB_GUARD_BITS', 'ACC_FRAC_RANGE', 'FULL_SUM_RANGE', 'DOUT_PLUS_GUARD_RANGE', 'OUTPUT_PLUS_GUARD_SLICE',...
  '%OUTPUT_MSB%', '%OUTPUT_LSB%', 'NB_COEF_FRAC_BITS' };
  outPatterns = {,dinPlusCoefRange,dinRangeString, doutRangeString, coefRangeString, firSumRangeString, ...,
   outputSliceRangeString, accFullRangeString, nbGuardBitsString, accFracRangeString, ...
   fullSumRangeString, doutPlusGuardBitsRangeString, outputPlusGuardSliceRangeString, ...
   outputMSBString, outputLSBString, nbCoefFracBitsString};
  

    for ii = 1 : length(patterns)
      text = regexprep(text,patterns{ii},outPatterns{ii},'freespacing');
    end  

    for ii = 1 : length(patterns)
      text = regexprep(text,'%ENTITY_NAME%',ENTITY_NAME,'freespacing');
    end  

    %ENTITY_NAME%

    
    text = regexprep(text, 'FIR_COEF_ARRAY_INIT', formatInitArray(numQuant, iirQuant.nbBitsCoef ));
    text = regexprep(text, 'ALL_POLE_COEF_ARRAY_INIT', formatInitArray(denQuant, iirQuant.nbBitsCoef ));
   % text = regexprep(text, 'ALL_POLE_COEF_ARRAY_INIT', firCoefArrayInitString);    
       fprintf(fidOut, '%s', text);
  fclose(fidOut);


endfunction

function arrayInitString = formatInitArray(array, nb_bits)


    arrayInitString = '(';
    for ii = 1 : length(array)
      arrayInitString = [arrayInitString, sprintf('%d => to_signed(%d, %d)', ii-1, array(ii), nb_bits)];
      if (ii < length(array))
        arrayInitString = [arrayInitString, ', '];
      else
        arrayInitString = [arrayInitString, ') '];
      end
    end  
   % disp(arrayInitString);
endfunction

