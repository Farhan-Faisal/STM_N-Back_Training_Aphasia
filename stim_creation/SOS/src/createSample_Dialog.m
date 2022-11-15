% - create sample dialog
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


function varargout = createSample_Dialog(varargin)
% CREATESAMPLE_DIALOG M-file for createSample_Dialog.fig
%      CREATESAMPLE_DIALOG, by itself, creates a new CREATESAMPLE_DIALOG or raises the existing
%      singleton*.
%
%      H = CREATESAMPLE_DIALOG returns the handle to a new CREATESAMPLE_DIALOG or the handle to
%      the existing singleton*.
%
%      CREATESAMPLE_DIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATESAMPLE_DIALOG.M with the given input arguments.
%
%      CREATESAMPLE_DIALOG('Property','Value',...) creates a new CREATESAMPLE_DIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before createSample_Dialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to createSample_Dialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help createSample_Dialog

% Last Modified by GUIDE v2.5 07-Sep-2010 10:06:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @createSample_Dialog_OpeningFcn, ...
                   'gui_OutputFcn',  @createSample_Dialog_OutputFcn, ...
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


% --- Executes just before createSample_Dialog is made visible.
function createSample_Dialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to createSample_Dialog (see VARARGIN)

% Choose default command line output for createSample_Dialog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes createSample_Dialog wait for user response (see UIRESUME)
% uiwait(handles.figure_createSample);


% --- Outputs from this function are returned to the command line.
function varargout = createSample_Dialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_setSampleSrc.
function pushbutton_setSampleSrc_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_setSampleSrc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % let user navigate to the script to run
    [fileName,pathName] = uigetfile('*','Run Script...');
    
    % check to make sure user didn't cancel (which cases fileName == 0)
    if fileName ~= 0
        fullName = strcat(pathName,fileName);

        set(handles.text_SampleSrc,'String',fullName);
    end
    

% --- Executes on button press in pushbutton_createSample.
function pushbutton_createSample_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_createSample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    makeObj = true;
    noSrc = false; % is there a sample src file
    
    % do basic validation on each variable
    
    %get number of items
    n = get(handles.edit_n,'String');
    valid = regexp(n,'^[1-9]+[0-9]*$');
    

    if isempty(valid)
        % name is not currently valid, tell the user.
        msgbox('Sample size must be a whole number > 0',...
                'Invalid sample size!');
        makeObj = false;
    end
    
    % validate the object name
    varName = get(handles.edit_sampleName,'String');
    valid = regexp(varName,'^[a-zA-Z]+\w*$');
    

    % check if the pointer is valid, but only if n is valid so as to
    % not clutter the user with msgboxes
    if isempty(valid) && makeObj == true
        % name is not currently valid, tell the user.
        msgbox('Only letters, numbers, and underscores are permitted in the name of the sample object.  The first character must also be a letter.',...
                'Invalid name!');
        makeObj = false;            
    end    
    
    % get src
    src = get(handles.text_SampleSrc,'String');
    
    if isempty(src)
        noSrc = true;
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
    outFile = get(handles.text_sampleOutfile,'String');
    
    % fill in outFile if it was left blank.
    if isempty(outFile)
        outFile = strcat(varName,'.out.txt');
    end
    
    if makeObj == true
        % a sample will be created:
        
        % the command to run to create a sample
        command = strcat(varName,'=','sample(',num2str(n),',''isHeader'',',...
                header,',''isFormatting'',',format,',''outFile'',''',outFile,...
                ''',''name'',','''',varName,''''); 
        
        %tweak the end of the command based on whether a partial sample
        %will be read in or not.  

        if noSrc == true
            command = strcat(command,');');
        else
            command = strcat(command,',''fileName'',''',src,''');');
        end
        
        verbosePrint(['Executing command: ','''',command,''''],'createSample_Dialog_Create');
        evalin('base',command);
        
        close(handles.figure_createSample);
    end
    

function edit_sampleName_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sampleName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sampleName as text
%        str2double(get(hObject,'String')) returns contents of edit_sampleName as a double

    varName = get(hObject,'String');
    
    %check to make sure that the name is a valid variable name:
    valid = regexp(varName,'^[a-zA-Z]+\w*$');
    

    if isempty(valid)
        % name is not currently valid, tell the user.
        msgbox('Only letters, numbers, and underscores are permitted in the name of the sample object.  The first character must also be a letter.',...
                'Invalid name!');
    else
        % check to make sure that the new variable name doesn't already exist.
        command = strcat('whos(''',varName,''')');
        varExists = evalin('base',command);


        % if a variable with this name already exists, warns the user
        if isempty(varExists) == 0
            msgbox('A sample with this name already exists and will be overridden if you continue',...
                    'Sample exists!');
        end
    end
        
        
        
    
% --- Executes during object creation, after setting all properties.
function edit_sampleName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sampleName (see GCBO)
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


% --- Executes on button press in pushbutton_setSampleOutfile.
function pushbutton_setSampleOutfile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_setSampleOutfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    [fileName,pathName] = uiputfile('*','Save optimized sample as...');
    
    % check to make sure user didn't cancel (which cases fileName == 0)
    if fileName ~= 0
        fullName = strcat(pathName,fileName);
    
        set(handles.text_sampleOutfile,'String',fullName);  
    end



function edit_n_Callback(hObject, eventdata, handles)
% hObject    handle to edit_n (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_n as text
%        str2double(get(hObject,'String')) returns contents of edit_n as a double

    varName = get(hObject,'String');
    
    %check to make sure that the name is a valid variable name:
    valid = regexp(varName,'^[1-9]+[0-9]*$');
    

    if isempty(valid)
        % name is not currently valid, tell the user.
        msgbox('Sample size must be a whole number > 0',...
                'Invalid sample size!');
    end



% --- Executes during object creation, after setting all properties.
function edit_n_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_n (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
