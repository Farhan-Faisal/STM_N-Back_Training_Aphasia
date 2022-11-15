% - object for creating t-tests
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

classdef sosttest < genericStatTest
    % runs user-specified t-tests and tests user hypotheses on their outcomes
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
    %     type    % type of ttest (paired,independent,
    %     runSpecificTest % handle to specific test method
    %     desiredpvalCondition % indicates the desired outcome of the test, either NaN, <= or >=
    %     desiredpvalConditionHandle  % handle to the function that will evaluate whether the desiredpValCondition was met
    %     desiredpval % desired p-val to test against
    %     targValue % target value for single-sample ttest
    %     tail % tail of test.  left -> t-vals < 0, right = t-vals > 0; both = pos. and neg. t will reject the null
    %     lastp % last p-value that was calcualted
    %     thresh % threshold between two means being compared that, if below, causes the test to pass regardless of the p-value
    %
    %METHODS:
    %   sosttest(sosObj,varargin)  %constructs an sosttest object of the specified type. 
    %   constructIndependentSamplettest(obj,sosObj,varargin)  %initialize an independent samples t-test object.
    %   constructPairedSamplettest(obj,sosObj,varargin)  %initialize a paired samples t-test object
    %   constructSingleSamplettest(obj,sosObj,varargin) %initialize a single sample t-test object
    %   [userHypothesis, prob, label] = runTest(obj,varargin) %runs the ttest
    %   [userHypothesis, prob, label] =  runIndependentSamplettest(obj,varargin) %runs an independent sample ttest.  Assumes equal variance
    %   [userHypothesis, prob, label] = runPairedSamplettest(obj,varargin)  %runs a paired sample ttest   
    %   [userHypothesis, prob, label] =  runSingleSamplettest(obj,varargin)  %runs a single sample ttest    
    %
    %METHODS (Static)
    %    userHypothesis = returnNaN(~,~)  % returns NaN
    %   flag = validTestType(str) % returns 1 if the name of type of test is 'single', 'paired',  or 'independent'; error otherwise.    

    
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
        targValue % target value for single-sample ttest 
        tail % tail of test.  left -> t-vals < 0, right = t-vals > 0; both = pos. and neg. t will reject the null
        lastp % last p-value that was calcualted
        label % label denoting what is being tested
        thresh % threshold between two means being compared that, if below, causes the test to pass regardless of the p-value
    end % properties
    
    methods
        
        %% sosttest CONSTRUCTOR
        function obj = sosttest(varargin)
            %constructs an sosttest object of the specified type. 
            %
            %PARAMETERS:
            % sosObj - sosObject test will be associated with
            % 'type'/string, type of ttest - either 'paired', 'independent', or 'single'
            % 'sample1'/sample - a sample associated with sosObj. 
            % 'thresh'/numeric - % threshold between two means being
            % compared that, if below, causes the test to pass regardless of the p-value
            %
            % ... Other parameters as required by the constructor for the
            % specific type of t-test requested.  See those constructors
            % for additional info.
            % 
            % Returns an sosttest object.
            
          %  varargin = varargin{1};

            % perform basic checks for universally required components of
            % the t-test
            p = inputParser;
            p.addParamValue('sosObj', 'null',...
                @(sosObj)strcmp(class(sosObj),'sos'));
            p.addParamValue('type','null', ...
                @(type)sosttest.validTestType(type));
            p.addParamValue('sample1','null', ...
                            @(sample1)strcmp(class(sample1),'sample'));            
            p.addParamValue('name','noname',@(name)ischar(name));

            
            %keep all of the parameters for specific t-tests
            p.KeepUnmatched = true;
            p.parse(varargin{:});

            
            
            %basic checks are passed, construct the specific type of t-test
            %that has been requested

            sosObj = p.Results.sosObj; %#ok<PROP>
            
            if(strcmp(p.Results.type,'independent'))
                obj.constructIndependentSamplettest(sosObj,varargin{:}) %#ok<PROP>
            elseif(strcmp(p.Results.type,'paired'))
                obj.constructPairedSamplettest(sosObj,varargin{:}); %#ok<PROP>
            elseif strcmp(p.Results.type,'single')
                obj.constructSingleSamplettest(sosObj,varargin{:}); %#ok<PROP>
            else 
               error(['Specified <type>: ',p.Results.type, ...
                        ' is not supported']);  
            end

            obj.lastp = NaN;
            obj.sosObj = p.Results.sosObj;
           
            
            % add the test's name.  
            if any(strcmp(p.UsingDefaults,'name'))
                 
                 numTests = length(obj.sosObj.sosstattests);

                 
             obj.name = ['ttest_',num2str(numTests+1)];  
             else
                 obj.name = p.Results.name;  
             end
            
        end % Constructor
        

        %% [userHypothesis, prob, label] = runTest(obj,varargin) METHOD
        function [userHypothesis, prob, label] = runTest(obj,varargin)
            %runs the ttest
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
        
        %% [userHypothesis, prob, label] =  runIndependentSamplettest(varargin) METHOD
        function [userHypothesis, prob, label] = ...
                runIndependentSamplettest(obj,varargin)
            %runs an independent sample ttest.  Assumes equal variance
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
             
            
            % Make sure that the samples have been filled before running
            % the actual test, otherwise generate an error
            if isempty(obj.s1.data) || length(obj.s1.data{obj.s1Col}) ~= obj.s1.n
                error('sample 1 has not been filled.  Aborting stat test.');
            end
            if isempty(obj.s2.data) || length(obj.s2.data{obj.s1Col}) ~= obj.s2.n
                error('sample 2 has not been filled.  Aborting stat test.');
            end            
            
            [h,prob,ci,stats] = ttest2(obj.s1.data{obj.s1Col},...
                                   obj.s2.data{obj.s2Col},...
                                0.05,obj.tail,'equal');       %#ok<ASGLU>

            % if prob was NaN, it's because the denominator in the t-test 
            % was 0.  So just check the means manually to determine
            % prob
            if isnan(prob)
             m1 = mean(obj.s1.data{obj.s1Col});
             m2 = mean(obj.s2.data{obj.s2Col});
             
             if m1==m2
                 prob = 1;
             else
                 prob = 0;
             end
             
            end
             
            userHypothesis = obj.desiredpvalConditionHandle(...
                                  prob,obj.desiredpval);

                                             
             m1 = mean(obj.s1.data{obj.s1Col});
             m2 = mean(obj.s2.data{obj.s2Col});
       
             stderr1 = std(obj.s1.data{obj.s1Col})/ ...
                        sqrt(length(obj.s1.data{obj.s1Col}));
             stderr2 = std(obj.s2.data{obj.s2Col})/ ...
                        sqrt(length(obj.s2.data{obj.s2Col}));
             
             label = [obj.s1.name, '{',obj.s1ColName, '}-', ...
                    obj.s2.name, '{',obj.s2ColName, '}'];
             
             if (isnan(userHypothesis))
                 printHyp = 'N/A';
             elseif userHypothesis == 1
                 printHyp = 'PASS';
             elseif userHypothesis == 0
                 printHyp = 'FAIL';
                 
                 if abs(m2 - m1) < obj.thresh && isnan(obj.thresh) == 0
                    userHypothesis = 1;
                    printHyp ='PTHR';

                 end
                 
             end
                 
             
             if (strcmp(reportStyle,'short'))
                verbosePrint([' UserHyp: ', printHyp, '; ', label, ': ', ...
                     't[',obj.type,'](',num2str(stats.df,3),') = ', ...
                     num2str(stats.tstat), ', p = ', num2str(prob), ...
                     ' p-des: ',num2str(obj.desiredpval)], ...
                     'sosttest_ruIndependentSamplettest');
             elseif (strcmp(reportStyle,'full'))
                 verbosePrint([' UserHyp: ', printHyp , ...
                     '; ', label, ': ', ...
                     't[',obj.type,'](',num2str(stats.df,3),') = ', ...
                     num2str(stats.tstat), ', p = ', num2str(prob), ...  
                     ' p-des: ',num2str(obj.desiredpval), ...
                     ' m(1) = ', num2str(m1),' (se=',num2str(stderr1,4), ...
                     '); m(2) = ', num2str(m2),' (se=',num2str(stderr2,4), ...
                     ')', ...
                     ' thresh = ', num2str(obj.thresh), ...
                     ], 'sosttest_ruIndependentSamplettest');
             end                            
        end %independentSamplesTtest

        
        %% [userHypothesis, prob, label] =  runPairedSamplettest(varargin) METHOD
        function [userHypothesis, prob, label] = ...
                runPairedSamplettest(obj,varargin)
            %runs a paired sample ttest
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
              
            [h,prob,ci,stats] = ttest(obj.s1.data{obj.s1Col},...
                                   obj.s2.data{obj.s2Col},...
                                0.05,obj.tail);       %#ok<ASGLU>

            if isnan(prob)
                 m = mean(obj.s1.data{obj.s1Col}-obj.s2.data{obj.s2Col});

                 if m == 0
                     prob = 1;
                 else
                     prob = 0;
                 end
             end
            
             userHypothesis = obj.desiredpvalConditionHandle(...
                                                    prob,obj.desiredpval);

                                                
             m1 = mean(obj.s1.data{obj.s1Col});
             m2 = mean(obj.s2.data{obj.s2Col});
             
            dat1 =  obj.s1.data{obj.s1Col};
            dat2 = obj.s2.data{obj.s2Col};
            
            meanDiff = mean(dat2-dat1);
            
             
          
             
             stderr = stats.sd/length(obj.s1.data{obj.s1Col});
             
             label = [obj.s1.name, '{',obj.s1ColName, '}-', ...
                    obj.s2.name, '{',obj.s2ColName, '}'];
                    
             if (isnan(userHypothesis))
                 printHyp = 'N/A';
             elseif userHypothesis == 1
                 printHyp = 'PASS';
             elseif userHypothesis == 0
                 printHyp = 'FAIL';
                 
                if abs(meanDiff) < obj.thresh && isnan(obj.thresh) == 0
                    userHypothesis = 1;
                    printHyp = 'PTHR';
                end   
            
             end
             
             if (strcmp(reportStyle,'short'))
                verbosePrint([' UserHyp: ', printHyp, ...
                     '; ', label, ': ', ...
                     't[',obj.type,'](',num2str(stats.df,3),') = ', ...
                     num2str(stats.tstat), ', p = ', num2str(prob), ...
                     ' p-des: ',num2str(obj.desiredpval)], ...
                     'sosttest_runPairedSamplettest');
            elseif (strcmp(reportStyle,'full'))
                 verbosePrint([' UserHyp: ', printHyp, ...
                     '; ', label, ': ', ...
                     't[',obj.type,'](',num2str(stats.df,3),') = ', ...
                     num2str(stats.tstat), ', p = ', num2str(prob), ...
                     ' p-des: ',num2str(obj.desiredpval), ...
                     ' m(1) = ', num2str(m1), '; m(2) = ', num2str(m2), ...
                     ' (se=',num2str(stderr), ')' ...
                     ' thresh = ', num2str(obj.thresh), ...
                     ], 'sosttest_runPairedSamplettest');
             end                            
        end %pairedSamplettest
        
        
        %% [userHypothesis, prob, label] = runSingleSamplettest(varargin) METHOD
        function [userHypothesis, prob, label] = ...
                runSingleSamplettest(obj,varargin)
            %runs a single sample ttest
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
              
            [h,prob,ci,stats] = ttest(obj.s1.data{obj.s1Col},...
                                   obj.targValue,...
                                    0.05,obj.tail);       %#ok<ASGLU>

            if isnan(prob)
                 m = mean(obj.s1.data{obj.s1Col});

                 if m == 0
                     prob = 1;
                 else
                     prob = 0;
                 end
            end
             
             userHypothesis = obj.desiredpvalConditionHandle(...
                                                    prob,obj.desiredpval);


                                                
             m1 = mean(obj.s1.data{obj.s1Col});
             stderr = stats.sd/length(obj.s1.data{obj.s1Col});
             

            
             
             label = [obj.s1.name, '{',obj.s1ColName, '}-', ...
                    num2str(obj.targValue)];
                    
             if (isnan(userHypothesis))
                 printHyp = 'N/A';
             elseif userHypothesis == 1
                 printHyp = 'PASS';
             elseif userHypothesis == 0
                 printHyp = 'FAIL';
                 
                 if abs(m1-obj.targValue) < obj.thresh && isnan(obj.thresh) == 0
                    userHypothesis = 1;
                    printHyp = 'PTHR';
                 end                 
             end
             
             if (strcmp(reportStyle,'short'))
                verbosePrint([' UserHyp: ', printHyp, ...
                    '; ', label, ': ', ...
                     't[',obj.type,'](',num2str(stats.df,3),') = ', ...
                     num2str(stats.tstat), ', p = ', num2str(prob), ...
                     ' p-des: ',num2str(obj.desiredpval)], ...
                     'sosttest_runSingleSamplettest');
             elseif (strcmp(reportStyle,'full'))
                 verbosePrint([' UserHyp: ', printHyp, ...
                     '; ', label, ': ', ...
                     't[',obj.type,'](',num2str(stats.df,3),') = ', ...
                     num2str(stats.tstat), ', p = ', num2str(prob), ...
                     ' p-des: ',num2str(obj.desiredpval), ...
                     ' m = ', num2str(m1), ...
                     ' (se=',num2str(stderr), ...
                     ')', ...
                    ' thresh = ', num2str(obj.thresh), ...
                    ], 'sosttest_runSingleSamplettest');
             end                        
        end %singleSamplettest
 
        
        %% constructIndependentSamplettest(sosObj,varargin) METHOD
        function constructIndependentSamplettest(obj,sosObj,varargin)
            %initialize an independent samples t-test object.
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
            %   
            % RETURNS:
            %   Configured sosttest object.
            

            p = inputParser;

            p.addRequired('sosObj', ...
                @(sosObj)strcmp(class(sosObj),'sos'));
            p.addParamValue('type','null', ...
                @(type)sosttest.validTestType(type));
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
            p.addParamValue('thresh',NaN,@(thres)validateattributes(thres, ...
                    {'numeric'}, {'scalar'}));            
       
            p.parse(sosObj,varargin{:});


            sample1 = p.Results.sample1;
            sample2 = p.Results.sample2;
            s1ColName = p.Results.s1ColName; %#ok<PROP>
            s2ColName = p.Results.s2ColName; %#ok<PROP>
            obj.desiredpvalCondition = p.Results.desiredpvalCondition;
            obj.thresh = p.Results.thresh;                

            if strcmp(obj.desiredpvalCondition,'N/A')
                obj.desiredpvalConditionHandle = @sosttest.returnNaN;
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

            obj.s1 = sample1;
            obj.s2 = sample2;
            obj.s1ColName = s1ColName; %#ok<PROP>
            obj.s2ColName = s2ColName; %#ok<PROP>
            obj.s1Col = col1;
            obj.s2Col = col2;
            obj.type = p.Results.type;
            obj.tail = p.Results.tail;

            obj.runSpecificTest = @obj.runIndependentSamplettest;
            
            obj.label = [obj.s1.name, '{',obj.s1ColName, '}-', ...
                    obj.s2.name, '{',obj.s2ColName, '}', ...
                    ':t[',obj.type,']'];            
          
                
        end

        %% constructPairedSamplettest(sosObj,varargin) METHOD
        function constructPairedSamplettest(obj,sosObj,varargin)
            %initialize a paired samples t-test object
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
            %   
            % RETURNS:
            %   Configured sosttest object.

            p = inputParser;

            p.addRequired('sosObj', ...
                @(sosObj)strcmp(class(sosObj),'sos'));
            p.addParamValue('type','null', ...
                @(type)sosttest.validTestType(type));
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
            p.addParamValue('thresh',NaN,@(thres)validateattributes(thres, ...
                    {'numeric'}, {'scalar'}));               
            
            
            p.parse(sosObj,varargin{:});

    
            sample1 = p.Results.sample1;
            sample2 = p.Results.sample2;
            s1ColName = p.Results.s1ColName; %#ok<PROP>
            s2ColName = p.Results.s2ColName; %#ok<PROP>
            obj.desiredpvalCondition = p.Results.desiredpvalCondition;
            obj.thresh = p.Results.thresh;

            if strcmp(obj.desiredpvalCondition,'N/A')
                obj.desiredpvalConditionHandle = @sosttest.returnNaN;
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

            %check that both columns of data have the same number of
            %observations
            
            if isempty(sample1.data)
                error('sample 1 does not contain items - did you fill it yet?');
            end
            
            if isempty(sample2.data)
                error('sample 2 does not contain items - did you fill it yet?');
            end            
            
            if (length(sample1.data{col1}) ~= length(sample2.data{col2}))
                error('Sample 1 and Sample 2 must have the same number of observations for a paired comparison');
            end
            
            %all variables check out, create the stats test

            obj.s1 = sample1;
            obj.s2 = sample2;
            obj.s1ColName = s1ColName; %#ok<PROP>
            obj.s2ColName = s2ColName; %#ok<PROP>
            obj.s1Col = col1;
            obj.s2Col = col2;
            obj.type = p.Results.type;
            obj.tail = p.Results.tail;

            obj.runSpecificTest = @obj.runPairedSamplettest;    

            obj.label = [obj.s1.name, '{',obj.s1ColName, '}-', ...
                    obj.s2.name, '{',obj.s2ColName, '}', ...
                    ':t[',obj.type,']'];
   
                 
        end

        %%  constructSingleSamplettest(sosObj,varargin) METHOD
        function constructSingleSamplettest(obj,sosObj,varargin)
            %initialize a single sample t-test object
            %
            % PARAMETERS:
            % Required:
            %   sosObj - sos Object test is to be associated with
            %   sample1 - a sample object
            %   s1ColName - name of data column in sample1
            %   ** See also 'optional' but recommended 'targValue'
            %
            % Optional:
            %   targValue/numeric - target value to test for equality with
            %   desiredpvalCondition/string - desired condition for the ttest
            %       pval. Either it should exceed (=>) some value, be less
            %       than '<=' some condition, or be 'N/A' if there is no
            %       desired condition.  Default is N/A.  Note that the
            %       ordering of '=' and '<' is important, so though '<=' is
            %       valid, '=<' is not.  
            %   desiredpval - desired p-value to evaluate the condition
            %       against.  Defaults to 0.05
            %   tail - tail of test - left/right/both
            %   
            % RETURNS:
            %   Configured sosttest object.

            p = inputParser;

            p.addRequired('sosObj', ...
                @(sosObj)strcmp(class(sosObj),'sos'));
            p.addParamValue('type','null', ...
                @(type)sosttest.validTestType(type));
            p.addParamValue('sample1','null', ...
                        @(sample1)strcmp(class(sample1),'sample'));
            %NaN will fail by default
            p.addParamValue('s1ColName',NaN, ...
                @(s1ColName)ischar(s1ColName));
            p.addParamValue('targValue', 0.0, ...
                @(targValue)validateattributes(targValue, ...
                    {'numeric'}, {'scalar'}));
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
            p.addParamValue('thresh',NaN,@(thres)validateattributes(thres, ...
                    {'numeric'}, {'scalar'}));               
            
            p.parse(sosObj,varargin{:});


            sample1 = p.Results.sample1;
            s1ColName = p.Results.s1ColName; %#ok<PROP>
            obj.desiredpvalCondition = p.Results.desiredpvalCondition;
            obj.targValue = p.Results.targValue;
            obj.thresh = p.Results.thresh;
            
            if strcmp(obj.desiredpvalCondition,'N/A')
                obj.desiredpvalConditionHandle = @sosttest.returnNaN;
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
            
            
            %all variables check out, create the stats test

            obj.s1 = sample1;
            obj.s1ColName = s1ColName; %#ok<PROP>
            obj.s1Col = col1;
            obj.type = p.Results.type;
            obj.tail = p.Results.tail;

            obj.runSpecificTest = @obj.runSingleSamplettest;   
            
            
            obj.label = [obj.s1.name, '{',obj.s1ColName, '}-', ...
                    num2str(obj.targValue),':t[',obj.type,']'];      
        
        end % constructSingleSamplettest
    end
    
     
    methods (Static)
        
        %% userHypothesis = returnNaN(~,~) STATIC FUNCTION
        function userHypothesis = returnNaN(~,~)
            % returns NaN
            userHypothesis = NaN;
        end

        %%  flag = validTestType(str) STATIC FUNCTION
        function flag = validTestType(str)
            % returns 1 if the name of type of test is 'single', 'paired',  or 'independent'; error otherwise.
            
            flag = 0; %#ok<NASGU>
            
            if(ischar(str) == false)
                error('<Type> must be either "single","paired", or "independent"');
            end
            
            if (strcmp(str,'single') || strcmp(str,'paired') || ...
                        strcmp(str,'independent'))
                flag = 1;   
            else
                error('<Type> must be either "single","paired", or "independent"');
            end
            
        end
    end
    
end

