% - sample object
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



classdef sample < dataFrame
    %% creates and supports sample objects
    %
    % Additional functionality is inherited from parent class <dataFrame>
    %
    %PROPERTIES
    %   n - target number of items for the sample (NOT necessarily current number of items)
    %   population - population to derive the sample from
    %   locks - int array of length <sampleObj>.n indicating if an item can be swapped (0) or not (1)
    %   name - string name associated with the object
    %
    % ** ALSO manages the global property 'sampleCount', which tracks the
    % number of samples that have been created.  
    %
    %METHODS
    %   sample(n,varargin) - Constructor - Creates a sample object
    %   lockAll() - locks all the items in the sample
    %   unlockAll() - locks all the items in the sample
    %   setPop(population) - links a sample with a population
    %   item = popItem(itemIndex) - pops the item from sample.data at itemIndex and returns it
    %	appendItem(oitem) - append the item at {item index}
    %   swapItems(,sIndex,df,dfIndex,sosObj) - swaps a sample item with a population item
    %
    %METHODS (STATIC)
    %   p = sampleInputParser() - generates an input parser for the constructor
    %
    %METHODS (Access = private) 
    %   createLocks() - creates locks for sample items
    %
    %METHODS (Static, Access = private)
    %   p = parseConstructorArgs(n,varargin) - parses arguments from sample constructor
    %
 
    %% PROPERTIES
    properties
        n % target number of items for the sample (NOT necessarily current number of items)
        population % population to derive the sample from
        locks % int array of length <sampleObj>.n indicating if an item can be swapped (0) or not (1)
        name
    end % properties
    
    
    methods
        
        %% sample CONSTRUCTOR
        function obj = sample(n,varargin)
        % Constructor - Creates a sample object
        %
        % CALL:
        % sample(n, ['filename',<string>, 'isHeader',<logical>, 'isFormatting',<logical>, 'outFile',<string>])
        %
        % SYNOPSIS:
        % Constructor - Creates a sample object and returns it
        %
        % PARAMETERS:
        %  REQUIRED:
        %   n - target number of observations for the sample
        %
        % OPTIONAL:
        %   fileName - src file for the sample, which must
        %       follow the SOS dataFrame format specifications.  
        %   isHeader/logical - param/logical-value pair indicating if
        %       the source file has a header.  Defaults to false.
        %   isFormatting/logical -  param/logical-value indicating if 
        %       the source file has formating.  Defaults to false.
        %   outFile - param/string-value pair indicating the name 
        %       (inc. path, if other than pwd is desired) of
        %       of file to save the sample in after
        %       optimization has been completed.  Outfile is not
        %       validated until write.  Defaults to 'null'
        %   name/string - param/string-value pair indicating string name to
        %       associate with the variable
        %
        % EXAMPLE:
        %   s1 = sample(5); %creates a sample object targeted to have 5 observations
        %   s2 = sample(10, 'fileName', 's1.txt'); % creates a sample
        %                % object with target of 10 obs, reading in initial
        %                % observations from s1.txt          
            
            verbosePrint([char(10) 'Creating and Configuring Sample Object'], ...
                'sample_constructor_startObjCreation');
            
            
            p = sample.parseConstructorArgs(n,varargin);
            
            global sampleCount;
            if(isempty(sampleCount))
                curCount = 1;
            else
                curCount = sampleCount + 1;
            end
            
            %override the default outFile with the sample number if a user
            %specified value was not specified.  
            if any(strcmp(p.UsingDefaults,'outFile'))
                outFile = ['sample',num2str(curCount),'.out.txt'];
            else
                outFile = p.Results.outFile;
            end
            
            %check that the outFile is associated with a valid file name.  If
            %it's not, print a message to that effect
            if ischar(outFile) == false || strcmp(outFile,'null')
                error('Outfile has not been set to a string != null.');
            end
            
            if (exist(outFile,'file'))
               verbosePrint([char(10) 'WARNING: File {', outFile, '} already exists.  ', ...
                   'If you attempt to write to this file, ',...
                   'the existing one will be overridden' char(10)], ...
                    'sample_constructor_fileExists');  
            end
               
            %similary, use a default name based on the sample count if
            %necessary
             if any(strcmp(p.UsingDefaults,'name'))
                 name = ['sample',num2str(curCount)];  %#ok<PROP>
             else
                 name = p.Results.name;  %#ok<PROP>
             end
            
            obj = obj@dataFrame('fileName',p.Results.fileName, ...
                'isHeader',p.Results.isHeader,'isFormatting', ...
                p.Results.isFormatting,'outFile',outFile);
                        
            obj.n = p.Results.n;
            
            obj.name = name; %#ok<PROP>
            
            %check that the user has not pre-loaded more data than the size
            %of the sample.  
            if(isempty(obj.data) == 0)
                userN = length(obj.data{1});
                
                if(userN > obj.n)
                    error('Sample Constructor: Pre-loaded sample size cannot be larger than target sample size {n}');
                end
            end
                
            obj.createLocks();
                   
            verbosePrint(['Creation of Sample Object Complete' char(10)], ...
                'sample_constructor_endObjCreation');
            
            % creation of object successful, increment the counter
            sampleCount = curCount;
            
        end % constructor
        
        
        %% lockAll() METHOD
        function lockAll(obj)
           % locks all the items in the sample
           %
           %EXAMPLE:
           %    s1.lockAll();
           
           if isempty(obj.data) == false
               for i=1:length(obj.data{1}); obj.locks(i) = 1; end;
           else
               error('ERROR: no data in sample to lock');
           end
           
           verbosePrint(['All items in sample ', obj.name,' are now locked '], ...
                    'sample_lockAll_end');             
        end
        
        %% unlockAll() METHOD
        function unlockAll(obj)
           % locks all the items in the sample
           %
           %EXAMPLE:
           %    s1.unlockAll();
           
           for i=1:length(obj.locks); obj.locks(i) = 0; end;
           
           verbosePrint(['All items in sample ', obj.name,' are now unlocked '], ...
                    'sample_unlockAll_end');             
                
        end
            
        %% setPop(population) METHOD
        function obj = setPop(obj,population)
            % links a sample with a population
            %
            %PARAMETERS:
            %   population - a population object
            %
            %EXAMPLE:
            %   s1.setPop(p1) % where s1 is a sample, p1 is a population
            
            if(strcmp(class(population),'population') ~= 1)
                error('{population} must be a population object');
            end
            
            %ensure that the population is compatible with the sample as it
            %is currently configured.  
           
            % if the sample has data, must make sure both the sample and
            % the population have the same columns; otherwise, sample can
            % just copy the population header info
            if(isempty(obj.data) == 0)
               [obj, population] = dataFrame.mergeHeaders(obj,population);
            else
               obj.header = population.header;
               obj.format = population.format;               
            end
                
           obj.population = population;
           
           %link the population with the sample as well
           population.addSample(obj);
           
           verbosePrint(['Sample ', obj.name,'''s population set to: ',obj.population.name], ...
                    'sample_setPop_end');  
           
        end % sample costructor
        
        
        
        %% popItem(itemIndex) METHOD
        function item = popItem(obj,itemIndex)  
            %pops the item from sample.data at itemIndex and returns it
            %
            %WARNING!!!:
            % Currently, this function pops an item and then shifts up all
            % of the subsequent data to fill the empty entries in the data.
            % To avoid altering the object locks, this method currently
            % will throw an error if the item at itemIndex, or a subsequent
            % item, is locked.  This is a known issue, but should not
            % interact with the standard swapping procedure or initial
            % filling of the items.  If there is demand for this function
            % its behavior may be corrected in the future. 
            %
            %CALL:
            % item =  <sampleObj>.popItem(itemIndex)  
            %
            %SYNOPSIS:
            % pops and returns the item at {itemIndex} 
            %
            %PARAMETERS:
            %   itemIndex - the row index of the to-be-popped item
            
            p = inputParser;
            
            p.addRequired('obj');
            p.addRequired('itemIndex',@(itemIndex)validateattributes(itemIndex, {'numeric'}, ...
                {'scalar', 'integer', 'positive','>' 0}));
            p.parse(obj,itemIndex);
            
            if(isempty(obj.data) == true)
                error('No data in sample object - cannot pop item');
            elseif itemIndex > length(obj.data{1})
                error('{itemIndex} exceeds row range of data array');
            elseif (any(obj.locks(itemIndex:end)) == 1)
                error(['ERROR: Attempted to pop an item, when that item ', ...
                    'or a subsequent one in obj.data has its obj.lock',...
                    'active.  See the sample.popItem docmuentation for more info.']);
            end
        
            item = popItem@dataFrame(obj,itemIndex);
        end
        
        
        %% appendItem(item) METHOD
        function obj = appendItem(obj,item)
            % append the item at {item index}
            %
            % Warning!!!  Method does not confirm that the column structure
            % of {item} (i.e., what columns of data are in what order)
            % match that of the sample's data.  This should be the case if
            % SOS is manipulating the items since it will only insert items
            % into the sample that belong to the corresponding population,
            % which should be in sync.  However, manual invocation of this
            % method does not have this guarantee.  Use carefully!  
            %
            %CALL:
            % item =  <sampleObj>.popItem(itemIndex)  
            %
            %SYNOPSIS:
            % pops and returns the item at {itemIndex} 
            %
            %PARAMETERS:
            %   itemIndex - the row index of the to-be-popped item 
            
            
            %check to make sure haven't exceeded sample size.
            if(isempty(obj.data) == false)
                if (length(obj.data{1}) +1 > obj.n)
                    error('Sample already full.  Cannot append item.');
                end
            end

            appendItem@dataFrame(obj,item);
        end
            
        %% swapItems(sIndex,pIndex) METHOD 
        
        %% THIS CLASS NEEDS TO BE CORRECTED
        
        
        function obj = swapItems(obj,sIndex,df,dfIndex,sosObj)
            % swaps a sample item with an item from another datafame that shares the (or is the) population associated with that sample
            %
            %CALL: 
            %   swapItems(sIndex,df,dfIndex,sosObj)
            %
            %SYNOPSIS:
            % swaps a sample item with an item from another data frame
            % This dataframe must either be the, or share the, population with
            % this sample.  This swap takes place both in the
            % place both in the item's (raw) data and (normalized) zdata.
            % Both objects must be associated with the same sosObj for the
            % swap to occur.  This is to ensure that the normalized data
            % that is being swapped is normalized relative to the other
            % data in this SOS object, and not relative to some other SOS
            % object of which this sample/population are also a part.  
            %
            %PARAMETERS:
            %   sIndex - index of sample item
            %   df - another dataframe
            %   dfIndex - index of population item
            %   sosObj - sosObj that sample and population are linked to (and usually the object making the function call).
            %
 
            %Validate the inputs
            p = inputParser;
            
            p.addRequired('obj');
            p.addRequired('sIndex',@(itemIndex)validateattributes(itemIndex, {'numeric'}, ...
                {'scalar', 'integer', 'positive','>' 0}));
            p.addRequired('df',@(df)any(strcmp(superclasses(df),'dataFrame')));
            p.addRequired('dfIndex',@(dfIndex)validateattributes(dfIndex, {'numeric'}, ...
                {'scalar', 'integer', 'positive','>' 0}));
            p.addRequired('sosObj',@(sosObj)strcmp(class(sosObj),'sos'));
            
            
            
            p.parse(obj,sIndex,df,dfIndex,sosObj);    
            
            %check that the population and sample exist and contain
            %normalized data for the right SOSobj
            
            %first make sure both the sample and the dataframe have data
            if(isempty(obj.data) == true)
                error('Sample data is empty');
            end
            
            
            if(isempty(df.data) == true)
                error('Population data is empty');
            end
            
            %check that sample and dataframe have been associated with the
            %current SOSobject, which should indicate whether any
            %normalized data was normalized for this particular SOS object.
            
            if(obj.sosObj ~= sosObj)
                error('Sample is not associated with SOS object executing match');
            end
            
            if(df.sosObj ~= sosObj)
                error('Dataframe is not associated with SOS object executing match');
            end
            
            
            %check that the sample and dataframe both share the same
            %population
            if(obj.population ~= df)
                if(strcmp(class(df),'sample'))
                    if(obj.population ~= df.population)
                        error('Sample and Dataframe do not share a population');
                    end
                else
                    error('If df is not the population for the sample, it should be a sample itself');
                end
                    
            end
            
              
            %check that the sample and the population contain normalized
            %data.  
            if(isempty(obj.zdata) || isempty(obj.population.zdata))
                error('df or sample do not contain normalized data.Data must be normalized prior to swaps');
            end
            
            %validate the indices for the swap:
            if(dfIndex > length(df.data{1}))
                error('df index exceeds number of rows in population');
            end
            
            if(sIndex > length(obj.data{1}))
                error('sample index exceeds number of rows in sample');
            end
            
            if(obj.locks(sIndex) == 1)
                error('item at specified sample index is locked');
            end
            
            if(strcmp(class(df),'sample'))
                if (df.locks(dfIndex) == 1)
                    error('item at specified df index is locked');
                end
            end           
            
            
            
            % copy the sample; again, assumes population and sample header
            % syncing works as designed
            sampleItemData = cell(1,length(obj.header));
            sampleItemzData = cell(1,length(obj.header));
            for i=1:length(obj.header)
                sampleItemData{i} = obj.data{i}(sIndex);
                sampleItemzData{i} = obj.zdata{i}(sIndex);
            end
      
            %move the df item into the sample, then move the copied
            % sample item into the df
            for i=1:length(obj.header)
                
                %try to speed up processing of strings by using a more
                %primitive operation to copy numbers;  Some more fancy
                %string wrapping will be necessary in the case of strings.
                
                if strcmp(obj.format{i},'%f')
                    obj.data{i}(sIndex) = df.data{i}(dfIndex);
                    obj.zdata{i}(sIndex) = df.zdata{i}(dfIndex);  
                    
                   df.data{i}(dfIndex) = sampleItemData{i};
                   df.zdata{i}(dfIndex) = sampleItemzData{i};
                   
                else
                    
                    obj.data{i}(sIndex) = df.data{i}(dfIndex);
                    obj.zdata{i}(sIndex) = df.zdata{i}(dfIndex);

                    %trying to optimize performance by changing these to sub
                    %cell references
                    % used to be:
                    %

                   %df.data{i}(dfIndex) = sampleItemData{i};
                   %df.zdata{i}(dfIndex) = sampleItemzData{i};

                   df.data{i}(dfIndex) = sampleItemData{i};
                   df.zdata{i}(dfIndex) = sampleItemzData{i};
                end
               
            end          
        end % swapItems()
        
    end
    
    methods (Access = private)
        
        %% createLocks() PRIVATE METHOD
        function createLocks(obj)
            % creates locks for sample items, using 'isLocked' data from a user-specified file, if applicable
            
            lockIndex=-1;
            for i=1:length(obj.header)              
               if(strcmp(obj.header{i},'isLocked'))
                   lockIndex=i;
               end
            end
            
            % if locks were specified, move them to the locks array and
            % remove them from the data file
            if(lockIndex >= 0)
                obj.header(lockIndex) = [];
                obj.format(lockIndex) = [];
            
                if(isempty(obj.data) == 0)
                    obj.locks=[obj.data{lockIndex} ... 
                        zeros(1,(obj.n-length(obj.data{1})))];
                    obj.data(lockIndex) = [];
                else
                    obj.locks=zeros(1,obj.n);
                end
            else
                obj.locks=zeros(1,obj.n);
            end
            
        end % createLocks
        
        
    end
    
    methods (Static)
        
        %% p = sampleInputParser() STATIC METHOD
        function p = sampleInputParser()
            %generates an input parser with parameter/value pairs and validators for the constructor
            
            p = inputParser;
            
            %Define required and optional arguments, and specify how they
            %are to be validated
            
            p.addRequired('n',@(n)validateattributes(n, {'numeric'}, ...
                {'scalar', 'integer', 'positive', '>', 0}));
            p.addParamValue('fileName','null', ...
                @(fileName)validFileNameOrNull(fileName));
            p.addParamValue('isHeader',false, ...
                @(isHeader)validLogical(isHeader));
            p.addParamValue('isFormatting',false, ...
                @(isFormatting)validLogical(isFormatting));
            p.addParamValue('name','noname', ...
                @(name)ischar(name));
            %Note that outfile is not validated at this point; this will be
            %done when it comes time to write to the file.  Motivation is
            %that I don't want to write to create a file (and directory
            %structure) unless the user ultimately wants to write
            %something. 
            p.addParamValue('outFile','null', ...
                @(outFile)validStringOrNull(outFile));     
        end % sampleInputParser               
    end
    
    
    methods (Static, Access =private)
        
        %% p = parseConstructorArgs(n,varargin) STATIC PRIVATE METHOD
        function p = parseConstructorArgs(n,varargin)
            % parses arguments from sample constructor
            %
            %CALL:
            % p = sample.parseConstructorArgs(n,varargin)
            % 
            %SYOPSIS:
            %parses the arguments from the sample constructor.  Default
            %values are substituted where appropriate.  Returns a struct
            %with the parsed args.
            % 
            %PARAMETERS:
            % SAME as population CONSTRUCTOR
            %
            %RETURNS:
            % the parsed constructor arguments in struct format
    
            %this cell gets recursively wrapped when it is passed, so
            %unwrap one layer.
            
            varargin = varargin{1};
            
            p = sample.sampleInputParser();   
              
            p.parse(n,varargin{:});
            
        end % parseConstructorArgs
                       
    end
end

