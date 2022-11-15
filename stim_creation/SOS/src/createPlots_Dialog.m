% - create sosplots dialog
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




function varargout = createPlots_Dialog(varargin)
% CREATEPLOTS_DIALOG M-file for createPlots_Dialog.fig
%      CREATEPLOTS_DIALOG, by itself, creates a new CREATEPLOTS_DIALOG or raises the existing
%      singleton*.
%
%      H = CREATEPLOTS_DIALOG returns the handle to a new CREATEPLOTS_DIALOG or the handle to
%      the existing singleton*.
%
%      CREATEPLOTS_DIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATEPLOTS_DIALOG.M with the given input arguments.
%
%      CREATEPLOTS_DIALOG('Property','Value',...) creates a new CREATEPLOTS_DIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before createPlots_Dialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to createPlots_Dialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help createPlots_Dialog

% Last Modified by GUIDE v2.5 09-Sep-2010 11:49:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @createPlots_Dialog_OpeningFcn, ...
                   'gui_OutputFcn',  @createPlots_Dialog_OutputFcn, ...
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



% --- Executes just before createPlots_Dialog is made visible.
function createPlots_Dialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to createPlots_Dialog (see VARARGIN)

% Choose default command line output for createPlots_Dialog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes createPlots_Dialog wait for user response (see UIRESUME)
% uiwait(handles.figure_createPlots);


% --- Outputs from this function are returned to the command line.
function varargout = createPlots_Dialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_createPlots.
function pushbutton_createPlots_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_createPlots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % validate the number of iterations to display
    
    create = true;
    
    dispIt = get(handles.edit_dispIt,'String');
    
    %check to make sure that the name is a valid variable name:
    valid = regexp(dispIt,'^[1-9]+[0-9]*$');
    

    if isempty(valid)
        % name is not currently valid, tell the user.
        msgbox('Sample size must be a whole number > 0',...
                'Invalid sample size!');
        create = false;
    end

    % if the first variable passed, proceed to check the second
    if create == true
        mainWindowHandle = sos_gui;
        mainWindowData = guidata(mainWindowHandle);

        sosObjName = getdfName(mainWindowData.popupmenu_SOSSelector,'SOS');

        if isempty(sosObjName) == 0
            % we have a valid name, run the command
            command = [sosObjName,'.createPlots(',dispIt,');'];

            verbosePrint(['Executing command: ','''',command,''''],'createPlots_Dialog_create');
            evalin('base',command);         

            close(handles.figure_createPlots);
        else
           % if it was empty, a warning message will have been triggered by getdfName;
           % no need to do anything here.
        end
    end
        


function edit_dispIt_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dispIt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dispIt as text
%        str2double(get(hObject,'String')) returns contents of edit_dispIt as a double
    varName = get(hObject,'String');
    
    %check to make sure that the name is a valid variable name:
    valid = regexp(varName,'^[1-9]+[0-9]*$', 'once');
    

    if isempty(valid)
        % name is not currently valid, tell the user.
        msgbox('Number of iterations to display must be > 0',...
                'Invalid dispIt!');
    end

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
