% - create uniformity ks-test dialog
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



function varargout = createMatchUniformkstest_Dialog(varargin)
% CREATEMATCHUNIFORMKSTEST_DIALOG M-file for createMatchUniformkstest_Dialog.fig
%      CREATEMATCHUNIFORMKSTEST_DIALOG, by itself, creates a new CREATEMATCHUNIFORMKSTEST_DIALOG or raises the existing
%      singleton*.
%
%      H = CREATEMATCHUNIFORMKSTEST_DIALOG returns the handle to a new CREATEMATCHUNIFORMKSTEST_DIALOG or the handle to
%      the existing singleton*.
%
%      CREATEMATCHUNIFORMKSTEST_DIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATEMATCHUNIFORMKSTEST_DIALOG.M with the given input arguments.
%
%      CREATEMATCHUNIFORMKSTEST_DIALOG('Property','Value',...) creates a new CREATEMATCHUNIFORMKSTEST_DIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before createMatchUniformkstest_Dialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to createMatchUniformkstest_Dialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help createMatchUniformkstest_Dialog

% Last Modified by GUIDE v2.5 16-Aug-2011 17:24:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @createMatchUniformkstest_Dialog_OpeningFcn, ...
                   'gui_OutputFcn',  @createMatchUniformkstest_Dialog_OutputFcn, ...
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


% --- Executes just before createMatchUniformkstest_Dialog is made visible.
function createMatchUniformkstest_Dialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to createMatchUniformkstest_Dialog (see VARARGIN)

% Choose default command line output for createMatchUniformkstest_Dialog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes createMatchUniformkstest_Dialog wait for user response (see UIRESUME)
% uiwait(handles.figure_createMatchUniformkstest_Dialog);


% --- Outputs from this function are returned to the command line.
function varargout = createMatchUniformkstest_Dialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_name_Callback(hObject, eventdata, handles)
% hObject    handle to edit_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_name as text
%        str2double(get(hObject,'String')) returns contents of edit_name as a double
    validate_name(handles);
    

