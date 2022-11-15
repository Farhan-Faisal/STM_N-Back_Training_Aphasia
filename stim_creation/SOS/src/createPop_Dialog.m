% - create population dialog
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



function varargout = createPop_Dialog(varargin)
% CREATEPOP_DIALOG M-file for createPop_Dialog.fig
%      CREATEPOP_DIALOG, by itself, creates a new CREATEPOP_DIALOG or raises the existing
%      singleton*.
%
%      H = CREATEPOP_DIALOG returns the handle to a new CREATEPOP_DIALOG or the handle to
%      the existing singleton*.
%
%      CREATEPOP_DIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATEPOP_DIALOG.M with the given input arguments.
%
%      CREATEPOP_DIALOG('Property','Value',...) creates a new CREATEPOP_DIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before createPop_Dialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to createPop_Dialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help createPop_Dialog

% Last Modified by GUIDE v2.5 07-Sep-2010 10:08:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @createPop_Dialog_OpeningFcn, ...
                   'gui_OutputFcn',  @createPop_Dialog_OutputFcn, ...
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


% --- Executes just before createPop_Dialog is made visible.
function createPop_Dialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to createPop_Dialog (see VARARGIN)

% Choose default command line output for createPop_Dialog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes createPop_Dialog wait for user response (see UIRESUME)
% uiwait(handles.figure_createPop);


% --- Outputs from this function are returned to the command line.
function varargout = createPop_Dialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_setPopSrc.
function pushbutton_setPopSrc_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_setPopSrc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % let user navigate to the script to run
    [fileName,pathName] = uigetfile('*','Run Script...');
    
    % check to make sure user didn't cancel (which cases fileName == 0)
    if fileName ~= 0
        fullName = strcat(pathName,fileName);

        set(handles.text_PopSrc,'String',fullName);
    end
    

% --- Executes on button press in pushbutton_createPop.
function pushbutton_createPop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_createPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    makeObj = true;
    % do basic validation on each variable
    src = get(handles.text_PopSrc,'String');
    
    
    if isempty(src)
        msgbox('You must specify the source data for the population',...
                'Missing source file!');        
       makeObj = false;  
    end
    
    
    varName = get(handles.edit_popName,'String');

    valid = regexp(varName,'^[a-zA-Z]+\w*$');
    

    % check if the pointer is valid, but only if the src is valid so as to
    % not clutter the user with msgboxes
    if isempty(valid) && makeObj == true
        % name is not currently valid, tell the user.
        msgbox('Only letters, numbers, and underscores are permitted in the name of the population object.  The first character must also be a letter.',...
                'Invalid name!');
        makeObj = false;
            
    end
    
    
    % get header and formatting switches, in string form
    % these data must always have reasonable values
    header = get(get(handles.uipanel_containsHeader,'SelectedObject'),...
                'String');
    format = get(get(handles.uipanel_containsFormatting,'SelectedObject'),...
                'String');            
    
    % the outfile will either have been set by the user to a reasonable
    % state via the GUI, or will be empty and the default value will be
    % substituted.
    outFile = get(handles.text_resPopOutfile,'String');
    
    % fill in outFile if it was left blank.
    if isempty(outFile)
        outFile = strcat(varName,'.res.out.txt');
    end
    
    if makeObj == true
        % the command to run to create a population
        command = strcat(varName,'=','population(''',src,''',''isHeader'',',...
                header,',''isFormatting'',',format,',''outFile'',''',outFile,...
                ''',''name'',''',varName,''');'); %'',''isHeader''',...
              %  header);

        verbosePrint(['Executing command: ','''',command,''''],'createPop_Dialog_Create');
        evalin('base',command);
        
        
        
        close(handles.figure_createPop);
    end
    

function edit_popName_Callback(hObject, eventdata, handles)
% hObject    handle to edit_popName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_popName as text
%        str2double(get(hObject,'String')) returns contents of edit_popName as a double

    varName = get(hObject,'String');
    
    %check to make sure that the name is a valid variable name:
    valid = regexp(varName,'^[a-zA-Z]+\w*$');
    

    if isempty(valid)
        % name is not currently valid, tell the user.
        msgbox('Only letters, numbers, and underscores are permitted in the name of the population object.  The first character must also be a letter.',...
                'Invalid name!');
    else
        % check to make sure that the new variable name doesn't already exist.
        command = strcat('whos(''',varName,''')');
        varExists = evalin('base',command);


        % if a variable with this name already exists, warns the user
        if isempty(varExists) == 0
            msgbox('A population with this name already exists and will be overridden if you continue',...
                    'Population exists!');
        end
    end
        
        
        
    
% --- Executes during object creation, after setting all properties.
function edit_popName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_popName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_setResPopOutfile.
function pushbutton_setResPopOutfile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_setResPopOutfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    [fileName,pathName] = uiputfile('*','Save residual population as...');
    
    % check to make sure user didn't cancel (which cases fileName == 0)
    if fileName ~= 0
        fullName = strcat(pathName,fileName);
    
        set(handles.text_resPopOutfile,'String',fullName);  
    end
