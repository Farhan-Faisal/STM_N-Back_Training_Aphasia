% Generates standalone binary for win32
%
% copyright 2009-2012 Blair Armstrong, Christine Watson, David Plaut
%
%    This file is part of SOS
%
%    SOS is free software: you can redistribute it and/or modify
%    it for academic and non-commercial purposes
%    under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.  For commercial or for-profit
%    uses, please contact the authors (sos@cnbc.cmu.edu).
%
%    SOS is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.

%    You should have received a copy of the GNU General Public License
%    along with SOS (see COPYING.txt).
%    If not, see <http://www.gnu.org/licenses/>.



% makes the sos binary based on the source files in ./src


mfiles = ls('./src/*.m');

list = {};
for i=1:length(mfiles)
    list = [list ['./src/' deblank(mfiles(i,:))]]; %#ok<AGROW>
end

%remove ./ and ../ from the ls return
list = list(3:length(list));

%swap sos_gui to the start of the list so that it is what is run when the
%binary is executed
ind = find(strcmp(list,'./src/sos_gui.m'));

tmp = list{1};
list{1} = list{ind};
list{ind} = tmp;


% base command
command = 'mcc -m';

% add src
for i=1:length(list)
    command = [command ' ' list{i}]; %#ok<AGROW>
end

% add output dir and output file
command = [command ' -d ./bin -o sos -v -M ./include/sos.res'];

% compile with specified options.  
eval(command);

clean