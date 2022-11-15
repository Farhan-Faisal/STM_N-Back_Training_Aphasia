% - population object
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


classdef population < dataFrame 
    %% creates and manipulates population objects
    %
    %   This class provides support for functions and data storage that are 
    %   specific to population objects, from which samples are created.
    %
    %   Additional functionality is inherited from parent class <dataFrame>
    %
    %
    %PROPERTIES
    %   samples - Array of samples associated with the population
    %   name - string name associated with the variable
    %
    % ** ALSO manages the global property 'popCount', which tracks the
    % number of populations that have been created. 
    %
    %METHODS
    %   population(filename, ['isHeader',<logical>, 'isFormatting',<logical>, 'outFile',<string>]) -  constructor     
    %   addSample(sample) - associate a sample with the population
    %   popItem(itemIndex) - pops and returns the item at {itemIndex} 
    %   insertItem(itemIndex,item) - inserts {item} at {itemIndex}
    %
    %METHODS (STATIC)
    %   populationInputParser() - generates an input parser for the constructor
    %
    %METHODS (Static, Access=private)
    % function p = parseConstructorArgs(fileName,varargin) - parses constructor args

    %% PROPERTIES
    properties
        samples % Array of samples associated with the population
        name % string name associated with the variable
    end %# properties

    %% METHODS
    methods
        
        %% population CONSTRUCTOR
        function obj = population(fileName,varargin)
        % Constructor - Creates a population object
            %
            % CALL:
            % population(filename, ['isHeader',<logical>, 'isFormatting',<logical>, 'outFile',<string>])
            %
            % SYNOPSIS:
            % Constructor - Creates a population object and returns it
            %
            % PARAMETERS:
            %  REQUIRED:
            %   fileName - src file for the population is required, which must
            %       follow the SOS dataFrame format specifications.  
            %
            %  OPTIONAL:
            %   isHeader/logical - param/logical-value pair indicating if
            %       the source file has a header.  Defaults to false.
            %   isFormatting/logical -  param/logical-value indicating if 
            %       the source file has formating.  Defaults to false.
            %   outFile - param/string-value pair indicating the name 
            %       (inc. path, if other than pwd is desired) of
            %       of file to save the residual population in after
            %       optimization has been completed.  Outfile is not
            %       validated until write.  Defaults to 'null'
            %   name/string - string name for the variable.  
            %
            % EXAMPLE:
            %   p1 = population('p1.txt',1,5);
            %
            
            verbosePrint([char(10) 'Creating and Configuring Population Object'], ...
                'population_constructor_startObjCreation');
            
            p = population.parseConstructorArgs(fileName,varargin);

            
             global popCount;
            if(isempty(popCount))
                curCount = 1;
            else
                curCount = popCount + 1;
            end
            
            %override the default outFile with the sample number if a user
            %specified value was not specified.  
            if any(strcmp(p.UsingDefaults,'outFile'))
                outFile = ['pop',num2str(curCount),'.res.out.txt'];
            else
                outFile = p.Results.outFile;
            end
            
            %check that the new outfile is a valid filename, warn if file
            %exists
            if ischar(outFile) == false || strcmp(outFile,'null')
                error('Outfile has not been set to a string != null.');
            end
            
            if (exist(outFile,'file'))
               verbosePrint([char(10) 'WARNING: File {', outFile, '} already exists.  ', ...
                   'If you attempt to write to this file, ',...
                   'the existing one will be overridden' char(10)], ...
                    'population_constructor_fileExists');  
            end
            
            %similarly, add a default name based on the sample count if no
            %name was supplied
            if (any(strcmp(p.UsingDefaults,'name')))
                name = ['pop',num2str(curCount)]; %#ok<PROP>
            else
                name = p.Results.name; %#ok<PROP>
            end
               
            
            obj = obj@dataFrame('fileName',p.Results.fileName,'isHeader',p.Results.isHeader, ...
                'isFormatting',p.Results.isFormatting,'outFile', ...
                 outFile);       
            
            obj.name = name; %#ok<PROP>
             
            verbosePrint(['Creation of Population Object Complete' char(10)], ...
                'population_constructor_endObjCreation');
            
            popCount = curCount;
            
        end % population constructor
        
        %% addSample METHOD
        function obj = addSample(obj,sample)
            % Associates a sample with a population
            %
            %CALL:
            % <populationObj>.addSample(sample)
            %
            %SYNOPSIS:
            %associates a sample with the population.  Also updates the number
            %and order of columns in the population and its samples so that
            %all of these dataframes are in sync.
            %
            %PARAMETERS:
            %   sample - a sample object
            %
            %EXAMPLE:
            %   p1.addSample(obj,s1); % where s1 is a sample object
            
            obj.samples = [obj.samples sample];

            %ensure that that all the samples associated with the
            %population have the same columns and order of columns as in
            %the population.  If addSample is called in the intended way,
            %i.e., from within the sample.setPop() method, the population
            %will already be synchronized with the new sample, so this just
            %pushes those changes to the other samples associated with the
            %population
            
            %First, make sure all the samples contain the same columns as
            %the population
            for i=1:length(obj.samples)
                updatedSample = dataFrame.aContainsb(obj.samples(i),obj);
                obj.samples(i) = updatedSample;
            end 
            
            %Second, make sure all the columns are ordered in the same way
            %across all the samples and the population.            
            for i=1:length(obj.samples)
                tmpData = obj.samples(i).data;  
                
                %if the sample does have data, need to make sure it's
                %odered.  
                
                %This section of the code could be make more efficient, as
                %it currently applies the same blind 'matching' algorithm
                %to all non-empty dataframes, even those that are already
                %sorted.  However, for present purposes, this method is a
                %simple, guaranteed way to make sure the columns line up.
                %Best to spend the time adding more features ;)
                if (isempty(tmpData) == 0)
                    for j=1:length(obj.header)
                       for k=1:length(obj.samples(i).header)
                            if(strcmp(char(obj.header{j}), ...
                                    char(obj.samples(i).header{k})))
                                sampleIndex = k;
                            end;
                       end
                   
                       tmpData(j) = obj.samples(i).data(sampleIndex);
                       
                    end
                end
                
                %update the sample dataframe and header information so it's
                %all synched with the population
                obj.samples(i).data = tmpData;
                obj.samples(i).header = obj.header;
                obj.samples(i).format = obj.format;
                           
            end     
        end %addSample
        
        %% popItem(itemIndex) METHOD
        function item = popItem(obj,itemIndex)  
            % pops and returns the item at {item index}
            %
            %CALL:
            % item =  <populationObj>.popItem(itemIndex)  
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
            
            if(isempty(obj.data{1}) == true)
                error(['ERROR: No data in dataframe object - cannot pop item.',...
                       char(10),'       If you are filling samples, make sure the pop size >= to',...
                       char(10),'       The number of items in all the samples drawing from it.']);
            elseif itemIndex > length(obj.data{1})
                error('{itemIndex} exceeds row range of data array');
            end
            
            item = popItem@dataFrame(obj,itemIndex);
        end
        
        %% insertItem(item, itemIndex) METHOD
        function obj = appendItem(obj,item)
            % inserts {item} at {itemIndex}
            %
            % Warning!!!  Method does not confirm that the column structure
            % of {item} (i.e., what columns of data are in what order)
            % match that of the population's data.  This should be the case if
            % SOS is manipulating the items since it will only insert items
            % into the population that belong to the corresponding samples,
            % which should be in sync.  However, manual invocation of this
            % method does not have this guarantee.  Use carefully!  
            %
            %CALL:
            % <populationObj>.insertItem(itemIndex,item)
            %
            %SYOPSIS:
            %inserts {item} at {itemIndex}
            %
            %PARAMETERS:
            %item - an item (row) consistent with the population
            %itemIndex - the index at which this item should be inserted
            
            appendItem@dataFrame(obj,item);
        end
            
    end %methods

    methods (Static)
        
        %% p = populationInputParser() STATIC METHOD
        function p = populationInputParser()
        % generates an input parser with parameter/value pairs and validators for the constructor args.

            p = inputParser;
            
            %Define required and optional arguments, and specify how they
            %are to be validated
            
            p.addRequired('fileName',@(fileName)validFileName(fileName));
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
            p.addParamValue('outFile','null',@(outFile)validStringOrNull(outFile));             
            
        end
        
    end
    
    methods (Static, Access=private)
        
        %% p = parseConstructorArgs(fileName,varargin) STATIC PRIVATE METHOD
        function p = parseConstructorArgs(fileName,varargin)
            % parses arguments from population constructor
            %
            %CALL:
            % p = population.parseConstructorArgs(fileName,varargin)
            % 
            %SYOPSIS:
            %parses the arguments from the population constructor.  Default
            %values are substituted where appropriate.  Returns a struct
            %with the parsed args
            % 
            %PARAMETERS:
            % SAME as population CONSTRUCTOR
            %
            %RETURNS:
            % the parsed constructor arguments in struct format
    
            %this cell gets recursively wrapped when it is passed, so
            %unwrap one layer.
            varargin = varargin{1};
           
            p = population.populationInputParser();

            p.parse(fileName,varargin{:});
  
        end %parse Constructor Args
            
    end % methods (Static)
end


         