function flag = validate_name(handles)

    varName = get(handles.edit_name,'String');
    
    %check to make sure that the name is a valid variable name:
    valid = regexp(varName,'^[a-zA-Z]+\w*$', 'once');
    
    if isempty(valid)
        % name is not currently valid, tell the user.
        msgbox('Only letters, numbers, and underscores are permitted in the name of the ttest object.  The first character must also be a letter.',...
                'Invalid name!');
        flag = false;
    else
        % check to make sure that the new variable name doesn't already exist.
        command = strcat('whos(''',varName,''')');
        varExists = evalin('base',command);


        % if a variable with this name already exists, warns the user
        if isempty(varExists) == 0
            msgbox('A variable with this name already exists and will be overridden if you continue',...
                    'Variable name already in use!');
        end
        
        flag = true;
    end
    
    

% --- Executes during object creation, after setting all properties.
function edit_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_sample1Selector.
function popupmenu_sample1Selector_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_sample1Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_sample1Selector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_sample1Selector
    populateSampleList(hObject);


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

% --- Executes during object creation, after setting all properties.
function popupmenu_sample1Selector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_sample1Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_refreshSample1List.
function pushbutton_refreshSample1List_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_refreshSample1List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    populateSampleList(handles.popupmenu_sample1Selector);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over popupmenu_sample1Selector.
function popupmenu_sample1Selector_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_sample1Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    populateSampleList(hObject);


% --- Executes on selection change in popupmenu_sample1ColSelector.
function popupmenu_sample1ColSelector_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_sample1ColSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    populateColumnList(hObject,handles.popupmenu_sample1Selector);

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_sample1ColSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_sample1ColSelector
function populateColumnList(hObject,sampleSelector)    
    % get a list of all populations in the base workspace:

    create = true;
    
    % get the sample in the first list.
    sampleMenuHandle = sampleSelector;
    sampleName = getdfName(sampleMenuHandle,'sample 1');    
    
    if isempty(sampleName)
        create = false;
    end
    
    if create == true
        % add in all of the header names associated with that sample.  
        tmpColNames = evalin('base',[sampleName,'.header']);
        
        % melt and refreeze cells
        colNames = {};
        
        for i=1:length(tmpColNames)
            colNames = [colNames ; tmpColNames{i}]; %#ok<AGROW>
        end
        
    
    % assign that list to the options in the pop up menu
        warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid');    
        set(hObject,'String',colNames);
    end

% --- Executes during object creation, after setting all properties.
function popupmenu_sample1ColSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_sample1ColSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_refreshsample1ColSelector.
function pushbutton_refreshsample1ColSelector_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_refreshsample1ColSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    populateColumnList(handles.popupmenu_sample1ColSelector,handles.popupmenu_sample1Selector);


% --- Executes on selection change in popupmenu_sample2Selector.
function popupmenu_sample2Selector_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_sample2Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_sample2Selector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_sample2Selector
    populateSampleList(hObject);


% --- Executes during object creation, after setting all properties.
function popupmenu_sample2Selector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_sample2Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_refreshSample2List.
function pushbutton_refreshSample2List_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_refreshSample2List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    populateSampleList(handles.popupmenu_sample2Selector);

% --- Executes on selection change in popupmenu_sample2ColSelector.
function popupmenu_sample2ColSelector_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_sample2ColSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_sample2ColSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_sample2ColSelector
    populateColumnList(hObject,handles.popupmenu_sample2Selector);


% --- Executes during object creation, after setting all properties.
function popupmenu_sample2ColSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_sample2ColSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_refreshsample2ColSelector.
function pushbutton_refreshsample2ColSelector_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_refreshsample2ColSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    populateColumnList(handles.popupmenu_sample2ColSelector,handles.popupmenu_sample2Selector);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over popupmenu_sample1ColSelector.
function popupmenu_sample1ColSelector_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_sample1ColSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    populateColumnList(hObject,handles.popupmenu_sample1Selector);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over popupmenu_sample2Selector.
function popupmenu_sample2Selector_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_sample2Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    populateSampleList(hObject);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over popupmenu_sample2ColSelector.
function popupmenu_sample2ColSelector_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_sample2ColSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    populateColumnList(hObject,handles.popupmenu_sample2Selector);



function edit_desiredpval_Callback(hObject, eventdata, handles)
% hObject    handle to edit_desiredpval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_desiredpval as text
%        str2double(get(hObject,'String')) returns contents of edit_desiredpval as a double
    validate_desiredpval(handles);


function flag = validate_desiredpval(handles)
    str = get(handles.edit_desiredpval,'String');
    
    errmsg = 'alpha must be a probability value between 0 and 1';
    errtitle = 'Invalid alpha!';
    
    flag = validateProbability(str,errmsg,errtitle);

% --- Executes during object creation, after setting all properties.
function edit_desiredpval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_desiredpval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_desiredpvalCondition.
function popupmenu_desiredpvalCondition_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_desiredpvalCondition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_desiredpvalCondition contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_desiredpvalCondition


% --- Executes during object creation, after setting all properties.
function popupmenu_desiredpvalCondition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_desiredpvalCondition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_tails.
function popupmenu_tails_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_tails (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_tails contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_tails


% --- Executes during object creation, after setting all properties.
function popupmenu_tails_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_tails (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_create_kstest.
function pushbutton_create_kstest_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_create_kstest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    type = getdfName(handles.popupmenu_type,'type');

    mainWindowHandle = sos_gui;
    mainWindowData = guidata(mainWindowHandle);

    sosObjName = getdfName(mainWindowData.popupmenu_SOSSelector,'SOS');

    if isempty(sosObjName) == 0
        % we have a valid SOS object to add the test to        
        % validate all of the parameters for the test        
        create = validate_name(handles);
        name = get(handles.edit_name,'String');
        
        if create == true
            sample1 = getdfName(handles.popupmenu_sample1Selector,'sample 1');
            
            if isempty(sample1) == 0
                sample1Col = getdfName(handles.popupmenu_sample1ColSelector','sample 1 column');
                
                if isempty(sample1Col) == 0
                    create = validate_nbin(handles);
                    
                    if create == true
                        nbin = get(handles.edit_nbin,'String');
                        
                            create  = validate_desiredpval(handles);

                            if create == true

                                pdSpread = getdfName(handles.popupmenu_pdSpreadSelector,...
                                                    'pdSpread');                                
                                desiredpval = get(handles.edit_desiredpval,'String');
                                
                                desiredpvalCondition = getdfName(handles.popupmenu_desiredpvalCondition,...
                                                    'desiredpvalCondition');
                                %all of the other options are in drop-down
                                %menus and as such necessarily will pass.
                                %run the command.
                                
                                if isempty(nbin)
                                    command = [sosObjName,'.addkstest(',...
                                        '''name'',''',name,''',',...
                                        '''type'',''',type,''',',...
                                        '''sample1'',',sample1,',',...
                                        '''s1ColName'',''',sample1Col,''',',...
                                        '''pdSpread'',''',pdSpread,''',',...                                       
                                        '''desiredpvalCondition'',''',desiredpvalCondition,''',',...
                                        '''desiredpval'',',desiredpval,');',...
                                        ];

                                    verbosePrint(['Executing command: ','''',command,''''],'createMatchUniformkstest_Dialog_create');
                                    evalin('base',command);      
                                    close(handles.figure_createMatchUniformkstest_Dialog);                                    
                                else
                                    
                                    command = [sosObjName,'.addkstest(',...
                                        '''name'',''',name,''',',...
                                        '''type'',''',type,''',',...
                                        '''sample1'',',sample1,',',...
                                        '''s1ColName'',''',sample1Col,''',',...
                                        '''pdSpread'',''',pdSpread,''',',...
                                        '''nbin'',',nbin,',',...
                                        '''desiredpvalCondition'',''',desiredpvalCondition,''',',...
                                        '''desiredpval'',',desiredpval,');',...
                                        ];

                                    verbosePrint(['Executing command: ','''',command,''''],'createMatchUniformkstest_Dialog_create');
                                    evalin('base',command);      
                                    close(handles.figure_createMatchUniformkstest_Dialog);
                                end
                                
                            end
                    end
                    
                end
            end
        end
        
        
    end


% --- Executes on selection change in popupmenu_type.
function popupmenu_type_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_type


% --- Executes during object creation, after setting all properties.
function popupmenu_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_nbin_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nbin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_nbin as text
%        str2double(get(hObject,'String')) returns contents of edit_nbin as a double
    validate_nbin(handles);
    
    
function flag = validate_nbin(handles)
     str = get(handles.edit_nbin,'String');
    
    errmsg = 'Bound value must be a number';
    errtitle = 'Invalid bound value!';
    
    if isempty(str)
        flag = true;
    else    
        flag = validatePositiveInteger(str,errmsg,errtitle);    
    end
    
    
function flag = validate_targValue(handles)
     str = get(handles.edit_nbin,'String');
    
    errmsg = 'target value must be a real number';
    errtitle = 'Invalid targValue!';
    
    flag = validateRealNumber(str,errmsg,errtitle);      

% --- Executes during object creation, after setting all properties.
function edit_nbin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nbin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in popupmenu_pdSpreadSelector.
function popupmenu_pdSpreadSelector_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_pdSpreadSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_pdSpreadSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_pdSpreadSelector


% --- Executes during object creation, after setting all properties.
function popupmenu_pdSpreadSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_pdSpreadSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
