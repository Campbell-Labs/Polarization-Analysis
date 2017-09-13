function varargout = ArtificialSubjectMetadataEntry(varargin)
% ARTIFICIALSUBJECTMETADATAENTRY MATLAB code for ArtificialSubjectMetadataEntry.fig
%      ARTIFICIALSUBJECTMETADATAENTRY, by itself, creates a new ARTIFICIALSUBJECTMETADATAENTRY or raises the existing
%      singleton*.
%
%      H = ARTIFICIALSUBJECTMETADATAENTRY returns the handle to a new ARTIFICIALSUBJECTMETADATAENTRY or the handle to
%      the existing singleton*.
%
%      ARTIFICIALSUBJECTMETADATAENTRY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ARTIFICIALSUBJECTMETADATAENTRY.M with the given input arguments.
%
%      ARTIFICIALSUBJECTMETADATAENTRY('Property','Value',...) creates a new ARTIFICIALSUBJECTMETADATAENTRY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ArtificialSubjectMetadataEntry_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ArtificialSubjectMetadataEntry_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ArtificialSubjectMetadataEntry

% Last Modified by GUIDE v2.5 12-Sep-2017 14:02:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ArtificialSubjectMetadataEntry_OpeningFcn, ...
                   'gui_OutputFcn',  @ArtificialSubjectMetadataEntry_OutputFcn, ...
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
end
% End initialization code - DO NOT EDIT


% --- Executes just before ArtificialSubjectMetadataEntry is made visible.
function ArtificialSubjectMetadataEntry_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ArtificialSubjectMetadataEntry (see VARARGIN)

%***********************************************************************************************
%INPUT: (suggestedSubjectNumber, existingSubjectNumbers, userName, importPath, isEdit, subject*)
%       *may be empty
%***********************************************************************************************

handles.suggestedSubjectNumber = varargin{1};
handles.exisitingSubjectNumbers = varargin{2};
handles.userName = varargin{3};
handles.importPath = varargin{4};

isEdit = varargin{5};

subject = [];

if length(varargin) > 5
    subject = varargin{6};
end

if isempty(subject)
    subject = ArtificialSubject;
end

handles.cancel = false;

if isEdit
    set(handles.pathTitle, 'Visible', 'off');
    set(handles.importPathTitle, 'Visible', 'off');

    handles.subjectNumber = subject.subjectNumber;
    handles.subjectId = subject.subjectId;    
    handles.preppedDate = subject.preppedDate;
    handles.preppedBy = subject.preppedBy;
    handles.incubationTime = subject.incubationTime;
    handles.incubationTemperature = subject.incubationTemperature;   
    handles.notes = subject.notes;
else
    set(handles.importPathTitle, 'String', handles.importPath);
    
    defaultSubject = ArtificialSubject;
    
    handles.subjectNumber = handles.suggestedSubjectNumber;
    handles.subjectId = defaultSubject.subjectId;    
    handles.preppedDate = defaultSubject.preppedDate;
    handles.preppedBy = defaultSubject.preppedBy;
    handles.incubationTime = defaultSubject.incubationTime;
    handles.incubationTemperature = defaultSubject.incubationTemperature;   
    handles.notes = defaultSubject.notes;
end

% ** SET TEXT FIELDS **

set(handles.subjectNameInput, 'String', handles.subjectId);
set(handles.subjectNumberInput, 'String', num2str(handles.subjectNumber));
set(handles.prepByInput, 'String', handles.preppedBy);
set(handles.incubationTimeInput, 'String', num2str(handles.incubationTime));
set(handles.incubationTempInput, 'String', num2str(handles.incubationTemperature));
set(handles.subjectNotesInput, 'String', handles.notes);

justDate = false;

setDateInput(handles.prepDateInput, handles.preppedDate, justDate);

% Choose default command line output for ArtificialSubjectMetadataEntry
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ArtificialSubjectMetadataEntry wait for user response (see UIRESUME)
uiwait(handles.ArtificialSubjectMetadataEntry);
end


% --- Outputs from this function are returned to the command line.
function varargout = ArtificialSubjectMetadataEntry_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ********************************************************************************************************************
% OUTPUT: [cancel, subjectNumber, subjectId, preppedDate, gender, diagnoses, causeOfDeath, timeOfDeath, medicalHistory, notes]
% ********************************************************************************************************************


% Get default command line output from handles structure
varargout{1} = handles.cancel;
varargout{2} = handles.subjectNumber;
varargout{3} = handles.subjectId;
varargout{4} = handles.preppedDate;
varargout{5} = handles.preppedBy;
varargout{6} = handles.incubationTime;
varargout{7} = handles.incubationTemperature;
varargout{8} = handles.notes;

close(handles.ArtificialSubjectMetadataEntry);
end



function importPathTitle_Callback(hObject, eventdata, handles)
% hObject    handle to importPathTitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of importPathTitle as text
%        str2double(get(hObject,'String')) returns contents of importPathTitle as a double

