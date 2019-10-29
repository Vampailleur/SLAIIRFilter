## Copyright (C) 2019 Benjamin
## 
## This program is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {} {@var{retval} =} IIRFixedPointFilter (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Benjamin <Benjamin@MSI>
## Created: 2019-08-24

function output = IIRSLAFixedPointFilter (numQuant, denQuant, iirQuant, input)
  
  fir_response = conv(numQuant,input);
  
  iir_states = zeros(1,4);
  fir_response_shifted = fir_response*2^iirQuant.nbAddPrecisionBits;
  fraction_saving = 0;
  all_pole_response = zeros(1,length(fir_response));
  for ii = 1 : length(fir_response)
    temp = fir_response_shifted(ii) - denQuant(3) * iir_states(2) - denQuant(5) * iir_states(4) - fraction_saving;
    temp2 = floor(temp/(2^(iirQuant.nbFracBitsCoef)));
    fraction_saving = temp2*(2^(iirQuant.nbFracBitsCoef)) - temp;
    all_pole_response(ii) = temp2;
    for jj = 3 :-1:1
      
      iir_states(jj+1) = iir_states(jj);
    end
    iir_states(1) = temp2;
  end  
  
  %% Convergent rounding
  %% In Matlab, one would use the "convergent" function
  output =  floor((all_pole_response(1:length(input)) + + 2^(iirQuant.nbAddPrecisionBits - 1))/(2^(iirQuant.nbAddPrecisionBits)) );
  maxValue = 2^(iirQuant.nbBitsOutput-1)-1;
  minValue = -2^(iirQuant.nbBitsOutput-1);
  output(output > maxValue) = maxValue;
  output(output < minValue) = minValue;
  
endfunction
