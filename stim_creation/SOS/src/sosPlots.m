% - object used to create detailed plots of SOS optimization 
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

classdef sosPlots < handle
    %% plots detailed history data
    %
    % This class provides support for creating plots of various metrics
    % related to the optimization process.  
    % plots various metrics related to the optimization process
    % Specifically, the following items are recorded:
    %
    % creates plots for several optimization parameters, as follows:
    %   - cost
    %   - deltaCost
    %   - temperature
    %   - pFlipHistory    
    %   - sosStatTestpvals (for all stat tests in the sos Object)
    %
    % This code uses the plt library by Paul Mennen (may 11, 2010 version)
    % and also takes some of its implementational inspiration 
    % from the demos therein.
    %
    % This class also inherits from the handle CLASS to gain standard
    % object-oriented behavior
    %
    % PROPERTIES
    %     sosObj % the sos object the plots are associated with
    %     histObj % pointer to history object in SOS object that is to be displayed
    %     hFig % handle to the plot graphic object
    %     pFig % pointer to traces in figure
    %     dispIt % range of iterations to show on the plots at any one time
    %     startIt % iteration that the plot was created at (plots from then on after)
    %     startRow % starting row when plotObj was created from which information will begin being plotted
    %     pvalTestNames % names of the stat tests to plot. these names are stored seperately than those in histObj so as to be able to discern if the stat tests to plot have changed.
    %     curXLim % range limit for x-axis
    %     curCostYLim % range limit for Cost Y axis
    %     curdeltaCostYLim % range limit for deltaCost Y axis
    %     curTempYLim % range limit for tempreature Y axis  
    %
    % METHODS
    %   sosPlots(sosObj,histObj,dispIt,startIt) % constructor
    %   updatePlots() % updates the plot based on the most recent history information
    %   namesBTN(~,~,t) % call linked to names button that toggles display of stat test names.
    %   namesBTN(obj,~,~,t) % call linked to names button that toggles display of stat test names.
    
    %% PROPERTIES
    properties
        sosObj % the sos object the plots are associated with
        histObj % pointer to history object in SOS object that is to be displayed
        hFig % handle to the plot graphic object
        pFig % pointer to traces in figure
        dispIt % range of iterations to show on the plots at any one time
        startIt % iteration that the plot was created at (plots from then on after)
        startRow % starting row when plotObj was created from which information will begin being plotted
        pvalTestNames % names of the stat tests to plot. these names are stored seperately than those in histObj so as to be able to discern if the stat tests to plot have changed.
        curXLim % range limit for x-axis
        curCostYLim % range limit for Cost Y axis
        curdeltaCostYLim % range limit for deltaCost Y axis
        curTempYLim % range limit for tempreature Y axis        
    end
    
    %% METHODS
    methods
        
        %% obj = sosPlots(sosObj,histObj,dispIt,startIt) CONSTRUCTOR
        function obj = sosPlots(sosObj,histObj,dispIt,startIt)
           % creates plots of optimization history metrics
           %
           % PARAMETERS:
           %    sosObj % sos object associated with the plot
           %    histObj % history object whose data will be plotted
           %    dispIt % default number of iterations to display on the plot at any one time
           %    startit % iteration that the plot was started on (plotting begins thereafter)
           
            % validate inputs
            if exist('dispIt','var') == 0
                dispIt = 100000;
            else
                validateattributes(dispIt, {'numeric'}, ...
                {'scalar', 'integer', 'positive', '>', 0});
            end
            
            obj.sosObj = sosObj;
            obj.histObj = histObj;
            obj.dispIt = dispIt;
            obj.startIt = startIt;            
            obj.pvalTestNames = obj.histObj.pvalTestNames;
            
            % begin the plot creation process:
            
            % prepare abbreviated trace names for p-vals
            shortNames = {};
            for i=1:length(obj.pvalTestNames)
                shortNames = [shortNames ; strcat('Test #',num2str(i))]; %#ok<AGROW>
            end
            

            minX = obj.startIt;

            % find the row in the history that the starting iteration
            % appears in
            obj.startRow = 1;
            for i=1:length(obj.histObj.itHistory)
                if obj.histObj.itHistory(i) < minX
                    obj.startRow = i+1;
                else
                    break;
                end
            end
            
            %need to include NaN's for as many traces as there are
            %statTests when first buiding the stat test.  There also needs
            %to be at least 1 stat test so that the stat test plot is
            %created, even if it will ultimately be empty.
            numStatTests = length(obj.pvalTestNames);
            
            initStatTraces = nan(1,max(numStatTests,1));
            
            % create initial x-limits based on the starting iteration and
            % the number of iterations to keep on the screen.
            obj.curXLim = [minX minX+obj.dispIt];

            % set the initial ranges for the y axis of the plots
            
            % create a small initial range on the axes;  The intent is to
            % have this range be overridden with the real data range
            % because that range will be bigger than smallNum.  This is a
            % somewhat awkward bit of the code that hopefully won't be too
            % troublesome, but is apparently needed because the plot must
            % take two real value min and max bounds such that min<max, and
            % more sophisticated overriding code probably isn't worth it
            % presently.  
            smallNum = 0.0000001;
            
            % range of probabilities is always 0-1
            probYLim = [0 1];
            
            % cost and deltaCost can have both positive and negative
            % values, so make their initial ranges symmetric around 1
            obj.curdeltaCostYLim = [-smallNum smallNum];
            obj.curCostYLim = [-smallNum smallNum];
            %temperature can only be negative, have it be bounded by zero
            obj.curTempYLim = [0 smallNum];
            
            % create empty initial traces for as many traces as will
            % ultimately be in the plot.  
            initYs = [NaN,NaN,NaN,NaN,initStatTraces];
            
            % have each individual data point marked with a star, below.
            % There are as many stars for trace marks as there are traces,
            % above.
            mark = '';
            for j=1:length(initYs)
                mark = strcat(mark,'*');
            end

            % create the figure.  
            obj.pFig = plt(NaN,initYs, ... % create NaN's for x-axis and y-axis traces
                'FigName','plotObj', ... % name of figure
                'SubPlot',[20 20 20 20 20] ... % percent of figure occupied by each subplot
                ,'Xlim',obj.curXLim, ... % set initial Xlimits
                'Options','Ticks',... init plots /w tick marks
                'Options','-Ylog',... % remove logy transform of y axis
                'Options','-Xlog',...% remove logx transform of xaxis
                'Options','-Rotate',... % 2-d plots don't need 3d rotation
                'Options','-Help',... % remove (non-existent) help access
                'Options','S',... % enable x-axis slider
                'ENApre', [0 0],... % disables unit scaling and uses scientific notation.
                'TraceID',shortNames,... % name all of the stat test traces
                'Markers',mark,... % add marks for each actual value on the plot that is not interpolated
                'LabelX','Iteration',...
                'LabelY',{'p-val','p(swap)','deltaCost','cost','temperature'},...
                'FigBKc',[0.3 0.3 0.3]);  % sets plot bg color to dark grey
            
            % get a pointer to the newly created figure.  
            obj.hFig = gcf();

            %update the axes for all of the other plots to their
            %default bounds
            hAxes = getappdata(obj.hFig,'axis');

            set(hAxes(1),'Ylim',probYLim); % pval plot
            set(hAxes(2),'Ylim',probYLim); % p(swap) plot
            set(hAxes(3),'Ylim',obj.curdeltaCostYLim); % deltaCost
            set(hAxes(4),'Ylim',obj.curCostYLim); % cost
            set(hAxes(5),'Ylim',obj.curTempYLim); % temperature
    
                    
            % create a message listing the names of all the stat tests
            dispMsg = sprintf('\nThe names of the stats tests are:\n\n');
        
            for i=1:length(obj.pvalTestNames)
                dispMsg = sprintf('  %s#%s: %s\n',dispMsg,num2str(i),...
                                    obj.pvalTestNames{i});
            end

            %add the 'names' button that displays the plot names
            % snippet inspired from plt demo trigplt.m by Paul Mennen
            plot.names = text(2,3,dispMsg,... % first 2 params are x,y offset
                          'HorizontalAlignment','left',...
                          'BackgroundColor',[0.5 0.5 0.5],...
                          'EdgeColor','red','Color','black','Editing','off');
        
            % try to adjust the color (plt seems to override this on
            % initialization though).
            set(plot.names,'units','norm','color',[1 .7 .7]);
  
            % add the names button
            uicontrol('string','Names','pos',[5 500 50 20],...
                        'CallBack',{@obj.namesBTN,plot.names});
             
            % hide names on plot creation.
            set(plot.names,'visible','off');
            
            % if the plot is closed via the plot's gui, have it delete the
            % plotObj in the main SOS variable:
            set(obj.hFig, 'closeReq',strcat('delete(',num2str(obj.hFig),...
                    '); mySOS.plotObj = {}; ')); 
            
            
            % ensure that the whole plot has been updated.  
            drawnow;
                      
            verbosePrint('Plotting detailed optimization history...', ...
                'sosPlots_constructor_end');     
           
        end % constructor
        
        
        %% function updatePlots() METHOD
        function updatePlots(obj)
            % updates the plot based on the most recent history information
            
            %number of data points in the history
            histLength = length(obj.histObj.itHistory);
            
            if histLength == 0
                error('updatePlots() was called but detailed optimization was not stored');
            else
                lastPoint = histLength;
                firstPoint = obj.startRow;
                
                % find the number of iterations on the last datapoint
                lastIt = max(obj.dispIt,obj.histObj.itHistory(length(obj.histObj.itHistory)));
                firstIt = max(0,lastIt-obj.dispIt);
               
                % check to see if the x-axes need to be updated.  This
                % should only happen if there are at least two datapoints;
                newXLim = [firstIt lastIt];
              
                % only try updating the original axes if more than one data
                % point is present; otherwise the initial value will be
                % fine
                if firstPoint < lastPoint && ...
                        (newXLim(1) ~= obj.curXLim(1) || ...
                         newXLim(2) ~= obj.curXLim(2))
                    hAxes = getappdata(obj.hFig,'axis');
                    obj.curXLim = newXLim;
                    
                    for i=1:5 % for every subplot
                    set(hAxes(i),'Xlim', ...
                        obj.curXLim); 
                    end
                end
                    
                % update datapoints on the p-val plot
                for i=1:length(obj.pvalTestNames)
                    set(obj.pFig(i),'x',obj.histObj.itHistory(firstPoint:lastPoint), ...
                       'y',obj.histObj.pvalHistory(firstPoint:lastPoint,i));                
                end

                
                nextIndex = i+1;
                
                % update pFlip   
                set(obj.pFig(nextIndex),'x',obj.histObj.itHistory(firstPoint:lastPoint), ...
                       'y',obj.histObj.pFlipHistory(firstPoint:lastPoint));
                    
                                   
                % from hereon out, it may be necessary to update the YLim
                % since they are not bounded
                
                % update deltaCost Axis
                obj.curdeltaCostYLim = obj.updateAxis(...
                            obj.histObj.deltaCostHistory(lastPoint), ...
                            obj.curdeltaCostYLim, 3);        
        
                % update deltaCost plot          
                nextIndex = nextIndex+1;
                set(obj.pFig(nextIndex),'x',obj.histObj.itHistory(firstPoint:lastPoint), ...
                   'y',obj.histObj.deltaCostHistory(firstPoint:lastPoint));   

               
               % same for cost
                obj.curCostYLim = obj.updateAxis(...
                            obj.histObj.costHistory(lastPoint), ...
                            obj.curCostYLim, 4);                      
                               
                nextIndex = nextIndex+1;
                set(obj.pFig(nextIndex),'x',obj.histObj.itHistory(firstPoint:lastPoint), ...
                        'y',obj.histObj.costHistory(firstPoint:lastPoint));    

                % same for temp
             
                obj.curTempYLim = obj.updateAxis(...
                            obj.histObj.tempHistory(lastPoint), ...
                            obj.curTempYLim, 5);          
                        
                nextIndex = nextIndex+1;
                set(obj.pFig(nextIndex),'x',obj.histObj.itHistory(firstPoint:lastPoint), ...
                        'y',obj.histObj.tempHistory(firstPoint:lastPoint));                                       
                                    
                
            end % if histLength == 0

            drawnow;
      
        end % updatePlots
        
        

        
        
        
        %% namesBTN(~,~,t) METHOD
        function namesBTN(obj,~,~,t)  
            % call linked to names button that toggles display of stat test
            % names.
            %
            % PARAMETERS:
            % ~ -- standard graphic parameters for button calls - not used.
            %   t - pionter to text object that displays the names
            %
            % snippet inspried from plt demo trigplt.m by Paul Mennen, in
            % the plt package demos
        
            dispMsg = sprintf('\nThe names of the stats tests are:\n');
        
            for i=1:length(obj.pvalTestNames)
                dispMsg = sprintf('%s#%s: %s\n',dispMsg,num2str(i), ...
                    obj.pvalTestNames{i});
            end

           v = get(t(1),'visible');
           if v(2)=='n'; v='off'; else v='on'; end;
           set(t,'visible',v);

           drawnow;
           
        end    
        
    end % methods

    
    %% METHODS (Access = private)
    methods (Access = private)
        
        %% curLim = updateAxis(x,curLim,subPlotIndex) METHOD
        function curLim = updateAxis(obj,x,curLim,subPlotIndex)
            % determines whether the y-axis for a given plot need to be
            % updated based on the new data, which may have changed the
            % min/max values for the axis.
            %
            % PARAMETERS:
            %   x - new data point in history array
            %   curLim - 2-entry array containing the current min/max vals
            %   subPlotIndex - index of subplot in hFig handle obj
            
            update = false;
            
            if x < curLim(1)
                curLim(1) = x;
                update = true;
            end

            if x > curLim(2)
                curLim(2) = x;
                update = true;
            end                

            if update == true
                hAxes = getappdata(obj.hFig,'axis');
                set(hAxes(subPlotIndex),'Ylim', ...
                    curLim); 
            end                            
            
        end
    end

end


