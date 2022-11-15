% - retrieves the popup menu name in the GUI
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



function valName = getPopupMenuName(handle,msg,msgTitle)   
    % retrieves the string representation of the selection in a popup menu
    % referenced by handle.  Displays an informative error message if no
    % selection is made or the popup list is empty.
    
    valIndex = get(handle,'Value');
    valStr = get(handle,'String');

    
    if isempty(valStr) == 0
        if iscell(valStr)
            valName = valStr{valIndex};
        elseif ischar(valStr)
            %if it's a string, it indicates that there is only one entry in
            %the popup menu, so return that entire entry
            valName = valStr;
        else
            error('Unrecognized popup array entry');
        end
        
    else
        valName = '';
    end    

   
    if isempty(valName) == 0
        % success
    else
        msgbox(msg,msgTitle);
    end    
    
end

