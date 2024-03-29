## Copyright (C) 2018 Benjamin
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
## @deftypefn {} {@var{retval} =} quantize_coefs (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Benjamin <Benjamin@MSI>
## Created: 2018-11-24

function [num_quant, den_quant] = quantize_coefs (num, den, nbBitsFrac)
  
  num_quant = round(num*2^(nbBitsFrac));
  den_quant = floor(den*2^(nbBitsFrac));

endfunction
