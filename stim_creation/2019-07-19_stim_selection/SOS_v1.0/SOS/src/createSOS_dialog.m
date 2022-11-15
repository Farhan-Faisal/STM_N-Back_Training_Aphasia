% - create SOS optimizer dialog
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


function varargout = createSOS_dialog(varargin)
% CREATESOS_DIALOG M-file for createSOS_dialog.fig
%      CREATESOS_DIALOG, by itself, creates a new CREATESOS_DIALOG or raises the existing
%      singleton*.
%
%      H = CREATESOS_DIALOG returns the handle to a new CREATESOS_DIALOG or the handle to
%      the existing singleton*.
%
%      CREATESOS_DIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATESOS_DIALOG.M with the given input arguments.
%
%      CREATESOS_DIALOG('Property','Value',...) creates a new CREATESOS_DIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before createSOS_dialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to createSOS_dialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help createSOS_dialog

% Last Modified by GUIDE v2.5 08-Sep-2010 22:22:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @createSOS_dialog_OpeningFcn, ...
                   'gui_OutputFcn',  @createSOS_dialog_OutputFcn, ...
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


% --- Executes just before createSOS_dialog is made visible.
function createSOS_dialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to createSOS_dialog (see VARARGIN)

% Choose default command line output for createSOS_dialog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes createSOS_dialog wait for user response (see UIRESUME)
% uiwait(handles.figure_createSOS);


% --- Outputs from this function are returned to the command line.
function varargout = createSOS_dialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_maxIt_Callback(hObject, eventdata, handles)
% hObject    handle to edit_maxIt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_maxIt as text
%        str2double(get(hObject,'String')) returns contents of edit_maxIt as a double
    validate_maxIt(handles);


function flag = validate_maxIt(handles)
    str = get(handles.edit_maxIt,'String');
    
    errmsg = 'Sample size must be a whole number > 0';
    errtitle = 'Invalid max iteration!';
    
    flag = validatePositiveInteger(str,errmsg,errtitle);        
        
        
    
% --- Executes during object creation, after setting all properties.
function edit_maxIt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_maxIt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_reportInterval_Callback(hObject, eventdata, handles)
% hObject    handle to edit_reportInterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_reportInterval as text
%        str2double(get(hObject,'String')) returns contents of edit_reportInterval as a double
    validate_reportInterval(handles);
    
function flag = validate_reportInterval(handles)
    str = get(handles.edit_reportInterval,'String');
    
    errmsg = 'Sample size must be a whole number > 0';
    errtitle = 'Invalid reportInterval!';
    
    flag = validatePositiveInteger(str,errmsg,errtitle);
   


% --- Executes during object creation, after setting all properties.
function edit_reportInterval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_reportInterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_statInterval_Callback(hObject, eventdata, handles)
% hObject    handle to edit_statInterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_statInterval as text
%        str2double(get(hObject,'String')) returns contents of
%        edit_statInterval as a double
    validate_statInterval(handles)
    
function flag = validate_statInterval(handles)    
    str = get(handles.edit_statInterval,'String');
    
    errmsg = 'Stat test interval must be a whole number > 0';
    errtitle = 'Invalid statInterval!';
    
    flag = validatePositiveInteger(str,errmsg,errtitle);
    
    
% --- Executes during object creation, after setting all properties.
function edit_statInterval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_statInterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    flag = validate_maxIt(handles);
    
    if flag == true
        disp('yes, valid string');
    end
    

    
    


% --- Executes on selection change in popupmenu_statReportStyle.
function popupmenu_statReportStyle_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_statReportStyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_statReportStyle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_statReportStyle


% --- Executes during object creation, after setting all properties.
function popupmenu_statReportStyle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_statReportStyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_stopFreezeIt_Callback(hObject, eventdata, handles)
% hObject    handle to edit_stopFreezeIt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_stopFreezeIt as text
%        str2double(get(hObject,'String')) returns contents of edit_stopFreezeIt as a double
    validate_stopFreezeIt(handles);


function flag = validate_stopFreezeIt(handles)
    str = get(handles.edit_stopFreezeIt,'String');
    
    errmsg = 'Freeze interval must be a whole number > 0';
    errtitle = 'Invalid stopFreezeIt!';
    
    flag = validatePositiveInteger(str,errmsg,errtitle);


% --- Executes during object creation, after setting all properties.
function edit_stopFreezeIt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_stopFreezeIt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_blockSize_Callback(hObject, eventdata, handles)
% hObject    handle to edit_blockSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_blockSize as text
%        str2double(get(hObject,'String')) returns contents of edit_blockSize as a double
    validate_blockSize(handles);


