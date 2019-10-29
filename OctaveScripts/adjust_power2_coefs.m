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
%%
%% You should have received a copy of the GNU General Public License
%% along with this program.  If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*- 
%% @deftypefn {} {@var{retval} =} adjust_power2_coefs (@var{coefficients}, @var{type})
%% type : 0 = low-pass, 1 = high-pass
%% This function adjust the sum of the cofficients. For low-pass, it will be a power of 2
%% For high-pass filters, it will be 0
%% Coefficients sum is equal to the DC gain of the corresponding FIR filter
%% @seealso{}
%% @end deftypefn

%% Author: Benjamin <Benjamin@MSI>
%% Created: 2019-02-08

function [coefficients] = adjust_power2_coefs (coefficients, type)
  if ((type == 1))
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
