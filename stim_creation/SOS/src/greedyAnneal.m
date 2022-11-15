% - greedy annealing (i.e., T = 0) object
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



classdef greedyAnneal < genericAnneal
    %% greedy annealing
    
    properties
    end
    
    methods
        function obj = greedyAnneal(varargin)
            %% creates the greedy anneal object
            
            p = inputParser;
            p.addParamValue('schedule','greedy', ...
                @(schedule)strcmp(schedule,'greedy'));            
            p.parse(varargin{:});
            
            verbosePrint('Creating greedy temperature annealing function...',...
                'greedyAnneal_constructor_startObjCreation');
            
           obj.temp = 0; 
        end
        
        
        function temp = getTemp(obj)
            %% returns the current temperature
            temp = obj.temp;
        end
        
        %does nothing in this implementation; temp is always zero
        function anneal(obj,~,~,~) %#ok<MANU>
            %% does nothing; temp is always 0
        end
        
    end
    
end