function flag = validate_blockSize(handles)
    str = get(handles.edit_blockSize,'String');
    
    errmsg = 'Block size must be a whole number > 0';
    errtitle = 'Invalid block size!';
    
    flag = validatePositiveInteger(str,errmsg,errtitle);

% --- Executes during object creation, after setting all properties.
function edit_blockSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_blockSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_targSampleCandSelectMethod.
function popupmenu_targSampleCandSelectMethod_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_targSampleCandSelectMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_targSampleCandSelectMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_targSampleCandSelectMethod


% --- Executes during object creation, after setting all properties.
function popupmenu_targSampleCandSelectMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_targSampleCandSelectMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_pSwapFunction.
function popupmenu_pSwapFunction_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_pSwapFunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_pSwapFunction contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_pSwapFunction


% --- Executes during object creation, after setting all properties.
function popupmenu_pSwapFunction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_pSwapFunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_createSOS.
function pushbutton_createSOS_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_createSOS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % re-validate all fields
    
    createObj = validate_name(handles);
    
    if createObj == true   
        createObj = validate_maxIt(handles);    
        if createObj == true
            createObj = validate_reportInterval(handles);

            if createObj == true
                createObj = validate_statInterval(handles);

                if createObj == true
                    createObj = validate_stopFreezeIt(handles);

                    if createObj == true
                        createObj = validate_blockSize(handles);

                        if createObj == true
                        % the other fields are pop-up menus and necessarily
                        % pass validation.  Go on to create the object.

                        %cmd = 
                        varName = get(handles.edit_name,'String');
                        maxIt = (get(handles.edit_maxIt,'String'));
                        reportInterval = (get(handles.edit_reportInterval,'String'));
                        statInterval = (get(handles.edit_statInterval,'String'));
                        stopFreezeIt = (get(handles.edit_stopFreezeIt,'String'));
                        blockSize = (get(handles.edit_blockSize,'String'));
                        
                        statMenuHandle = handles.popupmenu_statReportStyle;
                        reportStyle = getPopupMenuName(statMenuHandle,...
                                    'Error, could not retrieve label,','Error');
                         
                        SampleCandMenuHandle = handles.popupmenu_targSampleCandSelectMethod;   
                        targSampleCandSelectMethod = getPopupMenuName(SampleCandMenuHandle,...
                                    'Error, could not retrieve label,','Error');        
                        
                        feederdfCandSelectMethodHandle =  handles.popupmenu_feederdfCandSelectMethod;        
                        feederdfCandSelectMethod = getPopupMenuName(feederdfCandSelectMethodHandle,...
                                    'Error, could not retrieve label,','Error');      
                                
                        pSwapFunctionHandle =  handles.popupmenu_pSwapFunction;        
                        pSwapFunction = getPopupMenuName(pSwapFunctionHandle,...
                                    'Error, could not retrieve label,','Error');            

                        command = strcat(varName,'=','sos(','''maxIt'',', maxIt,...
                                ',''reportInterval'',',reportInterval,...
                                ',''statInterval'',',statInterval,...
                                ',''stopFreezeIt'',',stopFreezeIt,...
                                ',''blockSize'',',blockSize,...
                                ',''statTestReportStyle'',''',reportStyle,...
                                ''',''targSampleCandSelectMethod'',''',targSampleCandSelectMethod,...
                                ''',''feederdfCandSelectMethod'',''',feederdfCandSelectMethod,...
                                ''',''pSwapFunction'',''',pSwapFunction,...
                                ''');'...
                                );
                        
                            verbosePrint(['Executing command: ','''',command,''''],'createSOSDialog_createSOS');
                            evalin('base',command);
                            
                            
                            
                            
                            close(handles.figure_createSOS);
                        end
                    end
                end
            end
        end
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
    valid = regexp(varName,'^[a-zA-Z]+\w*$');
    
    if isempty(valid)
        % name is not currently valid, tell the user.
        msgbox('Only letters, numbers, and underscores are permitted in the name of the sample object.  The first character must also be a letter.',...
                'Invalid name!');
        flag = false;
    else
        % check to make sure that the new variable name doesn't already exist.
        command = strcat('whos(''',varName,''')');
        varExists = evalin('base',command);


        % if a variable with this name already exists, warns the user
        if isempty(varExists) == 0
            msgbox('A sample with this name already exists and will be overridden if you continue',...
                    'Sample exists!');
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
