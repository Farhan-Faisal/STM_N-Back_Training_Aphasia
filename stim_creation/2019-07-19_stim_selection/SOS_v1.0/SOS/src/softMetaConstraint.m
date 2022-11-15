% - parent class for soft meta-constraints
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


classdef softMetaConstraint < softConstraint
    %% creates and supports soft meta constraints.
    %
    % Meta constraints are a special type of soft constraint that operate
    % on the actual cost values of other constraints rather than creating
    % their own cost values from the actual data being matched.  These meta
    % cosntraints can help balance (or intentionally imbalance) the degree
    % to which different constraints are emphasized when optimizing sets.  
    %
    % PROPERTIES
    %     const1 % the first constraint
    %     const2 % the second constraint
    %     const2costScale % multiplier to apply to cost from the second constraint
    %     comparison % how the two cost values should be compared. 
    %
    % METHODS:
    %   obj = softMetaConstraint(varargin) % CONSTRUCTOR
    %   cost = initCost(obj)  % initializes cost
    %   cost = minDiff(obj,x1,x2) % calculates cost when trying to minimize difference between the two cosntraint's costs.
    %   cost = minDiff(obj,x1,x2) % calculates cost when trying to minimize difference between the two cosntraint's costs.
    %   cost = acceptSwap(obj) % accept the swap   
    %   cost = rejectSwap(obj) % reject the swap
    %

    
    %% PROPERTIES
    properties
        const1 % the first constraint
        const2 % the second constraint
        const2costScale % multiplier to apply to cost from the second constraint
        comparison % how the two cost values should be compared.  
    end
    
    %% METHODS
    methods
        
        function obj = softMetaConstraint(varargin)
            %% Constructs a softMetaConstraint object
            %
            % PARAMETERS
            %   sosObj - the sosObject this metacosntraint will be linked to
            %   constraintType - must be 'meta'
            %   fnc - match function to use ('matchCost' and matchCostNotMin are currently supported).
            %       
            %   constraint1 - first constraint object
            %   constraint2 - second constraint object
            %   constraint2costScale - multiplier for constraint2 cost
            %   exponent - exponent to use to scale the metaconstraint
            %   weight - weight to be used to scale the metaconstraint
            %   name - string label to assign to the object.
            
            p = inputParser;
            
            p.addParamValue('sosObj','null', ...
                                 @(sosObj)strcmp(class(sosObj),'sos'));
            p.addParamValue('constraintType', 'null', ...
                @(constraintType)strcmp('meta',constraintType));
            p.addParamValue('fnc','null', ...
                 @(fnc)any(strcmp({'matchCost','matchCostNotMin'},fnc)));
            p.addParamValue('constraint1','null', ...
                @(softCost1)any(strcmp(superclasses(softCost1),...
                                            'genericConstraint')));
            p.addParamValue('constraint2','null', ...
                @(softCost2)any(strcmp(superclasses(softCost2),...
                                            'genericConstraint')));
            p.addParamValue('constraint2costScale', 1, ...
                   @(constraint2costScale)isnumeric(constraint2costScale));
            p.addParamValue('exponent',2,@(exponent)isnumeric(exponent));
            p.addParamValue('weight',1,@(weight)isnumeric(weight));            
            p.addParamValue('name','noname',@(name)ischar(name));
            
            p.parse(varargin{:});
            
            % check additional constraints on values submitted to the
            % constructor         
            if(p.Results.sosObj.containsConstraint(p.Results.constraint1) == 0)
                error('Constraint2 is not part of the specified sosObj');
            end
 
            if(p.Results.sosObj.containsConstraint(p.Results.constraint2) == 0)
                error('Constraint2 is not part of the specified sosObj');
            end
            
            % assign properties to the object
            
            obj.sosObj = p.Results.sosObj;
            obj.constraintType = p.Results.constraintType;
            obj.fnc = p.Results.fnc;
            
            obj.weight = p.Results.weight;
            obj.exp = p.Results.exponent;     
            
            obj.const1 = p.Results.constraint1;
            obj.const2 = p.Results.constraint2;   
            obj.const2costScale = p.Results.constraint2costScale;
            
            if strcmp(obj.fnc,'matchCost')
                obj.comparison = @obj.minDiff;
            elseif strcmp(obj.fnc,'matchCostNotMin')
                obj.comparison = @obj.minDiffCond;
            else
                error(['fnc: "' obj.fnc, '" not yet supported']);
            end
           
            obj.cost = NaN;
            obj.swCost = NaN;

            % add the name and the label
            obj.label = [obj.constraintType,'_',obj.fnc,'_[',...
                    obj.const1.name,']_[',...
                    obj.const2.name,']_',...
                    'x',num2str(obj.const2costScale),'_w',...
                    num2str(obj.weight),'_e',num2str(obj.exp)];              
            if any(strcmp(p.UsingDefaults,'name'))                 
                obj.name = obj.label;
            else
                 obj.name = p.Results.name;  
            end                
            
            verbosePrint('Soft META Constraint has been created', ...
                    'softMetaConstraint_Constructor_endObjCreation');            
            
        end
            
        %% cost = initCost(obj) METHOD
        function cost = initCost(obj)
            % initializes cost
            cost = obj.comparison(obj.const1.cost,obj.const2.cost);
            obj.cost = cost;
        end
        
        function swCost = swapCost(obj)
            
            if isnan(obj.const1.swCost)
                cost1 = obj.const1.cost;
            else
                cost1 = obj.const1.swCost;
            end
            
            if isnan(obj.const2.swCost)
                cost2 = obj.const2.cost;
            else
                cost2 = obj.const2.swCost;
            end           
                        
            swCost = obj.comparison(cost1,cost2);
            obj.swCost = swCost;                    
        end           
            
        
        function cost = minDiff(obj,x1,x2)
            %% calculates cost when trying to minimize difference between the two cosntraint's costs.
            cost = (abs((obj.const2costScale*x2) - x1)^obj.exp)*obj.weight*100;
        end

        
        function cost = minDiffCond(obj,x1,x2)
            %% calculates cost when trying to minimize difference between the two cosntraint's costs.
            if x2 <= 0
                cost = ( ((abs(obj.const2costScale*x2 - x1)*x1)^0.5 )^obj.exp)*obj.weight*100;
            else
                 cost = 0;
            end
        end
        
        function cost = acceptSwap(obj)
            %% accept the swap
            cost = acceptSwap@genericConstraint(obj);
        end
        
        function cost = rejectSwap(obj)
            %% reject the swap
            cost = rejectSwap@genericConstraint(obj);
        end
        
    end
    
end

