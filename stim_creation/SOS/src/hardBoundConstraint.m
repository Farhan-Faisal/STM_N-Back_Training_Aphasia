% - hard bound constraint object
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



classdef hardBoundConstraint < hardConstraint
    %% creates and supports hardBoundConstraints
    %
    % Creates constraint objects that measure the number of items which
    % violate a specified hard bound in a sample, and which evaluates
    % whether a new item which could be swapped into a sample would also
    % violate this same hards bound.  
    %
    % Additional functionality and interface requirements are inherited
    % from hardConstraint
    %
    % PROPERTIES
    %     comparison - handle to specific comparison method to use
    %     bound   - the bound to evaluate an item against
    %     s1 - the sample 
    %     s1Col   - the column in the sample 
    %     s1ColName   - the name of the data stored in the column of the sample    
    % 
    % METHODS:
    %   hardBoundConstraint(varargin) - CONSTRUCTOR 
    %   cost = initCost(obj) Calculates, saves, and returns the cost value for the current  items in the sample.  
    %   swCost = swapCost(obj, targSample, targSampleIndex, feederdf, feederdfIndex) Calculates the new cost if items from targSample and feederdf were swapped.
    %   cost = itemCost(obj, targSample,targSampleIndex,feederdf, feederdfIndex) Calculates the cost of the specified item in df.  
    %   cost = itemCostFilling(obj,  targSample,targSampleIndex,feederdf, feederdfIndex) Calculates the cost of the specified item in df to the sample.
    %
    % METHODS (Static)
    %   p = hardBoundConstraintInputParser() - generates input parser for constructor args
    %
    % METHODS (Static, Access = private)
    %    p = parseConstructorArgs(varargin) - parses the construcvtor args
    
    
    %% PROPERTIES
    properties
        comparison % handle to specific comparison method to use
        bound   % the bound to evaluate an item against
        s1 % the sample 
        s1Col   % the column in the sample 
        s1ColName   % the name of the data stored in the column of the sample
    end
    
    methods
        
        %% hardBoundConstraint CONSTRUCTOR
        function obj = hardBoundConstraint(varargin)
            % CONSTRUCTOR - creates a hardBoundConstraint object
            %
            % CALL:
            % hardBoundConstraint(varargin <defined below> )
            %
            %PARAMETERS:
            %
            %   'sosObj'/sos object - the SOS object the constraint will be linked to, and which contains the samples the constraint operates on.  
            %   'constraintType'/'hard' - the type of contraint - must be 'hard'           
            %   'fnc'/'floor'|'ceiling' the type of bound to create
            %   'sample1'/sample     - the sample to apply the constraint to
            %   's1ColName'/string - name of column in 1st sample
            %   'value'/numeric -   value of the bound
            %
            % EXAMPLE: 
            % mySOS.addConstraint('constraintType','hard','fnc','ceiling','sample1',s1,'s1ColName','Lg10WF','value',1.5);
  
            p = hardBoundConstraint.parseConstructorArgs(varargin);
            
            
            %now check additional characteristics of the input parameters.
            
            if(p.Results.sosObj.containsSample(p.Results.sample1) == false)
                error('Cannot create hard bound constraint: sos Object does not contain the sample1');
            end
            
            col = p.Results.sample1.colName2colNum(p.Results.s1ColName);
            
            if(col == -1)
                error('Specified column name not found in sample1');
            end
            
            if(strcmp(p.Results.sample1.format{col},'%f') == 0)
                error('Specified column is not of numeric (%f) format, so cannot use as hard bound');
            end

            % properties meet requirements, assign properties to new obj
            
            %give a handle to either hte less than or greater than function
             if (strcmp(p.Results.fnc,'floor'))
                comp = @ge;
            elseif (strcmp(p.Results.fnc,'ceiling'))
                comp = @le;
            else
                error('Specified bound function not suported');
             end
                         
            %parent property
            obj.sosObj = p.Results.sosObj;
            obj.constraintType = p.Results.constraintType;
            obj.fnc = p.Results.fnc;

            obj.comparison = comp;
            obj.bound = p.Results.value;
            obj.s1 = p.Results.sample1;
            obj.s1Col = col;
            obj.s1ColName = p.Results.s1ColName;       
            
            
            obj.cost = NaN;
            obj.swCost = NaN;
            
            % add the name and the label
            obj.label = [obj.constraintType,'_',obj.fnc,'_',...
                    obj.s1.name,'_',obj.s1ColName,'_',num2str(obj.bound)];              
            if any(strcmp(p.UsingDefaults,'name'))                 
                obj.name = obj.label;
            else
                 obj.name = p.Results.name;  
            end
             
            
            verbosePrint('Hard Bound Constraint has been created', ...
                    'hardBoundConstraint_Constructor_endObjCreation');
                      
        end %constructor
        
        %% cost = initCost() METHOD
        function cost = initCost(obj)
            % Calculates, saves, and returns the cost value for the current items in the sample.  
            %
            %CALL: 
            % <hardBoundConstraint>.initCost();
            %
            % Calculates the cost of the hard bound for each item in the
            % sample.  As hard bounds should generally not be violated, a
            % warning message will also be displayed if items violating
            % a bound are present in the set.  This should indicate that
            % the user has forced items into the sample (e.g., by putting
            % them in a file listing items to be read into the sample 
            % object when it is created).  It should not be displayed
            % otherwise if SOS is operating as inteded.
            
            cost = 0;
            for i=1:length(obj.s1.data{obj.s1Col})
                if(obj.comparison(obj.s1.data{obj.s1Col}(i),obj.bound) == 0)
                    
                    %bca: may want to make this print statement more useful...
                    verbosePrint(['Warning: Item ', num2str(i), ' violated the hard bound constraint!'], ...
                        'hardBoundConstraint_initCost');
                    cost = cost + 1;
                end
            end
            
            obj.cost=cost;
            obj.swCost = NaN;
        end
        
        
         %%  swCost(targSample,targSampleIndex, feederdf,feederdfIndex) FUNCTION
        function swCost = swapCost(obj, targSample, targSampleIndex, feederdf, feederdfIndex)
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
                        
            curItemCost = obj.itemCost('null','null',targSample, targSampleIndex);
            newItemCost = obj.itemCost('null','null',feederdf, feederdfIndex);
          
           
            %can swap to another item that violates the constraint if you
            %currently violate the constraint
            if curItemCost == 1 && newItemCost == 1
                newSubCost = 0;
            elseif curItemCost == 0 && newItemCost == 1
                newSubCost = 1;
            %must swap if current item violates constraint and new one
            %doesn't
            elseif curItemCost == 1 && newItemCost == 0
                newSubCost = -1;
            elseif curItemCost == 0 && newItemCost == 0
                newSubCost = 0;
            else
                error('This condition should not have been met');
            end
            
            swCost = obj.cost + newSubCost;
            obj.swCost = swCost;
            
        end

        %% itemCost(targSample,targSampleIndex,feederdf, feederdfIndex) METHOD
        function cost = itemCost(obj, targSample,targSampleIndex,feederdf, feederdfIndex)
            %Calculates the cost of the specified item in df.  
            %Should usually be invoked once a sample is filled with items.
            %
            %NOTE:
            % Other parameters are provided only for consistency, but are not
            % used.  
            %
            %SEE swCost() doc/help for more details
            
            cost = obj.itemCostFilling(targSample,targSampleIndex,feederdf, feederdfIndex);
        end
        
        %% cost = itemCostFilling(targSample,targSampleIndex,feederdf, feederdfIndex) METHOD
        function cost = itemCostFilling(obj,  targSample,targSampleIndex,feederdf, feederdfIndex) %#ok<INUSL>
            %Calculates the cost of the specified item in df to the sample.
            % Should usually only be invoked when initially filling a
            % sample
            % 
            %NOTE:
            % Other parameters are provided only for consistency, but are not
            % used.  
            %
            %SEE swCost() doc/help for more details
            
            cost = 0;
            
            if(obj.comparison(feederdf.data{obj.s1Col}(feederdfIndex),obj.bound))
                %do nothing
            else
               cost = 1;
            end            
        end
            
        function cost = acceptSwap(obj)
            acceptSwap@genericConstraint(obj);
            cost = obj.cost;
        end
        
    end
    
    methods(Static)
        %% p = hardBoundConstraintInputParser() STATIC METHOD
        function p = hardBoundConstraintInputParser()
            % generates input parser for constructor args
            p = inputParser;

            %Note: some of these 'optional' parameters are de facto
            %required by making the default value fail validation
            p.addParamValue('sosObj','null', ...
                @(sosObj)strcmp(class(sosObj),'sos'));
            p.addParamValue('constraintType', 'null', ...
                @(constraintType)any(strcmp({'hard'},constraintType)));
            p.addParamValue('fnc','null', ...
                 @(fnc)any(strcmp({'floor' 'ceiling'},fnc)));
            p.addParamValue('sample1','null', ...
            @(sample1)strcmp(class(sample1),'sample'));
            p.addParamValue('s1ColName','',@(s1ColName)ischar(s1ColName));
            p.addParamValue('value','null',@(value)isnumeric(value));
            p.addParamValue('name','noname',@(name)ischar(name));
            
        end % hardBoundConstraintInputParser()
    end
    
    methods(Static, Access = private)
        
        %% parseConstructorArgs STATIC PRIVATE FUNCTION
        function p = parseConstructorArgs(varargin)
            % parses the construcvtor args
            %
            % see construcor help/doc for more info
            
            varargin = varargin{1};            
            p = hardBoundConstraint.hardBoundConstraintInputParser();
            p.parse(varargin{:});            
        end
    end
    
end

