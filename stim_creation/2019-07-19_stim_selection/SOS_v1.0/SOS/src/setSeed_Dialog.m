% - dialog for setting the random seed
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


function varargout = setSeed_Dialog(varargin)
% SETSEED_DIALOG M-file for setSeed_Dialog.fig
%      SETSEED_DIALOG, by itself, creates a new SETSEED_DIALOG or raises the existing
%      singleton*.
%
%      H = SETSEED_DIALOG returns the handle to a new SETSEED_DIALOG or the handle to
%      the existing singleton*.
%
%      SETSEED_DIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETSEED_DIALOG.M with the given input arguments.
%
%      SETSEED_DIALOG('Property','Value',...) creates a new SETSEED_DIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before setSeed_Dialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to setSeed_Dialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help setSeed_Dialog

% Last Modified by GUIDE v2.5 09-Sep-2010 17:39:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @setSeed_Dialog_OpeningFcn, ...
                   'gui_OutputFcn',  @setSeed_Dialog_OutputFcn, ...
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



% --- Executes just before setSeed_Dialog is made visible.
function setSeed_Dialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to setSeed_Dialog (see VARARGIN)

% Choose default command line output for setSeed_Dialog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes setSeed_Dialog wait for user response (see UIRESUME)
% uiwait(handles.figure_setSeed);


% --- Outputs from this function are returned to the command line.
function varargout = setSeed_Dialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_setSeed.
function pushbutton_setSeed_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_setSeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % validate the number of iterations to display
    
    create = true;
    
    seed = get(handles.edit_seed,'String');
    
    %check to make sure that the name is a valid variable name:
    valid = regexp(seed,'^(-)?[1-9]+[0-9]*$', 'once');
    

    if isempty(valid)
        % name is not currently valid, tell the user.
        msgbox('Seed must be an integer',...
                'Invalid seed!');
        create = false;
    end

    % if the first variable passed, proceed to check the second
    if create == true

            command = ['setSeed(',seed,');'];

            verbosePrint(['Executing command: ','''',command,''''],'setSeed_Dialog_Set');
            evalin('base',command);         

            close(handles.figure_setSeed);
    end

        


function edit_seed_Callback(hObject, eventdata, handles)
% hObject    handle to edit_seed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_seed as text
%        str2double(get(hObject,'String')) returns contents of edit_seed as a double
    seed = get(hObject,'String');
    
    % validate that the seed is an integer
    valid = regexp(seed,'^(-)?[1-9]+[0-9]*$', 'once');
    

    if isempty(valid)
        % name is not currently valid, tell the user.
        msgbox('Seed must be an integer',...
                'Invalid seed!');
    end

% --- Executes during object creation, after setting all properties.
function edit_seed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_seed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
