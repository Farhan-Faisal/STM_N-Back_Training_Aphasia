% - sos main GUI 
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


function varargout = sos_gui(varargin)
% SOS_GUI M-file for sos_gui.fig
%      SOS_GUI, by itself, creates a new SOS_GUI or raises the existing
%      singleton*.
%
%      H = SOS_GUI returns the handle to a new SOS_GUI or the handle to
%      the existing singleton*.
%
%      SOS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SOS_GUI.M with the given input arguments.
%
%      SOS_GUI('Property','Value',...) creates a new SOS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sos_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sos_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sos_gui

% Last Modified by GUIDE v2.5 16-Aug-2011 17:46:24

%
% BCA:
% Note: the following warning has been disabled.
% warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid');
% It occurs when the active population/sample lists are empty.
%



% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sos_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @sos_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT




% --- Executes just before sos_gui is made visible.
function sos_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sos_gui (see VARARGIN)

% Choose default command line output for sos_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sos_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

disp([char(10),char(10),'SOS: Stochastic Optimization of Stimuli',char(10),... 
'    Copyright 2009-2012 Blair Armstrong, Christine Watson, David Plaut',char(10),... 
char(10),... 
'    This binary executable is part of SOS',char(10),... 
char(10),...
'    SOS is free software: you can redistribute it and/or modify',char(10),... 
'    it for academic and non-commercial purposes',char(10),... 
'    under the terms of the GNU General Public License as published by',char(10),... 
'    the Free Software Foundation, either version 3 of the License, or',char(10),... 
'    (at your option) any later version.  For commercial or for-profit',char(10),... 
'    uses, please contact the authors (sos@cnbc.cmu.edu).',char(10),... 
char(10),...
'    SOS is distributed in the hope that it will be useful,',char(10),... 
'    but WITHOUT ANY WARRANTY; without even the implied warranty of',char(10),... 
'    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the',char(10),... 
'    GNU General Public License for more details.',char(10),... 
char(10),...
'    You should have received a copy of the GNU General Public License',char(10),... 
'    along with SOS (see COPYING.txt).',char(10),... 
'    If not, see <http://www.gnu.org/licenses/>.',char(10),char(10),char(10)]);


% --- Outputs from this function are returned to the command line.
function varargout = sos_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_CmdWindow_Callback(hObject, eventdata, handles)
% hObject    handle to edit_CmdWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_CmdWindow as text
%        str2double(get(hObject,'String')) returns contents of edit_CmdWindow as a double


    % technically, the command line will try to run whenever you loose
    % focus.  However, there doesn't seem to be an easy workaround (e.g.,
    % conditioning on carriage returns didn't seem to stop the call back).

    command = get(hObject,'String');
    
    verbosePrint(['Evaluating GUI command: ', command], ...
            'sos_gui_cmdWindow_CallBack_runcmd');       

    evalin('base',command);

    set(hObject,'String','');

    % END edit_CmdWindow CALLBACK

        

% --- Executes during object creation, after setting all properties.
function edit_CmdWindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_CmdWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

    set(hObject, 'KeyPressFcn', @edit_CmdWindow_KeyPressFcn);


