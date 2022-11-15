% - object for storing the detailed history of an optimization
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

classdef sosHistory < handle
    %% records and provides writing support for detailed optimization history data
    %
    % This class provides support for recording and writing several metrics
    % related to the optimization process.  Specifically, the following
    % items are recorded:
    %
    % creates plots for several optimization parameters, as follows:
    %   - cost
    %   - deltaCost
    %   - temperature
    %   - pFlipHistory    
    %   - sosStatTestpvals (for all stat tests in the sos Object)
    %
    % This class also inherits from the handle CLASS to gain standard
    % object-oriented behavior
    %
    % PROPERTIES:
    %     sosObj % the sos object the history data originated from
    %     itHistory % history of iteration numbers where reports were made
    %     tempHistory % history of temperature
    %     costHistory % history of cost
    %     deltaCostHistory % history of deltaCost
    %     pFlipHistory % history of the probability of flipping   
    %     pvalTestNames % names of the ttests for use as labels
    %     pvalHistory % history of pvalues for t-tests (2d; seperate column for each test)
    %     outFile % filename to write buffered output to
    %     bufferedWrite % switch indicating whether buffered writing is enabled/disabled
    %
    % METHODS
    %   obj = sosHistory(sosObj) % Constructor - creates an sosHistory object
    %   updateHistory(curIt,cost,deltaCost,pFlip,testNames,testps,temp) % updates the history with the passed data
    %   setBufferedHistoryOutfile(outFile) % writes the history on-line, one update at a time.  Overrides the existing file.  
    %   disableBufferedHistoryWrite() % disables buffered writing
    %   enableBufferedHistoryWrite() % enables buffered writing
    %   writeBuffer(updateHeader) % writes out the most recent update to outFile.  
    %   writeHistory(outFile) % writes the entire history to outFile
    %   addStatTestName(name) % adds a new stat test name to the list of stat test names.
    %
    % METHODS (Private)
    %    writeHeader(fid) % writes the header information to fid
    %
 
    
    %% PROPERTIES
    properties
        sosObj % the sos object the history data originated from
        itHistory % history of iteration numbers where reports were made
        tempHistory % history of temperature
        costHistory % history of cost
        deltaCostHistory % history of deltaCost
        pFlipHistory % history of the probability of flipping   
        pvalTestNames % names of the ttests for use as labels
        pvalHistory % history of pvalues for t-tests (2d; seperate column for each test)
        outFile % filename to write buffered output to
        bufferedWrite % switch indicating whether buffered writing is enabled/disabled
    end %# properties

    %% METHODS
    methods
        
        %% sosHistory() CONSTRUCTOR
        function obj = sosHistory(sosObj)
            % Constructor - creates an sosHistory object
            %
            % PARAMETERS:
            %   -sosObj - SOS object the history will be associated with
           
            obj.sosObj = sosObj;
            
            obj.costHistory = [];
            obj.deltaCostHistory = [];
            obj.pvalTestNames = {}; 
            obj.pvalHistory = [];
            obj.tempHistory= [];
            obj.pFlipHistory = [];      
            obj.itHistory = [];  
            
            obj.bufferedWrite = false;
            
            
            % get the labels for all of the ttests that already exist            
            for i=1:length(sosObj.sosstattests)
                obj.pvalTestNames = horzcat(obj.pvalTestNames,...
                    sosObj.sosstattests{i}.label);
            end
 
            verbosePrint('Detailed optimization history will now be recorded...', ...
                'sosHistory_constructor_end');     
            
        end % constructor
        
        
        %% updateHistory(obj,curIt,cost,deltaCost,pFlip,testNames,testps,temp) METHOD
        function updateHistory(obj,curIt,cost,deltaCost,pFlip, ...
                            testNames,testps,temp)
            % updates the history with the passed data
            %
            % PARAMETERS:
            %   curIt - current iteration
            %   cost - current cost
            %   deltaCost - current deltaCost
            %   pFlip - current pFlip
            %   testNames - cell array containing names of all stattests
            %   testps - array containing p-values for all stattests
            %   temp - current temperature
              
            
            % append data
            obj.costHistory = vertcat(obj.costHistory,cost);
            obj.deltaCostHistory = vertcat(obj.deltaCostHistory,deltaCost);
            obj.tempHistory= vertcat(obj.tempHistory, temp);
            obj.pFlipHistory = vertcat(obj.pFlipHistory, pFlip);    
            obj.itHistory = vertcat(obj.itHistory, curIt); 
            
            % check to make sure that no stat tests have been added 
            
            newRow = nan(1,length(obj.pvalTestNames));
            updateHeader = false;
            
            for i=1:length(testNames)
                index = -1;
                for j =1:length(obj.pvalTestNames)
                    if strcmp(testNames{i},obj.pvalTestNames{j})
                        index = j;
                        break;
                    end
                end
                
                %if the index was never found, a new column must be created
                %to hold its data.  
                if index == -1 
                    updateHeader = true;
                    obj.pvalTestNames = horzcat(obj.pvalTestNames,testNames{i});
                    newRow = horzcat(newRow,testps(i)); %#ok<AGROW>
                else
                   %the index already exists. Put in the p-value
                   newRow(index)=testps(i);
                end
        
            end
            
            %check to see if new ttests have been added.  If they have,
            %newRow will be longer than an existing row in the pvalHistory,
            %and you'll need to add some NaN fillers.
            
            if(size(obj.pvalHistory,2) == length(newRow))            
                obj.pvalHistory = vertcat(obj.pvalHistory, newRow);
            elseif(size(obj.pvalHistory,2) < length(newRow))
                % add in NaN's to the existing matrix
                diff = length(newRow) - size(obj.pvalHistory,2);
                len = size(obj.pvalHistory,1);
                newCols = nan(len,diff);
                
                %append the pval data
                obj.pvalHistory = horzcat(obj.pvalHistory,newCols);
                obj.pvalHistory = vertcat(obj.pvalHistory, newRow);
            else
                error('An error occured when adding a new row to pvalHistory');
            end
            
            % if buffered output is enabled, write out the new line.
            if obj.bufferedWrite
                obj.writeBuffer(updateHeader);
            end
                           
        end % updateHistory
    
        
        %% setBufferedHistoryOutfile(outFile) METHOD
        function setBufferedHistoryOutfile(obj,outFile)
            % writes the history on-line, one update at a time.  Overrides
            % the existing file.  
            %
            % PARAMETERS:
            %   outFile - string name of file to write to.
            %
            
            % test to make sure that the outFile is valid
            if exist('outFile','var') == 0
                error('"Outfile" argument was not supplied to writeHistory()');
            end

            if(ischar(outFile) == false)
                error('Outfile has not been set to a string != "null".');
            end

            if ischar(outFile) == false || strcmp(outFile,'null')
                error('Outfile has not been set to a string != "null".');
            end

            %outFile name is valid.  Try writing the header

            try
                fid = fopen(outFile,'w');
            catch exception
                error(['Could not open file: ', outFile]);
            end
            
            obj.writeHeader(fid);

            fclose(fid);

            obj.outFile = outFile;
            obj.bufferedWrite = true;
            
            verbosePrint(['Current and future history will be written to: ' outFile,' on each report...'],...
                'sosHistory_bufferedHistoryWrite_end');                      
        end

        
        %% disableBufferedHistoryWrite() METHOD
        function disableBufferedHistoryWrite(obj)
            % disables buffered writing
            
            obj.bufferedWrite = false;
            
            verbosePrint('Buffered writing of history disabled',...
                'sosHistory_disableBufferedHistoryWrite_end');   
        end
        
        
        %% enableBufferedHistoryWrite() METHOD
        function enableBufferedHistoryWrite(obj)
            % enables buffered writing
            
            % can only enable writing if an outFile has been set
            if isempty(obj.outFile) ==  0
       
                obj.bufferedWrite = true;

                verbosePrint('Buffered writing of history enabled',...
                    'sosHistory_enableBufferedHistoryWrite_end'); 
            else
                error('bufferedHistoryWrite(outFile) must be called to specify an outFile first!');
            end
        end        
        
        
        %% writeBuffer(updateHeader)
        function writeBuffer(obj,updateHeader)
            % writes out the most recent update to outFile.  
            %
            % PARAMETERS:
            %   updateHeader - flag indicating if the header changed and
            %                   hence needs to be reprinted
            %
           
            try
                fid = fopen(obj.outFile,'a');
            catch exception
                error(['Could not open file: ', obj.outFile]);
            end      
            
            if updateHeader
               obj.writeHeader(fid);                 
            end
            
            % write the data
            for i=length(obj.itHistory):length(obj.itHistory)
                obj.writeData(fid,i);
            end
                       
            fclose(fid);
            
        end
            
        
        %% writeHistory(outFile) METHOD
        function writeHistory(obj,outFile)
            % writes the entire history to outFile
            %
            % PARAMETERS:
            %   outFile - string name of file to write to
            %

            % check to see if the outFile is valid
            if exist('outFile','var') == 0
                error('"Outfile" argument was not supplied to writeHistory()');
            end

            if(ischar(outFile) == false)
                error('Outfile has not been set to a string != "null".');
            end

            if ischar(outFile) == false || strcmp(outFile,'null')
                error('Outfile has not been set to a string != "null".');
            end

            verbosePrint(['Writing optimization history to: ' outFile,' ...'],...
                'sosHistory_writeHistory_begin');      

            try
                fid = fopen(outFile,'w');
            catch exception
                error(['Could not open file: ', outFile]);
            end            
            
            % write the header
            obj.writeHeader(fid);
            
            %now we can write the data.  Since we forcibly collect all data
            %at the same time (i.e., no missing data allowed in any column)
            %we can just index the itHistory 
            
            % print each piece of data
            for i=1:length(obj.itHistory)
                obj.writeData(fid,i);
            end
                      
            fclose(fid);
            
        end
        
        %% addStatTestName(name) METHOD
        function addStatTestName(obj,name)
            % adds a new stat test name to the list of stat test names.
            %
            % This function is currently used by the sos object which owns
            % the history object to inform the history
            % object when a new stat test is added
            %
            % PARAMETERS:
            %   name - string name of new stat test
            
            obj.pvalTestNames = horzcat(obj.pvalTestNames,name);
            
        end
        
    end % methods

    %% METHODS (Access = private)
    methods (Access = private)
       
        %% writeHeader(fid) METHOD
        function writeHeader(obj,fid)
            % writes the header information to fid
            %
            % PARAMETERS:
            %   fid - pointer to file to write to
            
            fprintf(fid,'%s\t','iteration');
            fprintf(fid,'%s\t','temp');
            fprintf(fid,'%s\t','cost');
            fprintf(fid,'%s\t','deltaCost');
            fprintf(fid,'%s\t','pFlip');

            for i=1:length(obj.pvalTestNames)
                fprintf(fid,'%s\t',obj.pvalTestNames{i});
            end

            fprintf(fid,'\r\n');    
            
        end
        
        %% writeData(fid,index) METHOD
        function writeData(obj,fid,index)
            % writes the data at row 'index' to fid
            %
            % PARAMETERS:
            %   fid - pointer to file to write to
            %   index - row number to write
            
            fprintf(fid,'%s\t',num2str(obj.itHistory(index)));
            fprintf(fid,'%s\t',num2str(obj.tempHistory(index)));
            fprintf(fid,'%s\t',num2str(obj.costHistory(index)));
            fprintf(fid,'%s\t',num2str(obj.deltaCostHistory(index)));
            fprintf(fid,'%s\t',num2str(obj.pFlipHistory(index)));

            %print the p-vals

            for j=1:length(obj.pvalTestNames)
              fprintf(fid,'%s\t',num2str(obj.pvalHistory(index,j)));
            end

            fprintf(fid,'\r\n');            
            
        end
        
    end % methods (private)
    
end

