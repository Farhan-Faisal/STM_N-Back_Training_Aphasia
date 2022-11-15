% - SOS optimization object
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

classdef sos < genericStatTest
    % Creates and supports optimization objects
    %
    % Inherits from handle so that by-reference passing can be used with
    % the object
    %
    % PROPERTIES
    %     samples % array of samples linked to SOS object
    %     hardConstraints % array of hard constraint objects
    %     softConstraints % array of soft constraint objects
    %     metaConstraints % array of meta constraint objects
    %     cost % current cost
    %     sCandObj % object used to identify the target item in a sample which may be swapped
    %     feederCandObj % object used to identify the item in a population/other sample to be swapped with the target sample item
    %     pSwapObj  % object which determines the probability of making a swap based on deltaCost
    %     annealObj % object used to anneal temperature in pSwap
    %     maxIt % maximum number of iterations that an optimization will run for   
    %     allData % merge of all data from all samples/ pops linked to sosobj
    %     allDataColName % name of columns in allData
    %     allDataColMean % mean for each column in allData
    %     allDataColStd  % stdev for each column in all data
    %     reportInterval % number of iterations between progress reports
    %     curIt % current optimization iteration
    %     curFreezeIt % number of iterations cost has been frozen at a particular value
    %     stopFreezeIt % number of frozen iterations before algorithm stops
    %     sosstattests % array of handles to sos  stat tests requested by user
    %     statInterval % number of iterations between stat reports
    %     statTestReportStyle % style of report ('short' or 'full')
    %     deltaCost % delta cost from soft constraints from last attempted flip that met all hard constraints
    %     blockSize % number of iterations in a 'block' of trials for which average flip history /minDeltaCost stats are calculated
    %     nFlip % number of flips so far in the block
    %     deltaCostLog % log of deltaCost values for delta cost distribution analysis
    %     oldNumIt % number of iterations requested on the last optimization.  This is the default number for future optimizations.
    %     plotObj % sos object responsible for plotting
    %     histObj % object that contains detailed optimization history data
    % 
    % METHODS:
    %   sos(varargin) -  Constructor
    %   addSample(sample) adds a sample to the SOS object so that its items can be optimized.  
    %   present = containsSample(sample) evaluates whether the sos object already contains the specified sample
    %   constraint = addConstraint(varargin) % Adds a constraint to be optimized and returns it
    %   initFillSamples() % fills all samples to their specified capacity
    %   validItem = checkHardConstraintsFilling(sample,sItemIndex,newItemDataFrame,newItemIndex) returns a flag indicating if newIem can be added to sample during the initial filling of samples.
    %   swCost = checkHardConstraintsSwapping(sample,sItemIndex,newItemDataFrame,newItemIndex) returns the hard constraint cost of swapping item from newItemDataframe with item in sample.  
    %   swCost = checkSoftConstraintsSwapping(targSample,targSampleIndex,feederdf, feederdfIndex)  % calculates the cost of a swap on the soft constraints
    %   swCost = checkMetaConstraintsSwapping(~,~,~,~)  % calcualtes the cost of a swap on the meta constraints
    %   [colName,colMean,colStd,allData] = normalizeData() % Normalizes the data in the samples and populations linked to the SOS object to provide some coarse balancing of initial cost values.  
    %   cost = initCost()  %initializes and reports hard/soft/meta cost contraints
    %   setpSwapFunction(obj,swFunctionName) %sets the pSwap function for the sos obj.  
    %   setSampleCandidateSelectionMethod(methodName) % sets the sample Candidate selection method
    %   setFeederdfCandidateSelectionMethod(methodName)  % sets the feeder candidate selection method 
    %   setAnnealSchedule(varargin) % sets the anneal schedule for the SOS object
    %   goodEnding = optimize()  % Optimizes samples based on specified constraints
    %   doReport(tStart)  % displays a progress report from the last iteration in optimization
    %   writeSamples() % writes the data from the samples to text files specified in their 'outFile' property
    %   writePopulations() % writes the data from the populations to text files specified in their 'outFile' property
    %   writeAll() write all populations and samples associated with SOS object to disk
    %   addttest(obj, varargin) %adds a t-test to the list of analyses to run
    %   addztest(varargin) %adds a z-test to the list of analyses to run
    %   pass = doStatTests(varargin) % runs the stat tests and indicates if all passed the user hypotheses.  
    %   present = containsConstraint(constraint) % determines whether <constraint> is a constraint associated with the current SOSobj
    %   cost = dispCost()  %reports hard/soft/meta cost contraints
    %   deltaCostPercentiles() % displays the breakdown of deltaCost values per decile
    %   createPlots(dispIt) % creates plots for several optimization parameters
    %   updatePlots(curIt,cost,deltaCost,pFlip,temp) %updates the contents of the plot
    %   createHistory() % creates plots for several optimization parameters
    %   updateHistory(curIt,cost,deltaCost,pFlip,temp) %updates the contents of the plot
    %   writeHistory(fileName) %writes all history saved to date to file 'fileName'
    %   setBufferedHistoryOutfile(outFile) % writes the history on-line, one update at a time, to outfile
    %   enableBufferedHistoryWrite() % enables writing of buffered history.  
    %   disbleBufferedHistoryWrite() % disables writing of buffered history.  
    %
    % METHODS (STATIC,Acess = private)
    %   p = parseConstructorArgs(varargin) - parses the sos constructor arguments    
    
    %% PROPERTIES
    properties 
        samples % array of samples linked to SOS object
        hardConstraints % array of hard constraint objects
        softConstraints % array of soft constraint objects
        metaConstraints % array of meta constraint objects
        cost % current cost
        sCandObj % object used to identify the target item in a sample which may be swapped
        feederCandObj % object used to identify the item in a population/other sample to be swapped with the target sample item
        pSwapObj  % object which determines the probability of making a swap based on deltaCost
        annealObj % object used to anneal temperature in pSwap
        maxIt % maximum number of iterations that an optimization will run for   
        allData % merge of all data from all samples/ pops linked to sosobj
        allDataColName % name of columns in allData
        allDataColMean % mean for each column in allData
        allDataColStd  % stdev for each column in all data
        reportInterval % number of iterations between progress reports
        curIt % current optimization iteration
        curFreezeIt % number of iterations cost has been frozen at a particular value
        stopFreezeIt % number of frozen iterations before algorithm stops
        sosstattests % array of handles to sos  stat tests requested by user
        statInterval % number of iterations between stat reports
        statTestReportStyle % style of report ('short' or 'full')
        deltaCost % delta cost from soft constraints from last attempted flip that met all hard constraints
        blockSize % number of iterations in a 'block' of trials for which average flip history /minDeltaCost stats are calculated
        nFlip % number of flips so far in the block
        deltaCostLog % log of deltaCost values for delta cost distribution analysis  
        oldNumIt % number of iterations requested on the last optimization.  This is the default number for future optimizations.
        plotObj % object responsible for plotting
        histObj % object that contains detailed optimization history data
        targSampleCandSelectMethod % name of sample replacement method
        feederdfCandSelectMethod % name of neighbor method
        queryStopOptimize % how often to probe the gui to see if the stop button was pressed
    end
    
    %% PROPERTIES (Constant)
    properties (Constant)
        maxIt_def = 10000; % default
        pSwapFunction_def = 'logistic'; % default 
        targSampleCandSelectMethod_def = 'random'; % default
        feederdfCandSelectMethod_def = 'randomPopulationAndSample'; % default
        reportInterval_def = 1000; % default
        stopFreezeIt_def = 10000; % default
        statInterval_def = 10000; % default
        statTestReportStyle_def = 'short'; % default
        blockSize_def = 1000; % default
        queryStopOptimize_def = 100; % default
    end
         
    methods
        
        %% sos CONSTRUCTOR
        function obj = sos(varargin)
            % Constructor
            %
            % SYNOPSIS:
            % Creates an SOS object
            %
            %PARAMETERS:
            %Optional:
            %   'maxIt'/integer - maximum number of iterations to run the optimizer
            %   'pSwapFunction'/string - name of pSwapFunction to use.
            %   'targSampleCandSelectMethod'/string - name of target Sample Candidate selection method
            %   'feederdfCandSelectMethod'/string - name of feeder dataframe candidate selection method
            %   'reportInterval'/int - number of iterations between general cost reports
            %   'stopFreezeIt'/int - operationalized number of sequential iterations cost value must remain the same for state to be considered 'frozen'
            %   'statInterval'/int - number of iterations between stat reports
            %   'statTestReportStyle'/string - style of stat reports ('short' or 'full')
            %   'blockSize'/int - number of iterations in a block; used to determine length of deltaCostLog
            
            verbosePrint([char(10) 'Creating sos Object'], ...
                'sos_constructor_startObjCreation');

            p = sos.parseConstructorArgs(varargin);
            
            %potentially user-specified variables
            obj.maxIt = p.Results.maxIt;
            obj.oldNumIt = obj.maxIt;
            obj.reportInterval = p.Results.reportInterval;
            obj.stopFreezeIt = p.Results.stopFreezeIt; 
            obj.statInterval = p.Results.statInterval;
            obj.statTestReportStyle = p.Results.statTestReportStyle;
            obj.blockSize = p.Results.blockSize;
            
            obj.queryStopOptimize = obj.queryStopOptimize_def;
            
            setpSwapFunction(obj,p.Results.pSwapFunction);
            setSampleCandidateSelectionMethod(obj,...
                p.Results.targSampleCandSelectMethod);
            setFeederdfCandidateSelectionMethod(obj,...
                p.Results.feederdfCandSelectMethod);
            
            obj.targSampleCandSelectMethod = p.Results.targSampleCandSelectMethod;
            obj.feederdfCandSelectMethod = p.Results.feederdfCandSelectMethod;
            
            
            obj.curIt = 0;            
            obj.samples = [];       
            obj.hardConstraints = [];
            obj.softConstraints = [];
            obj.metaConstraints = [];
            obj.sosstattests = [];
            obj.curFreezeIt = 0;
            obj.deltaCost = NaN;
            obj.nFlip = NaN;
            obj.deltaCostLog = nan(obj.blockSize,1);
            
            %set default anneal schedule to greedy
            obj.setAnnealSchedule();

            verbosePrint(['Creation of sos object complete' char(10)], ...
                'sos_constructor_endObjCreation');
        end

        
        %% addSample METHOD
        function obj = addSample(obj, sample)
            % adds a sample to the SOS object so that its items can be optimized.  
            %
            % CALL:
            % <sosObj>.addSample(<sampleObj>)
            %
            % PARAMETERS:
            % sample - a sample object
            
            p = inputParser;
            p.addRequired('obj');
            p.addRequired('sample', ...
                 @(sample)strcmp(class(sample),'sample'));
            p.parse(obj,sample);
                                            
            if(isempty(sample.population)==1)
                verbosePrint('Warning: Sample has not been linked with a population', ...
                    'sos_addSample_NoPopForSampleWarn');
            end
          
            present = obj.containsSample(sample);
            
            if(present == 1)
                verbosePrint('Warning: Sample has already been added.  It cannot be added again', ...
                    'sos_addSample_SampleAlreadyAddedWarn');              
            else
                obj.samples = [obj.samples sample];  
                verbosePrint('Adding new Sample...', ...
                    'sos_addSample_sampleAdded');
            end
            
        end %addSample
        
        
        %% present = containsSample(sample) METHOD
        function present = containsSample(obj, sample)
            % evaluates whether the sos object already contains the specified sample
            %
            % PARAMETERS:
            %   sample - a sample object
            
            p = inputParser;
            p.addRequired('obj');
            p.addRequired('sample', ...
                 @(sample)strcmp(class(sample),'sample'));
            p.parse(obj,sample);
                                            
            present = max(ismember(obj.samples,sample));
 
        end %addSample       
        
        
        %% addConstraint(varargin) METHOD
        function constraint = addConstraint(obj, varargin)
           % Adds a constraint to be optimized
           %
           % PARAMETERS:
           % varies dependig on object to be created.  See
           % genericConstraint and the specific constraint you wish to
           % create for options.
           
           constraint = genericConstraint.createConstraint('sosObj',obj,varargin{:});
           
           if(strcmp(constraint.constraintType,'hard'))
               obj.hardConstraints = [obj.hardConstraints {constraint}];
           elseif(strcmp(constraint.constraintType,'soft'))
               obj.softConstraints = [obj.softConstraints {constraint}];          
           elseif(strcmp(constraint.constraintType,'meta'))
               obj.metaConstraints = [obj.metaConstraints {constraint}];
           else
               error('The type of the new constraint is not supported by the sos object.  Supported types are hard/soft/meta');
           end
         
        end

        %% present = containsConstraint(constraint) METHOD
        function present = containsConstraint(obj, constraint)
            % determines whether <constraint> is a constraint associated with the current SOSobj
            %
            % Returns 1 if <constraint> is present, 0 otherwise
            
            present = 0;

            for i=1:length(obj.hardConstraints)
                if(obj.hardConstraints{i} == constraint)
                    present = 1;
                    return;
                end
            end
            
            for i=1:length(obj.softConstraints)
                if(obj.softConstraints{i} == constraint)
                    present = 1;
                    return;
                end
            end
            
            for i=1:length(obj.metaConstraints)
                if(obj.metaConstraints{i} == constraint)
                    present = 1;
                    return;
                end
            end
            
        end
        
        %% initFillSamples()  METHOD
        function obj = initFillSamples(obj)
            % fills all samples to their specified capacity
            %
            
            verbosePrint('Filling All Samples...','sos_initFillSamples_start');
            
            if(isempty(obj.samples))
                 error('Error: No Samples in SOS Object!');
            end
            
            %total add stores references to the number of items left to
            %fill in to all of the different samples.
            totalAdd = [];
            for i=1:length(obj.samples)
               %find out how many observations are needed,
               %how many have already been filled,
               %and then fill the remainder
               
               n = obj.samples(i).n;
               
               if(isempty(obj.samples(i).data))
                   curN= 0;
               else
                curN = length(obj.samples(i).data{1});
               end
               
               toAdd = n-curN;               
               totalAdd = [totalAdd ones(1,toAdd)*i]; %#ok<AGROW>
                   
            end
            
           %now add all of those observations from the appropriate
           %population, enforcing hard bounds

           while(isempty(totalAdd) ==0)
               %select a sample at random
               toAddIndex=floor((length(totalAdd)*rand)+1);
               sIndex= totalAdd(toAddIndex);

               %randomly select an item from it's population:
                %make sure that the target population has at least one
                %item still in it
                if(isempty(obj.samples(sIndex).population))
                    error(['Sample ''',obj.samples(sIndex).name,''' is not filled to capacity, but has not been linked to a population to fill it']);
                end
                        
                    
                if(isempty(obj.samples(sIndex).population.data)==1)
                    error(['sos.initFillSamples Failed because ', ...
                        'a population was depeleted of items but ',...
                        'more items were still needed']);                       
                else
                    pItemIndex = ...
                     floor(length(obj.samples(sIndex).population.data{1})*rand+1);
                end
   
                if(isempty(obj.samples(sIndex).data))
                    sItemIndex = 1;
                else
                    sItemIndex = length(obj.samples(sIndex).data{1});
                end
                
                %pass it the current sample, where the item will go in it,
                %then the population, and the item from the pop's index.
                validItem = obj.checkHardConstraintsFilling( ...
                    obj.samples(sIndex),sItemIndex, ...
                    obj.samples(sIndex).population,pItemIndex);
                              
                if(validItem == 1)
                    %add that population item to the sample list; remove it
                    %from the population.  
                    totalAdd(toAddIndex)=[]; %#ok<AGROW>
                    pItem = obj.samples(sIndex).population.popItem(pItemIndex);
                    obj.samples(sIndex).appendItem(pItem);
                end
           end            
        end % initFillSamples
            
        
        %% validItem = checkHardConstraintsFilling(obj,sample,sItemIndex,newItemDataFrame,newItemIndex)
        function validItem = checkHardConstraintsFilling(obj,sample,sItemIndex,newItemDataFrame,newItemIndex)
            % returns a flag indicating if newItem can be added to sample during the initial filling of samples.
            %
            % Should only be invoked when initially filling the samples
            %
            %
            %   sample - the target sample 
            %   sItemIndex - row index of item to swap
            %   newItemDataframe - dataframe (sample/pop) containin the item to fill with.  
            %   newItemIndex - row index of item to swap.  
            validItem = 1;
            
            for i=1:length(obj.hardConstraints)
                if(obj.hardConstraints{i}.s1 == sample)
                    if (obj.hardConstraints{i}.itemCostFilling(...
                            sample,sItemIndex, ...
                            newItemDataFrame,newItemIndex) == 1)   
                        
                        validItem = 0;
                    end
                end
            end        
        end % checkHardConstraintsFilling
        
        
        %% swCost = checkHardConstraintsSwapping(obj,sample,sItemIndex,newItemDataFrame,newItemIndex)
        function swCost = checkHardConstraintsSwapping(obj,sample,sItemIndex,newItemDataFrame,newItemIndex)
            % returns the hard constraint cost of swapping item from newItemDataframe with item in sample.  
            %
            % Generally, if swCost > 0 the swap should not be executed
            %   sample - the target sample 
            %   sItemIndex - row index of item to swap
            %   newItemDataframe - dataframe (sample/pop) containin the item to fill with.  
            %   newItemIndex - row index of item to swap.  
            curCost = 0;
            newCost = 0;
            for i=1:length(obj.hardConstraints)
                if(obj.hardConstraints{i}.s1 == sample)
                        
                    curCost = curCost + obj.hardConstraints{i}.cost;
                    newCost = newCost + obj.hardConstraints{i}.swapCost(...
                        sample,sItemIndex,newItemDataFrame,newItemIndex);
                elseif (obj.hardConstraints{i}.s1 == newItemDataFrame)
                    curCost = curCost + obj.hardConstraints{i}.cost;
                    newCost = newCost + obj.hardConstraints{i}.swapCost(...
                        newItemDataFrame,newItemIndex,sample,sItemIndex);
                    
                end        
            end
                       
            swCost = newCost - curCost ;
                        
        end
        
        %% swCost =  checkSoftConstraintsSwapping(targSample,targSampleIndex,feederdf, feederdfIndex)
        function swCost = checkSoftConstraintsSwapping(obj,targSample,targSampleIndex,feederdf, feederdfIndex)
            % calculates the cost of a swap on the soft constraints
            %
            % PARAMETERS:
            %   targSample - the target sample 
            %   targSampleIndex - row index of item to swap
            %   feederdf - dataframe (sample/pop) containin the item to fill with.  
            %   feederdfIndex - row index of item to swap.  
            %
            % RETURNS:
            % swCost - cost of making the swap
            
            swCost = 0;
            
            for j=1:length(obj.softConstraints)
                if ((obj.softConstraints{j}.s1 == targSample ||  ...
                        obj.softConstraints{j}.s2 == targSample || ...
                        obj.softConstraints{j}.s1 == feederdf || ...
                        obj.softConstraints{j}.s2 == feederdf ))
                    swCost = swCost + ...
                      obj.softConstraints{j}.swapCost(...
                       targSample,targSampleIndex,feederdf, feederdfIndex);
                else
                    swCost = swCost +obj.softConstraints{j}.cost;
                end
            end       
        end
         
        %% swCost = checkMetaConstraintsSwapping(~,~,~,~) METHOD
        function swCost = checkMetaConstraintsSwapping(obj,~,~,~,~)
            % calcualtes the cost of a swap on the meta constraints
            %
            %Parameters:
            % parameters are the same as for hard and soft constraints, but
            % are ignored.  They are accepted as arguments merely to
            % increase the consistency of the argument.  
            
            %checking meta constraints is extremely computationally cheap,
            %so they are calculated every time.  
            
           swCost = 0; 
           
           for j=1:length(obj.metaConstraints)
               swCost = swCost + obj.metaConstraints{j}.swapCost();
           end
        end
             
             
        %% [colName,colMean,colStd,allData] = normalizeData() METHOD
        function [colName,colMean,colStd,allData] = normalizeData(obj)
            % Normalizes the data in the samples and populations linked to the SOS object to provide some coarse balancing of initial cost values.  
            
            verbosePrint('Normalizing Population and Sample Data', ...
                        'sos_normalizeData_start');
         
            %empty data frame
            allData = dataFrame();
            
            alreadyMerged = {};
            
            %go through each of the samples, and their populations.  
            for i=1:length(obj.samples)
                %first, check the population:
                
                popPresent = 0;
                if(isempty(alreadyMerged))
                    popPresent = 0;
                else
                    for j=1:length(alreadyMerged)
                        if(alreadyMerged{j} == obj.samples(i).population)
                            popPresent = 1;
                        end
                    end
                end
                
                %population has not already been added, so add it
                if(popPresent == 0)
                    %only add the population if the sample does in fact
                    %have a population
                    if isempty(obj.samples(i).population) ~= 1
                        allData = dataFrame.aContainsb(allData,obj.samples(i).population);
                        allData = dataFrame.aContainsbData(allData,obj.samples(i).population);
                        alreadyMerged = [alreadyMerged {obj.samples(i).population}]; %#ok<AGROW>
                    end
                end
                
                %now add the sample
                allData = dataFrame.aContainsb(allData,obj.samples(i));
                allData = dataFrame.aContainsbData(allData,obj.samples(i));
                %we don't need to check that the sample hasn't been added
                %stricly speaking, because samples can only appear once.
                %However, this may be necessary in a future version of
                %the code...
                alreadyMerged = [alreadyMerged {obj.samples(i)}]; %#ok<AGROW>
               
                
            end
            
            %we now have all of the data in a single dataframe; each column
            %can now be normalized and descriptive statistics stored.  
            
            colName = cell(1,length(allData.data));
            colMean = NaN(1,length(allData.data));
            colStd =  NaN(1,length(allData.data));
            
            
            for i=1:length(allData.data)
                %if it's a numeric vector, calculate mean/stdev
                colName{i} = allData.header{i}; 
                
                if(strcmp(allData.format{i},'%f'))
                   colMean(i) = nanmean(allData.data{i});
                   colStd(i) = nanstd(allData.data{i});
                end    
            end
                           
            %configure the z-data field in each sample and population to
            %reflect the new changes.  
            
            for i=1:length(alreadyMerged)
               %link the current normalization to this object
                alreadyMerged{i}.sosObj = obj; %#ok<AGROW>
                alreadyMerged{i}.zdata = {}; %#ok<AGROW>
               
               for j=1:length(alreadyMerged{i}.data)
                   col = alreadyMerged{i}.data{j};
                   
                  if(strcmp(alreadyMerged{i}.format{j},'%f'))
                      m= NaN;
                      std = NaN;
                      %get the relevant coefficients:
                      for k=1:length(colName)
                         if (strcmp(colName{k},alreadyMerged{i}.header{j}))                           
                            m = colMean(k);
                            std = colStd(k);
                             break;
                         end
                      end
                      
                      %check that m and std exist  
                      if(isnan(m) || isnan(std))
                          error('Normalization failed because either the mean or stdeviation was NaN');
                      end
                      
                      %they exist, so normalization can proceed
                      
                      
                      if std == 0
                          verbosePrint(['Warning: No variance in column: ', alreadyMerged{i}.header{j}],...
                            'sos_normalizeData_noVarWarn');
                          std = 1;
                      end
                      
                      col = (col-m)/std;
                                          
                  end

                  alreadyMerged{i}.zdata{j} = col; %#ok<AGROW>
                          
               end                
            end    
            
            obj.allData = allData;
            obj.allDataColName = colName;
            obj.allDataColMean = colMean;
            obj.allDataColStd = colStd;
            
        end %normalizeData
        
        
        %% initCost() METHOD
        function cost = initCost(obj)
            %initializes and reports hard/soft/meta cost contraints

            verbosePrint([char(10),'Initializing Constraints',char(10)],...
                'sos_initCost_startInit');
            
            
            
            % hard constraints
            hardConstraintCost = 0;
            for j = 1:length(obj.hardConstraints)
                try
                    tempCost = obj.hardConstraints{j}.initCost();
                catch exception
                    if strcmp(exception.identifier, ...
                            'MATLAB:cellRefFromNonCell')
                        error(['ERROR: Data needed to calculate hard constraint cost #' num2str(j),' is missing.',...
                            char(10),'       Have samples been filled and normalized?']);
                  
                    else
                        throw exception
                    end
                    
                end
                
                verbosePrint(['   Hard Constraint #: ',num2str(j),...
                    ' Cost: ' num2str(tempCost),'   ',obj.hardConstraints{j}.name], ...
                        'sos_initCost_indivHardCost');
                hardConstraintCost = hardConstraintCost + tempCost;
            end
 
            verbosePrint(['Hard Constraint Total: ', num2str(hardConstraintCost)], ...
                        'sos_initCost_totalHardCost');
                    
            % soft constraints        
            softConstraintCost = 0;
            for j=1:length(obj.softConstraints)
                try
                    tempCost = obj.softConstraints{j}.initCost();    
                catch exception
                    if strcmp(exception.identifier, ...
                            'MATLAB:cellRefFromNonCell')
                        error(['ERROR: Data needed to calculate soft constraint cost #' num2str(j),' is missing.',...
                            char(10),'       Have samples been filled and normalized?']);
                  
                    else
                        throw exception
                    end
                    
                end
                
                verbosePrint(['   Soft Constraint #: ',num2str(j),...
                    ' Cost: ' num2str(tempCost),'   ',obj.softConstraints{j}.name], ...
                        'sos_initCost_indivSoftCost');
               softConstraintCost = softConstraintCost + tempCost; 
            end
            
            verbosePrint(['Soft Constraint Total: ', num2str(softConstraintCost)], ...
                        'sos_initCost_totalSoftCost');
            
            % meta constraints
            metaConstraintCost = 0;
            for j=1:length(obj.metaConstraints)
                try
                    tempCost = obj.metaConstraints{j}.initCost();    
                catch exception
                    if strcmp(exception.identifier, ...
                            'MATLAB:cellRefFromNonCell')
                        error(['ERROR: Data needed to calculate meta constraint cost #' num2str(j),' is missing.',...
                            char(10),'       Have samples been filled and normalized?']);
                  
                    else
                        throw exception
                    end
                    
                end
                
                verbosePrint(['   Meta Constraint #: ',num2str(j),...
                    ' Cost: ' num2str(tempCost),'   ',obj.metaConstraints{j}.name], ...
                        'sos_initCost_indivMetaCost');
               metaConstraintCost = metaConstraintCost + tempCost; 
            end
            
            verbosePrint(['Meta Constraint Total: ', num2str(metaConstraintCost)], ...
                        'sos_initCost_totalMetaCost');            
            
            
            cost = softConstraintCost + metaConstraintCost;
            obj.cost=cost;
            
            verbosePrint([char(10),'TOTAL COST (soft + meta): ', num2str(cost), char(10)], ...
                'sos_initCost_totalSoftMetaCost');             
        end
        
        %% dispCost() METHOD
        function cost = dispCost(obj)
            %reports hard/soft/meta cost contraints

            verbosePrint([char(10),'Displaying Constraint Costs',char(10)],...
                'sos_dispCost_start');
            
            % hard constraints
            hardConstraintCost = 0;

            for j = 1:length(obj.hardConstraints)
                tempCost = obj.hardConstraints{j}.cost;    
                verbosePrint(['   Hard Constraint #: ',num2str(j),...
                    ' Cost: ' num2str(tempCost),'   ',obj.hardConstraints{j}.name], ...
                        'sos_dispCost_indivHardCost');
                hardConstraintCost = hardConstraintCost + tempCost;
            end
            
            verbosePrint(['Hard Constraint Total: ', num2str(hardConstraintCost)], ...
                        'sos_dispCost_totalHardCost');
                    
            % soft constraints        
            softConstraintCost = 0;
            
           
            for j=1:length(obj.softConstraints)
                tempCost = obj.softConstraints{j}.cost;    
                verbosePrint(['   Soft Constraint #: ',num2str(j),...
                    ' Cost: ' num2str(tempCost),'   ',obj.softConstraints{j}.name], ...
                        'sos_dispCost_indivSoftCost');
               softConstraintCost = softConstraintCost + tempCost; 
            end

            
            
            verbosePrint(['Soft Constraint Total: ', num2str(softConstraintCost)], ...
                        'sos_dispCost_totalSoftCost');
            
            % meta constraints
            metaConstraintCost = 0;
            
           
            for j=1:length(obj.metaConstraints)
                tempCost = obj.metaConstraints{j}.cost;    
                verbosePrint(['   Meta Constraint #: ',num2str(j),...
                    ' Cost: ' num2str(tempCost),'   ',obj.metaConstraints{j}.name], ...
                        'sos_dispCost_indivMetaCost');
               metaConstraintCost = metaConstraintCost + tempCost; 
            end

            
            verbosePrint(['Meta Constraint Total: ', num2str(metaConstraintCost)], ...
                        'sos_dispCost_totalMetaCost');            
            
            
            cost = softConstraintCost + metaConstraintCost;
            %obj.cost=cost;
            
            verbosePrint([char(10),'TOTAL COST (soft + meta): ', num2str(cost), char(10)], ...
                'sos_dispCost_totalSoftMetaCost'); 
            
            if isnan(cost)
                verbosePrint([char(10), ...
                    'Warning: Cost was NaN.  This should not happen if cost terms ',...
                    char(10),'         are present and cost has been initialized',...
                    char(10)], 'sos_dispCost_warnCostNaN');
            end
            
        end %dispCost        

        %% setAnnealSchedule(varargin) METHOD
        function setAnnealSchedule(obj,varargin)
            % sets the anneal schedule for the SOS object
            %
            % PARAMETERS:
            % Required:
            % 'schedule'/scheduleName - param/value pair indicating the name of the anneal schedule to use.  Defaults to greedy'
            %
            % Optional:
            %  - As required by specific schedule to create.  See its
            %  constructor for details.
            
            p = inputParser;
            p.addRequired('obj', @(obj)strcmp(class(obj),'sos'));
            p.addParamValue('schedule','greedy', ...
                @(schedule)ischar(schedule));            
            p.KeepUnmatched = true;
            
            % in case no parameters are passed to varargin, must make the
            % following decision
            if(isempty(varargin) == false)
                 p.parse(obj,varargin{:});
            else
                p.parse(obj);
            end
            
            scheduleName = p.Results.schedule;
             
            if any(strcmp(p.UsingDefaults,'schedule'))
                verbosePrint(['    Defaulting to ', scheduleName, ' annealing...'], ...
                    'sos_setAnnealSchedule_defaultAnneal'); 
            end
            
           if(strcmp(scheduleName, 'greedy') == 1)
               obj.annealObj = greedyAnneal(varargin{:});
           elseif (strcmp(scheduleName, 'exp') == 1)
                obj.annealObj = expAnneal(varargin{:});
           else
               error(['There is no schedule named: ' schedule])
           end                 
        end
            
        
        %% setSampleCandidateSelectionMethod(methodName) METHOD
        function setSampleCandidateSelectionMethod(obj,methodName)
            % sets the sample Candidate selection method
            %
            %PARAMETERS:
            % Name of a sampleCandidateSelectionMethod
            
            if (ischar(methodName) == false) 
                error('{methodName} must be a string');
            end   
            
           if (strcmp(methodName, 'random') == 1)
                obj.sCandObj = randSampleCandidateSelection(obj);
           else
               error(['Specified methodName ',methodName,' does not exist']); 
           end
        end
        
        
        %% setFeederdfCandidateSelectionMethod(obj,methodName)
        function setFeederdfCandidateSelectionMethod(obj,methodName)
            % sets the feeder candidate selection method
            %
            %PARAMETERS:
            % name of a feederCandidateSelectionMethod
            
            if (ischar(methodName) == false) 
                error('{methodName} must be a string');
            end   
            
           if (strcmp(methodName, 'randomPopulation') == 1)
                obj.feederCandObj= randPopulationCandidateSelection();
                obj.feederdfCandSelectMethod = methodName;
           elseif (strcmp(methodName, 'randomPopulationAndSample') == 1)
                obj.feederCandObj= randPopulationAndSampleCandidateSelection(obj);
                obj.feederdfCandSelectMethod = methodName;
           else
                error('Specified {methodName} does not exist'); 
           end
            
        end
        
         %% setpSwapFunction(methodName) METHOD
         function setpSwapFunction(obj,swFunctionName)
             %sets the pSwap function for the sos obj.  
             %
             %PARAMETERS: 
             %  swFunctionName - name of swap function.  Currently, 'logicistic' is the only supported function.  

            if (ischar(swFunctionName) == false) 
                error('SOS:setSwapFunction {swFunctionName} is not a valid string');
            end   
            
           if (strcmp(swFunctionName, 'logistic'))
                obj.pSwapObj = logisticpSwapFunction();
           else
                error('SOS:setpSwapFunction: specified function does not exist');
           end            
        end %setpSwapFunction
        
        
        %% optimize() METHOD
        function goodEnding = optimize(obj,varargin)
            % Optimizes samples based on specified constraints
            %
            % PARAMETERS
            %   numIt - number of iterations to run (otherwises uses
            %           default from obj init)
            %   'isGui' / 1 or 0 - flag denoting whether there is an active gui or not
            % RETURNS:
            %   1 if ended because statistical constraints reached, zero
            %   otherwise
            
            % It would be possible to seperate the normalization and
            % costInitialization procedures so that they need not be run
            % every time you begin optimizing.  In fact, the current code
            % probably enforces such a constraint and should generate an
            % error if normalization is attempted anyways.  Nevertheless,
            % it costs little to enforce it at this point in time given
            % that most time should be spent trying to make swaps, so it's
            % left that way in this version of the code.  In the future, it
            % may be useful to avoid any possible redundancy here, and also
            % consider adding the fillSamples() command to the
            % pre-optimization procedure.
               
            verbosePrint(['Setting up optimization procedure...', ...
                        char(10)], 'sos_optimize_begin');    
            
            
            %get all parameters passed to the alogirthm
            
            p = inputParser;
            p.addOptional('numIt',-1);
            p.addParamValue('isGui',NaN);
            p.parse(varargin{:});
            
            if any(strcmp(p.UsingDefaults,'numIt'))
                % do nothing, allow defaults to be used
            else
                numIt = p.Results.numIt;
                validateattributes(numIt, {'numeric'}, ...
                    {'scalar', 'integer', 'positive', '>', 0})
                obj.maxIt = obj.curIt + numIt; 
                obj.oldNumIt = numIt;
            end
            
            if any(strcmp(p.UsingDefaults,'isGui'))
                % do nothing, no gui
                isGui = 0;
            else
                isGui = p.Results.isGui;
                
                if isGui == 1
                    mainWindowHandle = sos_gui; %this connects/ launches the gui
                    mainWindowData = guidata(mainWindowHandle);
                    set(mainWindowData.pushbutton_stopOptimize,'UserData',0)
                elseif isGui == 0
                    % do nothing
                else
                    error('isGui should be a flag with value 1 or 0).');
                end
            end
            
             
            % flag indicating whether the optimization should be
            % stopped or not, as inidicated in the GUI
            stopOptimize = 0;
                    
            goodEnding = 0;
            
            % make sure that there are samples linked with the object
            % before running.  
            
            if isempty(obj.samples) 
                error('Cannot start optimization - there are no samples to optimize');
            end
            
           if isempty(obj.pSwapObj) 
                error('Cannot start optimization - the annealing schedule must be set (e.g., greedy, exp)');
            end
            
            % next, make sure that all of the samples have been filled.  
            
            for i=1:length(obj.samples)
                if isempty(obj.samples(i).data)
                    error(['Cannot start optimization - sample ''',...
                        obj.samples(i).name,''' is empty']);
                elseif length(obj.samples(i).data{1}) < obj.samples(i).n
                    error(['Cannot start optimization - sample ''',...
                        obj.samples(i).name,''' is missing items.  Did you initFillSamples()?']);
                end
            end
              
            
            if(obj.curIt == obj.maxIt)
                obj.maxIt = obj.maxIt+obj.oldNumIt;
            elseif obj.curIt > obj.maxIt
                error('Cannot start Optimization - curIt should never be greater than maxIt.  Increase by <SOSobj>.maxIt = <larger val>?');
            end
                    
            
            if(obj.curFreezeIt == obj.stopFreezeIt)
                obj.curFreezeIt = 0;
                verbosePrint('curFreezeIt was at maximum value at start of optimization; resetting to 0', ...
                'sos_optimize_resetFreezeIt');
            end
            
            obj.normalizeData();
            obj.initCost();
 
            % set up the sample and neighbor replacement methods
            obj.setSampleCandidateSelectionMethod(obj.targSampleCandSelectMethod);
            obj.setFeederdfCandidateSelectionMethod(obj.feederdfCandSelectMethod);
            
            
            
            verbosePrint(['Optimizing for ', num2str(obj.maxIt-obj.curIt), ' iterations'], ...
                'sos_optimize_startOptimization');
            
            tStart = tic;
            startIt = obj.curIt;
            allStatsPass = NaN;
            
            reportHeader = [char(10), ' Iteration              Cost  %Complete       Elapsed   Remaining'];
            verbosePrint(reportHeader,'sos_optimize_reportHeader');
            
            while obj.curIt<obj.maxIt && ...
                    obj.curFreezeIt < obj.stopFreezeIt && ...
                    allStatsPass ~= 1 && ...
                    stopOptimize == 0
                obj.curIt=obj.curIt+1;
               
                if mod(obj.curIt,obj.reportInterval) == 0  || obj.curIt == 1
                    obj.doReport(tStart,startIt);
                     obj.doStatTests('reportStyle','none');
                    
                    if isempty(obj.histObj) == 0
                        %updatePlots
                        pFlip = obj.nFlip/obj.reportInterval;
                        obj.updateHistory(obj.curIt,obj.cost,...
                              obj.deltaCost,pFlip,obj.annealObj.getTemp());
                        obj.nFlip = 0;
                        
                        if isempty(obj.plotObj) == 0
                            obj.updatePlots();
                        end
                    end
                end
                          
                
                %select items to swap
                [targSample,targSampleIndex] = obj.sCandObj.getCandidateIndex(); 
                [feederdf, feederdfIndex] = obj.feederCandObj.getCandidateIndex(targSample);
                

                % check to see how swap fares with regard to hard
                % constraints.  Abort swap if it would lead to an
                % (increased) violation of hard constraints.  
                sumHardswCost = obj.checkHardConstraintsSwapping(...
                       targSample,targSampleIndex,feederdf, feederdfIndex);
                
                %if hard constraint was not violated or improved continue.
                %A value < 0 indicates that hard constraint was improved so
                %there will be a swap no matter what the soft cost.
                if sumHardswCost <= 0 
                   curCost = obj.cost;
                       
                    sumSoftswCost = obj.checkSoftConstraintsSwapping(...
                       targSample,targSampleIndex,feederdf, feederdfIndex);
                   
                    sumMetaswCost = obj.checkMetaConstraintsSwapping(...
                       targSample,targSampleIndex,feederdf, feederdfIndex);
                    
                    swCost = sumSoftswCost + sumMetaswCost;
                    %sign flipped so that if swCost < curCost, we get a
                    %negative value, and negative values descend in cost
                    %space
                    
                    deltaCost = -1*(curCost - swCost); %#ok<PROP>
                    
                    % if a swap is possible based on hard constraints, but
                    % not necessary, base decision to swap on soft
                    % constraints
                    if sumHardswCost == 0
                        shouldSwap = obj.pSwapObj.shouldSwap(...
                            deltaCost,obj.annealObj.getTemp()); %#ok<PROP>
                        
                        obj.deltaCost = deltaCost; %#ok<PROP>
                        
                        
                        
                    else %swap is necessary based on hard constraints.  
                        shouldSwap = 1;
                        
                    end
                    
                    if shouldSwap == 1
                        
                        obj.nFlip = obj.nFlip + 1;
                        
                        
                        %we need to swap items
                        targSample.swapItems(...
                        targSampleIndex,feederdf, feederdfIndex,obj);

                        %update constraints
                        for j = 1:length(obj.hardConstraints)
                            obj.hardConstraints{j}.acceptSwap();
                        end

                        for j=1:length(obj.softConstraints)
                            obj.softConstraints{j}.acceptSwap();
                        end

                        for j=1:length(obj.metaConstraints)
                            obj.metaConstraints{j}.acceptSwap();
                        end

                        % see if the set is frozen
                        if sumHardswCost < 0
                            obj.curFreezeIt = 0;
                        elseif obj.cost ~= swCost
                            obj.curFreezeIt = 0;
                        else % we're swapping items with the same cost
                            obj.curFreezeIt = obj.curFreezeIt +1;
                        end
                        
                        obj.cost = swCost;
                    else
                        % reject the swap:
                        for j = 1:length(obj.hardConstraints)
                            obj.hardConstraints{j}.rejectSwap();
                        end

                        for j=1:length(obj.softConstraints)
                            obj.softConstraints{j}.rejectSwap();
                        end

                        for j=1:length(obj.metaConstraints)
                            obj.metaConstraints{j}.rejectSwap();
                        end
                        
                        obj.curFreezeIt = obj.curFreezeIt + 1;
                        
                    end
                else
                    for j = 1:length(obj.hardConstraints)
                            obj.hardConstraints{j}.rejectSwap();
                    end
                    
                    obj.curFreezeIt = obj.curFreezeIt + 1;
                end
                %on some subset of the intervals, display relevant
                %statistics.  
                
                %mod indexing needed to have deltaCostLog loop after
                %blockSize updates.  
                obj.deltaCostLog(mod(obj.curIt-1,obj.blockSize)+1) = obj.deltaCost;
                
                        
                obj.annealObj.anneal(obj.curIt,obj.cost,obj.deltaCost);
                
                % see if stats constraint has been met
                if mod(obj.curIt,obj.statInterval) == 0
                    allStatsPass = ...
                        obj.doStatTests('reportStyle',obj.statTestReportStyle);
                    verbosePrint(reportHeader,'sos_optimize_reportHeader');
                end
                
                %see if GUI interrupt has been requested
                if isGui
                    % check to see if the stop button has been pressed
                    % every so often.  This should not be done too
                    % frequently as the drawnow event could take some time.
                    if mod(obj.curIt,obj.queryStopOptimize) == 0
                        drawnow;
                        if  get(mainWindowData.pushbutton_stopOptimize,'UserData') ~= 0
                            stopOptimize = 1;
                        end
                    end
                end
                
                
            end %end iterations
            
            %avoid a redundant report
            if mod(obj.curIt,obj.reportInterval) ~= 0 && obj.curIt ~= 1
                obj.doReport(tStart,startIt);
                obj.doStatTests('reportStyle','none');
                
                if isempty(obj.histObj) == 0
                    %updatePlots
                    pFlip = obj.nFlip/obj.reportInterval;
                    obj.updateHistory(obj.curIt,obj.cost,...
                          obj.deltaCost,pFlip,obj.annealObj.getTemp());
                    obj.nFlip = 0;

                    if isempty(obj.plotObj) == 0
                        obj.updatePlots();
                    end
                end
            end
            
            if mod(obj.curIt,obj.statInterval) ~= 0
                    allStatsPass = ...
                        obj.doStatTests('reportStyle',obj.statTestReportStyle);
            end
             
            % state the reason why optimization was stopped
           if (allStatsPass == 1)
                verbosePrint([[char(10), 'Optimization ended after all statistical tests passed defined criteria', char(10)], ...
                        char(10)], 'sos_optimize_endallStatsPass');
                goodEnding = 1;
           elseif obj.curIt == obj.maxIt
                verbosePrint([char(10), 'Optimization ended after reaching the maximum number of iterations', ...
                        char(10)], 'sos_optimize_endMaxIt');
           elseif obj.curFreezeIt >= obj.stopFreezeIt
                verbosePrint([char(10), 'Optimization ended after cost value was frozen for specified number of iterations', ...
                        char(10)], 'sos_optimize_endstopFreezeIt');
           elseif isGui
               if get(mainWindowData.pushbutton_stopOptimize,'UserData') == 1
               verbosePrint([char(10),'Optimization ended after user interrupt (from graphical interface)',...
                        char(10)],'sos_optimize_endUserGuiInterrupt');
               end
           end

            if isGui == 1
                mainWindowHandle = sos_gui; %this connects/ launches the gui
                mainWindowData = guidata(mainWindowHandle);
                set(mainWindowData.pushbutton_optimize,'Enable','on')
                set(mainWindowData.pushbutton_stopOptimize,'Enable','off')
            end
                    
        end
        
        
        %% doReport (obj,tstart) METHOD
        function doReport(obj,tStart,startIt)
            % displays a progress report from the last iteration in optimization
            % 
            %PARAMETERS:
            %   tStart - tic() object indicating start of optimization

            percentComplete = (obj.curIt/obj.maxIt)*100;
            elapsedTime = toc(tStart);
            
            startPercent = (startIt/obj.maxIt)*100;
            
            remainingTime = (elapsedTime/ ...
               (percentComplete-startPercent))*(100-startPercent)-elapsedTime;     
            
            hElapsedTime = seconds2human(elapsedTime,'full');
            tempLen = length(hElapsedTime);
            hElapsedTime = strjust([blanks(8-tempLen) hElapsedTime],'right');

            hRemainingTime = seconds2human(remainingTime,'full');
            tempLen = length(hRemainingTime);
            hRemainingTime = strjust([blanks(8-tempLen) hRemainingTime],'right');


            report = sprintf('%9.0f) \t %15.5f \t %5.2f%% \t %s \t %s', ...
                    obj.curIt,obj.cost,percentComplete, ...
                    hElapsedTime,hRemainingTime);
            verbosePrint(report, 'sos_optimize_report');

        end
        
        %% createPlots() METHOD
        function createPlots(obj,dispIt)
            % creates plots for several optimization parameters, as
            % follows:
            %   - cost
            %   - deltaCost
            %   - sosStatTestpvals
            %   - temperature
            %   - pFlipHistory
            %
            % PARAMETERS:
            %   dispIt - number of iterations to show on the plot screen.
            %       All other datapoints plotted since the creation of the
            %       object will still be accessible by scrolling the x-axis
            
            
            if isempty(obj.histObj)
                obj.createHistory();
            end
            
            if exist('dispIt','var') == 0
                dispIt = 100000;
            else
                validateattributes(dispIt, {'numeric'}, ...
                {'scalar', 'integer', 'positive', '>', 0});
            end
                
                           
            if isempty(obj.plotObj)            
                obj.plotObj = sosPlots(obj,obj.histObj,dispIt, ...
                                        obj.curIt);
            else
                verbosePrint('Warning: Plots already exist so cannot be created',...
                    'sos_createPlots_alreadyCreated');
            end            
        end
        
        %% updatePlots() METHOD
        function updatePlots(obj)
            %updates the contents of the plot
            
            obj.plotObj.updatePlots();
            
        end

        
        %% createHistory() METHOD
        function createHistory(obj)
            % creates plots for several optimization parameters, as
            % follows:
            %   - cost
            %   - deltaCost
            %   - sosStatTestpvals
            %   - temperature
            %   - pFlipHistory
            
            if isempty(obj.histObj)
            
                obj.histObj = sosHistory(obj);
            else
                verbosePrint('Warning: History already exists so cannot be created',...
                    'sos_createHistory_alreadyCreated');
            end
            
        end

        
        %% updateHistory() METHOD
        function updateHistory(obj,curIt,cost,deltaCost,pFlip,temp)
            %updates the contents of the plot
            
            % get the information about the p-vals.  
            testNames = {};
            testps = [];
            
            for i=1:length(obj.sosstattests)
                testNames = horzcat(testNames,obj.sosstattests{i}.label); %#ok<AGROW>
                testps = horzcat(testps,obj.sosstattests{i}.lastp); %#ok<AGROW>
            end
            
            obj.histObj.updateHistory(curIt,cost,deltaCost,pFlip, ...
                            testNames,testps,temp);
            
        end
        
        %% function writeHistory(outFile) METHOD
        function writeHistory(obj,outFile)
            %writes all history saved to date to file 'outFile'            
                
             if exist('outFile','var') == 0
                 error('"Outfile" argument was not supplied to writeHistory()');
             end
             
             if(ischar(outFile) == false)
                error('Outfile has not been set to a string != "null".');
             end
    
            if isempty(obj.histObj) == 0
                obj.histObj.writeHistory(outFile);
            else
                error('No saved history to write - did you run createHistory() before optimizing?');
            end
        end
        
        %% setbufferedHistoryOutfile(outFile) METHOD
        function setBufferedHistoryOutfile(obj,outFile)
            % writes the history on-line, one update at a time, to outfile
            % If outfile exists, it will be overridden.
            
            if exist('outFile','var') == 0
                error('"Outfile" argument was not supplied to writeHistory()');
            end

            if(ischar(outFile) == false)
                error('Outfile has not been set to a string != "null".');
            end

            if ischar(outFile) == false || strcmp(outFile,'null')
                error('Outfile has not been set to a string != "null".');
            end
            
            if isempty(obj.histObj) == 0
                obj.histObj.setBufferedHistoryOutfile(outFile);
            else
                error('No saved history to write - did you start recording history with createHistory()?');
            end                                    
        end

        %% enableBufferedHistoryWrite() METHOD
        function enableBufferedHistoryWrite(obj)
            % enables writing of buffered history.  Enabled automatically
            % when bufferedHistoryWrite is first called; cannot be called
            % until that method has first been called to specify an
            % outfile.  Subsequent enablings continue to write to that
            % file.
            
            if isempty(obj.histObj) == 0
                obj.histObj.enableBufferedHistoryWrite();
            else
                error('History is not being recorded so buffered writing cannot be enabled - run createHistory() first');
            end     
        end
        
        %% disableBufferedHistoryWrite() METHOD
        function disableBufferedHistoryWrite(obj)
            % disables writing of buffered history.  
            
            if isempty(obj.histObj) == 0
                obj.histObj.disableBufferedHistoryWrite();
            else
                error('History is not being recorded so buffered writing cannot be disabled - run createHistory() first');
            end     
        end
        
        
        %% writeSamples()  METHOD
        function writeSamples(obj)
           % writes the data from the samples to text files specified in their 'outFile' property
           
           verbosePrint('Writing all samples to disk...',...
                            'sos_writeSamples_begin');
           
           for i=1:length(obj.samples)
               obj.samples(i).writeData();
           end
        end %writeSamples()
        
        %% writePopulations()  METHOD
        function writePopulations(obj)
           % writes the data from the populations to text files specified in their 'outFile' property
           
           verbosePrint('Writing all populations to disk...',...
                            'sos_writePopulations_begin');
           
           alreadyWritten = {};
           popWritten = 0;
           
           for i=1:length(obj.samples)
               if isempty(alreadyWritten)
                   popWritten = 0;
               else
                for j = 1:length(alreadyWritten)
                    if (alreadyWritten{j} == obj.samples(i).population)
                        popWritten = 1;
                    end
                end
               end
               
               if(popWritten == 0)
                obj.samples(i).population.writeData();
                alreadyWritten = [alreadyWritten {obj.samples(i).population}]; %#ok<AGROW>
               end
           end
        end %writeSamples()        
            
        %% writeAll() METHOD
        function writeAll(obj)
            %write all populations and samples associated with SOS object to disk
            obj.writeSamples();
            obj.writePopulations();
            
        end % writeAll()
        
        %% addttest(sample1, sample2, s1ColName, s2ColName, type) METHOD
        function addttest(obj, varargin)
                %adds a t-test to the list of analyses to run
                newTest = genericStatTest.createStatTest('ttest','sosObj',obj,varargin{:});
                obj.sosstattests = [obj.sosstattests {newTest}];   
                
                % if there is a history object at work, let it know that a
                % new stat test has been added.  
                if isempty(obj.histObj) == 0
                    obj.histObj.addStatTestName(newTest.name);
                end
                
             verbosePrint('t-test added...',  ...
                    'sos_addttest_end');    
        end
        
        %% addtzest(sample1, sample2, s1ColName, s2ColName, type, ...) METHOD
        function addztest(obj, varargin)
                %adds a z-test to the list of analyses to run
                
                % NOTE: If additional, more general types of z-tests are
                % added, this will need to be conditionalized so that
                % sosCorrelTest is not chosen by default...
                newTest = genericStatTest.createStatTest('matchCorrel','sosObj',obj,varargin{:});
                obj.sosstattests = [obj.sosstattests {newTest}];   
                
                % if there is a history object at work, let it know that a
                % new stat test has been added.  
                if isempty(obj.histObj) == 0
                    obj.histObj.addStatTestName(newTest.name);
                end
                
             verbosePrint('z-test added...',  ...
                    'sos_addztest_end');    
        end        

        
        %% addtzest(sample1, sample2, s1ColName, s2ColName, type, ...) METHOD
        function addkstest(obj, varargin)
                %adds a kstest to the list of analyses to run
                
                % NOTE: If additional, more general types of kstests are
                % added, this will need to be conditionalized so that
                % sosCorrelTest is not chosen by default...
                newTest = genericStatTest.createStatTest('matchUniform','sosObj',obj,varargin{:});
                obj.sosstattests = [obj.sosstattests {newTest}];   
                
                % if there is a history object at work, let it know that a
                % new stat test has been added.  
                if isempty(obj.histObj) == 0
                    obj.histObj.addStatTestName(newTest.name);
                end
                
             verbosePrint('ks-test added...',  ...
                    'sos_addkstest_end');    
        end    
        
        
        
        function pass = doStatTests(obj,varargin)
            % runs the stat tests and indicates if all passed the user
            % hypotheses.  
            %
            %PARAMETERS:
            %   'reportStyle'/'short'|'full' - style of report to be printed.
            %                               Either short or long
            %
            % RETURNS:
            %   NaN if user had no hypotheses about any of the tests that
            %   were run.  1 if there were hypotheses and all hypotheses
            %   passed their tests.  0  otherwise.  
            
           p = inputParser;            
           p.addParamValue('reportStyle','short', ...
                    @(reportStyle)any([strcmp(reportStyle,'short') ...
                                    strcmp(reportStyle,'full') ...
                                    strcmp(reportStyle,'none')]));
           p.parse(varargin{:});
           
           if strcmp(p.Results.reportStyle,'none') == 0
                verbosePrint([char(10),'Running all stat tests:'],...
                            'sos_doStatTests_begin');            
           end              
            pass = NaN;
            
            % 
            
            
            for i=1:length(obj.sosstattests)
                userHypothesis = obj.sosstattests{i}.runTest(varargin{:});
                
                if userHypothesis == 0
                    pass = 0;
                % if a hypothesis passes (as opposed to being NaN), set the
                % condition to pass;  If a hypothesis has already failed,
                % it cannot pass
                elseif userHypothesis == 1 && isnan(pass)
                    pass = 1;
                end
            end
        end % doStatTests
        
        %% function deltaCostPercentiles() METHOD
        function deltaCostPercentiles(obj)
            % displays the breakdown of deltaCost values per decile and
            % other important percentiles
            
            %one over 100 so that we get the 100th decile
            deciles = 0:10:101;
            scores = prctile(obj.deltaCostLog, deciles);
            
            %let the user know how many observations entered into the delta
            %cost report
            verbosePrint(['Deciles for deltaCost in last block:',char(10), ...
                '(',num2str(min(length(obj.deltaCostLog),obj.curIt)),...
                ' iterations total; numIt < blockSize in first block)',char(10)], ...
                        'sos_deltaCostPercentiles_Header');
                    
                    
           values = '';
           for i=1:length(deciles)
               line=sprintf('\t%1.0f:  \t %+10.8f \n',deciles(i),scores(i)); 
               values = [values line]; %#ok<AGROW>
           end 
               
           verbosePrint(values, 'sos_deltaCostPercentiles_Scores');
             
           
           %print out information that could be helpful for configuring the
           %expAnneal function
           
           percentiles = [2.5 97.5];
           scores = prctile(obj.deltaCostLog, percentiles);
                
           deltaCost95 = scores(2) - scores(1);
           
           msg = sprintf('\n\n 97.5th - 2.5th percentile deltaCost: %10.8f\n\n', ...
                        deltaCost95);
                    
           verbosePrint(msg, 'sos_deltaCostPercentiles_deltaCost95');
                
             
        end
        
    end %end methods
    
    methods (Static)
        
        %% p = sosInputParser() STATIC METHOD
        function p = sosInputParser()
            % returns an input parser for the sos constructor args
            %
            %CALL: 
            % p = sos.sosInputParser()
            %
            %SYNOPSIS:
            % returns an input parser for the sos constructor args
            %
            %PARAMETERS:
            %   Same as object constructor
            %
            %EXAMPLE:
            % p = sos.sosInputParser()
            %
            
             p = inputParser;

             %use NaN as null, since matlab doesn't support standard
             %NULL
             
             p.addParamValue('maxIt',  sos.maxIt_def, ...
                @(maxIt)validateattributes(maxIt, {'numeric'}, ...
                {'scalar', 'integer', 'positive', '>', 0}));
            p.addParamValue('pSwapFunction',sos.pSwapFunction_def, ...
                @(pSwapFunction)ischar(pSwapFunction));
            p.addParamValue('targSampleCandSelectMethod',sos.targSampleCandSelectMethod_def, ...
                @(targSampleCandSelectMethod)ischar(targSampleCandSelectMethod));
            p.addParamValue('feederdfCandSelectMethod',sos.feederdfCandSelectMethod_def, ...
                @(feederdfCandSelectMethod)ischar(feederdfCandSelectMethod));
            p.addParamValue('reportInterval',sos.reportInterval_def, ...
                @(reportInterval)validateattributes(reportInterval, {'numeric'}, ...
                {'scalar', 'integer', 'positive', '>', 0}));
            p.addParamValue('stopFreezeIt',sos.stopFreezeIt_def, ...
                @(stopFreezeIt)validateattributes(stopFreezeIt, {'numeric'}, ...
                {'scalar', 'integer', 'positive', '>', 0}));
            p.addParamValue('statInterval',sos.statInterval_def, ...
                @(statInterval)validateattributes(statInterval, {'numeric'}, ...
                {'scalar', 'integer', 'positive', '>', 0})); 
            p.addParamValue('statTestReportStyle',sos.statTestReportStyle_def, ...
                @(statTestReportStyle)any( ...
                    [strcmp(statTestReportStyle,'short'), ...
                     strcmp(statTestReportStyle,'full')]));
            p.addParamValue('blockSize',sos.blockSize_def, ...
                @(statInterval)validateattributes(statInterval, {'numeric'}, ...
                {'scalar', 'integer', 'positive', '>', 0})); 
            
      
        end
    end
    
    methods (Static, Access = private)
        %% parseConstructorArgs PRIVATE STATIC METHOD
        function p = parseConstructorArgs(varargin)
            %parses the constructor arguments
            %
            % CALL:
            % p = sos.parseConstructorArgs(varargin);
            %
            %parses the arguments from the  constructor.  Default
            %values are substituted where appropriate.  Returns a struct
            %with the parsed args
            % 
            %PARAMETERS:
            % SAME as sos CONSTRUCTOR
            %
            %RETURNS:
            %    p - parsed constructor input
            
             varargin = varargin{1};

             p = sos.sosInputParser();
             p.parse(varargin{:});
             
             if any(strcmp(p.UsingDefaults,'maxIt'))
                 verbosePrint(['    Defaulting to ',  ...
                     num2str(p.Results.maxIt), ' maximum iterations'], ...
                    'sos_parseConstructor_defaultMaxIt');
             end
             
             if any(strcmp(p.UsingDefaults,'pSwapFunction'))
                 verbosePrint(['    Defaulting to ', ...
                     (p.Results.pSwapFunction), ' pSwapFunction'], ...
                    'sos_parseConstructor_pSwapFunction');                         
             end

             if any(strcmp(p.UsingDefaults,'targSampleCandSelectMethod'))
                 verbosePrint(['    Defaulting to ', ...
                     (p.Results.targSampleCandSelectMethod), ...
                     ' targSample Candidate Selection Method'], ...
                    'sos_parseConstructor_targSampleCandSelectMethod');      
             end
             
             if any(strcmp(p.UsingDefaults,'feederdfCandSelectMethod'))
                 verbosePrint(['    Defaulting to ', ...
                     (p.Results.feederdfCandSelectMethod), ...
                     ' feederdf Candidate Selection Method'], ...
                    'sos_parseConstructor_feederdfCandSelectMethod');      
             end
             
             if any(strcmp(p.UsingDefaults,'reportInterval'))
                 verbosePrint(['    Defaulting to ', ...
                     num2str(p.Results.reportInterval), ...
                     ' iterations between reports'], ...
                    'sos_parseConstructor_reportInterval');      
             end
             
             if any(strcmp(p.UsingDefaults,'stopFreezeIt'))
                 verbosePrint(['    Defaulting to ', ...
                     num2str(p.Results.stopFreezeIt), ...
                     ' of same frozen cost before stopping'], ...
                    'sos_parseConstructor_stopFreezeIt');      
             end
             
             
             if any(strcmp(p.UsingDefaults,'statInterval'))
                 verbosePrint(['    Defaulting to ', ...
                     num2str(p.Results.statInterval), ...
                     ' intervals between stat reports'], ...
                    'sos_parseConstructor_statReports');      
             end
             
             if any(strcmp(p.UsingDefaults,'statTestReportStyle'))
                 verbosePrint(['    Defaulting to ', ...
                     p.Results.statTestReportStyle, ...
                     ' style stat reports'], ...
                    'sos_parseConstructor_statReports');      
             end             
                         
        end % parseConstructorArgs
    end        
    
end