% - swap function based on the logistic curve
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


classdef logisticpSwapFunction < genericpSwapFunction
    %% Creates and provides support for selecting swap probabilities based on the logistic function
       
    properties
    end
    
    methods
        
        %% shouldSwap(deltaCost,temp)
        function flag = shouldSwap(obj,deltaCost,temp)
            %calculates p(swap) based on deltaCost and temperature, using logistic function
            %
            % Currently implemented using OO design in anticipation of
            % possible expansion of the code, though this is not strictly
            % necessary at present.
            %
            %Parameters:
            %   deltaCost - diff in cost between curCost and swapCost
            %   temp - temperature
           
            % since we want to make swaps when cost is negative, the
            % negative sign that would usually proceed the net input
            % (delta cost) is removed in this version of the logistic fcn.
           p= 1/(1+exp(deltaCost*1/temp)); 
           
           if rand <= p               
               flag = 1;
           else
               flag = 0;
           end
        end
    end    
end

