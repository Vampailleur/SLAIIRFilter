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
## @deftypefn {} {@var{retval} =} scattered_lookahead_transform (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Benjamin <Benjamin@MSI>
## Created: 2018-11-22

function [num_sl, den_sl] = scattered_lookahead_transform (num, den, M)

  zeros_den = roots(den);
  den_sl = den;
  num_sl = num;
  if (abs(imag(zeros_den)) < eps)

    for ii = 1 : M-1
      for jj = 1 : 2 
         polynom = [1, zeros_den(jj)];
         den_sl = conv(den_sl, polynom);
         num_sl = conv(num_sl, polynom);
      end  
    end
   else
    angle_zero = angle(zeros_den(1));
    mod_zero = abs(zeros_den(1));
    sign_mult = [1, -1];
    for ii = 1 : M-1
      
      polynom = [1, -2*mod_zero*cos(angle_zero + 2*sign_mult(ii)*pi/M), mod_zero.^2];
      den_sl = conv(den_sl, polynom);
      num_sl = conv(num_sl, polynom);
    end
  end

  
  I = find (abs(den_sl)  < 1e-15) ;
  
  den_sl(I) = 0;

    
    

endfunction
