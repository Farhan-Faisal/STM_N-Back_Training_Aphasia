% - test for equivalence of two correlations
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


classdef sosCorrelTest < handle
    % runs user-specified z-tests on equivalence of a sample and a specified
    % target (population) correlation coefficient, 
    % and tests user hypotheses on their outcomes
    % NOTE: This uses a z-score approximation when testing the equivalence
    %   of the sample and population correlation coefficients.  Using
    %   sample sizes < 10 is not recommended, and a sample size of at least
    %   4 is required to have sufficient df for the test.
    %   Additionally, you should avoid trying to match to a correlation of 
    %   1.0, beceause that is undefined in the equation.  
    %   Further, note that for a same p-value, closer matches are required
    %   nearer to a correlation of 1.0 than to a correlation of 0, by
    %   virtue of the nonlinearity which is part of the stats test.  
    %
    %PROPERTIES
    %     sosObj % sos object the test is associated with
    %     name % string label to associate with the test
    %     s1 % sample1
    %     s2 % sample2
    %     s1ColName % column name of data in sample1
    %     s2ColName % column name of data in sample2
    %     s1Col   % column index in sample1
    %     s2Col   % column index in sample2
    %     type    % type of ztest (currently only 'matchCorrel')
    %     runSpecificTest % handle to specific test method
    %     desiredpvalCondition % indicates the desired outcome of the test, either NaN, <= or >=
    %     desiredpvalConditionHandle  % handle to the function that will evaluate whether the desiredpValCondition was met
    %     desiredpval % desired p-val to test against
    %     targValue % target correlation value for the test
    %     tail % tail of test.  left -> t-vals < 0, right = t-vals > 0; both = pos. and neg. z-score will reject the null
    %     lastp % last p-value that was calcualted
    %
    %METHODS:
    %   sosCorrelTest(sosObj,varargin)  %constructs an sosCorrelTest object of the specified type. 
    %   constructMatchCorrelztest(obj,sosObj,varargin)  %initialize object
    %   [userHypothesis, prob, label] = runTest(obj,varargin) %runs the test
    %   [userHypothesis, prob, label] =  runMatchCorrelztest(obj,varargin) % runs a matchCorrel test
    %
    %METHODS (Static)
    %   userHypothesis = returnNaN(~,~)  % returns NaN
    %   flag = validTestType(str) % returns 1 if the name of type of test is 'matchCorrel'; error otherwise.    

    
    %% PROPERTIES
    properties
        sosObj % sos object the test is associated with
        name % string label to associate with the test
        s1 % sample1
        s2 % sample2
        s1ColName % column name of data in sample1
        s2ColName % column name of data in sample2
        s1Col   % column index in sample1
        s2Col   % column index in sample2
        type    % type of ttest (paired,independent,
        runSpecificTest % handle to specific test method
        desiredpvalCondition % indicates the desired outcome of the test, either NaN, <= or >=
        desiredpvalConditionHandle  % handle to the function that will evaluate whether the desiredpValCondition was met
        desiredpval % desired p-val to test against
        targVal % target value for single-sample ttest 
        tail % tail of test.  left -> t-vals < 0, right = t-vals > 0; both = pos. and neg. t will reject the null
        lastp % last p-value that was calcualted
        label % label denoting what is being tested
    end % properties
    
    methods
        
        %% sosCorrelTest CONSTRUCTOR
        function obj = sosCorrelTest(varargin)
            %constructs an sosCorrelTest object of the specified type. 
            %
            %PARAMETERS:
            % sosObj - sosObject test will be associated with
            % 'type'/string, type of test - ('matchCorrel' only currently)
            % 'sample1'/sample - a sample associated with sosObj. 
            % ... Other parameters as required by the constructor for the
            % specific type of t-test requested.  See those constructors
            % for additional info.
            % 
            % Returns an sosCorrelTest object.
            

            % perform basic checks for universally required components of
            % the z-test
            p = inputParser;
            p.addParamValue('sosObj', 'null',...
                @(sosObj)strcmp(class(sosObj),'sos'));
            p.addParamValue('type','null', ...
                @(type)sosCorrelTest.validTestType(type));
            p.addParamValue('sample1','null', ...
                            @(sample1)strcmp(class(sample1),'sample'));            
            p.addParamValue('name','noname',@(name)ischar(name));
            
            %keep all of the parameters for specific t-tests
            p.KeepUnmatched = true;
            p.parse(varargin{:});

            
            
            %basic checks are passed, construct the specific type of t-test
            %that has been requested

           sosObj = p.Results.sosObj; %#ok<PROP>
           
            if(strcmp(p.Results.type,'matchCorrel'))
                obj.constructMatchCorrelztest(sosObj,varargin{:}) %#ok<PROP>
            else 
               error(['Specified <type>: ',p.Results.type, ...
                        ' is not supported']);  
            end

            obj.lastp = NaN;
            obj.sosObj = p.Results.sosObj;
            
            % add the test's name.  
            if any(strcmp(p.UsingDefaults,'name'))
                 
                 numTests = length(obj.sosObj.sosstattests);
                
             obj.name = ['ztest_',num2str(numTests+1)];  
             else
                 obj.name = p.Results.name;  
             end
            
        end % Constructor
        

        %% [userHypothesis, prob, label] = runTest(obj,varargin) METHOD
        function [userHypothesis, prob, label] = runTest(obj,varargin)
            %runs the ztest
            %
            % PARAMETERS:
            % 'reportStyle'/'short'|'full'/'none' - style of report to be
            %           printed.  Either none, short or full
            %
            % RETURNS:
            %   userHypothesis - whether the user's hypothesis has been met or not. NaN if no user hypothesis for the test.  
            %   prob - p-value from the ttest
            %   label - string label denoting what was tested.
            
            [userHypothesis, prob, label] = obj.runSpecificTest(varargin);
            obj.lastp = prob;
        end
        
        
        %% [userHypothesis, prob, label] =  runMatchCorrelztest(varargin) METHOD
        function [userHypothesis, prob, label] = ...
                runMatchCorrelztest(obj,varargin)
            %runs a matchCorrel test
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

            
            
            % Run the stats test
            sumx1sq = sum((obj.s1.zdata{obj.s1Col}).^2);
            sumx1 = sum((obj.s1.zdata{obj.s1Col}));
            n1 = length(obj.s1.zdata{obj.s1Col});
            
            sumx2sq = sum((obj.s2.zdata{obj.s2Col}).^2);
            sumx2 = sum((obj.s2.zdata{obj.s2Col}));
            n2 = length(obj.s2.zdata{obj.s2Col});
            
            sumx1x2 = (obj.s1.zdata{obj.s1Col})' * (obj.s2.zdata{obj.s2Col});
            
            ssx1 = sumx1sq - ((sumx1)^2)/n1;
            ssx2 = sumx2sq - ((sumx2)^2)/n2;
            
            spx1x2 = sumx1x2 - sumx1*sumx2/n1;
            
            % defining overrides...
            if(ssx1 == 0 && ssx2 == 0) % no variance in either condition, define correlation as being perfect in this case
                cor = 1;
            elseif(ssx1 == 0 || ssx2 == 0)
                cor = 0;
            else % compute correlation normally
                cor = spx1x2/(sqrt(ssx1)*sqrt(ssx2));
            end
            
            % convert correlation to z-score
            
            r= cor;
            
            if n1 > 4
                % we can compute the z-score
                
                z = (0.5*log((1+r)/(1-r)) - 0.5*log((1+obj.targVal)/(1-obj.targVal))) ...
                        /(1/sqrt(n1-3));
                [h,prob,ci,stats] = ztest(z,0,1);     %#ok<ASGLU>
            else
                %we can't convert sinze formula has sqrt of N-3 in denom
                
                %special override cases...
            end
            
            
% From ttest code.  Can remove.
%             % if prob was NaN, it's because the denominator in the t-test 
%             % was 0.  So just check the means manually to determine
%             % prob
%             if isnan(prob)
%              m1 = mean(obj.s1.data{obj.s1Col});
%              m2 = mean(obj.s2.data{obj.s2Col});
%              
%              if m1==m2
%                  prob = 1;
%              else
%                  prob = 0;
%              end
%              
%             end
             
            userHypothesis = obj.desiredpvalConditionHandle(...
                                  prob,obj.desiredpval);
             
             label = [obj.s1.name, '{',obj.s1ColName, '}-', ...
                    obj.s2.name, '{',obj.s2ColName, '}'];
             
             if (isnan(userHypothesis))
                 printHyp = 'N/A';
             elseif userHypothesis == 1
                 printHyp = 'PASS';
             elseif userHypothesis == 0
                 printHyp = 'FAIL';
             end
                 
             
             if (strcmp(reportStyle,'short'))
                verbosePrint([' UserHyp: ', printHyp, '; ', label, ': ', ...
                     'z[',obj.type,'](',num2str(n1),') = ', ...
                     num2str(stats), ', p = ', num2str(prob), ...
                     ' p-des: ',num2str(obj.desiredpval)], ...
                     'sosCorrelTest_runMatchCorrelztest');
             elseif (strcmp(reportStyle,'full'))
                 verbosePrint([' UserHyp: ', printHyp , ...
                     '; ', label, ': ', ...
                     'z[',obj.type,'](',num2str(n1),') = ', ...
                     num2str(stats), ', p = ', num2str(prob), ...  
                     ' p-des: ',num2str(obj.desiredpval), ...
                     ' cor = ', num2str(r),' targCor = ', num2str(obj.targVal)], ...
                     'sosCorrelTest_runMatchCorrelztest');
             end                            
        end 

        
 
        
        %% constructMatchCorrelztest(sosObj,varargin) METHOD
        function constructMatchCorrelztest(obj,sosObj,varargin)
            %initialize an matchCorrel z-test object.
            % Assumes equal variance.  
            %
            % PARAMETERS:
            % Required:
            %   sosObj - sos Object test is to be associated with
            %   sample1 - a sample object
            %   sample2 - a sample object
            %   s1ColName - name of data column in sample1
            %   s2ColName - name of data column in sample2 
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
            %   targVal - the target correlation value to match (must be in
            %   range (-1,1) (note round, not square brackets, as -1 and 1
            %   are NOTE allowed)
            %   
            % RETURNS:
            %   Configured sosCorrelTest object.
            

            p = inputParser;

            p.addRequired('sosObj', ...
                @(sosObj)strcmp(class(sosObj),'sos'));
            p.addParamValue('type','null', ...
                @(type)sosCorrelTest.validTestType(type));
            p.addParamValue('sample1','null', ...
                        @(sample1)strcmp(class(sample1),'sample'));
            p.addParamValue('sample2','null', ...
                        @(sample2)strcmp(class(sample2),'sample'));
            %NaN will fail by default
            p.addParamValue('s1ColName',NaN, ...
                @(s1ColName)ischar(s1ColName));
            p.addParamValue('s2ColName',NaN, ...
                @(s2ColName)ischar(s2ColName));
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
            p.addParamValue('name','noname',@(name)ischar(name)); % dealt with in the main constructor
            p.addParamValue('targVal',0.0, ... 
                @(targVal)validateattributes(targVal, ...
                    {'numeric'}, ...
                    {'scalar', '>=', -1, '<=', 1}));
            p.parse(sosObj,varargin{:});


            sample1 = p.Results.sample1;
            sample2 = p.Results.sample2;
            s1ColName = p.Results.s1ColName; %#ok<PROP>
            s2ColName = p.Results.s2ColName; %#ok<PROP>
            obj.desiredpvalCondition = p.Results.desiredpvalCondition;
            

            if strcmp(obj.desiredpvalCondition,'N/A')
                obj.desiredpvalConditionHandle = @sosCorrelTest.returnNaN;
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

            present2 = sosObj.containsSample(sample2);
            if (present2 == 0 )
                error('sos sosObject does not contain sample2');
            end               

            col1 = sample1.colName2colNum(s1ColName); %#ok<PROP>
            if(col1 == -1)
                error('<s1ColName> not a column of data in <sample1>');
            end

            col2 = sample1.colName2colNum(s2ColName); %#ok<PROP>
            if(col2 == -1)
                error('<s2ColName> not a column of data in <sample2>');
            end
            
            if isempty(sample1.data)
                error('sample 1 does not contain items - did you fill it yet?');
            end
            
            if isempty(sample2.data)
                error('sample 2 does not contain items - did you fill it yet?');
            end   
            %all variables check out, create the stats test

            
            if (length(sample1.data{col1}) ~= length(sample2.data{col2}))
                error('Sample 1 and Sample 2 must have the same number of observations for a paired comparison');
            end
            
            if sample1.n < 4
                % see note in the calculation for why the following is the
                % case
                error('The sosCorrelTest requires at least 4 items per sample');
            end
            
            
            obj.s1 = sample1;
            obj.s2 = sample2;
            obj.s1ColName = s1ColName; %#ok<PROP>
            obj.s2ColName = s2ColName; %#ok<PROP>
            obj.s1Col = col1;
            obj.s2Col = col2;
            obj.type = p.Results.type;
            obj.tail = p.Results.tail;
            obj.targVal = p.Results.targVal;

            obj.runSpecificTest = @obj.runMatchCorrelztest;
            
            obj.label = [obj.s1.name, '{',obj.s1ColName, '}-', ...
                    obj.s2.name, '{',obj.s2ColName, '}', ...
                    ':z[',obj.type,']'];            
          
                
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
            % returns 1 if the name of type of test is 'matchCorrel'; error otherwise.
            
            flag = 0; %#ok<NASGU>
            
            if(ischar(str) == false)
                error('<Type> must be "matchCorrel"');
            end
            
            if (strcmp(str,'matchCorrel'))
                flag = 1;   
            else
                error('<Type> must be "matchCorrel"');
            end
            
        end
    end
    
end

