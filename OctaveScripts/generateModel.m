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
## @deftypefn {} {@var{retval} =} generateModel (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Benjamin <Benjamin@MSI>
## Created: 2019-10-26

function [retval] = generateModel (modelName, path, numerator, denominator, iirQuant, stimulus, expectedStimulusResponse)



retval = mkdir(path);
convertSLAtoVHDL('test_iir',path, numerator, denominator, iirQuant);

% 2 VHDL testbenches are created
% one is self-checking, mostly used to make sure that the reset, and the interface 
% is functional
% The second one, is a file testbench that reads an input from a file and the output
% its reponse in another file. Used to compare the fixed-point Octave model with
% the VHDL model



createSLASelfCheckTB('test_iir', path, iirQuant, stimulus, expectedStimulusResponse);
%createSLAFileTB('test_iir', path, iirQuant);



endfunction
