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

% Last Modified by GUIDE v2.5 18-Sep-2017 10:29:17

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
if isa(varargin{1},'numeric')
    handles.suggestedSampleNumber = varargin{1}; %Parameter name is 'suggestedSampleNumber' from Eye class function
else
    handles.suggestedSampleNumber = '';
end

handles.exisitingSampleNumbers = varargin{2};

handles.userName = varargin{3};
handles.importPath = varargin{4};

isEdit = varargin{5};

sample = [];

if length(varargin) > 5
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
set(handles.sampleNotesInput, 'String', handles.notes);

justDate = true;

setDateInput(handles.prepDateInput, handles.preppedDate, ~justDate);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ArtificialSampleMetadataEntry wait for user response (see UIRESUME)
uiwait(handles.ArtificialSampleMetadataEntry);
end

% --- Outputs from this function are returned to the command line.
function varargout = ArtificialSampleMetadataEntry_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%**************************************************************************************************************************************************************************************************************************
%OUTPUT: [cancel, sampleId, sampleNumber, preppedBy, preppedDate, incubationTime, incubationTemperature, notes]
%**************************************************************************************************************************************************************************************************************************

varargout{1} = handles.cancel;
varargout{2} = handles.sampleId;
varargout{3} = handles.sampleNumber;
varargout{4} = handles.preppedBy;
varargout{5} = handles.preppedDate;
varargout{6} = handles.incubationTime;
varargout{7} = handles.incubationTemperature;
varargout{8} = handles.notes;


close(handles.ArtificialSampleMetadataEntry);
end

% --- Executes when user attempts to close ArtificialSampleMetadataEntry.
function ArtificialSampleMetadataEntry_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to ArtificialSampleMetadataEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    handles.cancel = true;
    handles.sampleId = '';
    handles.sampleNumber = [];
    handles.preppedBy = '';
    handles.preppedDate = [];
    handles.incubationTime = [];
    handles.incubationTemperature = [];
    handles.notes = '';
    guidata(hObject, handles);
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    handles.cancel = true;
    handles.sampleId = '';
    handles.sampleNumber = [];
    handles.preppedBy = '';
    handles.preppedDate = [];
    handles.incubationTime = [];
    handles.incubationTemperature = [];
    handles.notes = '';
    guidata(hObject, handles);
    delete(hObject);
end

end


function importPathDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to importPathDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of importPathDisplay as text
%        str2double(get(hObject,'String')) returns contents of importPathDisplay as a double

set(handles.importPathDisplay, 'String', handles.importPath);
guidata(hObject, handles);

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

%Get value from input box
handles.sampleId = get(hObject, 'String');

checkToEnableOkButton(handles);

guidata(hObject, handles);

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

%Get value from input box
if isnan(str2double(get(hObject, 'String')))
    
    set(handles.sampleNumberInput, 'String', '');
    handles.sampleNumber = [];
    
    warndlg('Sample Number must be numerical.', 'Sample Number Error', 'modal'); 
    
else
    handles.sampleNumber = str2double(get(hObject, 'String'));
end

checkToEnableOkButton(handles);

guidata(hObject, handles)

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

%Get value from input box
handles.preppedBy = get(hObject, 'String');

checkToEnableOkButton(handles);

guidata(hObject, handles);

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

%Get value from input box
if isnan(str2double(get(hObject, 'String')))
    
    set(handles.incubationTimeInput, 'String', '');
    handles.incubationTime = [];
    
    warndlg('Incubation time must be numerical.', 'Incubation Time Error', 'modal'); 
    
else
    handles.incubationTime = str2double(get(hObject, 'String'));
end

checkToEnableOkButton(handles);

guidata(hObject, handles)

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

%Get value from input box
if isnan(str2double(get(hObject, 'String')))
    
    set(handles.incubationTempInput, 'String', '');
    handles.incubationTemperature = [];
    
    warndlg('Incubation temperature must be numerical.', 'Incubation Temperature Error', 'modal'); 
    
else
    handles.incubationTemperature = str2double(get(hObject, 'String'));
end

checkToEnableOkButton(handles);

guidata(hObject, handles)

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

%Get value from input box
handles.notes = strjoin(rot90(cellstr(get(hObject, 'String'))));

checkToEnableOkButton(handles);

guidata(hObject, handles);

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

%Dialog box asking the user whether or not they wish to exit the program
exit = questdlg('Are you sure you want to quit?','Quit','Yes','No','No'); % TODO just cancel or is this just fine?
switch exit
    case 'Yes'
        %Clears variables in the case that they wish to exit the program
        handles.cancel = true;
        handles.sampleId = '';
        handles.sampleNumber = [];
        handles.preppedBy = '';
        handles.preppedDate = [];
        handles.incubationTime = [];
        handles.incubationTemperature = [];
        handles.notes = '';
        guidata(hObject, handles);
        uiresume(handles.ArtificialSampleMetadataEntry);
    case 'No'
end

end

% --- Executes on button press in OK.
function OK_Callback(hObject, eventdata, handles)
% hObject    handle to OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);
uiresume(handles.ArtificialSampleMetadataEntry);

end

% --- Executes on button press in prepDatePicker.
function prepDatePicker_Callback(hObject, eventdata, handles)
% hObject    handle to prepDatePicker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

justDate = false;

serialDate = guiDatePicker(now, justDate);

handles.preppedDate = serialDate;

setDateInput(handles.prepDateInput, serialDate, justDate);

checkToEnableOkButton(handles);

guidata(hObject, handles);

end

%% Local Functions

function checkToEnableOkButton(handles)

%This function will check to see if any of the input variables are empty,
%and if not it will enable the OK button

if ~isempty(handles.sampleId) && ~isempty(handles.sampleNumber) && ~isempty(handles.preppedBy) && ~isempty(handles.preppedDate) && ~isempty(handles.incubationTime) && ~isempty(handles.incubationTemperature)
    set(handles.OK, 'enable', 'on');
else
    set(handles.OK, 'enable', 'off');
end

end



