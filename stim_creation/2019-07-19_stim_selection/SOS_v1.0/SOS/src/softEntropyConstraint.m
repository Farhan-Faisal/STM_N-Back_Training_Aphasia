% - soft entropy constraint object 
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


classdef softEntropyConstraint < softConstraint
    %% creates and supports soft entropy constraints
    %
    % Objects of this class measure the cost in terms of minimizing or
    % maximizing a measure of entropy, or degree to which items have been
    % randomly distributed on a particular dimension.  
    %
    % Additional functionality is inherited from parent softConstraint
    %
    % The particular measure of entropy used in the class takes its
    % inspiration from the standard version of Gibbs entropy:
    %
    %   -k*[Sigma(p)*ln(p)]; 
    %   
    %  In this formula, k is a positive constant, and p is the probability
    %  of choosing an item with a particular value on the
    %  dimension of interest.  The sum of p*ln(p) is summed across all
    %  values of the dimension of interest.
    %
    %  In this standard version of entropy, the values of Entropy increase
    %  as the 'randomness' of the distribution of items increases.  That
    %  is, the highest values of entropy are obtained when a randomly
    %  selected item has an equal chance of having any one of the values on
    %  the dimension of interest.  This also corresponds to having a
    %  uniform distribution of items across values on the dimension of
    %  interest.  In contrast, when items are not randomly distributed in
    %  this uniform fashion, lower values of entropy are obtained.  The
    %  lowest possible entropy would occur when all items shared the same
    %  value.
    %
    %  Maximizing entropy thus provides one means of randomly distributing
    %  items across a range of values, whereas minimizing entropy can serve
    %  to force units to all take on the same value.
    %
    %  Though the standard Gibbs entropy formula has the desirable
    %  characteristics outlined above, for present purposes in one main
    %  respect: the domain of the results of the entropy formula are not
    %  well constrainted to a particular range.  This problem is due to two
    %  main aspects of the formula.  First, if a particular value of a
    %  dimension literally has no item representing it, its probability
    %  would be zero, and ln(0) = -Inf.  Second, the amount of entropy in
    %  the standard formula varies as a function of the number of items.
    %  Neither of these characteristics are desirable in the present
    %  context where it is useful to have the standard output of a cost
    %  function consistently have standardized values in the range -1 - 1 
    %   (or at least within an order of magnitude thereof).
    %
    %  This additional desirable characteristic resulted in the development
    %  of a new 'entropy' formula, as follows:
    %
    %     ent = (-1*Sigma(1:N)[p*log((p+1)')/Sum(N)] -1/(N)*ln((1/N)+1)) /
    %           (ln(2)/N - 1/N * ln((1/N) +1));
    %
    %  Don't let the complexity of this formula scare you though, as in
    %  principle it's quite straightforward.  First, to avoid the case
    %  where values with p=0 generated -Inf, it was necessary to add some
    %  constant value to the ln() term.  A value of 1 was selected as this
    %  results in only positive numbers being generated from the equation,
    %  since log(1) == 0 and log(1+positiveN) > 0.  Next, this equation is
    %  divided by N, the number of different possible items, which renders
    %  the output of the equation relatively insensitive to the number of
    %  items for which entropy is being calculated.  The theoretical
    %  minimum entropy for this particular dataset is then subtracted away
    %  from the result of hte previous step (1/N*ln((1/N)+1) corresponding
    %  to the case where all items are distributed uniformally across
    %  values) giving the equation a bound a bound of zero when maximum
    %  entropy is acheived.  The result of this entire calculation
    %  subsequently serves as the dividend in a division which
    %  standardizes the equation so that the maximum possible entropy that
    %  could result will always have a value of 1.0, thus bounding the
    %  formula to the 0-1 domain.  Finally, to conserve the property that
    %  entropy is maximized as randomness increases, the result of the
    %  previous calculation is multiplied by -1, thus yielding an entropy
    %  formula that is bounded at [-1, 0], where -1 corresponds to the
    %  least randomly distributed state, and 0 corresponds to the most
    %  randomly distributed state.  
    %
    %
    %     s1 % sample entropy is calculated on
    %     s1Col   % data column entropy is calculated on
    %     nbin    % number of bins to subdivide data into
    %     pdSpread % type of spread of scores desired.  Options currently are 'sample' and 'allItems'.  
    %     ent % current entropy value
    %     swEnt % swap entropy value
    %     comparison %handle to comparison calculator (to minimize or max entropy)
    %     initStats % handle to method that initializes stats
    %     swStats % handle to method that calculates swap stats
    %     scores % copy of scores in the column entropy is calucated for.
    %     swScores % copy of scores if a swap occured
    %     bins % mid-point of bins data is divided into
    %     swBins % mid-point of bins data is divided into after a swap
    %     pd % probability distribution of scores
    %     swpd % probability distribution of swap socres
    %     minScore % min score in set
    %     swMinScore % min score in swap set
    %     maxScore % max score in set
    %     swMaxScore % max score in swap set.  
    % 
    %PROPERTIES
    %     s1 % sample entropy is calculated on
    %     s1Col   % data column entropy is calculated on
    %     nbin    % number of bins to subdivide data into
    %     pdSpread % type of spread of scores desired.  Options currently are 'sample' and 'allItems'.  
    %     ent % current entropy value
    %     swEnt % swap entropy value
    %     comparison %handle to comparison calculator (to minimize or max entropy)
    %     initStats % handle to method that initializes stats
    %     swStats % handle to method that calculates swap stats
    %     scores % copy of scores in the column entropy is calucated for.
    %     swScores % copy of scores if a swap occured
    %     bins % mid-point of bins data is divided into
    %     swBins % mid-point of bins data is divided into after a swap
    %     pd % probability distribution of scores
    %     swpd % probability distribution of swap socres
    %     minScore % min score in set
    %     swMinScore % min score in swap set
    %     maxScore % max score in set
    %     swMaxScore % max score in swap set.  
    %
    %PROPERTIES (Constant)
    %    s2 = NaN; % s2 = NaN; for consistency with other methods, there is a swap2 property, but it is just set to a null-like value.  
    %   smallVal = 0.00000001 % small value added to avoid case where a value is exactly equal the min or max range of the distribution
    %
    %METHODS
    %   obj = softEntropyConstraint(varargin) % CONSTRUCTOR
    %   cost = initCost() METHOD
    %   initEnt() % calculates the initial entropy value for the scores in sample1<sample1Col>
    %   cost = minEnt(curEnt) % calculates the cost associated with curEnt, when minimal Entropy is desired 
    %   cost = maxEnt(curEnt)  % calculates the cost associated with curEnt, when maximal entropy is desired 
    %   swCost = swapCost(targSample,targSampleIndex, feederdf,feederdfIndex)  % Calculates the new cost if items from targSample and feederdf were swapped.
    %   swEntropy(obj,targSample,targSampleIndex, feederdf,feederdfIndex)  % Calculates the new (swap) entropy if items from targSample and feederdf were swapped.
    %   cost = acceptSwap()  % alter internal variables to reflect accepted swap
    %   cost = rejectSwap() % set internal variables to reflect rejection of proposed swap
    %   plotDistribution() % plots the probability distribution used to calculate entropy
    

    %% Properties
    properties
        s1 % sample entropy is calculated on
        s1Col   % data column entropy is calculated on
        s1ColName %name of column entropy is being calculated on
        nbin    % number of bins to subdivide data into
        pdSpread % type of spread of scores desired.  Options currently are 'sample' and 'allItems'.  
        ent % current entropy value
        swEnt % swap entropy value
        comparison %handle to comparison calculator (to minimize or max entropy)
        initStats % handle to method that initializes stats
        swStats % handle to method that calculates swap stats
        scores % copy of scores in the column entropy is calucated for.
        swScores % copy of scores if a swap occured
        bins % mid-point of bins data is divided into
        swBins % mid-point of bins data is divided into after a swap
        pd % probability distribution of scores
        swpd % probability distribution of swap socres
        minScore % min score in set
        swMinScore % min score in swap set
        maxScore % max score in set
        swMaxScore % max score in swap set.  
        figHandle % handle to figure for plotting entropy
    end
    
    %% Properties (Constant)
    properties (Constant)
        s2 = NaN; % s2 = NaN; for consistency with other methods, there is a swap2 property, but it is just set to a null-like value.  
        smallVal = 0.00000001 % small value added to avoid case where a value is exactly equal the min or max range of the distribution
    end
        
    
    methods
        %% obj = softEntropyConstraint(varargin) CONSTRUCTOR
        function obj = softEntropyConstraint(varargin)
            % Constructs a softEntropy constraint object
            %
            % PARAMETERS:
            % REQUIRED:
            %   'sosObj'/sos object - the SOS object the constraint will be linked to, and which contains the sample the constraint operates on.  
            %   'constraintType'/'soft' - the type of contraint - must be 'soft'
            %   'fnc'/'minEnt'|'maxEnt' the entropy cost to calculate.
            %   'sample1'/sample - the first sample
            %   's1ColName'/string - name of column in 1st sample
            %   'pSpread'/'sample'|'allItems'  Should entropy be maximized relative to sample items only, or to the theoretical min and max values in the population?
            %
            %
            % OPTIONAL:
            %   'nbin'/integer - number of bins to divide data into for
            %       purposes of calculating probability distribution.  Defaults
            %       to number of items in the sample.  Must be greater than 2
            %       and <= number of items in the sample
            %   'exponent'/numeric - defaults to 2 (quadratic difference)
            %   'weight'/numeric - defaults to 1 (equal weighting of all soft costs)    
            
            p = inputParser;

            p.addParamValue('sosObj','null',@(sosObj)strcmp(class(sosObj),'sos'));
            p.addParamValue('constraintType', 'null', ...
                @(constraintType)any(strcmp({'soft'},constraintType)));
            p.addParamValue('fnc','null', ...
                 @(fnc)any(strcmp({'minEnt' 'maxEnt'},fnc)));
            p.addParamValue('nbin',2,@(nbin)validateattributes(nbin, {'numeric'}, ...
                {'scalar', 'integer', 'positive', '>', 0}));
            p.addParamValue('pdSpread','null', ...
                 @(pdSpread)any(strcmp({'sample' 'allItems'},pdSpread)));
            p.addParamValue('sample1','null',@(sample1)strcmp(class(sample1),'sample'));
            p.addParamValue('s1ColName','',@(s1ColName)ischar(s1ColName));
            p.addParamValue('exponent',2,@(exponent)isnumeric(exponent));
            p.addParamValue('weight',1,@(weight)isnumeric(weight));
            p.addParamValue('name','noname',@(name)ischar(name));
            
            p.parse(varargin{:});
            
            % check additional constraints on values submitted to the
            % constructor
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
            
            if any(strcmp(p.UsingDefaults,'nbin'))
                obj.nbin = p.Results.sample1.n;
            else
                if p.Results.nbin <= p.Results.sample1.n
                    obj.nbin = p.Results.nbin;
                else
                    error('Number of bins must be <= number of observations in the sample');
                end
            end
            
            if obj.nbin < 2
                error ('There must be at least 2 bins in the entropy calculation');
            end
            
            
            %assign the appropriate handles for the calculation.       
            obj.sosObj = p.Results.sosObj;
            obj.constraintType = p.Results.constraintType;
            obj.fnc = p.Results.fnc;           
            obj.weight = p.Results.weight;
            obj.s1 = p.Results.sample1;     
            obj.s1ColName = p.Results.s1ColName;
            obj.s1Col = col1;   
            obj.exp = p.Results.exponent;      
            
            obj.initStats = @obj.initEnt;
            obj.swStats = @obj.swEntropy;
            
            if(strcmp(p.Results.fnc,'minEnt'))
                obj.comparison = @obj.minEnt;
            elseif(strcmp(p.Results.fnc,'maxEnt'))
               obj.comparison = @obj.maxEnt;
            else
                error('Entropy <fnc> must be either "minEnt" or "maxEnt"');
            end

            if(any(strcmp({'sample' 'allItems'},p.Results.pdSpread)))
                obj.pdSpread = p.Results.pdSpread;
            else
                error('pdSpread must be either "sample" or "allItems"');
            end
             
            obj.cost = NaN;
            obj.swCost = NaN;
            
            % add the name and the label
            obj.label = [obj.constraintType,'_',obj.fnc,...
                    '_pd_',obj.pdSpread,'_nbin',num2str(obj.nbin),'_',...
                    obj.s1.name,'_',...
                    obj.s1ColName,'_w',...
                    num2str(obj.weight),'_e',num2str(obj.exp)];              
            if any(strcmp(p.UsingDefaults,'name'))                 
                obj.name = obj.label;
            else
                 obj.name = p.Results.name;  
            end     
            
            
            verbosePrint('Soft Entropy Constraint has been created', ...
                    'softEntropyConstraint_Constructor_endObjCreation');
        end % constructor
        
            
        %% cost = initCost() METHOD
        function cost = initCost(obj)
            % Calculates, saves, and returns the cost value for the current items in the sample.  
          
            %init the stats, then compare them.  Return the calculated cost
            obj.initStats(); 
            cost = obj.comparison(obj.ent);
            
            obj.swEnt = NaN;
            obj.swScores = NaN;
            obj.swpd = NaN;
            obj.swMinScore = NaN;
            obj.swMaxScore = NaN;
                       
            obj.cost = cost;
            
        end %initCost
        
        %% initEnt() METHOD
        function initEnt(obj)
            % calculates the initial entropy value for the scores in
            % sample1<sample1Col>
            
            obj.scores = (obj.s1.zdata{obj.s1Col})';
            
            
            % get min and max values for the probability distribution:
            %this procedure is different depending on whether we are using
            %the sample as the range or allItems
            
            if strcmp(obj.pdSpread,'sample')
                minVal = min(obj.scores);
                maxVal = max(obj.scores);    
            elseif strcmp(obj.pdSpread,'allItems')
                %check in the population
                minVal = min([obj.s1.population.zdata{obj.s1Col}]);
                maxVal = max([obj.s1.population.zdata{obj.s1Col}]);

                %check in all samples associated with the population (this
                %includes the original one
                for i=1:length(obj.s1.population.samples)
                    minVal = min([minVal; ...
                        obj.s1.population.samples(i).zdata{obj.s1Col}]);
                    maxVal = max([maxVal; ...
                        obj.s1.population.samples(i).zdata{obj.s1Col}]);                
                end
            else
                error('Unsupported pdSpread in initEnt.  pdSpread must be "sample" or "allItems"');
            end
                
            % add a smallVal to avoid boundary cases
            minVal = minVal - obj.smallVal;
            maxVal = maxVal + obj.smallVal;
            
            %now have min and max values, determine size of each bin:
            obj.minScore = minVal;
            obj.maxScore = maxVal;
            
            spread  = maxVal - minVal;            
            binSize = spread/obj.nbin;
            
            %smallVal added so that the last score is included (simulating
            %<= rather than <
            obj.bins = (minVal+0.5*binSize):binSize:(maxVal-0.5*binSize)+obj.smallVal;
              
            % scale values to 0-1
            obj.pd = hist(obj.scores,obj.bins)/length(obj.scores);
           
            
            % calculate entropy
            obj.ent = obj.pd*log((obj.pd+1)')/length(obj.pd);     
            obj.ent = -1* (obj.ent - 1/length(obj.pd)*log(1/length(obj.pd)+1)) / ...
                (1*log(2)/length(obj.pd) - 1/length(obj.pd)*log(1/length(obj.pd)+1));
           
        end % initEnt
        
        %% cost = minEnt(curEnt) METHOD
        function cost = minEnt(obj,curEnt)
            % calculates the cost associated with curEnt, when minimal entropy is desired 
            cost = -(abs((curEnt))^obj.exp)*obj.weight;
        end
        
        %% cost = maxEnt(curEnt)
        function cost = maxEnt(obj,curEnt)
            % calculates the cost associated with curEnt, when maximal entropy is desired 
            cost = (abs((curEnt))^obj.exp)*obj.weight;
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
 
            
           if (obj.s1 ~= targSample && obj.s1 ~= feederdf)
               error('swCost called, but no sample part of this cost function');
           end

           % update the stats, then calculate cost of new stats
           obj.swStats(targSample,targSampleIndex, feederdf,feederdfIndex);
           
           swCost = obj.comparison(obj.swEnt);
            
           obj.swCost = swCost;
              
        end

        %% swEnt(targSample,targSampleIndex,feederdf,feederdfIndex) METHOD
        function swEntropy(obj,targSample,targSampleIndex, feederdf,feederdfIndex)
           % Calculates the new (swap) entropy if items from targSample and feederdf were swapped.
           % 
           % Inputs are the same as for swapCost()
 
           
           
           obj.swScores = obj.scores;
           obj.swpd = obj.pd;
           obj.swMinScore = obj.minScore;
           obj.swMaxScore = obj.maxScore;
           obj.swBins = obj.bins;
           
           % re-extract the raw, unnormalized entropy value from the
           % current entropy
           rawEnt = obj.ent;
           rawEnt = rawEnt *(1*log(2)/length(obj.pd) - 1/length(obj.pd)*log(1/length(obj.pd)+1));
           rawEnt = rawEnt*-1;
           rawEnt = rawEnt + 1/length(obj.pd)*log(1/length(obj.pd)+1);
      
           spread  = obj.swMaxScore - obj.swMinScore;            
           binSize = spread/obj.nbin;
                
           recalculate = false;

            if targSample == obj.s1
                
                obj.swScores(targSampleIndex) = ...
                    feederdf.zdata{obj.s1Col}(feederdfIndex);
                
                % if the min and max bounds may change and we're only
                % calculating the entropy of the sample and letting the
                % range of the sample vary dynamically, recalculate entropy
                % from scratch
                if(strcmp(obj.pdSpread,'sample') && ...
                    (lt(obj.swScores(targSampleIndex)-obj.smallVal, obj.minScore) || ...
                     gt(obj.swScores(targSampleIndex)+obj.smallVal, obj.maxScore) || ...
                     obj.scores(targSampleIndex)-obj.smallVal == obj.minScore || ...
                     obj.scores(targSampleIndex)+obj.smallVal == obj.maxScore))
                
                    recalculate = true;
                else
                   %we can do a local update 
                
                   found = false;
                   
                   % find the old bin:
                   for i=1:(length(obj.swBins))
                     
                       
                       if (obj.scores(targSampleIndex) >= obj.swBins(i) - 0.5*binSize ...
                               && obj.scores(targSampleIndex) < obj.swBins(i)+0.5*binSize) 
                               
                           %remove the old score
                           rawEnt = rawEnt - obj.swpd(i)*log(obj.swpd(i)+1)/length(obj.pd);
                           obj.swpd(i) = obj.swpd(i) - 1/length(obj.scores);
                           rawEnt = rawEnt + obj.swpd(i)*log(obj.swpd(i)+1)/length(obj.pd);
                           found = true; 
                           break;
                       end
                   end
                   
                   if found == false
                       error('unable to find the swap bin');
                   end
                   
                   found = false;
                  
                    for i=1:(length(obj.swBins))
                       if obj.swScores(targSampleIndex) >= obj.swBins(i) - 0.5*binSize ...
                               && obj.swScores(targSampleIndex) < obj.swBins(i) + 0.5*binSize
                           %add the new score
                           
                           rawEnt = rawEnt - obj.swpd(i)*log(obj.swpd(i)+1)/length(obj.pd);
                           obj.swpd(i) = obj.swpd(i) + 1/length(obj.scores);
                           rawEnt = rawEnt + obj.swpd(i)*log(obj.swpd(i)+1)/length(obj.pd);
                           
                            found = true;
                           break;
                       end
                    end  
                   
                   if found == false
                       error('unable to find the swap bin');
                   end
                   
                end                
             end
                               
             if feederdf == obj.s1
                
                obj.swScores(feederdfIndex) =  ...
                    targSample.zdata{obj.s1Col}(targSampleIndex);
 
                % if using the sample's spread and the new score could
                % exceed the existing bounds, recalculate from sractch
                if(strcmp(obj.pdSpread,'sample') && ...
                        (lt(obj.swScores(feederdfIndex)-obj.smallVal, obj.minScore) || ...
                         gt(obj.swScores(feederdfIndex)+obj.smallVal, obj.maxScore) || ...
                         obj.scores(feederdfIndex)-obj.smallVal == obj.minScore || ...
                         obj.scores(feederdfIndex)+obj.smallVal == obj.maxScore))
                
                    recalculate = true;
                else
                   %we can do a local update 
                  
                   found = false;
                   

                   
                   % find the old bin:
                   for i=1:(length(obj.swBins))
                       if obj.scores(feederdfIndex) >= obj.swBins(i) - 0.5*binSize ...
                               && obj.scores(feederdfIndex) < obj.swBins(i) + 0.5*binSize
                           %remove the old score
                           rawEnt = rawEnt - obj.swpd(i)*log(obj.swpd(i)+1)/length(obj.pd);
                           obj.swpd(i) = obj.swpd(i) - 1/length(obj.scores);
                           rawEnt = rawEnt + obj.swpd(i)*log(obj.swpd(i)+1)/length(obj.pd);
                            
                           found = true;
                           break;
                       end
                   end
                   
                   if found == false
                       error('Unable to find the old bin');
                   end
                   
                   found = false;
                    for i=1:(length(obj.swBins))
                       if obj.swScores(feederdfIndex) >= obj.swBins(i) - 0.5*binSize ...
                               && obj.swScores(feederdfIndex) < obj.swBins(i) + 0.5*binSize
                           %add the new score
                           rawEnt = rawEnt - obj.swpd(i)*log(obj.swpd(i)+1)/length(obj.pd);
                           obj.swpd(i) = obj.swpd(i) + 1/length(obj.scores);
                           rawEnt = rawEnt + obj.swpd(i)*log(obj.swpd(i)+1)/length(obj.pd);
                         
                           found = true;
                           break;
                       end
                    end    
                    
                    if found == false
                       error('Unable to find an appropriate swbin for the data');
                    end
                   
                end                
            end
            
            % a local update is possible if neither of the swap scores
            % exceeds the current spread.  
            
            %recalculate = true;
            
            if recalculate == true
                %re-derive all measures
                minVal = min(obj.swScores);
                maxVal = max(obj.swScores);  
                
                minVal = minVal - obj.smallVal;
                maxVal = maxVal + obj.smallVal;
                
                %now have min and max values, determine size of each bin:
                obj.swMinScore = minVal;
                obj.swMaxScore = maxVal;

                spread  = maxVal - minVal;            
                binSize = spread/obj.nbin;
                % remove the small -1.0e-14 value to avoid rounding errors
                % that result in non-overlapping bins.  So long as this
                % number is < e-16 then this appears to prevent these
                % rounding errors.  And so long as this number is
                % substantially smaller than smallVal it will not interfere
                % with the actual bin sizes (currently smallVal is <
                % 1.0-e10)
                obj.swBins = (minVal + 0.5*binSize):binSize:(maxVal - 0.5*binSize)+obj.smallVal;

                for i=1:length(obj.swBins)
                    obj.swBins(i) = obj.swBins(i) - 1.0e-14;
                end

                obj.swpd = hist(obj.swScores,obj.swBins)/length(obj.scores);
                obj.swEnt = obj.swpd*log((obj.swpd+1)')/length(obj.pd);     
                obj.swEnt = -1* (obj.swEnt - 1/length(obj.pd)*log(1/length(obj.pd)+1)) / ...
                    (1*log(2)/length(obj.pd) - 1/length(obj.pd)*log(1/length(obj.pd)+1));
            
            else
                % cannot exceed bounds because min and max were taken from
                % the population.  Proceed with local update
                obj.swEnt = -1* (rawEnt - 1/length(obj.pd)*log(1/length(obj.pd)+1)) / ...
                    (1*log(2)/length(obj.pd) - 1/length(obj.pd)*log(1/length(obj.pd)+1));
                            
            end
               
            if isnan(obj.swEnt)
                error('NaN obtained during swEnt computation (perhaps there is missing data for an item?)');
            end
      
        end %swEntropy()

        
       %% cost = acceptSwap() METHOD
        function cost = acceptSwap(obj)
            % alter internal variables to reflect accepted swap
            
            
            if isnan(obj.swEnt) 
                %do nothing, no need to swap
            else
                obj.ent = obj.swEnt;
                obj.swEnt = NaN;
                obj.scores = obj.swScores;
                obj.swScores = NaN;

               obj.pd = obj.swpd;
               obj.swpd = NaN;

               obj.minScore = obj.swMinScore;
               obj.swMinScore = NaN;
               obj.maxScore = obj.swMaxScore;
               obj.swMaxScore = NaN;
               
               obj.bins = obj.swBins;
               obj.swBins = NaN;
                      
            end
            
            cost = acceptSwap@genericConstraint(obj);
        end

        %% cost = rejectSwap() METHOD
        function cost = rejectSwap(obj)
            % set internal variables to reflect rejection of proposed swap
            obj.swEnt = NaN;
            obj.swScores = NaN;
            obj.swpd = NaN;
            obj.swMinScore = NaN;
            obj.swMaxScore = NaN;
            
            obj.swBins = NaN;
                        
            cost = rejectSwap@genericConstraint(obj);
        end
        
        %% plotDistribution() METHOD
        function plotDistribution(obj)
            % plots the probability distribution used to calculate entropy
            
            % make the entropy figure the active figure
            if isempty(obj.figHandle)
                obj.figHandle = figure('Name',['Entropy - ',obj.s1.name, ...
                    '|',obj.s1ColName],'NumberTitle','off');
                
            end
            
            figure(obj.figHandle);
            
            if isempty(obj.cost) == false && isnan(obj.cost) == false %the constraints have not been initialized
                clf();
                

                if strcmp(obj.pdSpread,'sample')
                    minVal = min(obj.s1.data{obj.s1Col});
                    maxVal = max(obj.s1.data{obj.s1Col});
                elseif strcmp(obj.pdSpread,'allItems')
                    %check in the population
                    minVal = min([obj.s1.population.data{obj.s1Col}]);
                    maxVal = max([obj.s1.population.data{obj.s1Col}]);

                    %check in all samples associated with the population (this
                    %includes the original one
                    for i=1:length(obj.s1.population.samples)
                        minVal = min([minVal; ...
                            obj.s1.population.samples(i).data{obj.s1Col}]);
                        maxVal = max([maxVal; ...
                            obj.s1.population.samples(i).data{obj.s1Col}]);                
                    end
                else
                    error('Unsupported pdSpread in initEnt.  pdSpread must be "sample" or "allItems"');
                end

                % add a smallVal to avoid boundary cases
                minVal = minVal - obj.smallVal;
                maxVal = maxVal + obj.smallVal;

                spread  = maxVal - minVal;            
                binSize = spread/obj.nbin;

                %smallVal added so that the last score is included (simulating
                %<= rather than <
                tmpbins = (minVal+0.5*binSize):binSize:(maxVal-0.5*binSize)+obj.smallVal;

                % scale values to 0-1
                tmppd = hist(obj.s1.data{obj.s1Col},obj.nbin)/length(obj.s1.data{obj.s1Col});
                
                bar(tmpbins,tmppd,'hist');
                ylim([0 1]);
                title(['Entropy - ',obj.s1.name, ...
                    '|',obj.s1ColName]);
                 xlabel([obj.s1ColName, ]);%' - each bar is centered on bin mid-point']);
                ylabel('p(item from a particular bin)');
            else
                clf();
                ylim([0 1]);
                title(['Entropy - ',obj.s1.name, ...
                    '|',obj.s1ColName]);
                xlabel([obj.s1ColName, ]);%' - each bar is centered on bin mid-point']);
                ylabel('p(item from a particular bin)');
                text(0.5,0.5,'Cost must be initialized before data is plotted', ...
                    'HorizontalAlignment','center');
            end
            

                      
          
        end
        
    end
    
end

