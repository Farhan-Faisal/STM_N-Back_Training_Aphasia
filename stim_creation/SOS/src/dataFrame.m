% - dataframe object
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


classdef dataFrame <  handle
    %% Creates a dataframe object.  Parent of population and sample.
    %
    % NOTE: Objects of this class are generally not generated directly; rather,
    % children such as population and sample generate objects which inherit
    % the characteristics of dataFrame objects.
    %
    % dataframe objects are used to store and manipulate sample and
    % population data, and other general information about samples and
    % populations such as their source files, where to save the dataframe,
    % and so on.  
    %
    % To allow for reference- as opposed to value- based passing of
    % dataFrame objects, this class inherits from handle.  
    %
    %PROPERTIES
    %    src - the name of the source file to be read in (if applicable)
    %    data - the actual data (a cell array of cell arrays/arrays)
    %    isHeader - logical indicating whether src has a header line (recommended!)
    %    header - the header info, each col stored in a cell array
    %    isFormatting - logical indicating whether src has formatting information in the header (recommended!)
    %    format - the format info, each col stored in a cell array
    %    sosObj - the SOS object currently associated with the dataframe
    %    zdata - the normalized data
    %    outFile - target output file name
    %
    %PROPERTIES (Constant)
    %   supportedFormats - cell array of supported data formats
    %
    %METHODS
    %   dataFrame(varargin) - Constructor - see it's doc for args
    %   item = popItem(obj,itemIndex) - pops and returns the item from {itemIndex}    
    %   item = appendItem(obj,item) - appends {item} to dataFrame
    %   colNum = colName2colNum(colName) - finds the column number (index) of the named column
    %   writeData() % writes the header and data from the dataframe to obj.outFile
    %
    %METHODS (STATIC)
    %   a = aContainsb(a,b)  - ensures that data from dataframe obj 'a' contains the same rows as 'b'. 
    %   [a,b] = mergeHeaders(a,b) -  merges the headers from dataFrames a and b
    %   [a,b] = aContainsbData(a,b) - ensures that data from dataframe obj 'a' contains the same data as 'b'.  
    %   p = dataFrameInputParser() - returns an input parser for the dataFrame constructor args
    %   [data,header,format] = readDataFrameData(fileName,isHeader,isFormatting) - reads the data for a dataframe from a file
    %   percent = overlap(df1,df2) % calculates the percent of overlapping items out of the total number of items in df1+df2.  
    %
    %METHODS (STATIC,Acess = private)
    %   p = parseConstructorArgs(varargin) - parses the dataFrame constructor arguments
        
    %% PROPERTIES
    properties   
        fileName % the name of the source file to be read in (if applicable)
        data % the actual data (a cell array of cell arrays/arrays)
        isHeader % logical indicating whether src has a header line (recommended!)
        header % the header info, each col stored in a cell array
        isFormatting % logical indicating whether src has formatting information in the header (recommended!)
        format % the format info, each col stored in a cell array
        sosObj % the SOS object currently associated with the dataframe
        zdata % the normalized data
        outFile % target output file name
    end %properties
    
    %%Properties (Constant)
    properties (Constant)
        supportedFormats = {'s' 'f'}; % cell array of supported data formats
    end
        
        
    
    methods
        
        %% dataframe CONSTRUCTOR
        function obj = dataFrame(varargin)
            %Constructor - Creates a dataFrame object
            %
            % CALL:
            % dataFrame(['filename',<string>, 'isHeader',<logical>, 'isFormatting',<logical>, 'outFile',<string>])
            %
            % SYNOPSIS:
            % Constructor - Creates a dataFrame object
            %
            % PARAMETERS:
            % OPTIONAL:
            %   fileName/string - param/string-value pair indicating the
            %       name of the file where data for the dataFrame is
            %       stored.  Defaults to NaN.
            %   isHeader/logical - param/logical-value pair indicating if
            %       the source file has a header.  Defaults to false.
            %   isFormatting/logical -  param/logical-value indicating if 
            %       the source file has formating.  Defaults to false.
            %   outFile - param/string-value pair indicating the name 
            %       (inc. path, if other than pwd is desired) of
            %       of file to save the residual population in after
            %       optimization has been completed.  Outfile is not
            %       validated until write.  Defaults to 'null'
            %
            % EXAMPLE: 
            %   d = dataFrame(); % creates an empty dataframe
            %
            
            p = dataFrame.parseConstructorArgs(varargin);

            obj.fileName = p.Results.fileName;
            obj.isHeader = p.Results.isHeader;
            obj.isFormatting = p.Results.isFormatting;
            obj.outFile = p.Results.outFile;
            
            obj.header = {};
            obj.format = {};

            %if there is a valid input file to read from, do so
            if(strcmp(obj.fileName,'null') == false)
              [obj.data, obj.header, obj.format] = ...
                 dataFrame.readDataFrameData(obj.fileName,obj.isHeader,obj.isFormatting);
            end     
        end % dataFrame

    
        %% item = popItem(itemIndex) METHOD
        function item = popItem(obj,itemIndex)
            % pops and returns the item from {itemIndex}
            %
            %CALL:
            % item =  <dataFrameObj>.popItem(itemIndex)  
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
            end
            
            
            item = cell(1,length(obj.data));

            for i=1:length(obj.data)
                cellpart = obj.data{i}(itemIndex);
                item(i) = {cellpart};
                obj.data{i}(itemIndex) = [];
            end
        end % popItem
        
        %% appendItem(item) STATIC METHOD
        function item = appendItem(obj,item)
            % appends {item} to dataFrame
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
            % <dataFrameObj>.insertItem(item)
            %
            %SYOPSIS:
            %appends{item} to data in dataFrame
            %
            %PARAMETERS:
            %item - an item (row) consistent with the population
            %
            
            if(isempty(obj.data))
                obj.data = item;
            else
                for i=1:length(obj.header)
                    obj.data{i} = vertcat(obj.data{i},item{i}(1));
                end
            end
        end    
  
        %% colName2colNum
        function colNum = colName2colNum(obj, colName)
            %finds the column number (index) of the named column
            %
            %CALL:
            % <dataFrameObj>.colName2colNum(colName);
            %
            %PARAMETERS:
            % colName - name of column
            %
            %RETURNS:
            % colNum with that colName, -1 if not found
            colNum = -1;
            
            for i=1:length(obj.header)
                if (strcmp(obj.header{i},colName) == 1)
                   colNum = i; 
                   break;
                end                        
            end
        end
        
        
        %% writeData() METHOD
        function writeData(obj)
            %writes the header and data from the dataframe to obj.outFile
                       
            % the name meets these very basic checks, try to open the file
            
            try
                fid = fopen(obj.outFile,'w');
            catch exception
                error(['Could not open file: ', obj.outFile]);
            end
            
            % write the data to the file            
            try
                %write the header
                for i=1:length(obj.header)    
                    fprintf(fid,'%s|%s\t',char(obj.header{i}), ...
                           regexprep(char(obj.format{i}),'%',''));
                end
                
                fprintf(fid,'\r\n');
                
                if(isempty(obj.data) == false)
                    if(isempty(obj.data{1}) == false)
                        for i=1:length(obj.data{1})
                            for j=1:length(obj.data)
                                if(strcmp(obj.format{j},'%s'))
                                    fprintf(fid,'%s\t',char(obj.data{j}(i)));
                                elseif(strcmp(obj.format{j},'%f'))
                                    % try to format ints nicely
                                    if int32(obj.data{j}(i)) == obj.data{j}(i)
                                        fprintf(fid,'%d\t',obj.data{j}(i));
                                    else
                                        %try to format other numbers nicely
                                        fprintf(fid,'%s\t',num2str(obj.data{j}(i)));
                                    end
                                    
                                else
                                   error('Unrecognized column format'); 
                                end
                            end
                            fprintf(fid,'\r\n');
                        end
                    end
                end
                
                
            catch exception
                try
                    fclose(fid);
                catch exception2 %#ok<NASGU>
                end
                
                disp(exception);
                error(['Error while writing to file: ', obj.outFile]);
                
            end
      
            fclose(fid);
            
            verbosePrint(['Data written to file: ', obj.outFile], ...
                'dataFrame_writeData_done');
        end %writeData()
    end
    
    
    
    methods (Static)
        
        %% a = aContainsb(a,b) STATIC METHOD
        function a = aContainsb(a,b)
            %ensures that data from dataframe obj 'a' contains the same rows as 'b'.  
            %
            %CALL:
            % dataFrame.aContainsb(a,b) % where a and b are dataframe objects
            %
            %SYNOPSIS:
            %ensures that data from dataframe obj 'a' contains the same rows as 'b'.  
            %If 'a' does not contain said rows, they are added to the 'a',
            %filled with the correct 'null' token for either strings
            %(literal string 'null') or NaN for floats.  Also updates the
            %header and format information for 'a' to reflect these new additions.
            %Returns updated a.  
            %
            %PARAMETERS:
            %   a - a dataframe object
            %   b - a dataframe object
            %
            %EXAMPLE:
            %   dataFrame.aContainsb(a,b) % where a and b are dataframe objects
   
            for i=1:length(b.header)
                isPresent = false;

                for j=1:length(a.header)
                    if (strcmp(b.header{i},a.header{j}) == 1)
                       isPresent = true; 
                       break;
                    end                        
                end

                if(isPresent == false)     
                   a.header = [a.header b.header(i)];
                   a.format = [a.format b.format(i)];

                   %need to fill the corresponding rows with NaN or
                   %Null, if there is already data in the array
                    if(isempty(a.data) == false)
                       if(strcmp(a.format{length(a.format)},'%s') ==1) 
                           emptyArray = nullArray(length(a.data{1}));
                       elseif (strcmp(a.format{length(a.format)},'%f') ==1)  
                           emptyArray = NaNArray(length(a.data{1}));
                       else
                            error('Unable to fill in empty column because format is invalid');
                       end

                       %merge in the empty column
                       a.data = [a.data {emptyArray}];
                    end
                end                  
            end         
        end
               
                
        %% [a,b] = mergeHeaders(a,b) STATIC METHOD
        function [a,b] = mergeHeaders(a,b)
            % merges the headers from dataFrames a and b
            %
            % CALL:
            %   [a, b] = dataFrame.mergeHeaders(a,b)
            %
            %PARAMETERS:
            %   a - a dataFrame object
            %   b - a dataFrame object
            %
            %RETURNS:
            % [a, b] with merged headers
            %
            %Example: 
            %   [sample,population] =
            %       dataFrame.mergeHeaders(sample,population);

            %check that each column in a is in b
            a = dataFrame.aContainsb(a,b);
            %check that each column in b is in a
            b = dataFrame.aContainsb(b,a);    

        end        
        
        
        %% [a,b] = aContainsbData(a,b) STATIC METHOD
        function [a,b] = aContainsbData(a,b)
           %ensures that data from dataframe obj 'a' contains the same data as 'b'.  
            %
            %CALL:
            % dataFrame.aContainsbData(a,b) % where a and b are dataframe objects
            %
            %SYNOPSIS:
            % ensures that a contains all of the data in b.  Currently
            % useds as part of the normalization function to create a
            % dataframe with all of the data in the SOS object.
            %
            %PARAMETERS:
            %   a - a dataframe object
            %   b - a dataframe object
            %
            %EXAMPLE:
            %   dataFrame.aContainsbData(a,b) % where a and b are dataframe
            %   objects
            
            if(isempty(a.data) == true)
               a.data = {}; 
            end

            if(isempty(b.data) == false) %only need to merge if b contains data
                l=length(b.data{1});
                for i=1:length(a.header)
                    index = -1;
                    
                    for j=1:length(b.header)
                         if (strcmp(b.header{j},a.header{i}) == 1)
                             %there is data about the column in a stored in b
                             index=j;
                             break;
                         end
                    end

                    if index == -1
                       %no data about the column in a in column of b; add in a
                       %blank column of the appropriate length
                       if(strcmp(a.format{i},'%s') ==1)            
                           emptyArray = nullArray(length(l));
                       elseif (strcmp(a.format{i},'%f') ==1)  
                           emptyArray = NaNArray(length(l));
                       else
                            error('Merging only supported for data types %s and %f');
                       end


                       if(isempty(a.data))
                           a.data{i} = {emptyArray};
                       else
                           if (length(a.data) >= i)
                                a.data{i} = vertcat(a.data{i},emptyArray);
                           else
                               a.data{i} = {emptyArray};
                           end
                       end

                    else
                        %need to move data over
                        if(isempty(a.data))
                            a.data{i} = b.data{index};
                        else
                            if(length(a.data) >= i)
                                
                                a.data{i} = vertcat(a.data{i},b.data{index});
                            else
                               a.data{i} = b.data{index};
                            end
                        end
                    end
                end
            end
        end        

        
        
        %% p = dataFrameInputParser() STATIC METHOD
        function p = dataFrameInputParser()
            % returns an input parser for the dataFrame constructor args
            %
            %CALL: 
            % p = dataFrame.dataFrameInputParser()
            %
            %SYNOPSIS:
            % returns an input parser for the dataFrame constructor args
            %
            %EXAMPLE:
            % p = dataFrame.dataFrameInputParser()
            %
            
             p = inputParser;

             %use NaN as null, since matlab doesn't support standard
             %NULL
             p.addParamValue('fileName','null',@(fileName)validFileNameOrNull(fileName));
             p.addParamValue('isHeader',false, ...
                @(isHeader)validLogical(isHeader));
            p.addParamValue('isFormatting',false, ...
                @(isFormatting)validLogical(isFormatting));
            p.addParamValue('outFile',NaN); 

        end
            
 
        %% [data,header,format] = readDataFrameData(fileName,isHeader,isFormatting)  STATIC METHOD
        function [data,header,format] = ...
                        readDataFrameData(fileName,isHeader,isFormatting)
            % reads the data for a dataframe from a file
            %
            %CALL: 
            %   [data,header,format] = readDataFrameData(fileName,isHeader,isFormatting)
            %
            %SYNOPSIS:
            %Reads the data for a dataframe from a file.  Will
            %automatically attempt to generate header and formatting
            %information if it is not present in the file.  The algorithm's
            %ability to do so is quite basic though, so it is strongly
            %reccomended that the file contain header and formatting
            %information.  
            %
            %PARAMETERS:
            %   fileName - string containing the location of the file to be read in
            %   isHeader - logical indicating if the file has header info
            %   isFormatting - logical indicating if the file has formatting info
            %
            %RETURNS:
            %   data - the data from the file
            %   header - header, either from file or automatically generated
            %   format - format, either from file or automatically generated
            %
            %EXAMPLE:
            %[data,header,format] = ... readDataFrameData('p1.txt',true,true)
            
    
            if isHeader == false && isFormatting == true
                error('Formatting information cannot be included without header information');
            end
                        
            verbosePrint(['Reading data from file: ',fileName], ...
                'dataFrame_readDataFrameData_reading'); 

            %variable {filename} has already been checked in the constructor as
            %being a valid filename, but some IO problems might still occur.
            try 
                fid = fopen(fileName,'r');
            catch exception
                exception = MException('IOError:InvalidFile', ...
                strcat('dataFrame: Error when opening: ', fileName));
                throw(exception);
            end

            %some compleities to deal with depending on whether headers /
            %formatting have been manually specified
            if(isHeader)  
                verbosePrint('  Reading user-specified header', ...
                        'dataFrame_readDataFrameData_HeaderPresent');        
                headerLine = fgetl(fid);
                headerLine = textscan(headerLine,'%s');
                headerLine = headerLine{1};

                if(isFormatting)
                    verbosePrint('  Reading user-specified formatting', ...
                        'dataFrame_readDataFrameData_FormattingPresent');    
                    for i=1:length(headerLine)
                        parseFormat =  regexp(headerLine(i),'\|', 'split','once');
                        parseFormat = parseFormat{1};
                        header{i} = parseFormat(1); %#ok<AGROW>

                        try
                            format{i} = strcat('%',parseFormat(2)); %#ok<AGROW>
                        catch %#ok<CTCH>
                            exception = MException('HeaderError:MissingFormat', ...
                            strcat('dataFrame: Format not specified for a',...
                            'variable. This can also happen if you have ',...
                            'whitespace in your header / data'));
                            throw(exception); 
                        end

                        %confirm that the format is valid
                        validFormat = false;
                        for j=1:length(dataFrame.supportedFormats)
                            if(char(parseFormat(2)) == dataFrame.supportedFormats{j})
                                validFormat = true;
                            end
                        end
                            
                        if validFormat == false
                            exception = MException('HeaderError:InvalidFormat', ...
                            strcat('dataFrame: Variable format invalid'));
                            throw(exception); 
                        end
                    end

                else %user-specified header, but no format information    
                    for i=1:length(headerLine)
                        header{i} = headerLine(i); %#ok<AGROW>
                    end
                end
            else % no header or formatting information specified
                
                verbosePrint('  Automatically generating header', ...
                    'dataFrame_readDataFrameData_HeaderAbsent'); 
                
                headerLine = fgetl(fid);
                headerLine = textscan(headerLine,'%s');
                headerLine = headerLine{1};
                for i = 1:length(headerLine)
                    header{i} = strcat('v',num2str(i)); %#ok<AGROW>
                end
            end % if there was a header

            %if no formatting information supplied, must try to derive it
            if(isFormatting == false)
               verbosePrint('  Automatically generating format', ...
                   'dataFrame_readDataFrameData_FormattingAbsent');   
               
               firstDataLine = fgetl(fid);
               firstDataLine =  textscan(firstDataLine,'%s');
               firstDataLine = firstDataLine{1};
               
               for i=1:length(firstDataLine)
                    try
                        conv = str2double(firstDataLine(i));
                        if isnan(conv) == false
                            format{i} = '%f'; %#ok<AGROW>
                        else
                            format{i} = '%s'; %#ok<AGROW>
                        end
                    catch %#ok<CTCH>
                        format{i} = '%s'; %#ok<AGROW>
                    end

               end
               
            end % isFormatting == false

            
            %at last, we can read in the data.         
            %we reset to the first line in the file; go to the second line
            %if there was header information.            
            fseek(fid,0,'bof');
            
            if isHeader == true
                fgetl(fid);
            end
            
            % create a meta-representation of each string using the newly
            % derived formatting information          
            formatStr = '';
            for i=1:length(format)
                formatStr = strcat(formatStr,char(format{i}));
            end

            %we can now read in the data
            try
                %read in the data.  Note that if there is a header present
                %but the user said that there was not, this next line may
                %not work properly!  Unfortunately, there does not appear
                %to be a straightforward workaround for this issue
                %presently.
                data = textscan(fid,formatStr,'Delimiter','\t');
            catch exception
                exception = MException('FormatError:IncorrectFormat', ...
                strcat('dataFrame: Data does not conform to column format'));
                throw(exception); 
            end

            %need to manually enter the last rows as NaN if they are
            %missing.  By definition, if there was a row, the first value
            %must be present.  
            nrow = length(data{1});

            for i=2:length(data);
                if (length(data{i}) < nrow)
                    data{i} = vertcat(data{i},NaN);
                end
            end

            %done with the file.  
            fclose(fid);
            verbosePrint('Done reading in data', ...
                    'dataFrame_readDataFrameData_DoneReadingData');  
                
            [data,header,format]; %#ok<VUNUS> % variables to return
        end  % readDataFrameData
        
        
        
        %% function percent = overlap(df1,df2) STATIC METHOD
        function percent = overlap(df1,df2)
            % calculates the percent of overlapping items out of the total
            % number of items in df1+df2.  The method will generate errors
            % if df1 and df2 do not contain items and if their
            % header/formatting information is non-identical (it should be
            % if they are both samples from the same optimization script).
            % This algorithm also assumes that every item within each
            % dataframe is unique.  It may produce incorrect results if
            % there are multiple copies of the same item within a
            % particular dataframe.
            %
            % PARAMETERS:
            %   df1 -first dataframe
            %   df2 -second dataframe
            %
            % RETURNS:
            %   percent - percent of shared items as a function of the
            %               total number of items
            
            %validate variables
            if any(strcmp(superclasses(df1),'dataFrame')) == 0
                error('argument 1 is not a dataFrame');
            end
            
            if any(strcmp(superclasses(df2),'dataFrame')) == 0
                error('argument 2 is not a dataFrame');
            end            
            
            
            % make sure that both dataFrames have at least one column 
            
            if isempty(df1.header)
                error([df1.name, ' does not contain any header information']);
            end
            
            if isempty(df2.header)
                error([df2.name, ' does not contain any header information']);
            end            
            
            
            % make sure that each dataframe contains some data           
            if isempty(df1.data)
                error([df1.name, ' does not contain any data']);
            end

           if isempty(df2.data)
                error([df2.name, ' does not contain any data']);
           end
           
           if isempty(df1.data{1})
               error([df1.name, ' does not contain any data']);
           end
           
           if isempty(df2.data{1})
               error([df2.name, ' does not contain any data']);
           end
           
           % make sure that both dataFrames have the same header
           % information
           
           if length(df1.header) ~= length(df2.header)
               error('dataFrames must contain the same number of column headers');
           end
           
           for i=1:length(df1.header)
               if(strcmp(df1.header(i),df2.header(i)))
                   error(['dataFrame header column: ', num2str(i), ' do not match']);
               end
               %check formatting as well
               if(strcmp(df1.format(i),df2.format(i)))
                   error(['dataFrame format for column: ', num2str(i), ' do not match']);
               end
           end

           %both dataFrames have at least some data in them and match in 
           %all other respect.  Now they can
           %be compared to see how much overlap exists between them.  
           
           total = length(df1.data{1}) + length(df2.data{1});
           overlap = 0;
           
           for i=1:length(df1.data{1})
               itemMatch = false;
               
               for j=1:length(df2.data{1})
                   rowMatch = true;
                   
                   for k=1:length(df1.header)

                       if strcmp(df1.format{k},'%s')
                           if strcmp(df1.data{k}(i),df2.data{k}(j)) == 0
                               rowMatch = false;
                           end
                       elseif strcmp(df1.format{k},'%f')
                           if df1.data{k}(i) ~= df2.data{k}(j)
                               rowMatch = false;
                           end
                       else
                           error(['Unrecognized column format: ',df1.format{k}{1}]);
                       end
             
                   end
                   
                   % if rowMatch is still true at this point, then we have
                   % an identical entry in both samples.  Cound that
                   
                   if rowMatch == true
                       itemMatch = true;
                       break;
                   end 
               end
               
               if itemMatch == true
                   overlap = overlap + 2;
               end
           end
           
           percent = overlap/total*100;
           
           verbosePrint(['Overlap between ',df1.name,' and ', df2.name, ': ',...
                        num2str(percent),'%'],'dataFrame_overlap_percent');
           
            
        end
        
        
   end
    
    methods (Static, Access = private)

        %% parseConstructorArgs PRIVATE STATIC METHOD
        function p = parseConstructorArgs(varargin)
            %parses the dataFrame constructor arguments
            %
            % CALL:
            % p = dataFrame.parseConstructorArgs(varargin);
            %
            %parses the arguments from the dataFrame constructor.  Default
            %values are substituted where appropriate.  Returns a struct
            %with the parsed args
            % 
            %PARAMETERS:
            % SAME as dataFrame CONSTRUCTOR
            %
            %RETURNS:
            %    p - parsed constructor input
            
             varargin = varargin{1};

             p = dataFrame.dataFrameInputParser();
             p.parse(varargin{:});
        end % parseConstructorArgs
    end
    
end %dataFrame




