% - helper function to validate that a string represents a probability
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


function flag = validateProbability(strNum,errmsg,errtitle)
    % validates that the string represents a propability

    valid = regexp(strNum,'^[0]?[\.][0-9]+$', 'once');
    

    if isempty(valid)
        % name is not currently valid, tell the user.
        msgbox(errmsg,...
                errtitle);
       flag = false;     
    else
        flag = true;
    end
    
    

end

