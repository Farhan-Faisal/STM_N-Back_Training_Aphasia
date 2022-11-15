% - calculate overlap dialog
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



function varargout = calculateOverlap_Dialog(varargin)
% CALCULATEOVERLAP_DIALOG M-file for calculateOverlap_Dialog.fig
%      CALCULATEOVERLAP_DIALOG, by itself, creates a new CALCULATEOVERLAP_DIALOG or raises the existing
%      singleton*.
%
%      H = CALCULATEOVERLAP_DIALOG returns the handle to a new CALCULATEOVERLAP_DIALOG or the handle to
%      the existing singleton*.
%
%      CALCULATEOVERLAP_DIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALCULATEOVERLAP_DIALOG.M with the given input arguments.
%
%      CALCULATEOVERLAP_DIALOG('Property','Value',...) creates a new CALCULATEOVERLAP_DIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before calculateOverlap_Dialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to calculateOverlap_Dialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help calculateOverlap_Dialog

% Last Modified by GUIDE v2.5 19-Sep-2010 12:19:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @calculateOverlap_Dialog_OpeningFcn, ...
                   'gui_OutputFcn',  @calculateOverlap_Dialog_OutputFcn, ...
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


% --- Executes just before calculateOverlap_Dialog is made visible.
function calculateOverlap_Dialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to calculateOverlap_Dialog (see VARARGIN)

% Choose default command line output for calculateOverlap_Dialog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes calculateOverlap_Dialog wait for user response (see UIRESUME)
% uiwait(handles.figure_calculateOverlap_Dialog);


% --- Outputs from this function are returned to the command line.
function varargout = calculateOverlap_Dialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


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

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over popupmenu_sample2Selector.
function popupmenu_sample2Selector_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_sample2Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 populateSampleList(hObject);


% --- Executes on button press in pushbutton_overlap.
function pushbutton_overlap_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_overlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    sample1MenuHandle = handles.popupmenu_sample1Selector;
    sample1Name = getdfName(sample1MenuHandle,'sample');
    
    sample2MenuHandle = handles.popupmenu_sample2Selector;
    sample2Name = getdfName(sample2MenuHandle,'sample');
    
    if isempty(sample1Name) == 0 && isempty(sample2Name) == 0
        % run the command
        
        command = ['dataFrame.overlap(',sample1Name,',',sample2Name,');'];
        
        verbosePrint(['Executing command: ','''',command,''''],'calculateOverlapDialog_calculateOverlap');
        evalin('base',command);
    end
