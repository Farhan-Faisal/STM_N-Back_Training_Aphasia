% - random population and sample selection method for swaps
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



classdef randPopulationAndSampleCandidateSelection < genericFeederCandidateSelection
    % selects a neighbor item from a sample's population or other children samples of that pop.
    % sample's population
    %
    %
    % PROPERTIES:
    %   samples - list of all samples swaps could occur in
    %   sampleItems - list of samples and items that could be swapped into those samples
    %
    % METHODS:
    %   randPopulationAndSampleCandidateSelection() % Constructor
    %   init() %initializes the sample method by generating a list of swap candidates for this sample.  
    %   [feederdf,feederdfIndex] = getCandidateIndex(obj,sample)  % returns a dataframe and row index for a swap candidate
   
    
    
    properties
        samples
        sampleItems
    end
    
    methods
       %% randPopulationAndSampleCandidateSelection() CONSTRUCTOR
        function obj = randPopulationAndSampleCandidateSelection(sosObj)
            % Constructor
            
            obj.init(sosObj);
            
            verbosePrint('Random Population And Sample Feeder Candidate Selection Ready', ...
                'randPopulationAndSampleCandidateSelection_const');
        end
        
        
        %% init(sosObj) METHOD
        function init(obj,sosObj)
            %initializes the sample method by generating a list of swap candidates for this sample.  
            %
            %PARAMETERS:
            % sosObj - the SOS object the candidate selection method is linked to
            
            obj.samples = [];
            obj.sampleItems = {};
            
            for i=1:length(sosObj.samples)
                curSample = sosObj.samples(i);
                obj.samples = [obj.samples curSample];
               
                alreadyMerged = {};
                
                candidateItemIndicies = {};
                %add it's own items to the list.  
                
                for j=1:curSample.n
                    if curSample.locks(j) == 0
                        candidateItemIndicies = [candidateItemIndicies ; {curSample j}]; %#ok<AGROW>
                    end
                end
                
                alreadyMerged = [alreadyMerged {curSample}]; %#ok<AGROW>
                
                %add it's population's item to the list
                
                if(isempty(curSample.population) == false && isempty(curSample.population.data) == false)
                    tempIndicies = cell(length(curSample.population.data{1}),2);
                    for j=1:length(curSample.population.data{1})
                        tempIndicies{j,1} = curSample.population; 
                        tempIndicies{j,2} = j; 
                    end

                    candidateItemIndicies = [candidateItemIndicies ; tempIndicies]; %#ok<AGROW>
                    alreadyMerged = [alreadyMerged {curSample.population}]; %#ok<AGROW>
                
                end
                % add other samples which are part of this SOS obj and
                % which share the sample population to the current sample.
                
                %no siblings if there is no population linked with the
                %object
                if isempty(curSample.population) ~= 1
                    numSiblings=length(curSample.population.samples);
                else
                    numSiblings = 0;
                end
                
                for k=1:numSiblings
                    siblingSample = curSample.population.samples(k);
                    
                    doneAlready = false;
                    for l=1:length(alreadyMerged)
                        if alreadyMerged{l} == siblingSample
                            doneAlready = true;
                        end
                    end
                    
                    
                    inSOSObj = max(ismember(siblingSample,sosObj.samples)); 
                    %doneAlready = max(ismember(siblingSample,alreadyMerged)); 
                    
                    if inSOSObj == true && doneAlready == false
                        for j=1:siblingSample.n
                            %also exclude locked items from the sibling
                            %sample from entering into the computation.
                            if siblingSample.locks(j) == 0
                             candidateItemIndicies = [candidateItemIndicies ; {siblingSample j}]; %#ok<AGROW>
                            end
                        end
                    end
                    
                    alreadyMerged = [alreadyMerged {siblingSample}]; %#ok<AGROW>
                     
                end
             
                obj.sampleItems{i} = candidateItemIndicies;
            end
                       
        end %init()
        
        
        %% [feederdf,feederdfIndex] = getCandidateIndex(obj,sample) METHOD
        function [feederdf,feederdfIndex] = getCandidateIndex(obj,sample) 
            % returns a dataframe and row index for a swap candidate
            %
            % PARAMETERS:
            %   sample - the target sample to swap into
            %
            % RETURNS:
            % feederdf - the feeder dataframe
            % feederdfIndex -row index of item in feederdf
            
            if(strcmp(class(sample),'sample') == false)
                error('Input must be a sample');
            end
            
            sampleIndex = -1;
            for i=1:length(obj.samples)
                if obj.samples(i) == sample
                    sampleIndex = i;
                end
            end
            
            %find the sample
            if sampleIndex == -1
                error('Unable to find sample');
            end
            
            %randomly select an item to swap with
            
            lookupIndex = floor((length(obj.sampleItems{sampleIndex})*rand)+1);
           
            feederdf = obj.sampleItems{1,sampleIndex}{lookupIndex,1};
            feederdfIndex = obj.sampleItems{1,sampleIndex}{lookupIndex,2};

        end
      
    end
    
end

