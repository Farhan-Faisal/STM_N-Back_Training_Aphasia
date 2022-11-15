% - random sample method for selecting swaps
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



classdef randSampleCandidateSelection < genericSampleCandidateSelection
    %% randomly select an item from one of the samples as a candidate for a swap.
    %
    % PROPERTIES:
    %   candidateItemIndices % list of possible sample items to swap
    %
    %METHODS
    %   randSampleCandidateSelection(sosObj) % Constructor
    %   init(sosObj) initialize the object by generating a list of possible sample items to swap
    %   [targSample, targIndex] = getCandidateIndex() % randomly select an item in a sample to swap    
    
    %% PROPERTIES
    properties
        candidateItemIndices % list of possible sample items to swap
    end
    
    methods
        %% randSampleCandidateSelection(sosObj) Constructor
        function obj = randSampleCandidateSelection(sosObj)
            % Constructor
            %
            %PARAMETERS:
            %   sosObj - the sos object this object is to be linked to
            
            obj.init(sosObj);
            verbosePrint('Random Sample Target Candidate Selection Ready', ...
                'randSampleCandidateSelection_const');
        end
        
        %% init(sosObj) METHOD
        function init(obj,sosObj)
            % initialize the object by generating a list of possible sample items to swap
            
            candidateItemIndices = {}; %#ok<PROP>
            
            for i =1:length(sosObj.samples)
                for j=1:sosObj.samples(i).n
                   if sosObj.samples(i).locks(j) == 0
                       candidateItemIndices = [candidateItemIndices ; {sosObj.samples(i) j}]; %#ok<AGROW,PROP>
                   end                    
                end                
            end
            
            obj.candidateItemIndices = candidateItemIndices;   %#ok<PROP>
            
        end
        
        %% getCandidateIndex() METHOD
        function [targSample, targIndex] = getCandidateIndex(obj) 
            % randomly select an item in a sample to swap
            %
            %RETRURNS:
            % Index of sample, and index of item in sample.  
            
            if isempty(obj.candidateItemIndices)
                error(['Cannot optimize - no unlocked items in samples.',...
                    char(10), 'Did you initFillSamples()? Is there at least one sample whose items are not all locked?']);
            end
            
            index = obj.candidateItemIndices(floor((length(obj.candidateItemIndices)*rand)+1), 1:2);            
            targSample = index{1};
            targIndex = index{2};
        end

    end
end
