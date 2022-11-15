% dialog used for calculating the largest p-decrease value
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


function varargout = maxpDecrease_Dialog(varargin)
% MAXPDECREASE_DIALOG M-file for maxpDecrease_Dialog.fig
%      MAXPDECREASE_DIALOG, by itself, creates a new MAXPDECREASE_DIALOG or raises the existing
%      singleton*.
%
%      H = MAXPDECREASE_DIALOG returns the handle to a new MAXPDECREASE_DIALOG or the handle to
%      the existing singleton*.
%
%      MAXPDECREASE_DIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAXPDECREASE_DIALOG.M with the given input arguments.
%
%      MAXPDECREASE_DIALOG('Property','Value',...) creates a new MAXPDECREASE_DIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before maxpDecrease_Dialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to maxpDecrease_Dialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help maxpDecrease_Dialog

% Last Modified by GUIDE v2.5 12-Sep-2010 13:41:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @maxpDecrease_Dialog_OpeningFcn, ...
                   'gui_OutputFcn',  @maxpDecrease_Dialog_OutputFcn, ...
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


% --- Executes just before maxpDecrease_Dialog is made visible.
function maxpDecrease_Dialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to maxpDecrease_Dialog (see VARARGIN)

% Choose default command line output for maxpDecrease_Dialog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes maxpDecrease_Dialog wait for user response (see UIRESUME)
% uiwait(handles.figure_maxpDecrease_Dialog);


% --- Outputs from this function are returned to the command line.
function varargout = maxpDecrease_Dialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_initDeltaCost_Callback(hObject, eventdata, handles)
% hObject    handle to edit_initDeltaCost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_initDeltaCost as text
%        str2double(get(hObject,'String')) returns contents of edit_initDeltaCost as a double
   
    % validate initDeltaCost
    validate_initDeltaCost(handles);
    
    
function flag = validate_initDeltaCost(handles)
     str = get(handles.edit_initDeltaCost,'String');
    
    errmsg = 'initDeltaCost must be a number';
    errtitle = 'Invalid initDeltaCost!';
    
    flag = validateRealNumber(str,errmsg,errtitle);      
    
    

% --- Executes during object creation, after setting all properties.
function edit_initDeltaCost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_initDeltaCost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_finalDeltaCost_Callback(hObject, eventdata, handles)
% hObject    handle to edit_finalDeltaCost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_finalDeltaCost as text
%        str2double(get(hObject,'String')) returns contents of edit_finalDeltaCost as a double
    validate_finalDeltaCost(handles);
    
    
function flag = validate_finalDeltaCost(handles)
     str = get(handles.edit_finalDeltaCost,'String');
    
    errmsg = 'finalDeltaCost must be a number';
    errtitle = 'Invalid initDeltaCost!';
    
    flag = validateRealNumber(str,errmsg,errtitle);      
    

% --- Executes during object creation, after setting all properties.
function edit_finalDeltaCost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_finalDeltaCost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_nStep_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_nStep as text
%        str2double(get(hObject,'String')) returns contents of edit_nStep as a double
    validate_nStep(handles);


function flag = validate_nStep(handles)
    str = get(handles.edit_nStep,'String');
    
    errmsg = 'nStep must be a positive integer';
    errtitle = 'Invalid pDecrease!';
    
    flag = validatePositiveInteger(str,errmsg,errtitle);

% --- Executes during object creation, after setting all properties.
function edit_nStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_Calculate.
function pushbutton_Calculate_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    run = true;
    
    run = validate_initDeltaCost(handles);
    
    if run == true
        run = validate_finalDeltaCost(handles);
        
        if run == true
            run = validate_nStep(handles);
            
            if run == true 
                % all data is valid, run the command.
                initDeltaCost = (get(handles.edit_initDeltaCost,'String'));
                finalDeltaCost = (get(handles.edit_finalDeltaCost,'String'));
                nStep = (get(handles.edit_nStep,'String'));
                
                command = ['expAnneal.maxpDecrease(',initDeltaCost,',',...
                        finalDeltaCost,',',nStep,');'];
                    
                verbosePrint(['Executing command: ','''',command,''''],'maxpDecrease_Dialog_calculate');    
                evalin('base',command);         

                close(handles.figure_maxpDecrease_Dialog);    
                
            end
        end
    end
