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
## @deftypefn {} {@var{retval} =} adjust_power2_coefs (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Benjamin <Benjamin@MSI>
## Created: 2019-02-08

function [coefficients] = adjust_power2_coefs (coefficients, type)
  if (type == 'high')
    sumExpected = 0;
  else
    sum_exp = ceil(log2(sum(coefficients)));
    sumExpected = 2^(sum_exp);
  end
  
  diff = sum(coefficients) - sumExpected;
  
  %find max coefficient in absolute value and adjust its value
  %TODO : Find an optimal way to balance coefficients

  [maxVal, idx] = max(abs(coefficients));
  
  coefficients(idx) = coefficients(idx) - diff;
   
  

endfunction
