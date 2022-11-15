% - create soft meta-constraint dialog
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


function varargout = createSoftMetaConstraint_Dialog(varargin)
% CREATESOFTMETACONSTRAINT_DIALOG M-file for createSoftMetaConstraint_Dialog.fig
%      CREATESOFTMETACONSTRAINT_DIALOG, by itself, creates a new CREATESOFTMETACONSTRAINT_DIALOG or raises the existing
%      singleton*.
%
%      H = CREATESOFTMETACONSTRAINT_DIALOG returns the handle to a new CREATESOFTMETACONSTRAINT_DIALOG or the handle to
%      the existing singleton*.
%
%      CREATESOFTMETACONSTRAINT_DIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATESOFTMETACONSTRAINT_DIALOG.M with the given input arguments.
%
%      CREATESOFTMETACONSTRAINT_DIALOG('Property','Value',...) creates a new CREATESOFTMETACONSTRAINT_DIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before createSoftMetaConstraint_Dialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to createSoftMetaConstraint_Dialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help createSoftMetaConstraint_Dialog

% Last Modified by GUIDE v2.5 17-Sep-2010 15:47:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @createSoftMetaConstraint_Dialog_OpeningFcn, ...
                   'gui_OutputFcn',  @createSoftMetaConstraint_Dialog_OutputFcn, ...
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


% --- Executes just before createSoftMetaConstraint_Dialog is made visible.
function createSoftMetaConstraint_Dialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to createSoftMetaConstraint_Dialog (see VARARGIN)

% Choose default command line output for createSoftMetaConstraint_Dialog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes createSoftMetaConstraint_Dialog wait for user response (see UIRESUME)
% uiwait(handles.figure_createSoftMetaConstraint_Dialog);


% --- Outputs from this function are returned to the command line.
function varargout = createSoftMetaConstraint_Dialog_OutputFcn(hObject, eventdata, handles) 
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


% --- Executes on selection change in popupmenu_constraint1Selector.
function popupmenu_constraint1Selector_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_constraint1Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_constraint1Selector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_constraint1Selector
    populateConstraintList(hObject);


function populateConstraintList(hObject)    
    % get a list of all populations in the base workspace:

    mainWindowHandle = sos_gui;
    mainWindowData = guidata(mainWindowHandle);

    sosObjName = getdfName(mainWindowData.popupmenu_SOSSelector,'SOS');

   list = {}; 
    % we have an SOS object.  List its constraints:
    if isempty(sosObjName) == 0    
        tmpSOS = evalin('base',sosObjName);
          
        for i=1:length(tmpSOS.hardConstraints)
            list = [list ; tmpSOS.hardConstraints{i}.name]; %#ok<AGROW>
        end
        
        for i=1:length(tmpSOS.softConstraints)
            list = [list ; tmpSOS.softConstraints{i}.name]; %#ok<AGROW>
        end        

    end
    
    
    % assign that list to the options in the pop up menu
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid');    
    set(hObject,'String',list);
    createSoftMetaConstraint_Dialog();

    
    
    
% --- Executes during object creation, after setting all properties.
function popupmenu_constraint1Selector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_constraint1Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_refreshSample2List.
function pushbutton_refreshSample1List_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_refreshSample2List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    populateConstraintList(handles.popupmenu_constraint1Selector);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over popupmenu_constraint1Selector.
function popupmenu_constraint1Selector_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_constraint1Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    populateConstraint(hObject);


% --- Executes on selection change in popupmenu_sample1ColSelector.
function popupmenu_sample1ColSelector_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_sample1ColSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    populateColumnList(hObject,handles.popupmenu_constraint1Selector);

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
    populateColumnList(handles.popupmenu_sample1ColSelector,handles.popupmenu_constraint1Selector);


% --- Executes on selection change in popupmenu_sample2Selector.
function popupmenu_sample2Selector_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_sample2Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_sample2Selector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_sample2Selector
    populateConstraintList(hObject);


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
populateConstraintList(handles.popupmenu_constraint2Selector);


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
    populateColumnList(hObject,handles.popupmenu_constraint1Selector);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over popupmenu_sample2Selector.
function popupmenu_sample2Selector_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_sample2Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    populateConstraintList(hObject);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over popupmenu_sample2ColSelector.
function popupmenu_sample2ColSelector_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_sample2ColSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    populateColumnList(hObject,handles.popupmenu_sample2Selector);



