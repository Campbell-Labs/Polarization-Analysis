function varargout = ArtificialSampleMetadataEntry(varargin)
% ARTIFICIALSAMPLEMETADATAENTRY MATLAB code for ArtificialSampleMetadataEntry.fig
%      ARTIFICIALSAMPLEMETADATAENTRY, by itself, creates a new ARTIFICIALSAMPLEMETADATAENTRY or raises the existing
%      singleton*.
%
%      H = ARTIFICIALSAMPLEMETADATAENTRY returns the handle to a new ARTIFICIALSAMPLEMETADATAENTRY or the handle to
%      the existing singleton*.
%
%      ARTIFICIALSAMPLEMETADATAENTRY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ARTIFICIALSAMPLEMETADATAENTRY.M with the given input arguments.
%
%      ARTIFICIALSAMPLEMETADATAENTRY('Property','Value',...) creates a new ARTIFICIALSAMPLEMETADATAENTRY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ArtificialSampleMetadataEntry_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ArtificialSampleMetadataEntry_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ArtificialSampleMetadataEntry

% Last Modified by GUIDE v2.5 15-Sep-2017 12:07:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ArtificialSampleMetadataEntry_OpeningFcn, ...
                   'gui_OutputFcn',  @ArtificialSampleMetadataEntry_OutputFcn, ...
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
end

% --- Executes just before ArtificialSampleMetadataEntry is made visible.
function ArtificialSampleMetadataEntry_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ArtificialSampleMetadataEntry (see VARARGIN)

% Choose default command line output for ArtificialSampleMetadataEntry
handles.output = hObject;

% ************************************************************************************************************************************************
% INPUT: (suggestedSampleNumber, existingSampleNumbers, userName, importPath, isEdit, sample*)
%        *may be empty
% ************************************************************************************************************************************************
if isa(varargin{1},'numeric');
    handles.suggestedSampleNumber = varargin{1}; %Parameter name is 'suggestedSampleNumber' from Eye class function
else
    handles.suggestedSampleNumber = '';
end

handles.exisitingSampleNumbers = varargin{2};

handles.userName = varargin{3};
handles.importPath = varargin{4};

isEdit = varargin{5};

sample = [];

if length(varargin) > 7
    sample = varargin{6};
end

if isempty(sample)
    sample = ArtificialSample;
end

handles.cancel = false;

if isEdit
    set(handles.OK, 'enable', 'on');
    
    set(handles.importPathDisplay, 'Visible', 'off');
    set(handles.importPathTitle, 'Visible', 'off')

    handles.sampleId = sample.sampleId;
    handles.sampleNumber = sample.sampleNumber;
    handles.preppedBy = sample.preppedBy;
    handles.preppedDate = sample.preppedDate;
    handles.incubationTime = sample.incubationTime;
    handles.incubationTemperature = sample.incubationTemperature;
    handles.notes = sample.notes;
else
    defaultSample = ArtificialSample;
    
    set(handles.OK, 'enable', 'off');
    
    set(handles.importPathDisplay, 'String', handles.importPath);
    
    handles.sampleId = defaultSample.sampleId;
    handles.sampleNumber = handles.suggestedSampleNumber;
    handles.preppedBy = defaultSample.preppedBy;
    handles.preppedDate = defaultSample.preppedDate;
    handles.incubationTime = defaultSample.incubationTime;
    handles.incubationTemperature = defaultSample.incubationTemperature;
    handles.notes = defaultSample.notes;
end

% ** SET TEXT FIELDS **

set(handles.artificialSampleIdInput, 'String', handles.sampleId);
set(handles.sampleNumberInput, 'String', num2str(handles.sampleNumber));
set(handles.preppedByInput, 'String', handles.preppedBy);
set(handles.incubationTimeInput, 'String', num2str(handles.incubationTime));
set(handles.incubationTempInput, 'String', num2str(handles.incubationTemperature));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ArtificialSampleMetadataEntry wait for user response (see UIRESUME)
% uiwait(handles.ArtificialSampleMetadataEntry);
end

% --- Outputs from this function are returned to the command line.
function varargout = ArtificialSampleMetadataEntry_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


function importPathDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to importPathDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of importPathDisplay as text
%        str2double(get(hObject,'String')) returns contents of importPathDisplay as a double
end

% --- Executes during object creation, after setting all properties.
function importPathDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to importPathDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function artificialSampleIdInput_Callback(hObject, eventdata, handles)
% hObject    handle to artificialSampleIdInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of artificialSampleIdInput as text
%        str2double(get(hObject,'String')) returns contents of artificialSampleIdInput as a double
end

% --- Executes during object creation, after setting all properties.
function artificialSampleIdInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to artificialSampleIdInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function sampleNumberInput_Callback(hObject, eventdata, handles)
% hObject    handle to sampleNumberInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sampleNumberInput as text
%        str2double(get(hObject,'String')) returns contents of sampleNumberInput as a double
end

% --- Executes during object creation, after setting all properties.
function sampleNumberInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sampleNumberInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function preppedByInput_Callback(hObject, eventdata, handles)
% hObject    handle to preppedByInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of preppedByInput as text
%        str2double(get(hObject,'String')) returns contents of preppedByInput as a double
end

% --- Executes during object creation, after setting all properties.
function preppedByInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to preppedByInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function prepDateInput_Callback(hObject, eventdata, handles)
% hObject    handle to prepDateInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of prepDateInput as text
%        str2double(get(hObject,'String')) returns contents of prepDateInput as a double
end

% --- Executes during object creation, after setting all properties.
function prepDateInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prepDateInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function incubationTimeInput_Callback(hObject, eventdata, handles)
% hObject    handle to incubationTimeInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of incubationTimeInput as text
%        str2double(get(hObject,'String')) returns contents of incubationTimeInput as a double
end

% --- Executes during object creation, after setting all properties.
function incubationTimeInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to incubationTimeInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function incubationTempInput_Callback(hObject, eventdata, handles)
% hObject    handle to incubationTempInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of incubationTempInput as text
%        str2double(get(hObject,'String')) returns contents of incubationTempInput as a double
end

% --- Executes during object creation, after setting all properties.
function incubationTempInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to incubationTempInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function sampleNotesInput_Callback(hObject, eventdata, handles)
% hObject    handle to sampleNotesInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sampleNotesInput as text
%        str2double(get(hObject,'String')) returns contents of sampleNotesInput as a double
end

% --- Executes during object creation, after setting all properties.
function sampleNotesInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sampleNotesInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on button press in OK.
function OK_Callback(hObject, eventdata, handles)
% hObject    handle to OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on button press in prepDatePicker.
function prepDatePicker_Callback(hObject, eventdata, handles)
% hObject    handle to prepDatePicker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end