% - function for setting the seed for the random number generator
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


function setSeed(seed)
    %% Sets the seed for the random number generator.  
    % Useful for repeating the exact same optimization in the future, or to
    % force a different series of random numbers to be used in running the
    % same optimization.  Supply a positive number to set a fixed seed.
    % 
    % Alternatively, supplying a negative number will set the generator to
    % a different random state on initialization, ensuring that a different
    % set of random states is generated.
    %
    %PARAMETERS:
    % seed - must be a positive number for that particular value to be used
    %       to seed the random generator.  Negative numbers set the random
    %       number generator to novel random states not linked to those
    %       numbers and can be used to forcibly generate different random
    %       sequences each time the algorithm is run.
    %
    
    p = inputParser;    
    p.addRequired('seed',@(seed)validateattributes(seed, {'numeric'}, ...
                {'scalar', 'integer'}));
    p.parse(seed);
   
    if seed < 0
        verbosePrint('Seed < 0; setting to random value based on clock time',...
            'setSeed_set');       
        seed = sum(100*clock);
    else
        verbosePrint(['Setting seed to: ',num2str(seed)],...
            'setSeed_set');
    end
    
        rand('twister',seed);
end