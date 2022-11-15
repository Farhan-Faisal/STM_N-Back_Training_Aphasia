% - parent class for soft distance constraints
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


classdef softDistanceConstraint < softConstraint
    %% creates and supports soft distance constraints
    %
    % This class creates softDistanceConstraint objects that measure the
    % cost (in terms of minimizing or maximizing a distance of a particular stat) 
    % associated with the current items in a set, and subsequent to
    % swapping a particular item with another items.  
    % 
    % Additional functionality and interface requirements are inherited
    % from softConstraint.
    %
    % Currently allows for the following:
    %
    %   min/max/OrderedMax of Group Means, Paired means, Group Stdev,
    %   Paired Stdev, Matching Mean to target, Matching stdev to target
    %       
    %
    %PROPERTIES
    %     stat % the statistic to calculate
    %     paired - logical indicating if paired differences or group differences are bieng used
    %     comparison - handle to specific comparison calculator
    %     initStats % handle to global stat initialization method
    %     swStats % handle to local stat update method
    %     acceptsw % handle to local accept swap method
    %     rejectsw % handle to local reject swap method
    %     s1 - sample1
    %     s2 - sample2
    %     s1Col - s1 column index
    %     s2Col - s2 column index
    %     s1ColName - name of column in s1
    %     s2ColName - name of column in s2
    %     stat1 - current stat of sample 1
    %     stat2 - current stat of sample2
    %     swstat1 - stat of sample 1 if swap occurs
    %     swstat2 - stat of sample2 if swap occurs
    %     sumx1sq % sum of the squared values, x, in an array.  Used in stdev calculation
    %     meanx1 % square of the mean value of x in an array.  Used in stdev calculation
    %     swpsumx1sq % swap sum of the squared values, x, in an array.  Used in stdev calculation
    %     swpmeanx1 % swap square of the mean value of x in an array.  Used in stdev calculation
    %     sumx2sq % sum of the squared values, x, in an array.  Used in stdev calculation
    %     meanx2 % square of the mean value of x in an array.  Used in stdev calculation
    %     swpsumx2sq % swap sum of the squared values, x, in an array.  Used in stdev calculation
    %     swpmeanx2 % swap square of the mean value of x in an array.  Used in stdev calculation
    %     targVal % target value to match for 1 sample-to-value matching
    %     zTargVal % normalized target value
    %
    %METHODS
    %   obj =softDistanceConstraint(varargin) - constructor
    %   obj = construct2SampleSoftDistanceConstraint(varargin) % creates a constraint object for cases wehre 2 samples are implicated.  
    %   obj = construct1SampleSoftDistanceConstraint(varargin)  % creates a constraint object for cases where 1 sample is implicated.  
    %   cost = initCost() - Calculates, saves, and returns the cost value for the currentitems in the sample. 
    %   swCost = swapCost(targSample,targSampleIndex, feederdf,feederdfIndex) - Calculates the new cost if items from targSample and feederdf were swapped.
    %   acceptSwap() - updates variables when the proposed swap is accepted 
    %   initGroupMeans() - calculates the means of the samples
    %   initPairedMeans() % prepares data for paired mean calculation
    %   initGroupStdev() %calculates the stdevs of the samples
    %   initPairedStdev() % prepares data for paired stdev calculation
    %   initSingleMeanandTarg()  % calculates the mean of the sample1 and sets the target as the target stat
    %   obj = initSingleStdevandtarg(obj) %calculates the stdevs of the samples
    %   swGroupMeans(targSample,targSampleIndex, feederdf,feederdfIndex) - Calculates the new (swap) means if items from targSample and feederd were swapped.
    %   swPairedMeans(targSample,targSampleIndex, feederdf,feederdfIndex) % Calculates the new (swap) means if items from targSample and  feederd were swapped.
    %   swGroupStdev(targSample,targSampleIndex, feederdf,feederdfIndex) % Calculates the new (swap) stdevs if items from targSample and feederd were swapped.
    %   swPairedStdev(targSample,targSampleIndex, feederdf,feederdfIndex) % Calculates the new (swap) stdev if items from targSample and feederdf were swapped.
    %   swSingleMean(targSample,targSampleIndex, feederdf,feederdfIndex) % Calculates the new (swap) mean if items from targSample and  feederd were swapped.
    %   swSingleStdev(targSample,targSampleIndex, feederdf,feederdfIndex)  % Calculates the new (swap) stdevs if items from targSample and feederd were swapped.
    %   cost = minDiff(x1,x2) -  cost function minimized by reduced differences on the statistic 
    %   cost = maxDiff(x1,x2) - cost function minimized by maximizing differences on the stat.  Many uses may want to use orderedMaxDiff, instead.    
    %   cost = orderedMaxDiff(x1,x2) - cost function minimized by maximizing a difference between the two groups that adheres to s1.stat < s2.stat cost function minimized by reduced differences on the statistic for paired groups
    %   acceptSwapMeans() % updates variables when the proposed swap is accepted for  means
    %   acceptSwapStdev()   % updates variables when the proposed swap is accepted for standard deviations
    %   cost = acceptSwap() % generic reject function
    %   rejectSwapMeans() % updates variables when swap is rejected
    %   rejectSwapStdev()  % updates variables when the proposed swap is rejected
    %
    %METHODS (Static)
    %   p = softDistanceConstraintInputParser2Sample() generates an input parser with parameter / value pairs and validators for the constructor args
    %
    %METHODS (Static, Access = private)
    %   p = parse2SampleConstructorArgs(varargin) - parses the constructor args for cases invovling 2 samples
    %   p = parse1SampleConstructorArgs(varargin)  % parses the constructor args for cases invovling 1 sample
    
    %% PROPERTIES
    properties
        stat % the statistic to calculate
        paired % logical indicating if paired differences or group differences are bieng used
        comparison % handle to specific comparison calculator   
        initStats % handle to global stat initialization method
        swStats % handle to local stat update method
        acceptsw % handle to local accept swap method
        rejectsw % handle to local reject swap method
        s1 % sample1
        s2 % sample2
        s1Col %s1 column index
        s2Col %s2 column index
        s1ColName % name of column in s1
        s2ColName % name of column in s2       
        stat1 % current stat of sample 1
        stat2 % current stat of sample2
        swstat1 % stat of sample 1 if swap occurs
        swstat2 % stat of sample2 if swap occurs    
        sumx1sq % sum of the squared values, x, in an array.  Used in stdev calculation
        meanx1 % square of the mean value of x in an array.  Used in stdev calculation
        swpsumx1sq % swap sum of the squared values, x, in an array.  Used in stdev calculation
        swpmeanx1 % swap square of the mean value of x in an array.  Used in stdev calculation
        sumx2sq % sum of the squared values, x, in an array.  Used in stdev calculation
        meanx2 % square of the mean value of x in an array.  Used in stdev calculation
        swpsumx2sq % swap sum of the squared values, x, in an array.  Used in stdev calculation
        swpmeanx2 % swap square of the mean value of x in an array.  Used in stdev calculation
        targVal % target value to match for 1 sample-to-value matching
        zTargVal % normalized target value
    end
    
    methods
        
        %% softDistanceConstraint CONSTRUCTOR
        function  obj = softDistanceConstraint(varargin)
            % Creates a softDistance Constraint object.  See the
            % constructors for the 2Sample and 1Sample case for additional
            % parameters
            
            
            %first, decide what type of object to create.  This will be
            %based on whether the desired function involves 2 means, or 1.
            p = inputParser;
            p.addParamValue('fnc','null', ...
                 @(fnc)any(strcmp({'min', 'max','orderedMax','match1SampleVal'},fnc)));
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            %cases involving 2 samples
            if any([strcmp(p.Results.fnc,'min'), ...
                    strcmp(p.Results.fnc,'max'), ...
                    strcmp(p.Results.fnc,'orderedMax')])
                obj = construct2SampleSoftDistanceConstraint(obj,varargin);
            % cases invovling 1 sample matched to a value
            elseif any(strcmp(p.Results.fnc,'match1SampleVal'))
                obj = construct1SampleSoftDistanceConstraint(obj,varargin);                
            else 
                error(['Could not create a soft constraint with <fnc>: ', ...
                        p.Results.fnc]);
            end
             
            obj.cost = NaN;
            obj.swCost = NaN;
               
            
            verbosePrint('Soft Distance Constraint has been created', ...
                    'softDistanceConstraint_Constructor_endObjCreation');
        end % constructor
        
        %% obj = construct2SampleSoftDistanceConstraint(varargin) METHOD
        function obj = construct2SampleSoftDistanceConstraint(obj,varargin)
            % creates a constraint object for cases where 2 samples are implicated. 
            % CONSTRUCTOR - Creates a softDistanceConstraint object
            %
            % CALL:
            % softDistanceConstraint(varargin<defined below>)
            %
            % PARAMETERS:
            % REQUIRED:
            %   'sosObj'/sos object - the SOS object the constraint will be linked to, and which contains the samples the constraint operates on.  
            %   'constraintType'/'soft' - the type of contraint - must be 'soft'
            %   'fnc'/'min'|'max'|'orderedMax' the distance function to create.  If orderedMax, s1 < s2 on the specified dimension
            %   'stat'/'mean'|'stdev' - the statistic to calculate the difference on
            %   'sample1'/sample - the first sample
            %   'sample2'/sample - the second sample
            %   's1ColName'/string - name of column in 1st sample
            %   's2ColName'/string - name of column in 2nd sample
            %   'paired'/logical - should pairwise or group level distances be calculated
            % OPTIONAL:
            %   'exponent'/numeric - defaults to 2 (quadratic difference)
            %   'weight'/numeric - defaults to 1 (equal weighting of all soft costs)
            %
            % EXAMPLE:
            % mySOS.addConstraint('sosObj',mySOS,'constraintType','soft', ...
            %   'fnc','min','stat','mean','sample1',s1,'sample2',s2,'s1ColName','Lg10WF', ...
            %   's2ColName','Lg10WF','exponent',2,'paired',false,'weight', 1);
            
                        
            p = softDistanceConstraint.parse2SampleConstructorArgs(varargin{:});
            
            if(p.Results.sosObj.containsSample(p.Results.sample1) == false)
                error('Cannot create soft distance constraint: sos Object does not contain the sample1');
            end
            
            if(p.Results.sosObj.containsSample(p.Results.sample2) == false)
                error('Cannot create soft distance constraint: sos Object does not contain sample2');
            end
            
            
            col1 = p.Results.sample1.colName2colNum(p.Results.s1ColName);           
            if(col1 == -1)
                error('Specified column name not found in sample1');
            end
            
            if(strcmp(p.Results.sample1.format{col1},'%f') == 0)
                error('Specified column is not of numeric (%f) format, so cannot use as hard bound');
            end           
                       
            col2 = p.Results.sample2.colName2colNum(p.Results.s2ColName);            
            if(col2 == -1)
                error('Specified column name not found in sample');
            end
            
            if(strcmp(p.Results.sample2.format{col2},'%f') == 0)
                error('Specified column is not of numeric (%f) format, so cannot use as hard bound; 2nd sample');
            end           
            
            %if the lengths are not going to be identical, do not run the
            %test if it is paired.  The init and swap methods will ensure
            %that if practically the data are NaN, the optimization will
            %stop.
            if(p.Results.paired == true)
                if length(p.Results.sample1.n) ~= length(p.Results.sample2.n)
                    error('Sample sizes must be equal if using paired matching');
                end
            end
            % Assign the comparison function appropriate for the constraint
            
            if(p.Results.paired ~= true & p.Results.paired ~= false)
                error('<paired> parameter must be either true/false (1/0)');
            end
            
            
            %ASSIGN HANDLE TO STAT CALCULATION METHOD
            if(strcmp(p.Results.stat,'mean') && p.Results.paired == false)
                obj.initStats = @obj.initGroupMeans;
                obj.swStats = @obj.swGroupMeans;
                obj.acceptsw = @obj.acceptSwapMeans;
                obj.rejectsw = @obj.rejectSwapMeans;
            elseif(strcmp(p.Results.stat,'mean') && p.Results.paired == true)
                obj.initStats = @obj.initPairedMeans;
                obj.swStats = @obj.swPairedMeans;    
                obj.acceptsw = @obj.acceptSwapMeans;
                obj.rejectsw = @obj.rejectSwapMeans;
            elseif(strcmp(p.Results.stat,'stdev')  && p.Results.paired == false)
                obj.initStats = @obj.initGroupStdev;
                obj.swStats = @obj.swGroupStdev;
                obj.acceptsw = @obj.acceptSwapStdev;  
                obj.rejectsw = @obj.rejectSwapStdev;  
            elseif(strcmp(p.Results.stat,'stdev')  && p.Results.paired == true)
                obj.initStats = @obj.initPairedStdev;
                obj.swStats = @obj.swPairedStdev;
                obj.acceptsw = @obj.acceptSwapStdev; 
                obj.rejectsw = @obj.rejectSwapStdev;  
            else
               error('function not yet supported');
            end
            
            % ASSIGN HANDLE TO DIFFERENCE COMPARISON METHOD
            % Group differences:
            if(strcmp(p.Results.fnc,'min'))
                obj.comparison = @obj.minDiff;
            elseif(strcmp(p.Results.fnc,'max'))
                obj.comparison = @obj.maxDiff;                     
            elseif(strcmp(p.Results.fnc,'orderedMax'))
                obj.comparison = @obj.orderedMaxDiff;   
            else
                error('function not yet supported');
            end
            
            % parent properties
            obj.sosObj = p.Results.sosObj;
            obj.constraintType = p.Results.constraintType;
            obj.fnc = p.Results.fnc;
            
            
            obj.weight = p.Results.weight;
            obj.exp = p.Results.exponent;         
            
            obj.stat = p.Results.stat;
            obj.s1 = p.Results.sample1;
            obj.s2 = p.Results.sample2;
            obj.s1Col = col1;
            obj.s2Col = col2;           
            obj.s1ColName = p.Results.s1ColName;
            obj.s2ColName = p.Results.s2ColName;           
              
            obj.paired = p.Results.paired;
            
            
            % add the name and the label
            obj.label = [obj.constraintType,'_',obj.fnc,'_',...
                    obj.stat,'_',...
                    obj.s1.name,'_',obj.s1ColName,'_',...
                    obj.s2.name,'_',obj.s2ColName,'_',...
                    'p',num2str(obj.paired)','_w',...
                    num2str(obj.weight),'_e',num2str(obj.exp)];              
            if any(strcmp(p.UsingDefaults,'name'))                 
                obj.name = obj.label;
            else
                 obj.name = p.Results.name;  
            end               
        end %construct2SampleSoftDistanceConstraint
        
        %% obj = construct1SampleSoftDistanceConstraint(varargin) METHOD
        function obj = construct1SampleSoftDistanceConstraint(obj,varargin)
            % creates a constraint object for cases where 1 sample is implicated.  
            % CONSTRUCTOR - Creates a softDistanceConstraint object
            %
            % CALL:
            % softDistanceConstraint(varargin<defined below>)
            %
            % PARAMETERS:
            % REQUIRED:
            %   'sosObj'/sos object - the SOS object the constraint will be linked to, and which contains the samples the constraint operates on.  
            %   'constraintType'/'soft' - the type of contraint - must be 'soft'
            %   'fnc'/'match1SampleVal' the distance function to create.  If orderedMax, s1 < s2 on the specified dimension
            %   'stat'/'mean'|'stdev' - the statistic to calculate the difference on
            %   'sample1'/sample - the first sample
            %   's1ColName'/string - name of column in 1st sample
            % OPTIONAL:
            %   'exponent'/numeric - defaults to 2 (quadratic difference)
            %   'weight'/numeric - defaults to 1 (equal weighting of all soft costs)
            %   'targVal'/numeric - value to match the stat to.  
            %
    
            
            p = softDistanceConstraint.parse1SampleConstructorArgs(varargin{:});
            
            if(p.Results.sosObj.containsSample(p.Results.sample1) == false)
                error('Cannot create soft distance constraint: sos Object does not contain the sample1');
            end
            
            
            col1 = p.Results.sample1.colName2colNum(p.Results.s1ColName);           
            if(col1 == -1)
                error('Specified column name not found in sample1');
            end
            
            if(strcmp(p.Results.sample1.format{col1},'%f') == 0)
                error('Specified column is not of numeric (%f) format, so cannot use as hard bound');
            end           
                  
            
            % Assign the comparison function appropriate for the constraint
            
            %ASSIGN HANDLE TO STAT CALCULATION METHOD
            if(strcmp(p.Results.stat,'mean'))
                obj.initStats = @obj.initSingleMeanandTarg;
                obj.swStats = @obj.swSingleMean;
                obj.acceptsw = @obj.acceptSwapMeans;
                obj.rejectsw = @obj.rejectSwapMeans;
                
                obj.comparison = @obj.minDiff;
                
            elseif(strcmp(p.Results.stat,'stdev'))
                obj.initStats = @obj.initSingleStdevandTarg;
                obj.swStats = @obj.swSingleStdev;
                obj.acceptsw = @obj.acceptSwapStdev;  
                obj.rejectsw = @obj.rejectSwapStdev;
                
                obj.comparison = @obj.minDiff;
            else
               error('function not yet supported');
            end
            
            
            %Finally, need to convert the raw value supplied by the user
            %into the standardized value used for comparison purposes.  We
            %do this by conslulting the SOS object's normalization data.  
            
            %find the normalization params for this data column:
            
            obj.targVal = p.Results.targVal;
            obj.zTargVal = NaN;
            
            % parent properties
            obj.sosObj = p.Results.sosObj;
            obj.constraintType = p.Results.constraintType;
            obj.fnc = p.Results.fnc;
            
            
            obj.weight = p.Results.weight;
            
            
            obj.stat = p.Results.stat;
            obj.s1 = p.Results.sample1;
            obj.s1Col = col1;   
            obj.s2 = NaN;
            obj.s1ColName = p.Results.s1ColName;         
            obj.exp = p.Results.exponent;           
            
            % add the name and the label
            obj.label = [obj.constraintType,'_',obj.fnc,'_',...
                    obj.stat,'_',num2str(obj.targVal),'_',obj.s1.name,'_',...
                    obj.s1ColName,'_w',...
                    num2str(obj.weight),'_e',num2str(obj.exp)];              
            if any(strcmp(p.UsingDefaults,'name'))                 
                obj.name = obj.label;
            else
                 obj.name = p.Results.name;  
            end            
            
        end %construct1SampleSoftDistanceConstraint
        
        
        
        %% cost = initCost() METHOD
        function cost = initCost(obj)
            % Calculates, saves, and returns the cost value for the current items in the sample.  
            %
            %CALL:
            %   <softDistanceConstraint>.initCost();
            %
            %SYNOPSIS:
            % Calculates the cost for the current items in the sample based
            % on the specified constraint.  This calculation is done on the
            % global dataset, rather than using the differential local
            % computation used when calculating swap costs.  
            %
          
            %init the stats, then compare them.  Return the calculated cost
            obj = obj.initStats(); 
            cost = obj.comparison(obj.stat1,obj.stat2);
            
            obj.swstat1 = NaN;
            obj.swstat2 = NaN;
            
            obj.cost = cost;
            obj.swCost = NaN;
        end

        %%  swCost(targSample,targSampleIndex, feederdf,feederdfIndex) FUNCTION
        function swCost = swapCost(obj,targSample,targSampleIndex, feederdf,feederdfIndex)
            % Calculates the new cost if items from targSample and feederdf were swapped.
            %
            %By definition, if this method is called it means that at least
            % one of the two swap objects is implicated in this function
            %
            %PARAMETERS:
            %   targSample - the target sample (i.e., the object that will call it's swapSample() method if a swap later occurs).
            %   targSampleIndex - row index of item to swap
            %   feederdf - dataframe (sample/pop) containin the other item to swap
            %   feederdfIndex - row index of item to swap.  
                       
           if (obj.s1 ~= targSample && obj.s2 ~= targSample ... 
                   && obj.s1 ~= feederdf && obj.s2  ~= feederdf)
               error('swCost called, but no sample part of this cost function');
           end

           % update the stats, then calculate cost of new stats
           obj.swStats(targSample,targSampleIndex, feederdf,feederdfIndex);
 
            swCost = obj.comparison(obj.swstat1,obj.swstat2);
            obj.swCost = swCost;
              
        end
        
        
        %% initGroupMeans() METHOD
        function obj = initGroupMeans(obj)
            % calculates the means of the samples
            obj.stat1= mean(obj.s1.zdata{obj.s1Col});
            obj.stat2= mean(obj.s2.zdata{obj.s2Col});
            
            
            if isnan(obj.stat1) || isnan(obj.stat2)
                error('NaN obtained during initstat computation (perhaps there is missing data for an item?)');
            end
        end

        %% initPairedMeans() METHOD
        function obj = initPairedMeans(obj)
            % prepares data for paired mean calculation
                      
            % make sure there are no nan's.  
            if (any(isnan(obj.s1.zdata{obj.s1Col})))
                error('NaN obtained during initstat computation of sample 1 (perhaps there is missing data for an item?)');
            elseif (any(isnan(obj.s2.zdata{obj.s2Col})))
                error('NaN obtained during initstat computation of sample 2 (perhaps there is missing data for an item?)');
            end
            
            % calculate the statistic.  In contrast to the group mean
            % statistic, here we'll calculate the difference in each pair
            % of observations and sum that in stat2, and leave stat1  ==0
            
            tmpstat2 = 0;
            for i=1:obj.s1.n
                x = obj.s2.zdata{obj.s2Col}(i) - obj.s1.zdata{obj.s1Col}(i);
                
                % when trying to minimize, any difference, in either
                % direction, is bad.  When trying to maximize, then let the
                % sign enter into the equation.  
                if strcmp(obj.fnc,'min')
                    x = abs(x);
                end

                 tmpstat2 = tmpstat2 + x;               
            end
            
            % calculate the mean of x
            obj.stat2 = tmpstat2/obj.s1.n;
            obj.stat1 = 0; % always relative to no difference
            
            
        end        
        
        %% initStdev(obj) METHOD
        function obj = initGroupStdev(obj)
            %calculates the stdevs of the samples
            
            obj.sumx1sq = sum((obj.s1.zdata{obj.s1Col}).^2);
            obj.meanx1 = mean(obj.s1.zdata{obj.s1Col});
            n1 = length(obj.s1.zdata{obj.s1Col});
            
            %use the computational formula to efficiently calculate the sum
            stdevx1 = (1/(n1-1) * obj.sumx1sq ...
                        - n1/(n1-1) * obj.meanx1^2)^0.5;
                    
            obj.sumx2sq = sum((obj.s2.zdata{obj.s2Col}).^2);
            obj.meanx2 = mean(obj.s2.zdata{obj.s2Col});
            n2 = length(obj.s2.zdata{obj.s2Col});
            
            %use the computational formula to efficiently calculate the sum
            stdevx2 = (1/(n2-1) * obj.sumx2sq ...
                        - n2/(n2-1) * obj.meanx2^2)^0.5;
                    
            obj.stat1 = stdevx1;
            obj.stat2 = stdevx2;
            
            if isnan(obj.stat1) || isnan(obj.stat2)
                error('NaN obtained during initstat computation (perhaps there is missing data for an item?)');
            end     
            
        end
            
        %% initPairedMeans() METHOD
        function obj = initPairedStdev(obj)
            % prepares data for paired mean calculation
                      
            % make sure there are no nan's.  
            if (any(isnan(obj.s1.zdata{obj.s1Col})))
                error('NaN obtained during initstat computation of sample 1 (perhaps there is missing data for an item?)');
            elseif (any(isnan(obj.s2.zdata{obj.s2Col})))
                error('NaN obtained during initstat computation of sample 2 (perhaps there is missing data for an item?)');
            end
            
            % calculate the statistic.  In contrast to the group mean
            % statistic, here we'll calculate the difference in each pair
            % of observations and sum that in stat2, and leave stat1  ==0
            
            obj.sumx2sq = 0;
            obj.meanx2 = 0;
            n = length(obj.s2.zdata{obj.s2Col});
            
            for i=1:n
                x = obj.s2.zdata{obj.s2Col}(i) - obj.s1.zdata{obj.s1Col}(i);
                obj.sumx2sq = obj.sumx2sq + x^2;
                obj.meanx2 = obj.meanx2 + x/n;
                            
            end
            
            %use the computational formula to efficiently calculate the sum
            stdevx2 = (1/(n-1) * obj.sumx2sq ...
                        - n/(n-1) * obj.meanx2^2)^0.5;            
            
            
            % calculate the mean of x
            obj.stat2 = stdevx2;
            obj.stat1 = 0; % always relative to no difference
            
            
        end    

        %% initSingleMeanandTarg() METHOD
        function obj = initSingleMeanandTarg(obj)
            % calculates the mean of the sample1 and sets the target as the target stat
            
            obj.stat2= mean(obj.s1.zdata{obj.s1Col});
            
             %normalize the target value to match against           
            targCol = obj.sosObj.allData.colName2colNum(obj.s1ColName);           
            if(targCol == -1)
                error('Normalized data for this value may not yet exist (try normalizing first)');
            end    
            
            obj.zTargVal = (obj.targVal - obj.sosObj.allDataColMean(targCol)) ...
                            / obj.sosObj.allDataColStd(targCol);
                        
           obj.stat1 = obj.zTargVal;
                        
            if isnan(obj.stat1) || isnan(obj.stat2)
                error('NaN obtained during initstat computation (perhaps there is missing data for an item?)');
            end
        end

        %% initSingleStdevandtarg(obj) METHOD
        function obj = initSingleStdevandTarg(obj)
            %calculates the stdevs of the samples
                    
            obj.sumx2sq = sum((obj.s1.zdata{obj.s1Col}).^2);
            obj.meanx2 = mean(obj.s1.zdata{obj.s1Col});
            n2 = length(obj.s1.zdata{obj.s1Col});
            
            %use the computational formula to efficiently calculate the sum
            stdevx2 = (1/(n2-1) * obj.sumx2sq ...
                        - n2/(n2-1) * obj.meanx2^2)^0.5;
            
            obj.stat2 = stdevx2;

             %normalize the target value to match against           
            targCol = obj.sosObj.allData.colName2colNum(obj.s1ColName);           
            if(targCol == -1)
                error('Normalized data for this value may not yet exist (try normalizing first)');
            end    
            
            obj.zTargVal = (obj.targVal) ...
                            / obj.sosObj.allDataColStd(targCol);
                        
            obj.stat1 = obj.zTargVal;            
            
            
            if isnan(obj.stat1) || isnan(obj.stat2)
                error('NaN obtained during initstat computation (perhaps there is missing data for an item?)');
            end     
            
        end
        
        %% swGroupMeans(targSample,targSampleIndex,feederdf,feederdfIndex) FUNCTION
        function swGroupMeans(obj,targSample,targSampleIndex, feederdf,feederdfIndex)
           % Calculates the new (swap) means if items from targSample and feederd were swapped.
           % 
           % Inputs are the same as for swapCost()
         
           tempswm1 = obj.stat1;
           tempswm2 = obj.stat2;
       
            %do the adjustments of the means
            %basic idea is to take out the old value from that mean and
            %then put in the new one.  Do that seperately for each
            %dataframe to cover all eventualities (i.e., if either
            %targSample or feederdf, or both, are part of the current cost
            %function.
            
            if targSample == obj.s1
                tempswm1 = tempswm1 - (targSample.zdata{obj.s1Col}(targSampleIndex)/length(targSample.zdata{obj.s1Col}));
                tempswm1 = tempswm1 + (feederdf.zdata{obj.s1Col}(feederdfIndex)/length(targSample.zdata{obj.s1Col}));
            elseif targSample == obj.s2
                tempswm2 = tempswm2 - (targSample.zdata{obj.s2Col}(targSampleIndex)/length(targSample.zdata{obj.s2Col}));
                tempswm2 = tempswm2 + (feederdf.zdata{obj.s2Col}(feederdfIndex)/length(targSample.zdata{obj.s2Col}));
            end
                               
            if feederdf == obj.s1
                tempswm1 = tempswm1 - (feederdf.zdata{obj.s1Col}(feederdfIndex)/length(feederdf.zdata{obj.s1Col}));
                tempswm1 = tempswm1 + (targSample.zdata{obj.s1Col}(targSampleIndex)/length(feederdf.zdata{obj.s1Col}));
            elseif feederdf == obj.s2 
                tempswm2 = tempswm2 - (feederdf.zdata{obj.s2Col}(feederdfIndex)/length(feederdf.zdata{obj.s2Col}));
                tempswm2 = tempswm2 + (targSample.zdata{obj.s2Col}(targSampleIndex)/length(feederdf.zdata{obj.s2Col}));
            end           
            
            obj.swstat1 = tempswm1;
            obj.swstat2 = tempswm2;
               
            if isnan(obj.swstat1) || isnan(obj.swstat2)
                error('NaN obtained during swstat computation (perhaps there is missing data for an item?)');
            end
        end
        

        
        
        %% swPairedMeans(targSample,targSampleIndex,feederdf,feederdfIndex) FUNCTION
        function swPairedMeans(obj,targSample,targSampleIndex, feederdf,feederdfIndex)
           % Calculates the new (swap) means if items from targSample and feederd were swapped.
           % 
           % Inputs are the same as for swapCost()
         
           tempswm2 = obj.stat2;
           %tempswm2 should remain 0 at all times
       
            %do the adjustments of the means
            %basic idea is to take out the old value from that mean and
            %then put in the new one.  Do that seperately for each
            %dataframe to cover all eventualities (i.e., if either
            %targSample or feederdf, or both, are part of the current cost
            %function.

                       
            nobs = length(obj.s1.zdata{obj.s1Col});

            if targSample == obj.s1
                %take the existing contribution to the stat due to the data
                %out.
                curx = (obj.s2.zdata{obj.s2Col}(targSampleIndex) - ...
                        targSample.zdata{obj.s1Col}(targSampleIndex))/nobs;
                
                if strcmp(obj.fnc,'min')
                    curx = abs(curx);
                end
                
                tempswm2 = tempswm2 - curx;
                
                %add in the new value
                newx = (obj.s2.zdata{obj.s2Col}(targSampleIndex) - ...
                          feederdf.zdata{obj.s1Col}(feederdfIndex)) / nobs;
                    
                if strcmp(obj.fnc,'min')
                    newx = abs(newx);
                end     
                
                tempswm2 = tempswm2 + newx;     
                
                % update is complete
            elseif targSample == obj.s2
                
                curx  = (targSample.zdata{obj.s2Col}(targSampleIndex) - ...
                            obj.s1.zdata{obj.s1Col}(targSampleIndex))/nobs;
                        
                if strcmp(obj.fnc,'min')
                    curx = abs(curx);
                end

                tempswm2 = tempswm2 - curx;         
                
                newx = (feederdf.zdata{obj.s2Col}(feederdfIndex) - ...
                        obj.s1.zdata{obj.s1Col}(targSampleIndex))/nobs;

                if strcmp(obj.fnc,'min')
                    newx = abs(newx);
                end     
                
                tempswm2 = tempswm2 + newx;    
                
            end
            
            
            if feederdf == obj.s1
                
                curx = (obj.s2.zdata{obj.s2Col}(feederdfIndex) - ...
                          feederdf.zdata{obj.s1Col}(feederdfIndex)) / nobs;
                
                if strcmp(obj.fnc,'min')
                    curx = abs(curx);
                end                
        
                tempswm2 = tempswm2 - curx;       
                
                newx = (obj.s2.zdata{obj.s2Col}(feederdfIndex) - ...
                        targSample.zdata{obj.s1Col}(targSampleIndex))/nobs;
                
                 if strcmp(obj.fnc,'min')
                    newx = abs(newx);
                end     
                
                tempswm2 = tempswm2 + newx;   
                
                
            elseif feederdf == obj.s2 
                curx = (feederdf.zdata{obj.s2Col}(feederdfIndex) - ...
                        obj.s1.zdata{obj.s1Col}(feederdfIndex))/nobs;
                    
                 
                if strcmp(obj.fnc,'min')
                    curx = abs(curx);
                end                
        
                tempswm2 = tempswm2 - curx;       
                
                newx = (targSample.zdata{obj.s2Col}(targSampleIndex) - ...
                            obj.s1.zdata{obj.s1Col}(feederdfIndex))/nobs;
                
                if strcmp(obj.fnc,'min')
                    newx = abs(newx);
                end     
                
                tempswm2 = tempswm2 + newx;      
                
            end
            
            obj.swstat2 = tempswm2;
            obj.swstat1 = obj.stat1; % again, just copy the zero over
               
            if isnan(obj.swstat1)
                error('NaN obtained during swstat computation (perhaps there is missing data for an item?)');
            end
        end %swPairedMeans

        %% swGroupStdev(targSample,targSampleIndex, feederdf,feederdfIndex)
        function swGroupStdev(obj,targSample,targSampleIndex, feederdf,feederdfIndex)
           % Calculates the new (swap) stdevs if items from targSample and feederd were swapped.
           % 
           % Inputs are the same as for swapCost()
            
            n1 = length(obj.s1.zdata{obj.s1Col});
            n2 = length(obj.s2.zdata{obj.s2Col});           
                       
            obj.swpsumx1sq = obj.sumx1sq;
            obj.swpmeanx1 = obj.meanx1;
            
            obj.swpsumx2sq = obj.sumx2sq;
            obj.swpmeanx2 = obj.meanx2;
            
            if targSample == obj.s1
                %must update 2 params %first, take out the old observation, then add in thew new
                obj.swpsumx1sq = obj.swpsumx1sq - (targSample.zdata{obj.s1Col}(targSampleIndex))^2;
                obj.swpmeanx1 = obj.swpmeanx1 - (targSample.zdata{obj.s1Col}(targSampleIndex))/n1;                
                obj.swpsumx1sq = obj.swpsumx1sq + (feederdf.zdata{obj.s1Col}(feederdfIndex))^2;
                obj.swpmeanx1 = obj.swpmeanx1 + (feederdf.zdata{obj.s1Col}(feederdfIndex))/n1;
            elseif targSample == obj.s2
                obj.swpsumx2sq = obj.swpsumx2sq - (targSample.zdata{obj.s2Col}(targSampleIndex))^2;
                obj.swpmeanx2 = obj.swpmeanx2 - (targSample.zdata{obj.s2Col}(targSampleIndex))/n2;                
                obj.swpsumx2sq = obj.swpsumx2sq + (feederdf.zdata{obj.s2Col}(feederdfIndex))^2;
                obj.swpmeanx2 = obj.swpmeanx2 + (feederdf.zdata{obj.s2Col}(feederdfIndex))/n2;     
            end
            
            if feederdf == obj.s1
                obj.swpsumx1sq = obj.swpsumx1sq -  (feederdf.zdata{obj.s1Col}(feederdfIndex))^2;
                obj.swpmeanx1 = obj.swpmeanx1 - (feederdf.zdata{obj.s1Col}(feederdfIndex))/n1;                
                obj.swpsumx1sq = obj.swpsumx1sq + (targSample.zdata{obj.s1Col}(targSampleIndex))^2;
                obj.swpmeanx1 = obj.swpmeanx1 + (targSample.zdata{obj.s1Col}(targSampleIndex))/n1;   
            elseif feederdf == obj.s2
                obj.swpsumx2sq = obj.swpsumx2sq -  (feederdf.zdata{obj.s2Col}(feederdfIndex))^2;
                obj.swpmeanx2 = obj.swpmeanx2 - (feederdf.zdata{obj.s2Col}(feederdfIndex))/n2;                
                obj.swpsumx2sq = obj.swpsumx2sq + (targSample.zdata{obj.s2Col}(targSampleIndex))^2;
                obj.swpmeanx2 = obj.swpmeanx2 + (targSample.zdata{obj.s2Col}(targSampleIndex))/n2;  
            end
     
            stdevx1 = (1/(n1-1) * obj.swpsumx1sq ...
                        - n1/(n1-1) * obj.swpmeanx1^2)^0.5;
                    
            stdevx2 = (1/(n2-1) * obj.swpsumx2sq ...
                        - n2/(n2-1) * obj.swpmeanx2^2)^0.5;
                    
            obj.swstat1 = stdevx1;
            obj.swstat2 = stdevx2;
            
            if isnan(obj.swstat1) || isnan(obj.swstat2)
                error('NaN obtained during swstat computation (perhaps there is missing data for an item?)');
            end            
          
        end
        
        %% swPairedStdev(targSample,targSampleIndex,feederdf,feederdfIndex) FUNCTION
        function swPairedStdev(obj,targSample,targSampleIndex, feederdf,feederdfIndex)
           % Calculates the new (swap) stdev if items from targSample and feederd were swapped.
           %
           %NOTE: When repeated tens of thousands of times, this manner of
           %updated std via local difference calculations tends to lead to
           %some very small imprecisions relative to re-calculating the
           %actual values from scratch.  These deviations appear to be
           %trivially small in all cases examined to date though.  This
           %fact is mentioned here presently only because the
           %detail-oriented individual may find values like  0.00000001
           %instead of 0, which nevertheless 
           %likely will have no practical consequence
           %for the matching algorithm.
           %
           % Inputs are the same as for swapCost()

           
           
            obj.swpsumx2sq = obj.sumx2sq;
            obj.swpmeanx2 = obj.meanx2;     
            n = length(obj.s1.zdata{obj.s1Col});
                       
            if targSample == obj.s1
                %take the existing contribution to the stat due to the data
                %out.
                curx = (obj.s2.zdata{obj.s2Col}(targSampleIndex) - ...
                        targSample.zdata{obj.s1Col}(targSampleIndex));
                               
                obj.swpsumx2sq = obj.swpsumx2sq - curx^2;
                obj.swpmeanx2 = obj.swpmeanx2 - curx/n;
                
                %add in the new value
                newx = (obj.s2.zdata{obj.s2Col}(targSampleIndex) - ...
                          feederdf.zdata{obj.s1Col}(feederdfIndex));
                    
                obj.swpsumx2sq = obj.swpsumx2sq + newx^2;
                obj.swpmeanx2 = obj.swpmeanx2 + newx/n;                
                                
                % update is complete
            elseif targSample == obj.s2
                
                curx  = (targSample.zdata{obj.s2Col}(targSampleIndex) - ...
                            obj.s1.zdata{obj.s1Col}(targSampleIndex));
                                        
                obj.swpsumx2sq = obj.swpsumx2sq - curx^2;
                obj.swpmeanx2 = obj.swpmeanx2 - curx/n;
                
                newx = (feederdf.zdata{obj.s2Col}(feederdfIndex) - ...
                        obj.s1.zdata{obj.s1Col}(targSampleIndex));
                    
                obj.swpsumx2sq = obj.swpsumx2sq + newx^2;
                obj.swpmeanx2 = obj.swpmeanx2 + newx/n;       
                
            end
            
            
            if feederdf == obj.s1
                
                curx = (obj.s2.zdata{obj.s2Col}(feederdfIndex) - ...
                          feederdf.zdata{obj.s1Col}(feederdfIndex));
                      
                obj.swpsumx2sq = obj.swpsumx2sq - curx^2;
                obj.swpmeanx2 = obj.swpmeanx2 - curx/n;
                
                newx = (obj.s2.zdata{obj.s2Col}(feederdfIndex) - ...
                        targSample.zdata{obj.s1Col}(targSampleIndex));
                
                obj.swpsumx2sq = obj.swpsumx2sq + newx^2;
                obj.swpmeanx2 = obj.swpmeanx2 + newx/n;       
                
                
            elseif feederdf == obj.s2 
                curx = (feederdf.zdata{obj.s2Col}(feederdfIndex) - ...
                        obj.s1.zdata{obj.s1Col}(feederdfIndex));
                    
                obj.swpsumx2sq = obj.swpsumx2sq - curx^2;
                obj.swpmeanx2 = obj.swpmeanx2 - curx/n;
                
                newx = (targSample.zdata{obj.s2Col}(targSampleIndex) - ...
                            obj.s1.zdata{obj.s1Col}(feederdfIndex));
                        
                obj.swpsumx2sq = obj.swpsumx2sq + newx^2;
                obj.swpmeanx2 = obj.swpmeanx2 + newx/n;       
                
            end
            
            % Special override:
            % if it happens that targSample and feederdf both correspond to
            % the samples for which stdev is being calculated, and that
            % the exact same item is being swapped out in both cases, the
            % swpsumx2sq should not change because the two swaps should
            % cancel each other out.  However, in the current
            % implementation this doesn't happen and instead we get 2x the
            % negative subtraction because the second calculation is not
            % aware of the shifts completed in the first.  This can,
            % however, be fixed in the present case quite simply by not
            % changing swpsumx2sq in this specific instance.  This only
            % happens in this case because the squaring of the terms leads
            % to the sign of the calculation being ignored, and as such the
            % calculation of swap means should not suffer in the same
            % fashion.  
            if((targSample == obj.s1 || targSample == obj.s2) && ...
                    (feederdf == obj.s1 || feederdf == obj.s2) && ...
                targSampleIndex == feederdfIndex)
                obj.swpsumx2sq = obj.sumx2sq;
            end
            
            % calculate the updated stdev:
           %use the computational formula to efficiently calculate the sum
            swpstdevx2 = (1/(n-1) * obj.swpsumx2sq ...
                        - n/(n-1) * obj.swpmeanx2^2)^0.5;  
                    
            obj.swstat2 = swpstdevx2;
            obj.swstat1 = obj.stat1; % again, just copy the zero over
               
            if isnan(obj.swstat1)
                error('NaN obtained during swstat computation (perhaps there is missing data for an item?)');
            end
        end %swPairedStdev
       
        
        %% swSingleMean(targSample,targSampleIndex,feederdf,feederdfIndex) METHOD
        function swSingleMean(obj,targSample,targSampleIndex, feederdf,feederdfIndex)
           % Calculates the new (swap) mean if items from targSample and feederd were swapped.
           % 
           % Inputs are the same as for swapCost()
         
           tempswm2 = obj.stat2;
       
            %do the adjustments of the means
            %basic idea is to take out the old value from that mean and
            %then put in the new one.  Do that seperately for each
            %dataframe to cover all eventualities (i.e., if either
            %targSample or feederdf, or both, are part of the current cost
            %function.
            
            if targSample == obj.s1
                tempswm2 = tempswm2 - (targSample.zdata{obj.s1Col}(targSampleIndex)/length(targSample.zdata{obj.s1Col}));
                tempswm2 = tempswm2 + (feederdf.zdata{obj.s1Col}(feederdfIndex)/length(targSample.zdata{obj.s1Col}));
            end
            
            
            if feederdf == obj.s1
                tempswm2 = tempswm2 - (feederdf.zdata{obj.s1Col}(feederdfIndex)/length(feederdf.zdata{obj.s1Col}));
                tempswm2 = tempswm2 + (targSample.zdata{obj.s1Col}(targSampleIndex)/length(feederdf.zdata{obj.s1Col}));
            end
            
            obj.swstat2 = tempswm2;
            obj.swstat1 = obj.stat1;
               
            if isnan(obj.swstat1) || isnan(obj.swstat2)
                error('NaN obtained during swstat computation (perhaps there is missing data for an item?)');
            end
        end
        
        %% swSingleStdev(targSample,targSampleIndex, feederdf,feederdfIndex)
        function swSingleStdev(obj,targSample,targSampleIndex, feederdf,feederdfIndex)
           % Calculates the new (swap) stdevs if items from targSample and feederd were swapped.
           % 
           % Inputs are the same as for swapCost()
            
            n2 = length(obj.s1.zdata{obj.s1Col});           
                       
            obj.swpsumx2sq = obj.sumx2sq;
            obj.swpmeanx2 = obj.meanx2;
            
            if targSample == obj.s1
                %must update 2 params %first, take out the old observation, then add in thew new
                obj.swpsumx2sq = obj.swpsumx2sq - (targSample.zdata{obj.s1Col}(targSampleIndex))^2;
                obj.swpmeanx2 = obj.swpmeanx2 - (targSample.zdata{obj.s1Col}(targSampleIndex))/n2;                
                obj.swpsumx2sq = obj.swpsumx2sq + (feederdf.zdata{obj.s1Col}(feederdfIndex))^2;
                obj.swpmeanx2 = obj.swpmeanx2 + (feederdf.zdata{obj.s1Col}(feederdfIndex))/n2;
            end
            
            if feederdf == obj.s1
                obj.swpsumx2sq = obj.swpsumx2sq -  (feederdf.zdata{obj.s1Col}(feederdfIndex))^2;
                obj.swpmeanx2 = obj.swpmeanx2 - (feederdf.zdata{obj.s1Col}(feederdfIndex))/n2;                
                obj.swpsumx2sq = obj.swpsumx2sq + (targSample.zdata{obj.s1Col}(targSampleIndex))^2;
                obj.swpmeanx2 = obj.swpmeanx2 + (targSample.zdata{obj.s1Col}(targSampleIndex))/n2;   
            end
                    
            stdevx2 = (1/(n2-1) * obj.swpsumx2sq ...
                        - n2/(n2-1) * obj.swpmeanx2^2)^0.5;
                    
            obj.swstat1 = obj.stat1; %just copy over the target
            obj.swstat2 = stdevx2;
            
            if isnan(obj.swstat1) || isnan(obj.swstat2)
                error('NaN obtained during swstat computation (perhaps there is missing data for an item?)');
            end            
          
        end
        
        
        
        %% minDiff() FUNCTION
        function cost = minDiff(obj,x1,x2)
            % cost function minimized by reduced differences on the statistic
            cost = (abs((x2-x1))^obj.exp)*obj.weight;
        end % minDiff

        
        %% maxDiff() FUNCTION
        function cost = maxDiff(obj,x1,x2)
            % cost function minimized by maximizing differences on the stat.  Many uses may want to use orderedMaxDiff, instead.
            cost = (-(abs((x2-x1))^obj.exp))*obj.weight;
        end       
        
        %% orderedMaxDiff() FUNCTION
        function cost = orderedMaxDiff(obj,x1,x2)
            % cost function minimized by maximizing a difference between the two groups that adheres to s1.stat < s2.stat
            if x1 < x2; cost = (-(abs((x2-x1))^obj.exp))*obj.weight;
            else cost = ((abs((x2-x1))^obj.exp))*obj.weight; end;
        end
        
        %% cost = acceptSwap(obj)
        function cost = acceptSwap(obj)
            %generic acceptSwap function
            obj.acceptsw();
            cost = acceptSwap@genericConstraint(obj);
        end

        %% cost = rejectSwap(obj)
        function cost = rejectSwap(obj)
            %generic reject function
            obj.rejectsw();
            cost = rejectSwap@genericConstraint(obj);
        end
        
        %% acceptSwapMeans() METHOD
        function acceptSwapMeans(obj)
            % updates variables when the proposed swap is accepted for
            % means
            
            if(isnan(obj.swstat1) && isnan(obj.swstat2))
                %do nothing, this method does not need to update
            elseif(isnan(obj.swstat1) == false && isnan(obj.swstat2) == false)
              obj.stat1=obj.swstat1;
              obj.stat2=obj.swstat2;
         
              obj.swstat1 = NaN;
              obj.swstat2 = NaN;
            else
                error('This should not have happened.  Maybe NaN in data?');
            end            
        end

        %% rejectSwapMeans() METHOD
        function rejectSwapMeans(obj)
            % updates variables when swap is rejected         
              obj.swstat1 = NaN;
              obj.swstat2 = NaN;       
        end
        
         %% acceptSwapStdev() METHOD
        function acceptSwapStdev(obj)
            % updates variables when the proposed swap is accepted for
            % standard deviations
            
            if(isnan(obj.swstat1) && isnan(obj.swstat2))
                %do nothing, this method does not need to update
            elseif(isnan(obj.swstat1) == false && isnan(obj.swstat2) == false)
                
%               disp('clearing swap memory');
              obj.stat1=obj.swstat1;
              obj.stat2=obj.swstat2;
         
          
              obj.sumx1sq = obj.swpsumx1sq;
              obj.meanx1 = obj.swpmeanx1;
              
              obj.sumx2sq = obj.swpsumx2sq;
              obj.meanx2 = obj.swpmeanx2;      
              
              obj.swpsumx1sq = NaN;
              obj.swpmeanx1 = NaN;

              obj.swpsumx2sq = NaN;
              obj.swpmeanx2 = NaN;   
              
              obj.swstat1 = NaN;
              obj.swstat2 = NaN;
            else
                error('This should not have happened');
            end            
        end       
        
        %% rejectSwapStdev() METHOD
        function rejectSwapStdev(obj)
            % updates variables when the proposed swap is rejected
              
              obj.swpsumx1sq = NaN;
              obj.swpmeanx1 = NaN;

              obj.swpsumx2sq = NaN;
              obj.swpmeanx2 = NaN;   
              
              obj.swstat1 = NaN;
              obj.swstat2 = NaN;       
        end                 
    end
        

    
    
    methods (Static)
        %% p = softDistanceConstraintInputParser2Sample() STATIC METHOD
        function p = softDistanceConstraintInputParser2Sample()
            % generates an input parser with parameter / value pairs and validators for the constructor args
            %
            % See constructor help/doc for more details
            
            p = inputParser;

            %NOTE: though these technically are 'optional' according to
            %MATLAB's definition of what an input parser does, the fact
            %that most of their default values will fail validation in all cases
            %makes them de facto required parameters.  
            
            p.addParamValue('sosObj','null',@(sosObj)strcmp(class(sosObj),'sos'));
            p.addParamValue('constraintType', 'null', ...
                @(constraintType)any(strcmp({'soft'},constraintType)));
            p.addParamValue('fnc','null', ...
                 @(fnc)any(strcmp({'min' 'max','orderedMax'},fnc)));
            p.addParamValue('stat','null', ...
                 @(stat)any(strcmp({'mean' 'stdev'},stat)));
            p.addParamValue('sample1','null',@(sample1)strcmp(class(sample1),'sample'));
            p.addParamValue('sample2','null',@(sample2)strcmp(class(sample2),'sample'));
            p.addParamValue('s1ColName','',@(s1ColName)ischar(s1ColName));
            p.addParamValue('s2ColName','',@(s2ColName)ischar(s2ColName));
            p.addParamValue('paired','null',@(paired)islogical(paired));
            p.addParamValue('exponent',2,@(exponent)isnumeric(exponent));
            p.addParamValue('weight',1,@(weight)isnumeric(weight));
            p.addParamValue('name','noname',@(name)ischar(name));
            
        end % softDistanceConstraintInputParser()
        
        
        
        function p = softDistanceConstraintInputParser1Sample()
            % generates an input parser with parameter / value pairs and validators for the constructor args
            %
            % See constructor help/doc for more details
            
            p = inputParser;

            %NOTE: though these technically are 'optional' according to
            %MATLAB's definition of what an input parser does, the fact
            %that most of their default values will fail validation in all cases
            %makes them de facto required parameters.  
            
            p.addParamValue('sosObj','null',@(sosObj)strcmp(class(sosObj),'sos'));
            p.addParamValue('constraintType', 'null', ...
                @(constraintType)any(strcmp({'soft'},constraintType)));
            p.addParamValue('fnc','null', ...
                 @(fnc)any(strcmp({'match1SampleVal'},fnc)));
            p.addParamValue('stat','null', ...
                 @(stat)any(strcmp({'mean' 'stdev'},stat)));
            p.addParamValue('sample1','null',@(sample1)strcmp(class(sample1),'sample'));
            p.addParamValue('s1ColName','',@(s1ColName)ischar(s1ColName));
            p.addParamValue('exponent',2,@(exponent)isnumeric(exponent));
            p.addParamValue('weight',1,@(weight)isnumeric(weight));
            p.addParamValue('targVal','null',@(targVal)isnumeric(targVal));
            p.addParamValue('name','noname',@(name)ischar(name));
            
        end % softDistanceConstraintInputParser()        
            
    end
        
    
    methods (Static, Access = private)
        
        %% p = parse2SampleContructorArgs(varargin) STATIC PRIVATE FUNCTION
        function p = parse2SampleConstructorArgs(varargin)
            % parses the constructor args
            % 
            % See constructor help/doc for more info
                        
            varargin = varargin{1};
            p = softDistanceConstraint.softDistanceConstraintInputParser2Sample();
            p.parse(varargin{:});
        end
        
        %% p = parse1SampleContructorArgs(varargin) STATIC PRIVATE FUNCTION
        function p = parse1SampleConstructorArgs(varargin)
            % parses the constructor args
            % 
            % See constructor help/doc for more info
                        
            varargin = varargin{1};
            p = softDistanceConstraint.softDistanceConstraintInputParser1Sample();
            p.parse(varargin{:});
        end
    end
    
end % end class

