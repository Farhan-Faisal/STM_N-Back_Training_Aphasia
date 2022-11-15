% - master print function that regulates cmd line output based on verbosity flags
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

function verbosePrint(msg,fieldName)
    % the main output driver for SOS information.  
    % provides support for displaying data to the standard output.  It's
    % associated functions (e.g., setVerbosePrintVerbosity) can also be
    % used to set what messages will be printed and to what output stream
    % (though only stdout is currently supported).  
    
    %check that what was supplied is a string
    if (ischar(msg) == false) 
        error('{msg} supplied to verbosePrint is not a String');
    end
    
    if (ischar(fieldName) == false) 
        error('{fieldName} supplied to verbosePrint is not a String');
    end
    
    global verbosityFlags;
    if(isempty(verbosityFlags))
        initVerbosePrint(); 
    end
    
    %try looking up the string,  
    if (isfield(verbosityFlags,fieldName))
        if getfield(verbosityFlags,fieldName) == 1
            disp(msg);
        end
    else
       error('{fieldName} is not a registered verbosityFlag');
    end
end



