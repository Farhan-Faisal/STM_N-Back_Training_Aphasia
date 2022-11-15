% - exponentially-decaying temperature annealing object
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



classdef expAnneal < genericAnneal
    %% Provides support for exponentially decaying temperature annealing
    %
    %  Provides support for an exponential anneal function governed by the
    %  following equation:
    %
    %       temp = N*e^(-lambda*curStep);
    %
    % The Schedule operates as follows:
    %   {blockSize} iterations are run with temperature set to Inf (the -1
    %   value of curStep, which reflects the current temperature step).
    %   provides an initial sample of the types of cost values encountered
    %   when making purely random switches.  From this sample, the maximum
    %   delta cost in the block is calculated by subtracting the biggest
    %   cost from the smallest and multiplying this value by 10.  The x10
    %   multiple is applied because in the context of the logicstic
    %   function, a temperature 10x greater than deltaCost provides a good
    %   approximation of random behavior.
    %
    %   Next, to fit the lambda term in the equation
    %   the user must express how large of a decrease in this initial temp
    %    is desired on the next step, as a probability.  For slower annealing, the
    %   decrease in temperature should be small, and values should be close
    %   to 1to 0.  For faster descent, values closer to 1 should be used.
    %
    %   Once the values for the variable in the formula have been derived,
    %   the curStep is set to '0' and the initial temperature is calculated
    %   using the formula (in this case = N).  Thus, the '0' step should
    %   also basically yield random.
    %
    %   Subsequent changes in temperature occur when the state of the
    %   optimizer is said to have reached thermal equilibrium and a new 
    %   temperature step begins.  This
    %   approximated in the algorithm as when the previous two 'blocks' of
    %   cost values are non-significantly different from one another
    %   according to an independent samples t-test.  The value of this
    %   t-test can be adjusted to make it easier or harder to reject the
    %   null hypothesis.  In the present case, thermal equilibrium is
    %   reached when we fail to reject the null hypothesis, and thus one
    %   could also make a Type-II error and incorrectly fail to reject a
    %   false null hypothesis.  This can be avoided by using p-values
    %   closer to 1.  It doesn't take that much to cause a p-value to
    %   exceed even the standard cutoff of 0.05 though if blockSizse
    %   becomes large (e.g., 1000), so keep that in mind, otherwise thermal
    %   equilibrium may never be reached
    %
    %   It is worth noting, however, that this measurement of
    %   thermal equilibrium is merely intended to serve as a quick and
    %   readily-interpretable approximation thereof.  A failure to reject
    %   the null hypothesis does not stricly == confirmation of the null
    %   hypothesis, and there are no explicit checks of the t-test
    %   assumptions to have a strong basis for believing that the exact
    %   p-value set is the true p-value for a given data set.  Again
    %   though, for present purposes this approximation has proven to
    %   adequately satisfy its intended purpose.  
    %   
    %
    % PROPERTIES:
    %     blockSize % size of the block of cost values used to determine initial max Delta cost and assess thermal equilibrium
    %     pval % p-value for the test of equality of cost; p-values greater than this are indicative of thermal equilibrium.
    %     N  %  N from exponential decay equation
    %     lambda % lambda from exponental decay equation
    %     curStep % current temperatuer step
    %     pDecrease % proportion decrease in temperature on next step.        
    %     tempLog  % log of all temperature values produced by the algorithm, and the iteration they were set at 
    %     prevBlock % history of cost values from previous block
    %     curBlock % history of cost values from current block
    %     startDeltaCost % history of delta cost values from the first block for equation calibration.
    %
    %METHODS:
    %   expAnneal(varargin) - CONSTRUCTOR
    %   temp = getTemp(obj)  - Returns current temperature
    %   anneal(obj,curIt,cost,deltaCost) - anneal current temperature using the exponentially decay annealing schedule.
    %
    %METHODS (Static)
    %   numSteps(initDeltaCost, finalDeltaCost, pDecrease) % calculates the number of steps that would be necessary to go from initDeltaCost to finaldeltaCost
    %   maxpDecrease(initDeltaCost, finalDeltaCost,nStep) % calculates the maxDecrease that would be necessary to go from initDeltaCost to finaldeltaCost using at least 3 drops in temperature.      
    
    %% PROPERTIES
    properties
        blockSize % size of the block of cost values used to determine initial max Delta cost and assess thermal equilibrium
        pval % p-value for the test of equality of cost; p-values greater than this are indicative of thermal equilibrium.
        N  %  N from exponential decay equation
        lambda % lambda from exponental decay equation
        curStep % current temperature step
        pDecrease % proportion decrease in temperature on next step.        
        tempLog  % log of all temperature values produced by the algorithm, and the iteration they were set at 
        prevBlock % history of cost values from previous block
        curBlock % history of cost values from current block
        startDeltaCost % history of delta cost values from the first block for equation calibration.
        overrideInitDeltaCost % user-specified override for the calculated initDeltaCost value.  
    end
    
    
    methods
        %% expAnneal CONSTRUCTOR
        function obj = expAnneal(varargin)
            % creates and initializes an expAnneal object
            %
            %PARAMETERS:
            %Optional:
            %   'blockSize'/integer - size of blocks to use when estimating the initial temperature and thermal equilibrium. Default: 1000
            %   'pVal'/numeric - p-value to use when testing for thermal equilibrium. Default = 0.05
            %   'pDecrease'/numeric - % decrease in previous temperature when temperature is decreased
            %   'schedule'/'exp' - name of annealing schedule
                        
            verbosePrint('Creating exponential decay temperature annealing function...',...
                'expAnneal_constructor_startObjCreation');
            
            p = expAnneal.parseConstructorArgs(varargin);
            
            % potentially altered by user input
            obj.blockSize = p.Results.blockSize; % must be >=2
            obj.pval = p.Results.pval;
            obj.pDecrease = p.Results.pDecrease;
            
            
            if(any(strcmp(p.UsingDefaults,'overrideInitDeltaCost')))
                obj.overrideInitDeltaCost = NaN;
            else
                obj.overrideInitDeltaCost = p.Results.overrideInitDeltaCost;
            end
            
            
            % variables for expDecay equation
            obj.curStep = -1;                   
            obj.N = NaN;
            obj.lambda = NaN;
                      
            obj.tempLog = [];            
            obj.temp = Inf;    
            obj.tempLog = [obj.temp 0];
            
            obj.curBlock = nan(obj.blockSize,1);
            obj.startDeltaCost = nan(obj.blockSize,1);
        end
        
        %% temp = getTemp()  METHOD
        function temp = getTemp(obj)
            %Returns current temperature
            temp = obj.temp;
        end
            
        %% anneal(obj,sosIt,cost) METHOD
        function anneal(obj,curIt,cost,deltaCost)
            %anneal current temperature using the exponentially decay annealing schedule.
            %
            % PARAMETERS:
            %   curIt - current iteration in sosObj
            %   cost - cost value produced during optimization
            %   deltaCost - deltaCost value during optimization

            if(mod(curIt,obj.blockSize)) == 0
                curIndex = obj.blockSize;
            else
                curIndex = mod(curIt,obj.blockSize);
            end
            
            obj.curBlock(curIndex) = cost;
            
            
            if(curIt <= obj.blockSize)
                obj.startDeltaCost(curIt) = deltaCost;
            end
            
            % if < 1 stepSize of iterations have been run, temp = inf to
            % derive an initial estimation of typical cost values.  After
            % this block, we can fit the decay equation            
            if(mod(curIt,obj.blockSize) == 0 && (curIt)/obj.blockSize == 1 )
                
                % The safest thing to do is to always use the largest
                % possible difference (maxCost - minCost in the set) as the
                % largest possible delta cost.  However, this  makes it
                % harder to reliably replicate a given run because the
                % initial calibration can be influenced by those two data
                % points alone.  So instead, use the 90th-10th percentile
                % as the basis for calibrating the annealing equation.
                
                percentiles = [2.5 97.5];
                scores = prctile(obj.startDeltaCost, percentiles);
                
                DeltaCost95 = scores(2) - scores(1);
                
              %apply override if it has been specified;
              
               if isnan(obj.overrideInitDeltaCost) == 0
                   DeltaCost95 = obj.overrideInitDeltaCost;
                   
                   verbosePrint('Applying user-specified override to initDeltaCost', ...
                    'expAnneal_anneal_calibration');
               end
              
                % fit the decay function.  
                % for the logistic funciton, if temp is 10x greater than
                % the largest cost, even the  minCost
                % would only have a 0.0525 chance of eliciting a swap.
                
                
                
                obj.N = DeltaCost95; 
                
                step1Cost = (1-obj.pDecrease)*obj.N;
                obj.lambda = -1*log((step1Cost/obj.N))/1;
                
                obj.curStep = 0;
                
                obj.temp = obj.N*exp(-obj.lambda*obj.curStep); 
                obj.tempLog = [obj.tempLog ; obj.temp curIt];
                
                obj.prevBlock = obj.curBlock;
                obj.curBlock = nan(obj.blockSize,1);
                

                verbosePrint([sprintf('%i) ', curIt), ...
                    'Annealing Equation calibrated, changing temperature from ', ...
                    num2str(obj.tempLog(length(obj.tempLog)-1),1), ...
                    ' to ', num2str(obj.temp)], ...
                    'expAnneal_anneal_calibration');
                    
            % otherwise, if a new block has been completed, see if thermal
            % thermal equilibrium has been reached, i.e., cost is no longer
            % descending
            elseif (mod(curIt,obj.blockSize) == 0 && (curIt)/obj.blockSize > 1 )
                
                [H,p] = ttest2(obj.prevBlock,obj.curBlock,obj.pval,'both',...
                            'unequal'); 
                
                verbosePrint([sprintf('%i) ', curIt), ...
                    'p(thermEquil): ', num2str(p), ...
                    '  prevBlock m = ', num2str(mean(obj.prevBlock)), ...
                    ' (se = ', num2str(std(obj.prevBlock)/length(obj.prevBlock)), ...
                    ') curBlock m = ', num2str(mean(obj.curBlock)), ...
                    ' (se = ', num2str(std(obj.curBlock)/length(obj.curBlock)), ...
                    ')'], ...
                                'expAnneal_anneal_pthermalEquil');
                
                %we've reached our operational definition of thermal
                %equilibrium if H == 0
                if H == 0 
                    obj.curStep = obj.curStep + 1;                                  
                    obj.temp = obj.N*exp(-obj.lambda*obj.curStep);
                    obj.tempLog = [obj.tempLog ; obj.temp curIt];
           
                    verbosePrint([sprintf('%i) ', curIt), ...'
                        'Thermal Equilibrium Reached - Dropping temperature from ', ...
                        num2str(obj.tempLog(length(obj.tempLog)-1,1)), ...
                        ' to ', num2str(obj.temp)], ...
                        'expAnneal_anneal_dropTemp');                   
                end
                
                obj.prevBlock = obj.curBlock;
                obj.curBlock = nan(obj.blockSize,1);
                
            end
        end % anneal
    end
    
    
    methods (Static) 
        
        %% p = expAnnealInputParser()
        function p = expAnnealInputParser()
            % creates an input parser for the constructor args
            %
            %PARAMETERS:
            %   see constructor args
            
            p = inputParser;
            
            p.addParamValue('blockSize',1000, ...
                @(blockSize)validateattributes(blockSize, {'numeric'}, ...
                {'scalar', 'integer', 'positive', '>', 1}));
            p.addParamValue('pval',0.05, ...
                @(pval)validateattributes(pval, {'numeric'}, ...
                {'scalar', 'positive', '>', 0, '<',1}));
            p.addParamValue('pDecrease',0.5,...
            @(pDecrease)validateattributes(pDecrease, {'numeric'}, ...
                {'scalar', 'positive', '>', 0, '<',1}));
            p.addParamValue('schedule','exp', ...
                @(schedule)strcmp(schedule,'exp'));  
            %override value should be overriden later to set it to Nan
            p.addParamValue('overrideInitDeltaCost',0,...
                        @(overrideInitDeltaCost)validateattributes(overrideInitDeltaCost, {'numeric'}, ...
                {'scalar'})); 
            
        end
        
        
        %% numSteps(initDeltaCost, finalDeltaCost, pDecrease) STATIC FUNCTION
        function numSteps(initDeltaCost, finalDeltaCost, pDecrease)
            % calculates the number of steps that would be necessary to go
            % from initDeltaCost to finaldeltaCost, given a particular
            % pDecrease.  
            %
            % The intended use of this function is to help determine the
            % value of pDecrease.  To do so, a couple of steps are
            % invovled.  First, run sos with an exponential anneal function
            % for expAnneal.blockSize iterations.  During this first block, 
            % temperature is set to infinitie, so cost values are changed
            % randomly. Once blockSize iteractions have been completed,
            % run <sosObj>.deltaCostPercentiles to see the  deltaCost value
            % for the 97.5th - 2.5th percentile, which is the deltaCost
            % value used by the exponential anneal object during it's
            % calibration of the initial temperature value.  The next step
            % is determining the finalDeltaCost value.  To determine that
            % value, run SOS again, this time in greedy mode, and examine
            % the distribution of deltaCosts once the algorithm reaches a
            % frozen state.  For the stochastic annealing to find a better
            % solution than what was found by the exponential annealer, it
            % must approach that frozen state slowly.  For the frozen state
            % to have been reached, by definition no swaps occured and
            % therefore all delta costs should have an upper bound of zero.
            %  For a very slow anneal, you could try to reach the point at
            %  which a large number of swaps would have occured quite slowly, 
            % which corresponds to the delta cost from a high decile like 90%).  
            % This could take a while though. Alternatively, you could try
            % to reach a lower decile instead (e.g., 10%).  A good
            % compromise might be to aim for the 50th percentile so that
            % you approach that point more slowly.  So to sum up to this
            % point, input the initdeltaCost for the 97.5th to the 2.5th 
            % percentile from the first block in an
            % exponential anneal optimization and the finalDeltaCost from
            % a perceintile of your choice as the from the percentiles
            % listed when a greedy anneal was run to a frozen state.  
            % 
            % Now, you have to decide what the pDecrease value will be.  It
            % must be bounded between 0-1, and it should lead to at least 3
            % steps for the exponential anneal to really be effective at
            % gradually lowering temperature.  of course, more steps than 3
            % will result in even slower and potentially better annealing.
            % (1 step at inf, 1 intermediate step, and 1 step at a
            % temperature low enough to cause freezing in a greedy anneal).
            % Try a few different values to see how they would correspond
            % to this constraint and the amount of time you're willing to
            % wait while the algorithm runs.  Lowever values should lead to
            % more steps, whereas higher value will lead to fewer steps.
            %
            %
            % PARAMETERS
            %   -initDeltaCost - the initial delta cost for the first
            %      block of optimizatoin
            %   -finalDeltaCost - the approximate delta cost value that you
            %   wish to approach slowly to avoid premature freezing
            %   -pDecrease - the reduction in the previous temperature to be
            %       applied to generate the new temperature
            %
            % 
            
           
      
            validateattributes(initDeltaCost, {'numeric'}, ...
                {'scalar', 'positive', '>', 0});
            validateattributes(finalDeltaCost, {'numeric'}, ...
                {'scalar', 'positive', '>', 0});     
            validateattributes(pDecrease, {'numeric'}, ...
                {'scalar', 'positive', '>', 0, '<',1});
            
            if(finalDeltaCost >= initDeltaCost)
                error('final delta cost must be < init delta cost.  Consult the manual if this is not the case for your data.');
            end
            
            
            
            % calibrate the expAnneal equation
            N = initDeltaCost*1;      %#ok<PROP>
            step1Cost = (1-pDecrease)*N; %#ok<PROP>
            lambda = -1*log((step1Cost/N))/1; %#ok<PROP>
            
            %calculate initial temperature;
            initTemp = N*exp(-lambda*0);   %#ok<PROP>
            
            %calculate the ifnal temperature.
            finalTemp = (initTemp * (finalDeltaCost/(initDeltaCost*10)))*10;
                        
            %calculate the number of steps.  
            nStep = -1*log(finalTemp/N)/lambda; %#ok<PROP>
            nStep = upper(nStep);
            
            msg = sprintf('\n%g steps needed to reach a temp low enough to freeze given finalDeltaCost\n', ...
                        nStep);
                    
            verbosePrint(msg, ...
                        'expAnneal_numSteps_nStep');    
                    
            if(nStep < 3)
                verbosePrint(['Warning: pDecrease should be lowered until nStep >= 3 ',...
                             char(10),'         at least if exponentially decaying annealing ',...
                             char(10),'         is to have an appreciable effect on annealing'],...
                             'expAnneal_numSteps_Warn');
            end
           
        end

        %% maxpDecrease(initDeltaCost, finalDeltaCost) STATIC FUNCTION
        function maxpDecrease(initDeltaCost, finalDeltaCost,nStep)
            % calculates the maxDecrease that would be necessary to go
            % from initDeltaCost to finaldeltaCost using at least 3 drops
            % in temperature.  
            %
            % The intended use of this function is to help determine the
            % value of pDecrease.  To do so, a couple of steps are
            % invovled.  First, run sos with an exponential anneal function
            % for expAnneal.blockSize iterations.  During this first block, 
            % temperature is set to infinitie, so cost values are changed
            % randomly. Once blockSize iteractions have been completed,
            % run <sosObj>.deltaCostPercentiles to see the  deltaCost value
            % for the 97.5th - 2.5th percentile, which is the deltaCost
            % value used by the exponential anneal object during it's
            % calibration of the initial temperature value.  The next step
            % is determining the finalDeltaCost value.  To determine that
            % value, run SOS again, this time in greedy mode, and examine
            % the distribution of deltaCosts once the algorithm reaches a
            % frozen state.  For the stochastic annealing to find a better
            % solution than what was found by the exponential annealer, it
            % must approach that frozen state slowly.  For the frozen state
            % to have been reached, by definition no swaps occured and
            % therefore all delta costs should have an upper bound of zero.
            %  For a very slow anneal, you could try to reach the point at
            %  which a large number of swaps would have occured quite slowly, 
            % which corresponds to the delta cost from a high decile like 90%).  
            % This could take a while though. Alternatively, you could try
            % to reach a lower decile instead (e.g., 10%).  A good
            % compromise might be to aim for the 50th percentile so that
            % you approach that point more slowly.  So to sum up to this
            % point, input the initdeltaCost for the 97.5th to the 2.5th 
            % percentile from the first block in an
            % exponential anneal optimization and the finalDeltaCost from
            % a perceintile of your choice as the from the percentiles
            % listed when a greedy anneal was run to a frozen state.  
            % 
            % From this point, the algorithm will determine what the value
            % of pDecrease would be if you were to have 3 steps in
            % temperature during the annealing.  This is probably the
            % minimum number that youèd wnat oth ave to be useful
            % (otherwise you simply go from a first step of near-random
            % behavior to a next step of basically stochastic behavior).
            % If desired, you can then experiment with how many steps you
            %
            %
            % PARAMETERS
            %   -initDeltaCost - the initial delta cost for the first
            %      block of optimizatoin
            %   -finalDeltaCost - the approximate delta cost value that you
            %   wish to approach slowly to avoid premature freezing
            %   -pDecrease - the reduction in the previous temperature to be
            %       applied to generate the new temperature
            %
            % 
            
           
      
            validateattributes(initDeltaCost, {'numeric'}, ...
                {'scalar', 'positive', '>', 0});
            validateattributes(finalDeltaCost, {'numeric'}, ...
                {'scalar', 'positive', '>', 0});     
            validateattributes(nStep, {'numeric'}, ...
                {'integer', 'scalar', 'positive', '>', 0});    
            
            if(finalDeltaCost >= initDeltaCost)
                error('final delta cost must be < init delta cost.  See the manual for what to do if this is the case');
            end

            if(nStep < 3)
                error('nStep should be >=3 for exponentially-decaying annealing to have an appreciable effect');
            end
            
            % calibrate the expAnneal equation
            N = initDeltaCost*1;      %#ok<PROP>

            %calculate initial temperature;
            initTemp = N*exp(0);   %#ok<PROP>
            
            %calculate the ifnal temperature
            finalTemp = (initTemp * (finalDeltaCost/(initDeltaCost*10)))*10;
            
                    
            lambda= -1*log(finalTemp/N)/(nStep); %#ok<PROP>
            
            step1Cost = N*exp(-lambda*1);  %#ok<PROP>
            
            pDecrease = -1*(step1Cost/N -1); %#ok<PROP>
            
            
            msg = sprintf('\n%f is max pDecrease to ensure %d steps during exp anneal', ...
                        pDecrease,nStep); %#ok<PROP>
            
            verbosePrint(msg, ...
                        'expAnneal_maxpDecrease_maxpDecrease');
            
                
        end
        
        
    end
    
    methods (Static, Access = private)
        
        %% parseConstructorArgs(varargin)
        function p = parseConstructorArgs(varargin)
            % parsers the constructor arguments
            %
            %PARAMETERS:
            %   see constructor args
            
            varargin = varargin{1};
            p = expAnneal.expAnnealInputParser();
            p.parse(varargin{:});         
        end       
    end
end
 