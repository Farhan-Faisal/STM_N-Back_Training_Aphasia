% - parent class for constraints
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


classdef genericConstraint < handle
    % Class defines general functionality of constraint objects
    %
    %PROPERTIES
    %     sosObj  % SOS object constraint is associated with
    %     name % string name to associate with the object
    %     label % label to associate with the object (e.g., containing additional information than in the name)
    %     constraintType %label indicating type of constraint (hard/soft/meta)
    %     fnc % name of function used to compute constraint
    %     cost % current cost of constraint
    %     swCost % cost if a swap was executed
    %
    %METHODS (Abstract)
    %   cost = initCost() - object must be able to initially calculate cost
    %   swCost = swapCost() - object must be able to calculate the cost of doing a swap
    %
    %METHODS
    %   obj = acceptSwap() - Makes the swap cost the current cost
    %   cost = rejectSwap(obj) %rejects the swap, resets swCost
    %
    %METHODS (Static)
    %   obj = createConstraint(varargin) - creates an appropriate constraint given varagin
    
    
    %%PROPERTIES
    properties
        sosObj  % SOS object constraint is associated with
        name % string name to associate with the object
        label % label to associate with the object (e.g., containing additional information than in the name)
        constraintType %label indicating type of constraint (hard/soft/meta)
        fnc % name of function used to compute constraint
        cost % current cost of constraint
        swCost % cost if a swap was executed
    end
    
    methods (Abstract)
        cost = initCost(obj);
        swCost = swapCost(obj);
    end
    
    
    methods
        
        %% acceptSwap() METHOD
        function cost = acceptSwap(obj)
            %Makes the swap cost the current cost
            %
            %Child objects of genericConstraint may need to do additional
            %computations in their own acceptSwap function
            
            %Only swap if swCost is NaN, which should only be true if a
            %given swap implicates this cost function
            if(isnan(obj.swCost) == false)
                obj.cost = obj.swCost;
                obj.swCost = NaN;
               
            end
            
            cost = obj.cost;
        end
        
        %% rejectSwap() METHOD
        function cost = rejectSwap(obj)
            %rejects the swap, resets swCost
            obj.swCost = NaN;
            cost = obj.cost;
        end
    end
    

    methods (Static)
        
        %% obj = createConstraint(varargin)
        function obj = createConstraint(varargin)
            % creates an appropriate constraint given varagin
            %
            % Note: Parameters must pass both this function's minimal
            % checking AND the checking required by the specific object to
            % be created
            %
            %PARAMETERS:
            %Required:
            %   'sosObj'/sos object - the SOS object the constraint will be linked to, and which contains the samples the constraint operates on.  
            %   'constraintType'/<str name of constraint as required by desired constraint> - see desired obj's constructor for options
            %   'fnc'/<str name of fnc as required by desired constraint> - see desired obj's constructor for options
            %
            %Optional:
            %   <all required parameters for specific constraint>
            %
            %RETURNS:
            %   Constraint object
           

        
            %check the universal requirements of the method
            p = inputParser;
            p.KeepUnmatched = true;
            
            p.addParamValue('sosObj','null',...
                @(sosObj)strcmp(class(sosObj),'sos'));           
            p.addParamValue('constraintType', 'null', ...
                @(constraintType)ischar(constraintType));
            p.addParamValue('fnc','null', ...
                 @(fnc)ischar(fnc));
            
            p.parse(varargin{:});   
            
            
            %minimum information needed to try to create a constraint
            %exists, try to create constraint
            
            if strcmp(p.Results.constraintType, 'hard')
                if(strcmp(p.Results.fnc,'floor') || strcmp(p.Results.fnc,'ceiling'))
                    obj = hardBoundConstraint(varargin{:});
                else
                    error(['Could not create a hard constraint with <fnc>: ', ...
                        p.Results.fnc]);
                end
            elseif strcmp(p.Results.constraintType, 'soft')   
                if(strcmp(p.Results.fnc,'min') || ...
                        strcmp(p.Results.fnc,'max') || ...
                        strcmp(p.Results.fnc,'orderedMax') || ...
                        strcmp(p.Results.fnc,'match1SampleVal'))
          
                    obj = softDistanceConstraint(varargin{:});
                    
                elseif(strcmp(p.Results.fnc,'minEnt') || ...
                        strcmp(p.Results.fnc,'maxEnt'))
                    obj = softEntropyConstraint(varargin{:});
                elseif(strcmp(p.Results.fnc,'matchCorrel'))
                    obj = softMatchCorrelConstraint(varargin{:});
                else
                    error(['Could not create a soft constraint with <fnc>: ', ...
                        p.Results.fnc]);
                end
                
            elseif strcmp(p.Results.constraintType, 'meta')   
                if(strcmp(p.Results.fnc,'matchCost') || ...
                        strcmp(p.Results.fnc,'matchCostNotMin') )
                    obj = softMetaConstraint(varargin{:});
                else
                    error(['Could not create a meta constraint with <fnc>: ', ...
                        p.Results.fnc]);
                end
            else
               error('The type of the new constraint is not supported in genericConstraint.  Supported types are hard/soft/meta');
            end
       
        end %createConstraint
    end
        
        
end

