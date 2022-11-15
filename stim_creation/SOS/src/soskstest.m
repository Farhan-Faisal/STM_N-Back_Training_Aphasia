% - object for testing normality using a Kolmogorov-Smirnov test
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


classdef soskstest < handle
    % runs user-specified Kolmogorov-Smirnov tests to evaluate whether the 
    % distribution of values on a given dimension is uniform.
    %   Note: test may be under-powered for sample sizes < 10.  Requires at
    %   least 2 bins in the histogram.  
    %   Requiring a p > 0.001 to infer that a distribution is uniform is
    %   probably more than sufficiently in most cases.  Considerably smaller
    %   values may still yeild quite acceptable results.  

    %
    %PROPERTIES
    %     sosObj % sos object the test is associated with
    %     name % string label to associate with the test
    %     s1 % sample1
    %     s1ColName % column name of data in sample1
    %     s1Col   % column index in sample1
    %     type    % type of ztest (currently only 'matchUniform')
    %     runSpecificTest % handle to specific test method
    %     desiredpvalCondition % indicates the desired outcome of the test, either NaN, <= or >=
    %     desiredpvalConditionHandle  % handle to the function that will evaluate whether the desiredpValCondition was met
    %     desiredpval % desired p-val to test against
    %     tail % tail of test. % Does nothing currently; must be modified for 'upper and 'lower
    %     lastp % last p-value that was calcualted
    %
    %METHODS:
    %   sosCorrelTest(sosObj,varargin)  %constructs an soskstest object of the specified type. 
    %   constructMatchCorrelztest(obj,sosObj,varargin)  %initialize object
    %   [userHypothesis, prob, label] = runTest(obj,varargin) %runs the test
    %   [userHypothesis, prob, label] =  runkstest(obj,varargin) % runs a%   kstest
    %
    %METHODS (Static)
    %   userHypothesis = returnNaN(~,~)  % returns NaN
    %   flag = validTestType(str) % returns 1 if the name of type of test is 'matchUniform'; error otherwise.    

    
    %% PROPERTIES
    properties
        sosObj % sos object the test is associated with
        name % string label to associate with the test
        s1 % sample1
        s1ColName % column name of data in sample1
        s1Col   % column index in sample1
        type    % type of test('matchUniform')
        runSpecificTest % handle to specific test method
        desiredpvalCondition % indicates the desired outcome of the test, either NaN, <= or >=
        desiredpvalConditionHandle  % handle to the function that will evaluate whether the desiredpValCondition was met
        desiredpval % desired p-val to test against
        tail % tail of test.  %currently does nothing, but must be recoded as 'upper' and 'lower'
        label % label denoting what is being tested
        pdSpread % 'sample' or 'allItems', as in the entropy constraint
        nbin % number of bins in the pdSpread
        lastp % last p-value reported by the test
    end % properties

   %% Properties (Constant)
    properties (Constant)
        smallVal = 0.00000001 % small value added to avoid case where a value is exactly equal the min or max range of the distribution
    end
    
    
    methods
        
        %% sosCorrelTest CONSTRUCTOR
        function obj = soskstest(varargin)
            %constructs an soskstest object of the specified type. 
            %
            %PARAMETERS:
            % sosObj - sosObject test will be associated with
            % 'type'/string, type of test - ('matchUniform' only currently)
            % 'sample1'/sample - a sample associated with sosObj. 
            % ... Other parameters as required by the constructor for the
            % specific type of t-test requested.  See those constructors
            % for additional info.
            % 
            % Returns a kstest object.
            

            % perform basic checks for universally required components of
            % the kstest
            p = inputParser;
            p.addParamValue('sosObj', 'null',...
                @(sosObj)strcmp(class(sosObj),'sos'));
            p.addParamValue('type','null', ...
                @(type)soskstest.validTestType(type));
            p.addParamValue('sample1','null', ...
                            @(sample1)strcmp(class(sample1),'sample'));            
            p.addParamValue('name','noname',@(name)ischar(name));
            
            %keep all of the parameters for specific kstests
            p.KeepUnmatched = true;
            p.parse(varargin{:});

            
            
            %basic checks are passed, construct the specific type of t-test
            %that has been requested

           sosObj = p.Results.sosObj; %#ok<PROP>
           
            if(strcmp(p.Results.type,'matchUniform'))
                obj.constructkstest(sosObj,varargin{:}) %#ok<PROP>
            else 
               error(['Specified <type>: ',p.Results.type, ...
                        ' is not supported']);  
            end

            obj.lastp = NaN;
            obj.sosObj = p.Results.sosObj;
            
            % add the test's name.  
            if any(strcmp(p.UsingDefaults,'name'))
                 
                 numTests = length(obj.sosObj.sosstattests);
                
             obj.name = ['kstest_',num2str(numTests+1)];  
             else
                 obj.name = p.Results.name;  
             end
            
        end % Constructor
        

        %% [userHypothesis, prob, label] = runTest(obj,varargin) METHOD
        function [userHypothesis, prob, label] = runTest(obj,varargin)
            %runs the kstest
            %
            % PARAMETERS:
            % 'reportStyle'/'short'|'full'/'none' - style of report to be
            %           printed.  Either none, short or full
            %
            % RETURNS:
            %   userHypothesis - whether the user's hypothesis has been met or not. NaN if no user hypothesis for the test.  
            %   prob - p-value from the kstest
            %   label - string label denoting what was tested.
            
            [userHypothesis, prob, label] = obj.runSpecificTest(varargin);
            obj.lastp = prob;
        end
        
        
        %% [userHypothesis, prob, label] =  runkstest(varargin) METHOD
        function [userHypothesis, prob, label] = ...
                runkstest(obj,varargin)
            %runs a kstest test
            %
            % PARAMETERS:
            % 'reportStyle'/'short'|'full' - style of report to be printed.  Either short or long
            %
            % RETURNS:
            %   userHypothesis - whether the user's hypothesis has been met or not. NaN if no user hypothesis for the test.  
            %   prob - p-value from the ttest
            %   label - string label denoting what was tested.
                     
            
            varargin = varargin{1};
                      
            p = inputParser;
            
            p.addParamValue('reportStyle','short', ...
                    @(reportStyle)any([strcmp(reportStyle,'short') ...
                                    strcmp(reportStyle,'full') ...
                                    strcmp(reportStyle,'none')]));
            p.parse(varargin{:});

            
            reportStyle = p.Results.reportStyle;


            
            % calculates the initial entropy value for the scores in
            % sample1<sample1Col>
            
            scores = (obj.s1.zdata{obj.s1Col})';
 
            rawScores = (obj.s1.data{obj.s1Col})';
            
            % get min and max values for the probability distribution:
            %this procedure is different depending on whether we are using
            %the sample as the range or allItems
            
            if strcmp(obj.pdSpread,'sample')
                minVal = min(scores);
                maxVal = max(scores);    
                minRaw = min(rawScores);
                maxRaw = max(rawScores);
            elseif strcmp(obj.pdSpread,'allItems')
                %check in the population
                minVal = min([obj.s1.population.zdata{obj.s1Col}]);
                maxVal = max([obj.s1.population.zdata{obj.s1Col}]);
                minRaw = min([obj.s1.population.data{obj.s1Col}]);
                maxRaw = max([obj.s1.population.data{obj.s1Col}]);
                
                %check in all samples associated with the population (this
                %includes the original one
                for i=1:length(obj.s1.population.samples)
                    minVal = min([minVal; ...
                        obj.s1.population.samples(i).zdata{obj.s1Col}]);
                    maxVal = max([maxVal; ...
                        obj.s1.population.samples(i).zdata{obj.s1Col}]);  
                    minRaw = min([minRaw; ...
                        obj.s1.population.samples(i).data{obj.s1Col}]);
                    maxRaw = max([maxRaw; ...
                        obj.s1.population.samples(i).data{obj.s1Col}]);                      
                end
            else
                error('Unsupported pdSpread in kstest.  pdSpread must be "sample" or "allItems"');
            end
                
            % add a smallVal to avoid boundary cases
            minVal = minVal - obj.smallVal;
            maxVal = maxVal + obj.smallVal;
            
            %now have min and max values, determine size of each bin:
            
            spread  = maxVal - minVal;            
            binSize = spread/obj.nbin;
            
            %smallVal added so that the last score is included (simulating
            %<= rather than <
            bins = (minVal+0.5*binSize):binSize:(maxVal-0.5*binSize)+obj.smallVal;
              
            % scale values to 0-1
            pd = hist(scores,bins)/length(scores);
                          
            pdScores = [];            
            for i=1:length(pd)
               for j=1:pd(i)*length(scores) 
                   pdScores = [pdScores; bins(i)]; %#ok<AGROW>
               end
            end
           
            
            yScores = cdf('Uniform',bins,min(bins),max(bins));
            
            
           [h,prob,stats,cutoff] = kstest(pdScores, [bins; yScores]');     %#ok<ASGLU,NASGU>

    %       confirms that a uniform distribution fails to reject the null        
    %       [h,prob,ksstat,cutoff] = kstest(bins, [bins; yScores]');        
            
            
            % calculate entropy
            ent = pd*log((pd+1)')/length(pd);     
            ent = -1* (ent - 1/length(pd)*log(1/length(pd)+1)) / ...
                (1*log(2)/length(pd) - 1/length(pd)*log(1/length(pd)+1));
      
             
            userHypothesis = obj.desiredpvalConditionHandle(...
                                  prob,obj.desiredpval);
             
             label = [obj.s1.name, '{',obj.s1ColName, '}-', ...
                    '{Uniform}'];
             
             if (isnan(userHypothesis))
                 printHyp = 'N/A';
             elseif userHypothesis == 1
                 printHyp = 'PASS';
             elseif userHypothesis == 0
                 printHyp = 'FAIL';
             end
                 
             
             if (strcmp(reportStyle,'short'))
                verbosePrint([' UserHyp: ', printHyp, '; ', label, ': ', ...
                     'ks[',obj.type,'](',num2str(length(obj.s1.zdata{obj.s1Col})),') = ', ...
                     num2str(stats), ', p = ', num2str(prob), ...
                     ' p-des: ',num2str(obj.desiredpval)], ...
                     'soskstest_runMatchUniformkstest');
             elseif (strcmp(reportStyle,'full'))
                 verbosePrint([' UserHyp: ', printHyp , ...
                     '; ', label, ': ', ...
                     'ks[',obj.type,'](',num2str(length(obj.s1.zdata{obj.s1Col})),') = ', ...
                     num2str(stats), ', p = ', num2str(prob), ...  
                     ' p-des: ',num2str(obj.desiredpval), ...
                     ' ent = ', num2str(ent),', targmin = ',num2str(minRaw), ...
                     ', targmax = ',num2str(maxRaw)], ...
                     'soskstest_runMatchUniformkstest');
             end                            
        end 

        
 
        
        %% constructkstest(sosObj,varargin) METHOD
        function constructkstest(obj,sosObj,varargin)
            %initialize a kstest object.
            %
            % PARAMETERS:
            % Required:
            %   sosObj - sos Object test is to be associated with
            %   sample1 - a sample object
            %   s1ColName - name of data column in sample1
            %
            % Optional:
            %   desiredpvalCondition/string - desired condition for the ttest
            %       pval. Either it should exceed (=>) some value, be less
            %       than '<=' some condition, or be 'N/A' if there is no
            %       desired condition.  Default is N/A.  Note that the
            %       ordering of '=' and '<' is important, so though '<=' is
            %       valid, '=<' is not.  
            %   desiredpval - desired p-value to evaluate the condition
            %       against.  Defaults to 0.05
            %   tail - tail of test - left/right/both
            %   pdSpread -'sample' or 'allItems', as in the entropy
            %   constraint
            %   nbins - number of bins (min2, defaults to #items)
            %   
            % RETURNS:
            %   Configured sosCorrelTest object.
            

            p = inputParser;

            p.addRequired('sosObj', ...
                @(sosObj)strcmp(class(sosObj),'sos'));
            p.addParamValue('type','null', ...
                @(type)soskstest.validTestType(type));
            p.addParamValue('sample1','null', ...
                        @(sample1)strcmp(class(sample1),'sample'));
            p.addParamValue('s1ColName',NaN, ...
                @(s1ColName)ischar(s1ColName));
            p.addParamValue('desiredpvalCondition','N/A', ...
                @(desiredpvalCondition)any([strcmp(desiredpvalCondition,'<='), ...
                            strcmp(desiredpvalCondition,'=>'), ...
                            strcmp(desiredpvalCondition,'N/A')]));
            p.addParamValue('desiredpval', 0.05, ...
                @(desiredpval)validateattributes(desiredpval, ...
                    {'numeric'}, ...
                    {'scalar', 'positive', '>=', 0, '<=', 1}));
            p.addParamValue('tail','both', ...
                @(tail)any([strcmp(tail,'both'), strcmp(tail,'left'),strcmp(tail,'right')]));
            p.addParamValue('pdSpread','null', ...
                @(pdSpread)any([strcmp(pdSpread,'sample'), strcmp(pdSpread,'allItems')]));            
            p.addParamValue('name','noname',@(name)ischar(name)); % dealt with in the main constructor
            p.addParamValue('nbin',2,@(nbin)validateattributes(nbin, {'numeric'}, ...
                {'scalar', 'integer', 'positive', '>', 0}));
            p.parse(sosObj,varargin{:});

           
            

            sample1 = p.Results.sample1;
            s1ColName = p.Results.s1ColName; %#ok<PROP>
            obj.desiredpvalCondition = p.Results.desiredpvalCondition;
            obj.pdSpread = p.Results.pdSpread;
            
            
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
            
            
            if strcmp(obj.desiredpvalCondition,'N/A')
                obj.desiredpvalConditionHandle = @sosksest.returnNaN;
            elseif strcmp(obj.desiredpvalCondition,'<=')
                obj.desiredpvalConditionHandle = @le;
            elseif strcmp(obj.desiredpvalCondition,'=>')
                obj.desiredpvalConditionHandle = @ge;
            end

            % can't have a desiredpval without a desiredpvalcondition
            if strcmp(obj.desiredpvalCondition,'N/A')
                obj.desiredpval = NaN;
            else
                obj.desiredpval = p.Results.desiredpval;
            end


            % perform additional checks on the objects
            
            present1 = sosObj.containsSample(sample1);
            if (present1 == 0 )
                error('sos sosObject does not contain sample1');
            end

            col1 = sample1.colName2colNum(s1ColName); %#ok<PROP>
            if(col1 == -1)
                error('<s1ColName> not a column of data in <sample1>');
            end
            
            if isempty(sample1.data)
                error('sample 1 does not contain items - did you fill it yet?');
            end
 

            
            if sample1.n < 2
                % see note in the calculation for why the following is the
                % case
                error('The ks requires at least 2 items in the sample');
            end
            
            
            obj.s1 = sample1;
            obj.s1ColName = s1ColName; %#ok<PROP>
            obj.s1Col = col1;
            obj.type = p.Results.type;
            obj.tail = p.Results.tail;

            obj.runSpecificTest = @obj.runkstest;
            
            obj.label = [obj.s1.name, '{',obj.s1ColName, '}-{Uniform}', ...
                     ...
                    ':ks[',obj.type,']'];            
          
                
        end
 
 
    end
    
     
    methods (Static)
        
        %% userHypothesis = returnNaN(~,~) STATIC FUNCTION
        function userHypothesis = returnNaN(~,~)
            % returns NaN
            userHypothesis = NaN;
        end

        %%  flag = validTestType(str) STATIC FUNCTION
        function flag = validTestType(str)
            % returns 1 if the name of type of test is 'matchUniform'; error otherwise.
            
            flag = 0; %#ok<NASGU>
            
            if(ischar(str) == false)
                error('<Type> must be "matchUniform"');
            end
            
            if (strcmp(str,'matchUniform'))
                flag = 1;   
            else
                error('<Type> must be "matchUniform"');
            end
            
        end
    end
    
end