set(handles.importPathTitle, 'String', handles.importPath);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function importPathTitle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to importPathTitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function subjectNameInput_Callback(hObject, eventdata, handles)
% hObject    handle to subjectNameInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of subjectNameInput as text
%        str2double(get(hObject,'String')) returns contents of subjectNameInput as a double

handles.subjectId = get(hObject, 'String');

checkToEnableOkButton(handles);

guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function subjectNameInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subjectNameInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function subjectNumberInput_Callback(hObject, eventdata, handles)
% hObject    handle to subjectNumberInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of subjectNumberInput as text
%        str2double(get(hObject,'String')) returns contents of subjectNumberInput as a double

if isnan(str2double(get(hObject, 'String')))
    
    set(handles.subjectNumberInput, 'String', '');
    handles.subjectNumber = [];
    
    warndlg('Subject number must be numerical.', 'Subject Number Error', 'modal'); 
    
else
    handles.subjectNumber = str2double(get(hObject, 'String'));
end

checkToEnableOkButton(handles);

guidata(hObject, handles);


end

% --- Executes during object creation, after setting all properties.
function subjectNumberInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subjectNumberInput (see GCBO)
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


function prepByInput_Callback(hObject, eventdata, handles)
% hObject    handle to prepByInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of prepByInput as text
%        str2double(get(hObject,'String')) returns contents of prepByInput as a double

handles.preppedBy = get(hObject, 'String');

checkToEnableOkButton(handles);

guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function prepByInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prepByInput (see GCBO)
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

if isnan(str2double(get(hObject, 'String')))
    
    set(handles.incubationTimeInput, 'String', '');
    handles.incubationTime = [];
    
    warndlg('Subject number must be numerical.', 'Subject Number Error', 'modal'); 
    
else
    handles.incubationTime = str2double(get(hObject, 'String'));
end

checkToEnableOkButton(handles);

guidata(hObject, handles);

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

if isnan(str2double(get(hObject, 'String')))
    
    set(handles.incubationTempInput, 'String', '');
    handles.incubationTemperature = [];
    
    warndlg('Subject number must be numerical.', 'Subject Number Error', 'modal'); 
    
else
    handles.incubationTemperature = str2double(get(hObject, 'String'));
end

checkToEnableOkButton(handles);

guidata(hObject, handles);

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


function subjectNotesInput_Callback(hObject, eventdata, handles)
% hObject    handle to subjectNotesInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of subjectNotesInput as text
%        str2double(get(hObject,'String')) returns contents of subjectNotesInput as a double

handles.notes = strjoin(rot90(cellstr(get(hObject, 'String'))));

checkToEnableOkButton(handles);

guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function subjectNotesInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subjectNotesInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

enableLineScrolling(hObject);

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
        handles.subjectNumber = [];
        handles.subjectId = '';    
        handles.preppedDate = [];
        handles.preppedBy = '';
        handles.incubationTime = [];
        handles.incubationTemperature = [];   
        handles.notes = '';
        handles.cancel = true;
        guidata(hObject, handles);
        uiresume(handles.ArtificialSubjectMetadataEntry);
    case 'No'
end

end

% --- Executes on button press in OK.
function OK_Callback(hObject, eventdata, handles)
% hObject    handle to OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);
uiresume(handles.ArtificialSubjectMetadataEntry);

end


% --- Executes on button press in prepDateButton.
function prepDateButton_Callback(hObject, eventdata, handles)
% hObject    handle to prepDateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

justDate = false;

serialDate = guiDatePicker(now, justDate);

handles.preppedDate = serialDate;

setDateInput(handles.prepDateInput, serialDate, justDate);

checkToEnableOkButton(handles);

guidata(hObject, handles);

end


% --- Executes when user attempts to close ArtificialSubjectMetadataEntry.
function ArtificialSubjectMetadataEntry_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to ArtificialSubjectMetadataEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
     handles.subjectNumber = [];
     handles.subjectId = '';    
     handles.preppedDate = [];
     handles.preppedBy = '';
     handles.incubationTime = [];
     handles.incubationTemperature = [];   
     handles.notes = '';
     handles.cancel = true;
     guidata(hObject, handles);
     uiresume(hObject);
else
     handles.subjectNumber = [];
     handles.subjectId = '';    
     handles.preppedDate = [];
     handles.preppedBy = '';
     handles.incubationTime = [];
     handles.incubationTemperature = [];   
     handles.notes = '';
     handles.cancel = true;
     guidata(hObject, handles);
     delete(hObject);
end
end

%% Local Functions

function checkToEnableOkButton(handles)

%This function will check to see if any of the input variables are empty,
%and if not it will enable the OK button

if ~isempty(handles.subjectNumber) && ~isempty(handles.subjectId) && ~isempty(handles.preppedDate) && ~isempty(handles.preppedBy) && ~isempty(handles.incubationTime) && ~isempty(handles.incubationTemperature)
    set(handles.OK, 'enable', 'on');
else
    set(handles.OK, 'enable', 'off');
end

end