% --- Executes on button press in pushbutton_runScript.
function pushbutton_runScript_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton_runScript (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % let user navigate to the script to run
    [fileName,pathName] = uigetfile('*','Run Script...');
    
    if fileName ~= 0
        

        fullName = strcat(pathName,fileName);


        % try to run the script...
        verbosePrint(['Running script: ', fullName], ...
                    'sos_gui_runScript_CallBack_runScript');

        cd(pathName);
        %first, read in the script:
        try
            fid = fopen(fullName,'r');
        catch exception
            error(['Could not open file: ', fullName]);
        end

        try
            script = fscanf(fid,'%c');
        catch
             error(['Error while reading file: ', fullName]);
        end

        %run the script
        evalin('base',script);
    end
    % END runScript CALLBACK
    


% --- Executes on button press in pushbutton_CreatePopulation.
function pushbutton_CreatePopulation_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_CreatePopulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    createPop_Dialog();

% --- Executes on key press with focus on edit_CmdWindow and none of its controls.
function edit_CmdWindow_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to edit_CmdWindow (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
 


% --- Executes on selection change in popupmenu_popSelector.
function popupmenu_popSelector_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_popSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_popSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_popSelector

    populatePopList(hObject);


% --- Executes during object creation, after setting all properties.
function popupmenu_popSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_popSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

    %populatePopList(hObject);


    
% populates the population list   
function populatePopList(hObject)    
    % get a list of all populations in the base workspace:
    vars = evalin('base','whos()');
    
    pops = [];
    for i=1:length(vars)
        if strcmp(vars(i).class,'population')
            pops = [pops; {vars(i).name}]; %#ok<AGROW>
        end
    end
    
    %in case no populations are present, set to the empty string:
    if isempty(pops)
        pops = '';
    end
    
    
    % assign that list to the options in the pop up menu.  Disable warnings
    % if the list is empty and then re-enable them.  
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid');
    set(hObject,'String',pops);            

    
% populates the sample list   
function populateSampleList(hObject)    
    % get a list of all populations in the base workspace:
    vars = evalin('base','whos()');
    
    samples = [];
    for i=1:length(vars)
        if strcmp(vars(i).class,'sample')
            samples = [samples; {vars(i).name}]; %#ok<AGROW>
        end
    end
    
    
    
    % assign that list to the options in the pop up menu
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid');    
    set(hObject,'String',samples); 
    
    

% --- Executes on button press in pushbutton_popWriteData.
function pushbutton_popWriteData_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_popWriteData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    menuHandle = handles.popupmenu_popSelector;
    writedf(menuHandle,'population');

    
 
function writedf(handle,dfType)
    % get the active population's name
    dfNum = get(handle,'Value');
    dfNames = get(handle,'String');
    
    if isempty(dfNames) == 0
        dfName = dfNames{dfNum};
    else
        dfName = '';
    end
    
    %make sure there is an active population
    if isempty(dfName) == 0
        command = strcat(dfName,'.writeData()');
        verbosePrint(['Executing command: ','''',command,''''],'sosGui_writeDF');
        evalin('base',command);
    else
        msgbox(['A ',dfType,' must be active to write data'],...
                ['No active ',dfType]);
    end


    


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over popupmenu_popSelector.
function popupmenu_popSelector_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_popSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    populatePopList(hObject);


% --- Executes on key press with focus on popupmenu_popSelector and none of its controls.
function popupmenu_popSelector_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_popSelector (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_refreshPopList.
function pushbutton_refreshPopList_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_refreshPopList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % refresh the list of populations
    populatePopList(handles.popupmenu_popSelector);


% --- Executes on button press in pushbutton_createSample.
function pushbutton_createSample_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_createSample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    createSample_Dialog();

% --- Executes on selection change in popupmenu_sampleSelector.
function popupmenu_sampleSelector_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_sampleSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_sampleSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_sampleSelector
    populateSampleList(hObject);

% --- Executes during object creation, after setting all properties.
function popupmenu_sampleSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_sampleSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_writeSampleData.
function pushbutton_writeSampleData_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_writeSampleData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    menuHandle = handles.popupmenu_sampleSelector;
    writedf(menuHandle,'sample');

% --- Executes on button press in pushbutton_refreshSampleList.
function pushbutton_refreshSampleList_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_refreshSampleList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    populateSampleList(handles.popupmenu_sampleSelector);

% --- Executes during object creation, after setting all properties.
function pushbutton_createSample_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_createSample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over popupmenu_sampleSelector.
function popupmenu_sampleSelector_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_sampleSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    populateSampleList(hObject);


% --- Executes on button press in pushbutton_setPop.
function pushbutton_setPop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_setPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    %two things to do: first, make sure that there is an active population.
    % Second, make sure that there is an active sample.
    
    link = true;
   
    popMenuHandle = handles.popupmenu_popSelector;
    popName = getdfName(popMenuHandle,'population');
    
    if isempty(popName)
        link = false;
    end
    
    if link == true    
        sampleMenuHandle = handles.popupmenu_sampleSelector;
        sampleName = getdfName(sampleMenuHandle,'sample');
        
        if isempty(sampleName)
            link = false;
        end
        
        if link == true
            % we have valid samples and populations.  Link them.  
            
            command = [sampleName,'.setPop(',popName,');'];
            
            verbosePrint(['Executing command: ','''',command,''''],'sosGui_links2p');
            evalin('base',command);
        end
    end
 
    
% retrieves the name of a dataframe from the active lists of data frames    
% function dfName = getdfName(handle,dfType)    
%     dfNum = get(handle,'Value');
%     dfNames = get(handle,'String');
%     
%     if isempty(dfNames) == 0
%         dfName = dfNames{dfNum};
%     else
%         dfName = '';
%     end    
% 
%     %make sure there is an active df
%     if isempty(dfName) == 0
%         % success
%     else
%         msgbox(['A ',dfType,' must be active'],...
%                 ['No active ',dfType]);  
%     end
%     


% --- Executes on button press in pushbutton_sampleLock.
function pushbutton_sampleLock_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sampleLock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    menuHandle = handles.popupmenu_sampleSelector;
    execSimpleCmd(menuHandle,'sample','lockAll()');


% provides functiona
function execSimpleCmd(handle,dfType,cmd)
    % get the active population's name
    dfNum = get(handle,'Value');
    dfNames = get(handle,'String');
    
    if isempty(dfNames) == 0
        dfName = dfNames{dfNum};
    else
        dfName = '';
    end
    
    %make sure there is an active population
    if isempty(dfName) == 0
        command = strcat(dfName,'.',cmd);
        
        verbosePrint(['Executing command: ','''',command,''''],'sosGui_simpleCmd');
        evalin('base',command);
    else
        msgbox(['A ',dfType,' must be active to run: ',cmd],...
                ['No active ',dfType]);
    end
    
    


% --- Executes on button press in pushbutton_sampleUnlock.
function pushbutton_sampleUnlock_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sampleUnlock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    menuHandle = handles.popupmenu_sampleSelector;
    execSimpleCmd(menuHandle,'sample','unlockAll()');


% --- Executes on button press in pushbutton_createSOS.
function pushbutton_createSOS_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_createSOS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    createSOS_dialog();


% --- Executes on button press in pushbutton_refresh_SOSlist.
function pushbutton_refresh_SOSlist_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_refresh_SOSlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    populateSOSList(handles.popupmenu_SOSSelector);

    
% --- Executes on selection change in popupmenu_SOSSelector.
function popupmenu_SOSSelector_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_SOSSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_SOSSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_SOSSelector
    populateSOSList(hObject);
    
% --- Executes during object creation, after setting all properties.
function popupmenu_SOSSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_SOSSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function populateSOSList(hObject)    
    % get a list of all populations in the base workspace:
    vars = evalin('base','whos()');
    
    sosObjs = [];
    for i=1:length(vars)
        if strcmp(vars(i).class,'sos')
            sosObjs = [sosObjs; {vars(i).name}]; %#ok<AGROW>
        end
    end
    
    
    
    % assign that list to the options in the pop up menu
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid');    
    set(hObject,'String',sosObjs); 


% --- Executes on key press with focus on popupmenu_sampleSelector and none of its controls.
function popupmenu_sampleSelector_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_sampleSelector (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over popupmenu_SOSSelector.
function popupmenu_SOSSelector_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_SOSSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    populateSOSList(hObject);


% --- Executes on button press in pushbutton_addSample.
function pushbutton_addSample_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_addSample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    add = true;
    
    %retrieve name of active sample
    sampleMenuHandle = handles.popupmenu_sampleSelector;
    sampleName = getdfName(sampleMenuHandle,'sample');
    
    if isempty(sampleName)
        add = false;
    end
    
    % if there is a valid active sample, add it.
    
    if add == true
        sosMenuHandle = handles.popupmenu_SOSSelector;
        sosName = getdfName(sosMenuHandle,'SOS');
        
        if isempty(sosName)
            add = false;
        end
        
        if add == true
            % we have a valid sample and a valid SOS object.  Add the
            % sample to the sos object
            
            command = [sosName,'.addSample(',sampleName,');'];
            
            verbosePrint(['Executing command: ','''',command,''''],'sosGui_addSample');
            evalin('base',command);
        end
    end
    


% --- Executes on button press in pushbutton_createHistory.
function pushbutton_createHistory_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_createHistory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

        create = true;
    
        sosMenuHandle = handles.popupmenu_SOSSelector;
        sosName = getdfName(sosMenuHandle,'SOS');
        
        if isempty(sosName)
            create = false;
        end
        
        if create == true   
            % create the history
            command = [sosName,'.createHistory();'];
            
            verbosePrint(['Executing command: ','''',command,''''],'sosGui_createHistory');
            evalin('base',command);         
        end
        
            
            


% --- Executes on button press in pushbutton_createPlots.
function pushbutton_createPlots_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_createPlots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    create = true;
    
        sosMenuHandle = handles.popupmenu_SOSSelector;
        sosName = getdfName(sosMenuHandle,'SOS');
        
        if isempty(sosName)
            create = false;
        end
        
        if create == true   
            % run the createPlots dialog to give users choice of optional
            % params
            createPlots_Dialog();
        end
        



function edit_dispIt_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dispIt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dispIt as text
%        str2double(get(hObject,'String')) returns contents of edit_dispIt as a double


% --- Executes during object creation, after setting all properties.
function edit_dispIt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dispIt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_deltaCostPercentiles.
function pushbutton_deltaCostPercentiles_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_deltaCostPercentiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        run = true;
    
        sosMenuHandle = handles.popupmenu_SOSSelector;
        sosName = getdfName(sosMenuHandle,'SOS');
        
        if isempty(sosName)
            run = false;
        end
        
        if run == true   
            % create the history
            command = [sosName,'.deltaCostPercentiles();'];
            
            verbosePrint(['Executing command: ','''',command,''''],'sosGui_deltaCostDeciles');
            evalin('base',command);         
        end


% --- Executes on button press in pushbutton_writeHistory.
function pushbutton_writeHistory_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_writeHistory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    saveHistory_Dialog();


% --- Executes on button press in pushbutton_writeSamples.
function pushbutton_writeSamples_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_writeSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        write = true;
    
        sosMenuHandle = handles.popupmenu_SOSSelector;
        sosName = getdfName(sosMenuHandle,'SOS');
        
        if isempty(sosName)
            write = false;
        end
        
        if write == true   
            % create the history
            command = [sosName,'.writeSamples();'];
            
            verbosePrint(['Executing command: ','''',command,''''],'sosGui_writeSamples');
            evalin('base',command);         
        end
        


% --- Executes on button press in pushbutton_writePopulations.
function pushbutton_writePopulations_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_writePopulations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        write = true;
    
        sosMenuHandle = handles.popupmenu_SOSSelector;
        sosName = getdfName(sosMenuHandle,'SOS');
        
        if isempty(sosName)
            write = false;
        end
        
        if write == true   
            % create the history
            command = [sosName,'.writePopulations();'];
            
            verbosePrint(['Executing command: ','''',command,''''],'sosGui_writePopulations');
            evalin('base',command);         
        end


% --- Executes on button press in pushbutton_dispCost.
function pushbutton_dispCost_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_dispCost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        write = true;
    
        sosMenuHandle = handles.popupmenu_SOSSelector;
        sosName = getdfName(sosMenuHandle,'SOS');
        
        if isempty(sosName)
            write = false;
        end
        
        if write == true   
            % create the history
            command = [sosName,'.dispCost();'];
            
            verbosePrint(['Executing command: ','''',command,''''],'sosGui_dispCost');
            evalin('base',command);         
        end


% --- Executes on button press in pushbutton_initCost.
function pushbutton_initCost_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_initCost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        write = true;
    
        sosMenuHandle = handles.popupmenu_SOSSelector;
        sosName = getdfName(sosMenuHandle,'SOS');
        
        if isempty(sosName)
            write = false;
        end
        
        if write == true   
            % create the history
            command = [sosName,'.initCost();'];
            
            verbosePrint(['Executing command: ','''',command,''''],'sosGui_initCost');
            evalin('base',command);         
        end


% --- Executes on button press in pushbutton_writeAll.
function pushbutton_writeAll_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_writeAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        write = true;
    
        sosMenuHandle = handles.popupmenu_SOSSelector;
        sosName = getdfName(sosMenuHandle,'SOS');
        
        if isempty(sosName)
            write = false;
        end
        
        if write == true   
            % create the history
            command = [sosName,'.writeAll();'];
            
            verbosePrint(['Executing command: ','''',command,''''],'sosGui_writeAll');
            evalin('base',command);         
        end


% --- Executes on button press in pushbutton_initFillSamples.
function pushbutton_initFillSamples_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_initFillSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        write = true;
    
        sosMenuHandle = handles.popupmenu_SOSSelector;
        sosName = getdfName(sosMenuHandle,'SOS');
        
        if isempty(sosName)
            write = false;
        end
        
        if write == true   
            % create the history
            command = [sosName,'.initFillSamples();'];
            
            verbosePrint(['Executing command: ','''',command,''''],'sosGui_initFillSamples');
            evalin('base',command);         
        end


% --- Executes on button press in pushbutton_normalizeData.
function pushbutton_normalizeData_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_normalizeData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        write = true;
    
        sosMenuHandle = handles.popupmenu_SOSSelector;
        sosName = getdfName(sosMenuHandle,'SOS');
        
        if isempty(sosName)
            write = false;
        end
        
        if write == true   
            % create the history
            command = [sosName,'.normalizeData();'];
            
            verbosePrint(['Executing command: ','''',command,''''],'sosGui_initFillSamples');
            evalin('base',command);         
        end


% --- Executes on button press in pushbutton_setSeed.
function pushbutton_setSeed_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_setSeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    setSeed_Dialog();


% --- Executes on button press in pushbutton_setBufferedHistoryOutfile.
function pushbutton_setBufferedHistoryOutfile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_setBufferedHistoryOutfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    setBufferedHistoryOutfile_Dialog();


% --- Executes on button press in pushbutton28.
function pushbutton28_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_enableBufferedHistoryWrite.
function pushbutton_enableBufferedHistoryWrite_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_enableBufferedHistoryWrite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

        create = true;
    
        sosMenuHandle = handles.popupmenu_SOSSelector;
        sosName = getdfName(sosMenuHandle,'SOS');
        
        if isempty(sosName)
            create = false;
        end
        
        if create == true   
            % create the history
            command = [sosName,'.enableBufferedHistoryWrite();'];
            
            
            verbosePrint(['Executing command: ','''',command,''''],'sosGui_enableBufferedHistory');
            evalin('base',command);         
        end


% --- Executes on button press in pushbutton_disableBufferedHistoryWrite.
function pushbutton_disableBufferedHistoryWrite_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_disableBufferedHistoryWrite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        create = true;
    
        sosMenuHandle = handles.popupmenu_SOSSelector;
        sosName = getdfName(sosMenuHandle,'SOS');
        
        if isempty(sosName)
            create = false;
        end
        
        if create == true   
            % create the history
            command = [sosName,'.disableBufferedHistoryWrite();'];
            
            verbosePrint(['Executing command: ','''',command,''''],'sosGui_disableBufferedHistory');
            evalin('base',command);         
        end


% --- Executes on selection change in popupmenu_reportStyleSelector.
function popupmenu_reportStyleSelector_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_reportStyleSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_reportStyleSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_reportStyleSelector


% --- Executes during object creation, after setting all properties.
function popupmenu_reportStyleSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_reportStyleSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_doStatsTests.
function pushbutton_doStatsTests_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_doStatsTests (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

        run = true;
    
        sosMenuHandle = handles.popupmenu_SOSSelector;
        sosName = getdfName(sosMenuHandle,'SOS');
        
        if isempty(sosName)
            run = false;
        end
        
        if run == true   
            
            % retrieve the reportStyle
            
            styleMenuHandle = handles.popupmenu_reportStyleSelector;
            style = getdfName(styleMenuHandle,'reportStyle');
            
            % create the history
            command = [sosName,'.doStatTests(''reportStyle'',''',style,''');'];
            
            verbosePrint(['Executing command: ','''',command,''''],'sosGui_doStats');
            evalin('base',command);         
        end


% --- Executes on button press in pushbutton_setFeederdfCandidateSelectionMethod.
function pushbutton_setFeederdfCandidateSelectionMethod_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_setFeederdfCandidateSelectionMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        set = true;
    
        sosMenuHandle = handles.popupmenu_SOSSelector;
        sosName = getdfName(sosMenuHandle,'SOS');
        
        if isempty(sosName)
            set = false;
        end
        
        if set == true   
            
            modeMenuHandle = handles.popupmenu_feederdfCandSelectMethod;
            mode = getdfName(modeMenuHandle,'neighborMode');
            
            % create the history
            command = [sosName,'.setFeederdfCandidateSelectionMethod(''',mode,''');'];
            
            verbosePrint(['Executing command: ','''',command,''''],'sosGui_setFeederdfCandMethod');
            evalin('base',command);         
        end

% --- Executes on selection change in popupmenu_feederdfCandSelectMethod.
function popupmenu_feederdfCandSelectMethod_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_feederdfCandSelectMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_feederdfCandSelectMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_feederdfCandSelectMethod


% --- Executes during object creation, after setting all properties.
function popupmenu_feederdfCandSelectMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_feederdfCandSelectMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_greedyAnneal.
function pushbutton_greedyAnneal_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_greedyAnneal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        set = true;
    
        sosMenuHandle = handles.popupmenu_SOSSelector;
        sosName = getdfName(sosMenuHandle,'SOS');
        
        if isempty(sosName)
            set = false;
        end
        
        if set == true   
            % create the history
            command = [sosName,'.setAnnealSchedule(''schedule'',''greedy'');'];
            
            verbosePrint(['Executing command: ','''',command,''''],'sosGui_greedyAnneal');
            evalin('base',command);         
        end


% --- Executes on button press in pushbutton_expAnneal.
function pushbutton_expAnneal_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_expAnneal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    expAnneal_Dialog();


% --- Executes on button press in pushbutton_numSteps.
function pushbutton_numSteps_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_numSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    numSteps_Dialog();

% --- Executes on button press in pushbutton_maxpDecrease.
function pushbutton_maxpDecrease_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_maxpDecrease (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    maxpDecrease_Dialog();


% --- Executes on button press in pushbutton_optimize.
function pushbutton_optimize_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_optimize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  %  disp('STOPPING');


    set(handles.pushbutton_stopOptimize,'UserData',0);
    run = true;

    sosMenuHandle = handles.popupmenu_SOSSelector;
    sosName = getdfName(sosMenuHandle,'SOS');
 
    if isempty(sosName)
        run = false;
    end

    if run == true   

        % if the number of iterations to run for is blank, run
        numIt = (get(handles.edit_numIt,'String'));

       set(handles.pushbutton_stopOptimize,'Enable','on');
        
        if isempty(numIt)
        % 
            command = [sosName,'.optimize(''isGui'',1);'];
            verbosePrint(['Executing command: ','''',command,''''],'sosGui_optimize');  
            
            set(handles.pushbutton_optimize,'Enable','off');
            evalin('base',command);      
            
        elseif validate_numIt(handles)
            command = [sosName,'.optimize(',numIt,',''isGui'',1);'];
            verbosePrint(['Executing command: ','''',command,''''],'sosGui_optimize');
            
            set(handles.pushbutton_optimize,'Enable','off');              
            evalin('base',command);  
          
        end
    end
        

% --- Executes on button press in pushbutton_stopOptimize.
function pushbutton_stopOptimize_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_stopOptimize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  %  disp('STOPPING');
    set(handles.pushbutton_stopOptimize,'UserData',1);
    %guidata(hObject,handles);
    set(handles.pushbutton_stopOptimize,'Enable','off');
    set(handles.pushbutton_optimize,'Enable','on');
    

function edit_numIt_Callback(hObject, eventdata, handles)
% hObject    handle to edit_numIt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_numIt as text
%        str2double(get(hObject,'String')) returns contents of edit_numIt as a double
    validate_numIt(handles);


function flag = validate_numIt(handles)
    str = get(handles.edit_numIt,'String');
    
    if isempty(str)
        flag = 1; % valid if empty
    else

        errmsg = 'Number of iterations must be a whole number > 0';
        errtitle = 'Invalid numIt!';

        flag = validatePositiveInteger(str,errmsg,errtitle);
    end
    

% --- Executes during object creation, after setting all properties.
function edit_numIt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_numIt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function pushbutton_stopOptimize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_stopOptimize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton_2sample_ttest.
function pushbutton_2sample_ttest_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_2sample_ttest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        create = true;
    
        sosMenuHandle = handles.popupmenu_SOSSelector;
        sosName = getdfName(sosMenuHandle,'SOS');
        
        if isempty(sosName)
            create = false;
        end
        
        if create == true   
            create2samplettest_Dialog();        
        end


    
    


% --- Executes on button press in pushbutton_singlettest.
function pushbutton_singlettest_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_singlettest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        create = true;
    
        sosMenuHandle = handles.popupmenu_SOSSelector;
        sosName = getdfName(sosMenuHandle,'SOS');
        
        if isempty(sosName)
            create = false;
        end
        
        if create == true   
            createsinglesamplettest_Dialog();        
        end


% --- Executes on button press in pushbutton_createHardBoundConstraint.
function pushbutton_createHardBoundConstraint_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_createHardBoundConstraint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    createHardBoundConstraint_Dialog();

% --- Executes on button press in pushbutton_createSingleSampleSoftDistanceConstraint.
function pushbutton_createSingleSampleSoftDistanceConstraint_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_createSingleSampleSoftDistanceConstraint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    createSingleSampleSoftDistanceConstraint_Dialog();

% --- Executes on button press in pushbutton_create2SampleSoftDistanceConstraint.
function pushbutton_create2SampleSoftDistanceConstraint_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_create2SampleSoftDistanceConstraint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    createTwoSampleSoftDistanceConstraint_Dialog();


% --- Executes on button press in pushbutton_createSoftEntropyConstraint.
function pushbutton_createSoftEntropyConstraint_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_createSoftEntropyConstraint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    createSoftEntropyConstraint_Dialog();


% --- Executes on selection change in popupmenu_entropyConstraintSelector.
function popupmenu_entropyConstraintSelector_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_entropyConstraintSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    populateEntropyConstraintList(hObject);

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_entropyConstraintSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_entropyConstraintSelector
function populateEntropyConstraintList(hObject)    
    % get a list of all populations in the base workspace:
    vars = evalin('base','whos()');
    
    cObjs = [];
    for i=1:length(vars)
        if strcmp(vars(i).class,'softEntropyConstraint')
            cObjs = [cObjs; {vars(i).name}]; %#ok<AGROW>
        end
    end
    
    
    
    % assign that list to the options in the pop up menu
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid');    
    set(hObject,'String',cObjs); 
    
    

% --- Executes during object creation, after setting all properties.
function popupmenu_entropyConstraintSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_entropyConstraintSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_plotSoftEntropyConstraint.
function pushbutton_plotSoftEntropyConstraint_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_plotSoftEntropyConstraint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

        create = true;
    
        entropyMenuHandle = handles.popupmenu_entropyConstraintSelector;
        entName = getdfName(entropyMenuHandle,'Soft entropy constraint');
        
        if isempty(entName)
            create = false;
        end
        
        if create == true   
            % create the history
            command = [entName,'.plotDistribution();'];
            
            evalin('base',command);         
        end

% --- Executes on button press in pushbutton_refreshSoftEntropyConstraintSelector.
function pushbutton_refreshSoftEntropyConstraintSelector_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_refreshSoftEntropyConstraintSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    populateEntropyConstraintList(handles.popupmenu_entropyConstraintSelector);


% --- Executes on button press in pushbutton_createSoftMetaConstraint.
function pushbutton_createSoftMetaConstraint_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_createSoftMetaConstraint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    createSoftMetaConstraint_Dialog();


% --- Executes on button press in pushbutton_calculateOverlap.
function pushbutton_calculateOverlap_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_calculateOverlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    calculateOverlap_Dialog();
    


% --- Executes on button press in pushbutton_createSoftMatchCorrelConstraint.
function pushbutton_createSoftMatchCorrelConstraint_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_createSoftMatchCorrelConstraint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    createSoftMatchCorrelDistanceConstraint_Dialog();


% --- Executes on button press in pushbutton_matchCorrel_ztest.
function pushbutton_matchCorrel_ztest_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_matchCorrel_ztest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        create = true;
    
        sosMenuHandle = handles.popupmenu_SOSSelector;
        sosName = getdfName(sosMenuHandle,'SOS');
        
        if isempty(sosName)
            create = false;
        end
        
        if create == true   
            createMatchCorrelztest_Dialog();        
        end


% --- Executes on button press in pushbutton_kstest.
function pushbutton_kstest_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_kstest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        create = true;
    
        sosMenuHandle = handles.popupmenu_SOSSelector;
        sosName = getdfName(sosMenuHandle,'SOS');
        
        if isempty(sosName)
            create = false;
        end
        
        if create == true   
            createMatchUniformkstest_Dialog();        
        end
