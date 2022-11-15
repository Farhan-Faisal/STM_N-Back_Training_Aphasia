% -  extracts a dataframe name selected in the GUI
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


% returns the string label of the dataframe (techically and more generally now, the
% name of the object) that has been selected in a gui popup menu.
function dfName = getdfName(handle,dfType)    
    %% returns the string label (name) of an object in a gui popup menu
    
    dfNum = get(handle,'Value');
    dfNames = get(handle,'String');
    
    if isempty(dfNames) == 0
        if ischar(dfNames) % for if there is only one entry in the list
            dfName = dfNames;
        else
            dfName = dfNames{dfNum};
        end
    else
        dfName = '';
    end    

    %make sure there is an active df
    if isempty(dfName) == 0
        % success
    else
        msgbox(['A ',dfType,' must be active'],...
                ['No active ',dfType]);  
    end

    
