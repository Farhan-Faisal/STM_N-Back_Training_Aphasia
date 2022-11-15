% - helper function to validate that a string represents a correlation
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

function flag = validateCorrel(strNum,errmsg,errtitle)
    % validates that the string represents a propability

    valid = str2double(strNum);
    
    if isnan(valid)
        % name is not currently valid, tell the user.
        msgbox(errmsg,...
                errtitle);
       flag = false;     
    else
        if valid <=1 && valid >= -1
            flag = true;
        else
            msgbox(errmsg,...
                errtitle);
            flag = false;     
        end
    end
    
    
 