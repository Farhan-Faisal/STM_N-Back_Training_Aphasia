% - random population selection method for selecting swaps
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



classdef randPopulationCandidateSelection < genericFeederCandidateSelection
    %% Randomly selects an item from the targetSample's population to swap into the sample.
    %
    % This particular obj does not need to be implemented in OO style, but
    % it has been done for consistency with the rest of the implementation
    %
    %METHODS:
    % randPopulationCandidateSelection()  % Constructor
    % init() %Not needed for this class; no functional role in object
    %[feederdf,feederdfIndex] = getCandidateIndex(obj,sample)  % returns a dataframe and row index for a swap candidate
    
    
    properties
    end
    
    methods
        
        %% randPopulationCandidateSelection() CONSTRUCTOR
        function obj = randPopulationCandidateSelection()
            % Constructor
            
            obj.init();
            
            verbosePrint('Random Population Candidate Feeder Selection Ready', ...
                'randPopulationCandidateSelection_const');
        end
        
        %% init() Method
        function init(obj)
            %Not needed for this class; no functional role in object
        end
        
        %% [feederdf,feederdfIndex] = getCandidateIndex(obj,sample) METHOD
        function [feederdf,feederdfIndex] = getCandidateIndex(obj,sample) 
            % returns a dataframe and row index for a swap candidate
            %
            %PARAMETERS:
            %   sample - the target sample to swap into
            %
            % RETURNS:
            % feederdf - the feeder dataframe
            % feederdfIndex -row index of item in feederdf
            
            feederdf = sample.population;
            feederdfIndex = floor((length(sample.population.data{1})*rand)+1);
        end

    end
end
