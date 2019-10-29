## Copyright (C) 2019 Benjamin
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.

%% -*- texinfo -*- 
%% @deftypefn {} {@var{retval} =} createDoFile (@var{input1}, @var{input2})

%% @seealso{}
%% @end deftypefn
%%
%% Author: Benjamin <Benjamin@MSI>
%% Created: 2019-02-09

function  createDoFile ( doFilename, path, DUT_NAME, TB_NAME)
	

  text = fileread('..\VHDLTemplates\run_template.do');
  
  fidOut = fopen([path,'\',doFilename, '.do'], 'w+');  
  patterns = {'%DUT_NAME%','%TB_NAME%'};
  
  outPatterns = {DUT_NAME, TB_NAME};
  

    for ii = 1 : length(patterns)
      text = regexprep(text,patterns{ii},outPatterns{ii},'freespacing');
    end  

   fprintf(fidOut, '%s', text);
  fclose(fidOut);


endfunction

