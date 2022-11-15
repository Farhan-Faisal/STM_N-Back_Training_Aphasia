% - dialog used to save the optimization history
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



function varargout = saveHistory_Dialog(varargin)
% SAVEHISTORY_DIALOG M-file for saveHistory_Dialog.fig
%      SAVEHISTORY_DIALOG, by itself, creates a new SAVEHISTORY_DIALOG or raises the existing
%      singleton*.
%
%      H = SAVEHISTORY_DIALOG returns the handle to a new SAVEHISTORY_DIALOG or the handle to
%      the existing singleton*.
%
%      SAVEHISTORY_DIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAVEHISTORY_DIALOG.M with the given input arguments.
%
%      SAVEHISTORY_DIALOG('Property','Value',...) creates a new SAVEHISTORY_DIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before saveHistory_Dialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to saveHistory_Dialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help saveHistory_Dialog

% Last Modified by GUIDE v2.5 09-Sep-2010 15:38:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @saveHistory_Dialog_OpeningFcn, ...
                   'gui_OutputFcn',  @saveHistory_Dialog_OutputFcn, ...
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


% --- Executes just before saveHistory_Dialog is made visible.
function saveHistory_Dialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to saveHistory_Dialog (see VARARGIN)

% Choose default command line output for saveHistory_Dialog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes saveHistory_Dialog wait for user response (see UIRESUME)
% uiwait(handles.figure_writeHistory);


% --- Outputs from this function are returned to the command line.
function varargout = saveHistory_Dialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_setHistoryOutFile.
function pushbutton_setHistoryOutFile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_setHistoryOutFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    [fileName,pathName] = uiputfile('*','Save history as...');
    
    % check to make sure user didn't cancel (which cases fileName == 0)
    if fileName ~= 0
        fullName = strcat(pathName,fileName);
    
        set(handles.text_historyOutFile,'String',fullName);  
    end


% --- Executes on button press in pushbutton_saveHistory.
function pushbutton_saveHistory_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_saveHistory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    outFile = get(handles.text_historyOutFile,'String');
    
    write = true;
    
    % don't write if no file specified;
    if isempty(outFile)
        write = false;
        msgbox('A valid file must be specified','Write error');
        
    end
    
    if write == true
        mainWindowHandle = sos_gui;
        mainWindowData = guidata(mainWindowHandle);

        sosObjName = getdfName(mainWindowData.popupmenu_SOSSelector,'SOS');

        if isempty(sosObjName) == 0    
            % write the file
             command = [sosObjName,'.writeHistory(''',outFile,''');'];

            verbosePrint(['Executing command: ','''',command,''''],'saveHistory_Dialog_save');
            evalin('base',command);         

            close(handles.figure_writeHistory);
        else
            % no need to do anything, all methods called generate errors if
            % they contain invalid fields.
        end
    end
    
