% - soft correlation matching constraint object
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

classdef softMatchCorrelConstraint < softConstraint
    %% creates and supports soft matchCorrel constraints
    %
    % This class creates softMatchCorrelConstraint objects that measure the
    % cost (in terms of matching a correlation across two variables) 
    % associated with the current items in a set, and subsequent to
    % swapping a particular item with another items.  
    % 
    % Additional functionality and interface requirements are inherited
    % from softConstraint.  
    %
    % a beautiful property:
    % correlation == covariance / stdev(x)stdev(y)
    % BUT because both numerator and denominators standardize for number of
    % observations, this cancels each other out, so also:
    %   cor = SPxy / sqrt(SSx)*sqrt(SSy), where SP = sum of products
    % This can be reduced to a set of very computationally efficient
    % equations:
    % SSx = Sum(x^2) - (Sum(x))^2/N  --- i.e., subtract correction factor
    % AND: SPxy = Sum(xy) - Sum(x)*Sum(y)/N
    % Gotta love algebra.  Pythagoras would be all over this...
    %
    % PROPERTIES
    %     stat % the statistic to calculate (correlation)
    %     comparison % handle to specific comparison calculator   
    %     initStats % handle to global stat initialization method
    %     swStats % handle to local stat update method
    %     acceptsw % handle to local accept swap method
    %     rejectsw % handle to local reject swap method
    %     s1 % sample1
    %     s2 % sample2
    %     s1Col %s1 column index
    %     s2Col %s2 column index
    %     s1ColName % name of column in s1
    %     s2ColName % name of column in s2       
    %     targVal % target value to match for 1 sample-to-value matching  
    %     sumx1sq % sum of squares in sample 1
    %     sumx1 % sum of sample 1
    %     n1 % number of observations in sample 1 
    %     sumx2sq % same for sample 2
    %     sumx2 % same for sample 2
    %     n2 % same for sample 2
    %     sumx1x2 % sum of product of x1 and x2, across all items
    %     swpsumx1sq % same as above for swap set
    %     swpsumx2sq % same as above for swap set
    %     swpsumx1 % same as above for swap set
    %     swpsumx2 % same as above for swap set
    %     swpsumx1x2 % same as above for swap set        
    %     cor % the correlation between the two sets
    %     swpcor % the correlation if the swap was applied.
    %
    % METHODS
    %   function obj = softMatchCorrelConstraint(varargin) % constructor
    %   cost = initCost() - Calculates, saves, and returns the cost value for the current items in the sample. 
    %   swCost = swapCost(targSample,targSampleIndex, feederdf,feederdfIndex) % Calculates the new cost if items from targSample and feederdf were swapped.
    %   initCorrel() FUNCTION calculates the correlation and initializes the parameters needed for local stat updates
    %   swCorrel(targSample,targSampleIndex, feederdf,feederdfIndex) % calculates the correlation if the swap were applied
    %   matchCorrel(x1,x2) % cost function minimized by reduced differences on the statistic
    %   acceptSwap() % generic acceptSwap function
    %   cost = rejectSwap() % generic reject function
    %   acceptSwapCorrel() % updates variables when the proposed swap is accepted for means
    %   rejectSwapCorrel() % resets swap variables
    %   constructSoftMatchCorrelConstraint(varargin)  % creates a constraint object
    %
    % METHODS (Static)
    %   softMatchCorrelConstraintInputParserMatchCorrel() % generates an input parser with parameter / value pairs and validators for the constructor args
    %
    % METHODS (Static, Access = private)
    %   p = parseMatchCorrelConstructorArgs(varargin) % parses the constructor args

    %% PROPERTIES
    properties
        stat % the statistic to calculate (correlation)
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
        targVal % target value to match for 1 sample-to-value matching  
        sumx1sq % sum of squares in sample 1
        sumx1 % sum of sample 1
        n1 % number of observations in sample 1 
        sumx2sq % same for sample 2
        sumx2 % same for sample 2
        n2 % same for sample 2
        sumx1x2 % sum of product of x1 and x2, across all items
        swpsumx1sq % same as above for swap set
        swpsumx2sq % same as above for swap set
        swpsumx1 % same as above for swap set
        swpsumx2 % same as above for swap set
        swpsumx1x2 % same as above for swap set        
        cor % the correlation between the two sets
        swpcor % the correlation if the swap was applied.
        
    end
    
    
    %% METHODS
    methods
        
        %% softMatchCorrelConstraint CONSTRUCTOR
        function obj = softMatchCorrelConstraint(varargin)
            % Creates a soft distance constraint.  See the parse
            % constructor args functions for parameters.
            
            p = inputParser;
            p.addParamValue('fnc','null', ...
                @(fnc)any(strcmp({'matchCorrel'},fnc)));
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            if any(strcmp(p.Results.fnc,'matchCorrel'))
                % can create the matchCorrel constraint
                obj = constructSoftMatchCorrelConstraint(obj,varargin);
            else
                error(['Could not create a soft constraint with <fnc>: ', ...
                        p.Results.fnc]); 
            end
            
            obj.cost = NaN;
            obj.swCost = NaN;
            
            
            verbosePrint('Soft matchCorrel Constraint has been created', ...
                    'softMatchCorrelConstraint_Constructor_endObjCreation');
                    
        end %constructor
        
        
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
            cost = obj.comparison(obj.targVal,obj.cor); %where we match the correlation...
            
            obj.swpcor = NaN;
            obj.swpsumx1sq = NaN;
            obj.swpsumx2sq = NaN;
            obj.swpsumx1 = NaN;
            obj.swpsumx2 = NaN;
            obj.swpsumx1x2 = NaN;
            
            obj.cost = cost;
            obj.swCost = NaN;
        end
        
        %%  swCost(targSample,targSampleIndex, feederdf,feederdfIndex) METHOD
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
 

            swCost = obj.comparison(obj.targVal,obj.swpcor);
            obj.swCost = swCost;
              
        end

        %% obj = initCorrel() METHOD
        function obj = initCorrel(obj)
            %  calculates the correlation and initializes the parameters
            %  needed for local stat updates
           
            obj.sumx1sq = sum((obj.s1.zdata{obj.s1Col}).^2);
            obj.sumx1 = sum((obj.s1.zdata{obj.s1Col}));
            obj.n1 = length(obj.s1.zdata{obj.s1Col});
            
            obj.sumx2sq = sum((obj.s2.zdata{obj.s2Col}).^2);
            obj.sumx2 = sum((obj.s2.zdata{obj.s2Col}));
            obj.n2 = length(obj.s2.zdata{obj.s2Col});
            
            obj.sumx1x2 = (obj.s1.zdata{obj.s1Col})' * (obj.s2.zdata{obj.s2Col});
            
            ssx1 = obj.sumx1sq - ((obj.sumx1)^2)/obj.n1;
            ssx2 = obj.sumx2sq - ((obj.sumx2)^2)/obj.n2;
            
            spx1x2 = obj.sumx1x2 - obj.sumx1*obj.sumx2/obj.n1;
            
            
            if(ssx1 == 0 && ssx2 == 0) % no variance in either condition, define correlation as being perfect in this case
                obj.cor = 1;
            elseif(ssx1 == 0 || ssx2 == 0)
                obj.cor = 0;
            else % compute correlation normally
                obj.cor = spx1x2/(sqrt(ssx1)*sqrt(ssx2));
            end
                       
            obj.swpcor = NaN;
            obj.swpsumx1sq = NaN;
            obj.swpsumx2sq = NaN;
            obj.swpsumx1 = NaN;
            obj.swpsumx2 = NaN;
            obj.swpsumx1x2 = NaN;
        end
        
        
        %% swCorrel(targSample,targSampleIndex,feederdf,feederdfIndex) METHOD
        function swCorrel(obj,targSample,targSampleIndex, feederdf,feederdfIndex)
            % calculates the correlation if the swap were applied
            obj.swpsumx1sq = obj.sumx1sq;
            obj.swpsumx2sq = obj.sumx2sq;
            obj.swpsumx1 = obj.sumx1;
            obj.swpsumx2 = obj.sumx2;
            obj.swpsumx1x2 = obj.sumx1x2;
                       
            %NOTE: if both target and feeder are identical, swapping items
            %within those two samples will not change the correlation.
            %This could be leveraged to simplify the conditionalization.  
            
             if targSample == obj.s1
                %must update 2 params %first, take out the old observation, then add in thew new
                obj.swpsumx1sq = obj.swpsumx1sq - (targSample.zdata{obj.s1Col}(targSampleIndex))^2;
                obj.swpsumx1 = obj.swpsumx1 - (targSample.zdata{obj.s1Col}(targSampleIndex));                
                obj.swpsumx1sq = obj.swpsumx1sq + (feederdf.zdata{obj.s1Col}(feederdfIndex))^2;
                obj.swpsumx1 = obj.swpsumx1 + (feederdf.zdata{obj.s1Col}(feederdfIndex));
             end
             
             if targSample == obj.s2
                obj.swpsumx2sq = obj.swpsumx2sq - (targSample.zdata{obj.s2Col}(targSampleIndex))^2;
                obj.swpsumx2 = obj.swpsumx2 - (targSample.zdata{obj.s2Col}(targSampleIndex));                
                obj.swpsumx2sq = obj.swpsumx2sq + (feederdf.zdata{obj.s2Col}(feederdfIndex))^2;
                obj.swpsumx2 = obj.swpsumx2 + (feederdf.zdata{obj.s2Col}(feederdfIndex)); 
             end
            
          
            if feederdf == obj.s1
                obj.swpsumx1sq = obj.swpsumx1sq -  (feederdf.zdata{obj.s1Col}(feederdfIndex))^2;
                obj.swpsumx1 = obj.swpsumx1 - (feederdf.zdata{obj.s1Col}(feederdfIndex));                
                obj.swpsumx1sq = obj.swpsumx1sq + (targSample.zdata{obj.s1Col}(targSampleIndex))^2;
                obj.swpsumx1 = obj.swpsumx1 + (targSample.zdata{obj.s1Col}(targSampleIndex));                   
            end
            
            if feederdf == obj.s2
                obj.swpsumx2sq = obj.swpsumx2sq -  (feederdf.zdata{obj.s2Col}(feederdfIndex))^2;
                obj.swpsumx2 = obj.swpsumx2 - (feederdf.zdata{obj.s2Col}(feederdfIndex));                
                obj.swpsumx2sq = obj.swpsumx2sq + (targSample.zdata{obj.s2Col}(targSampleIndex))^2;
                obj.swpsumx2 = obj.swpsumx2 + (targSample.zdata{obj.s2Col}(targSampleIndex)); 
            end  

            % Special overrides
            
            if targSample == obj.s1 && targSample ~= obj.s2
                obj.swpsumx1x2 = obj.swpsumx1x2 - (targSample.zdata{obj.s1Col}(targSampleIndex)) * obj.s2.zdata{obj.s2Col}(targSampleIndex);
                obj.swpsumx1x2 = obj.swpsumx1x2 + (feederdf.zdata{obj.s1Col}(feederdfIndex))     * obj.s2.zdata{obj.s2Col}(targSampleIndex);
            elseif targSample == obj.s2 && targSample ~= obj.s1               
                obj.swpsumx1x2 = obj.swpsumx1x2 - (targSample.zdata{obj.s2Col}(targSampleIndex)) * obj.s1.zdata{obj.s1Col}(targSampleIndex);
                obj.swpsumx1x2 = obj.swpsumx1x2 + (feederdf.zdata{obj.s2Col}(feederdfIndex))     * obj.s1.zdata{obj.s1Col}(targSampleIndex);                
            elseif targSample == obj.s1 && targSample == obj.s2
                obj.swpsumx1x2 = obj.swpsumx1x2 - (obj.s1.zdata{obj.s1Col}(targSampleIndex)) * obj.s2.zdata{obj.s2Col}(targSampleIndex);
                obj.swpsumx1x2 = obj.swpsumx1x2 + (feederdf.zdata{obj.s1Col}(feederdfIndex))     * feederdf.zdata{obj.s2Col}(feederdfIndex);                
            end
            
            
             if feederdf == obj.s1 && feederdf ~= obj.s2
                obj.swpsumx1x2 = obj.swpsumx1x2 - (feederdf.zdata{obj.s1Col}(feederdfIndex))     * obj.s2.zdata{obj.s2Col}(feederdfIndex);
                obj.swpsumx1x2 = obj.swpsumx1x2 + (targSample.zdata{obj.s1Col}(targSampleIndex)) * obj.s2.zdata{obj.s2Col}(feederdfIndex); 
             elseif feederdf == obj.s2 && feederdf ~= obj.s1               
                obj.swpsumx1x2 = obj.swpsumx1x2 - (feederdf.zdata{obj.s2Col}(feederdfIndex))     * obj.s1.zdata{obj.s1Col}(feederdfIndex);
                obj.swpsumx1x2 = obj.swpsumx1x2 + (targSample.zdata{obj.s2Col}(targSampleIndex)) * obj.s1.zdata{obj.s1Col}(feederdfIndex); 
               elseif feederdf == obj.s1 && feederdf == obj.s2
                obj.swpsumx1x2 = obj.swpsumx1x2 - (obj.s1.zdata{obj.s1Col}(feederdfIndex)) * obj.s2.zdata{obj.s2Col}(feederdfIndex);
                obj.swpsumx1x2 = obj.swpsumx1x2 + (targSample.zdata{obj.s1Col}(targSampleIndex))     * targSample.zdata{obj.s2Col}(targSampleIndex);                
             end           
            
            if((targSample ~= feederdf) && ...
                    (targSample == obj.s1 || targSample == obj.s2) && ...
                    (feederdf == obj.s1 || feederdf == obj.s2) && ...
                    targSampleIndex == feederdfIndex  && ...
                    obj.s1Col == obj.s2Col)
                obj.swpsumx1x2 = obj.sumx1x2;
            end
                
                
           if((targSample ~= feederdf) && ...
                    (targSample == obj.s1 || targSample == obj.s2) && ...
                    (feederdf == obj.s1 || feederdf == obj.s2) && ...
                    targSampleIndex == feederdfIndex  && ...
                    obj.s1Col ~= obj.s2Col)
                
                    obj.swpsumx1x2 = obj.sumx1x2 - obj.s1.zdata{obj.s1Col}(targSampleIndex) * obj.s2.zdata{obj.s2Col}(feederdfIndex) + ...
                        obj.s2.zdata{obj.s1Col}(feederdfIndex) * obj.s1.zdata{obj.s2Col}(targSampleIndex);             
           end 

            
            swpssx1 = obj.swpsumx1sq - ((obj.swpsumx1)^2)/obj.n1;
            swpssx2 = obj.swpsumx2sq - ((obj.swpsumx2)^2)/obj.n2;
            
            swpspx1x2 = obj.swpsumx1x2 - obj.swpsumx1*obj.swpsumx2/obj.n1;
            
            
            if(swpssx1 == 0 && swpssx2 == 0) % no variance in either condition, define correlation as being perfect in this case
                obj.swpcor = 1;
            elseif(swpssx1 == 0 || swpssx2 == 0)
                obj.swpcor = 0;
            else % compute correlation normally
                obj.swpcor = swpspx1x2/(sqrt(swpssx1)*sqrt(swpssx2));
            end       
            
            
        end
        

        
        %% matchCorrel() METHOD
        function cost = matchCorrel(obj,x1,x2)
            % cost function minimized by reduced differences on the statistic
            cost = ((abs(x2-x1)/2)^obj.exp)*obj.weight;
            
        end % matchCorrel
        
        
        %% cost = acceptSwap() METHOD
        function cost = acceptSwap(obj)        
            %generic acceptSwap function
            obj.acceptsw();
            cost = acceptSwap@genericConstraint(obj);
        end
        
        %% cost = rejectSwap()  METHOD
        function cost = rejectSwap(obj)
            %generic reject function
            obj.rejectsw();
            cost = rejectSwap@genericConstraint(obj);
        end
        
        %% acceptSwapCorrel() METHOD
        function acceptSwapCorrel(obj)
            % updates variables when the proposed swap is accepted for
            % means
            
            if(isnan(obj.swpcor))
                %do nothing, this method does not need to update
            else
            obj.sumx1sq = obj.swpsumx1sq;
            obj.sumx2sq = obj.swpsumx2sq;
            obj.sumx1 = obj.swpsumx1;
            obj.sumx2 = obj.swpsumx2;
            obj.sumx1x2 = obj.swpsumx1x2;
            obj.cor = obj.swpcor;
            
            
            obj.rejectSwapCorrel();
            
            end
        end      
        
        %% rejectSwapCorrel() METHOD
        function rejectSwapCorrel(obj)
            %resets swap variables
            obj.swpcor = NaN;
            obj.swpsumx1sq = NaN;
            obj.swpsumx2sq = NaN;
            obj.swpsumx1 = NaN;
            obj.swpsumx2 = NaN;
            obj.swpsumx1x2 = NaN;                        
        end
        
        %% obj = constructSoftMatchCorrelConstraint(varargin) METHOD
        function obj = constructSoftMatchCorrelConstraint(obj,varargin)
            % creates a constraint object
            % CONSTRUCTOR - Creates a softDistanceConstraint object
            %
            % CALL:
            % softDistanceConstraint(varargin<defined below>)
            %
            % PARAMETERS:
            % REQUIRED:
            %   'sosObj'/sos object - the SOS object the constraint will be linked to, and which contains the samples the constraint operates on.  
            %   'constraintType'/'soft' - the type of contraint - must be 'soft'
            %   'fnc'/'matchCorrel' the distance function to create.
            %   'sample1'/sample - the first sample
            %   'sample2'/sample - the second sample
            %   's1ColName'/string - name of column in 1st sample
            %   's2ColName'/string - name of column in 2nd sample
            %   'targVal'/integer [-1,1] - target correlation to match

            % OPTIONAL:
            %   'exponent'/numeric - defaults to 2 (quadratic difference)
            %   'weight'/numeric - defaults to 1 (equal weighting of all soft costs)
            %
            % EXAMPLE:
            %     c2 = mySOS.addConstraint('sosObj',mySOS,'name','matchFreqCorrelConstraint','constraintType', ...
            %     'soft','fnc','matchCorrel',...
            %     'sample1',mySample1,'s1ColName','KFfrequency', ...
            %     'sample2',mySample2,'s2ColName','KFfrequency','targVal',1,'exponent',2,'weight',1);
            
                        
            p = softMatchCorrelConstraint.parseMatchCorrelConstructorArgs(varargin{:});
            
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
                error('Specified column is not of numeric (%f) format, so cannot use as soft constraint');
            end           
                       
            col2 = p.Results.sample2.colName2colNum(p.Results.s2ColName);            
            if(col2 == -1)
                error('Specified column name not found in sample');
            end
            
            if(strcmp(p.Results.sample2.format{col2},'%f') == 0)
                error('Specified column is not of numeric (%f) format, so cannot use as soft constraint; 2nd sample');
            end           
            
            %if the lengths are not going to be identical, do not run the
            %correlation.  The init and swap methods will ensure
            %that if practically the data are NaN, the optimization will
            %stop.

            if length(p.Results.sample1.n) ~= length(p.Results.sample2.n)
                error('Sample sizes must be equal if using paired matching');
            end

            % Assign the comparison function appropriate for the constraint
            
            %ASSIGN HANDLE TO STAT CALCULATION METHOD

            obj.initStats = @obj.initCorrel;
            obj.swStats = @obj.swCorrel;
            obj.acceptsw = @obj.acceptSwapCorrel;
            obj.rejectsw = @obj.rejectSwapCorrel;
            
            % ASSIGN HANDLE TO DIFFERENCE COMPARISON METHOD
            % Group differences:
            if(strcmp(p.Results.fnc,'matchCorrel'))
                obj.comparison = @obj.matchCorrel;
            else
                error('function not yet supported');
            end
            
            % parent properties
            obj.sosObj = p.Results.sosObj;
            obj.constraintType = p.Results.constraintType;
            obj.fnc = p.Results.fnc;
            
            
            obj.weight = p.Results.weight;
            obj.exp = p.Results.exponent;  
            
            if(p.Results.targVal < -1 || p.Results.targVal > 1 || isnan(p.Results.targVal))
                error('Target correlation value must be a number -1 <= targ <= 1');
            end
            
            obj.targVal = p.Results.targVal;
            
            obj.s1 = p.Results.sample1;
            obj.s2 = p.Results.sample2;
            obj.s1Col = col1;
            obj.s2Col = col2;           
            obj.s1ColName = p.Results.s1ColName;
            obj.s2ColName = p.Results.s2ColName;           
            
            % add the name and the label
            obj.label = [obj.constraintType,'_',obj.fnc,'_',...
                    obj.targVal,'_',...
                    obj.s1.name,'_',obj.s1ColName,'_',...
                    obj.s2.name,'_',obj.s2ColName,'_',...
                    'p','1','_w',...
                    num2str(obj.weight),'_e',num2str(obj.exp)];              
            if any(strcmp(p.UsingDefaults,'name'))                 
                obj.name = obj.label;
            else
                 obj.name = p.Results.name;  
            end               
        end %construct2SampleSoftDistanceConstraint
        
        
    end
    
    methods (Static)
        %% p = softMatchCorrelConstraintInputParserMatchCorrel() STATIC METHOD
        function p = softMatchCorrelConstraintInputParserMatchCorrel()
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
                 @(fnc)any(strcmp({'matchCorrel'},fnc)));
            p.addParamValue('sample1','null',@(sample1)strcmp(class(sample1),'sample'));
            p.addParamValue('sample2','null',@(sample2)strcmp(class(sample2),'sample'));
            p.addParamValue('s1ColName','',@(s1ColName)ischar(s1ColName));
            p.addParamValue('s2ColName','',@(s2ColName)ischar(s2ColName));
            p.addParamValue('targVal',NaN,@(targVal)isnumeric(targVal));
            p.addParamValue('exponent',2,@(exponent)isnumeric(exponent));
            p.addParamValue('weight',1,@(weight)isnumeric(weight));
            p.addParamValue('name','noname',@(name)ischar(name));
            
        end
        
        
    end
    
    methods (Static, Access = private)
        
        %% p = parseMatchCorrelConstructorArgs(varargin) STATIC PRIVATE FUNCTION
        function p = parseMatchCorrelConstructorArgs(varargin)
            % parses the constructor args
            % 
            % See constructor help/doc for more info
                        
            varargin = varargin{1};
            p = softMatchCorrelConstraint.softMatchCorrelConstraintInputParserMatchCorrel();
            p.parse(varargin{:});
        end
        
    end
    
    
end