function edit_value_Callback(hObject, eventdata, handles)
% hObject    handle to edit_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_value as text
%        str2double(get(hObject,'String')) returns contents of edit_value as a double
    validate_value(handles);
    
    
function flag = validate_value(handles)
     str = get(handles.edit_value,'String');
    
    errmsg = 'Multiplier must be a number';
    errtitle = 'Invalid Multiplier!';
    
    flag = validateRealNumber(str,errmsg,errtitle);    
    
    

% --- Executes during object creation, after setting all properties.
function edit_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_value (see GCBO)
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


% --- Executes on button press in pushbutton_createSoftMetaConstraint.
function pushbutton_createSoftMetaConstraint_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_createSoftMetaConstraint (see GCBO)
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
            constraint1 = getdfName(handles.popupmenu_constraint1Selector,'constraint 1');
            
            if isempty(constraint1) == 0
                constraint2 = getdfName(handles.popupmenu_constraint2Selector','constraint 2');
                
                if isempty(constraint2) == 0
                   create = validate_value(handles);
                   
                   if create == true
                       % all values have passed.  Can execute the command
                        value = get(handles.edit_value,'String');
                        
                        % check weight
                        create = validate_weight(handles);
                        if create == true
                            weight = get(handles.edit_weight,'String');
                            
                            create = validate_exp(handles);
                            if create == true
                                exp = get (handles.edit_exp,'String');
                                
                                    %all functions passed, retrieve the
                                    %hard-coded popup menu data

                                    fnc = getdfName(handles.popupmenu_fncSelector,...
                                                    'fnc');
                                                
                                    %all of the other options are in drop-down
                                    %menus and as such necessarily will pass.
                                    %run the command.

                                    command = [name,'=',sosObjName,'.addConstraint(',...
                                        '''name'',''',name,''',',...
                                        '''constraintType'',''',type,''',',...
                                        '''fnc'',''',fnc,''',',...
                                        '''constraint1'',',constraint1,',',...
                                        '''constraint2'',',constraint2,',',...
                                        '''constraint2costScale'',',value,',',...
                                        '''weight'',',weight,','...
                                        '''exponent'',',exp,');',...
                                        ];
                                    
                                    
                                    verbosePrint(['Executing command: ','''',command,''''],'createSoftMetaConstraint_Dialog_create');
                                    evalin('base',command);      
                                    close(handles.figure_createSoftMetaConstraint_Dialog);   
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


% --- Executes on selection change in popupmenu_fncSelector.
function popupmenu_fncSelector_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_fncSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_fncSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_fncSelector


% --- Executes during object creation, after setting all properties.
function popupmenu_fncSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_fncSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_weight_Callback(hObject, eventdata, handles)
% hObject    handle to edit_weight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_weight as text
%        str2double(get(hObject,'String')) returns contents of edit_weight as a double
    validate_weight(handles);
    
    
function flag = validate_weight(handles)
     str = get(handles.edit_weight,'String');
    
    errmsg = 'Weight must be a number';
    errtitle = 'Invalid weight!';
    
    flag = validateRealNumber(str,errmsg,errtitle); 

% --- Executes during object creation, after setting all properties.
function edit_weight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_weight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_exp_Callback(hObject, eventdata, handles)
% hObject    handle to edit_exp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_exp as text
%        str2double(get(hObject,'String')) returns contents of edit_exp as a double
    validate_exp(handles);
    
    
function flag = validate_exp(handles)
     str = get(handles.edit_exp,'String');
    
    errmsg = 'Exponent must be a number';
    errtitle = 'Invalid exponent!';
    
    flag = validateRealNumber(str,errmsg,errtitle); 

% --- Executes during object creation, after setting all properties.
function edit_exp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_exp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_statSelector.
function popupmenu_statSelector_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_statSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_statSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_statSelector


% --- Executes during object creation, after setting all properties.
function popupmenu_statSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_statSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_constraint2Selector.
function popupmenu_constraint2Selector_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_constraint2Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_constraint2Selector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_constraint2Selector
    populateConstraintList(hObject);

% --- Executes during object creation, after setting all properties.
function popupmenu_constraint2Selector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_constraint2Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_refreshSample2List.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_refreshSample2List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on popupmenu_constraint2Selector and none of its controls.
function popupmenu_constraint2Selector_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_constraint2Selector (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over popupmenu_constraint2Selector.
function popupmenu_constraint2Selector_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_constraint2Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
populateConstraintList(hObject);
