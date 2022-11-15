% - helper function to validate that a string represents a valid file name
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

function flag = validFileName(fileName)
%   Checks whether <fileName> is a string reference to an existing file.
%   Returns 1 if TRUE, displays problem and generates ERRROR if FALSE
%
%   Example:
%       validFileName('population1.txt'); % returns 1 if exists, specific
%                                         % cause of error otherwise

    if (ischar(fileName) == false) 
        error('ERROR: <fileName> is not a string');
    elseif(exist(fileName,'file') == 0)
        error('ERROR: Cannot open file: %s\n\tImplicit relative path (used if path unspecified): %s', ...
            fileName, pwd);
    else
        flag = 1;
    end
    
end %validFileName
