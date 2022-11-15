% - create expAnneal dialog
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


function varargout = expAnneal_Dialog(varargin)
% EXPANNEAL_DIALOG M-file for expAnneal_Dialog.fig
%      EXPANNEAL_DIALOG, by itself, creates a new EXPANNEAL_DIALOG or raises the existing
%      singleton*.
%
%      H = EXPANNEAL_DIALOG returns the handle to a new EXPANNEAL_DIALOG or the handle to
%      the existing singleton*.
%
%      EXPANNEAL_DIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPANNEAL_DIALOG.M with the given input arguments.
%
%      EXPANNEAL_DIALOG('Property','Value',...) creates a new EXPANNEAL_DIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before expAnneal_Dialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to expAnneal_Dialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help expAnneal_Dialog

% Last Modified by GUIDE v2.5 12-Sep-2010 14:28:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @expAnneal_Dialog_OpeningFcn, ...
                   'gui_OutputFcn',  @expAnneal_Dialog_OutputFcn, ...
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


% --- Executes just before expAnneal_Dialog is made visible.
function expAnneal_Dialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to expAnneal_Dialog (see VARARGIN)

% Choose default command line output for expAnneal_Dialog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes expAnneal_Dialog wait for user response (see UIRESUME)
% uiwait(handles.figure_expAnneal_Dialog);


% --- Outputs from this function are returned to the command line.
function varargout = expAnneal_Dialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_createExpAnneal.
function pushbutton_createExpAnneal_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_createExpAnneal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    createObj = true;
    
    createObj = validate_blockSize(handles);
    
    if createObj == true
        createObj = validate_pDecrease(handles);
        
        if createObj == true
            createObj = validate_pval(handles);
            
            if createObj == true
    
                mainWindowHandle = sos_gui;
                mainWindowData = guidata(mainWindowHandle);
        
                sosObjName = getdfName(mainWindowData.popupmenu_SOSSelector,'SOS');

                if isempty(sosObjName) == 0  
                    
                    blockSize = (get(handles.edit_blockSize,'String'));
                    pDecrease = (get(handles.edit_pDecrease,'String'));
                    pval = (get(handles.edit_pval,'String'));
                   
                    overrideInitDeltaCost = (get(handles.edit_overrideInitDeltaCost,'String'));
                    
                    % use different commands if overrideInitDeltaCost is
                    % present
                    if isempty(overrideInitDeltaCost) 
                    
                    % write the file
                         command = [sosObjName,'.setAnnealSchedule(''schedule'',''exp'',',...
                             '''blockSize'',',blockSize,','...
                             '''pDecrease'',',pDecrease,','...
                             '''pval'',',pval,');'];

                         verbosePrint(['Executing command: ','''',command,''''],'expAnneal_Dialog_createExpAnneal');
                        evalin('base',command);     
                        close(handles.figure_expAnneal_Dialog);
                    elseif validate_overrideInitDeltaCost(handles)
                         command = [sosObjName,'.setAnnealSchedule(''schedule'',''exp'',',...
                             '''blockSize'',',blockSize,','...
                             '''pDecrease'',',pDecrease,','...
                             '''pval'',',pval,','...
                             '''overrideInitDeltaCost'',',overrideInitDeltaCost,');'];

                         
                        verbosePrint(['Executing command: ','''',command,''''],'expAnneal_Dialog_createExpAnneal');
                        evalin('base',command);     
                        close(handles.figure_expAnneal_Dialog);                        
                        
                    end

                    
                else
                    % no need to use this, all methods generate errors
                end
            end
        end
    end

        
            
function edit_pval_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_pval as text
%        str2double(get(hObject,'String')) returns contents of edit_pval as a double
    validate_pval(handles);


function flag = validate_pval(handles)
    str = get(handles.edit_pval,'String');
    
    errmsg = 'alpha must be a probability value between 0 and 1';
    errtitle = 'Invalid alpha!';
    
    flag = validateProbability(str,errmsg,errtitle);
    

% --- Executes during object creation, after setting all properties.
function edit_pval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_pDecrease_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pDecrease (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_pDecrease as text
%        str2double(get(hObject,'String')) returns contents of edit_pDecrease as a double
    validate_pDecrease(handles);


function flag = validate_pDecrease(handles)
    str = get(handles.edit_pDecrease,'String');
    
    errmsg = 'pDecrease must be a probability value between 0 and 1';
    errtitle = 'Invalid pDecrease!';
    
    flag = validateProbability(str,errmsg,errtitle);


% --- Executes during object creation, after setting all properties.
function edit_pDecrease_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pDecrease (see GCBO)
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



function edit_overrideInitDeltaCost_Callback(hObject, eventdata, handles)
% hObject    handle to edit_overrideInitDeltaCost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_overrideInitDeltaCost as text
%        str2double(get(hObject,'String')) returns contents of edit_overrideInitDeltaCost as a double
    validate_overrideInitDeltaCost(handles);
    
    
function flag = validate_overrideInitDeltaCost(handles)
     str = get(handles.edit_overrideInitDeltaCost,'String');
    
    errmsg = 'initDeltaCost must be a number';
    errtitle = 'Invalid overrideInitDeltaCost!';
    
    flag = validateRealNumber(str,errmsg,errtitle);      
    

% --- Executes during object creation, after setting all properties.
function edit_overrideInitDeltaCost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_overrideInitDeltaCost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
