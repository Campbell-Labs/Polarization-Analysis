function varargout = NaturalSubjectMetadataEntry(varargin)
% NATURALSUBJECTMETADATAENTRY MATLAB code for NaturalSubjectMetadataEntry.fig
%      NATURALSUBJECTMETADATAENTRY, by itself, creates a new NATURALSUBJECTMETADATAENTRY or raises the existing
%      singleton*.
%
%      H = NATURALSUBJECTMETADATAENTRY returns the handle to a new NATURALSUBJECTMETADATAENTRY or the handle to
%      the existing singleton*.
%
%      NATURALSUBJECTMETADATAENTRY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NATURALSUBJECTMETADATAENTRY.M with the given input arguments.
%
%      NATURALSUBJECTMETADATAENTRY('Property','Value',...) creates a new NATURALSUBJECTMETADATAENTRY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NaturalSubjectMetadataEntry_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NaturalSubjectMetadataEntry_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NaturalSubjectMetadataEntry

% Last Modified by GUIDE v2.5 16-Feb-2016 16:36:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NaturalSubjectMetadataEntry_OpeningFcn, ...
                   'gui_OutputFcn',  @NaturalSubjectMetadataEntry_OutputFcn, ...
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

% --- Executes just before NaturalSubjectMetadataEntry is made visible.
function NaturalSubjectMetadataEntry_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NaturalSubjectMetadataEntry (see VARARGIN)

%******************************************************************************
%INPUT: (subjectNumber, existingSubjectNumbers, userName, importPath, subject*)
%       *may be empty
%******************************************************************************

handles.subjectNumber = varargin{1};
handles.existingSubjectNumbers = varargin{2};
handles.userName = varargin{3};
handles.importPath = varargin{4};


[~, genderChoiceStrings] = choicesFromEnum('GenderTypes');
[~, diagnosisChoiceStrings] = choicesFromEnum('DiagnosisTypes');

%Default gender choice list setting
handles.genderChoiceListDefault = 'Select a Gender';

%Default diagnosis choice list setting
handles.diagnosisChoiceListDefault = 'Select a Diagnosis';

%Setting the list values for the Gender Type pop up menu
genderChoiceList = {handles.genderChoiceListDefault};
for i = 1:size(genderChoiceStrings)
    genderChoiceList{i+1} = genderChoiceStrings{i};
end
set(handles.genderInput, 'String', genderChoiceList);

%Setting the list values for the Diagnosis Type pop up menu
diagnosisChoiceList = {handles.diagnosisChoiceListDefault};
for i = 1:size(diagnosisChoiceStrings)
    diagnosisChoiceList{i+1} = diagnosisChoiceStrings{i};
end
set(handles.diagnosisInput, 'String', diagnosisChoiceList);


if length(varargin) > 4
    subject = varargin{5};
    
    handles.subjectNumber = subject.subjectNumber;
    handles.importPath = 'None';
    
    handles.age = subject.age;
    handles.gender = subject.gender;
    handles.ADDiagnosis = subject.ADDiagnosis;
    handles.causeOfDeath = subject.causeOfDeath;
    handles.subjectNotes = subject.notes;
    handles.medicalHistory = subject.medicalHistory;
    handles.subjectId = subject.subjectId;
    
    set(handles.ageInput, 'String', num2str(handles.age));
    set(handles.deathInput, 'String', handles.causeOfDeath);
    set(handles.subjectNumberInput, 'String', num2str(handles.subjectNumber));
    set(handles.subjectIdInput, 'String', handles.subjectId);
    set(handles.medicalHistoryInput, 'String', handles.medicalHistory);
    set(handles.sbjNotesInput, 'String', handles.subjectNotes);
    
    genderMatchString = handles.gender.displayString;
    
    for i=1:length(genderChoiceStrings)
        if strcmp(genderMatchString, genderChoiceStrings{i})
            set(handles.genderInput, 'Value', i+1);
            break;
        end
    end
    
    diagnosisMatchString = handles.ADDiagnosis.displayString;
    
    for i=1:length(diagnosisChoiceStrings)
        if strcmp(diagnosisMatchString, diagnosisChoiceStrings{i})
            set(handles.diagnosisInput, 'Value', i+1);
            break;
        end
    end
    
    set(handles.OK, 'enable', 'on');
else
    %Defining the different input variables as empty, awaiting user input
    handles.age = [];
    handles.gender = [];
    handles.ADDiagnosis = [];
    handles.causeOfDeath = '';
    handles.subjectNotes = '';
    handles.medicalHistory = '';
    handles.subjectId = '';
    
    set(handles.subjectNumberInput, 'String', handles.subjectNumber);
    
    set(handles.OK, 'enable', 'off');
end


%Display the import path name
set(handles.importPathTitle, 'String', handles.importPath);

handles.cancelValue = false;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NaturalSubjectMetadataEntry wait for user response (see UIRESUME)
uiwait(handles.NaturalSubjectMetadataEntry);
end

% --- Outputs from this function are returned to the command line.
function varargout = NaturalSubjectMetadataEntry_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.cancelValue;
varargout{2} = handles.subjectNumber;
varargout{3} = handles.subjectId;
varargout{4} = handles.age;
varargout{5} = handles.gender;
varargout{6} = handles.ADDiagnosis;
varargout{7} = handles.causeOfDeath;
varargout{8} = handles.medicalHistory;
varargout{9} = handles.subjectNotes;

close(handles.NaturalSubjectMetadataEntry);
end


function ageInput_Callback(hObject, eventdata, handles)
% hObject    handle to ageInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ageInput as text
%        str2double(get(hObject,'String')) returns contents of ageInput as a double

if isnan(str2double(get(hObject, 'String')))
    
    set(handles.ageInput, 'String', '');
    handles.age = [];
    
    warndlg('Age must be numerical.', 'Age Error', 'modal'); 
    
else
    handles.age = str2double(get(hObject, 'String'));
end

checkToEnableOkButton(handles);

guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function ageInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ageInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on selection change in genderInput.
function genderInput_Callback(hObject, eventdata, handles)
% hObject    handle to genderInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns genderInput contents as cell array
%        contents{get(hObject,'Value')} returns selected item from genderInput

%Get value from popup list
[genderChoice,~] = choicesFromEnum('GenderTypes');

if get(hObject, 'Value') == 1 
    handles.gender = [];
else
    handles.gender = genderChoice(get(hObject, 'Value')-1); 
end

checkToEnableOkButton(handles);

guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function genderInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to genderInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on selection change in diagnosisInput.
function diagnosisInput_Callback(hObject, eventdata, handles)
% hObject    handle to diagnosisInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns diagnosisInput contents as cell array
%        contents{get(hObject,'Value')} returns selected item from diagnosisInput



[diagnosisChoice,~] = choicesFromEnum('DiagnosisTypes');

%Check if value is default value
if get(hObject, 'Value') == 1 
    handles.ADDiagnosis = [];
else
    handles.ADDiagnosis = diagnosisChoice(get(hObject, 'Value')-1); 
end

checkToEnableOkButton(handles);

guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function diagnosisInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to diagnosisInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function deathInput_Callback(hObject, eventdata, handles)
% hObject    handle to deathInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of deathInput as text
%        str2double(get(hObject,'String')) returns contents of deathInput as a double

handles.causeOfDeath = get(hObject, 'String');

checkToEnableOkButton(handles);

guidata(hObject, handles);


end

% --- Executes during object creation, after setting all properties.
function deathInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to deathInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function sbjNotesInput_Callback(hObject, eventdata, handles)
% hObject    handle to sbjNotesInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sbjNotesInput as text
%        str2double(get(hObject,'String')) returns contents of sbjNotesInput as a double

handles.subjectNotes = strjoin(rot90(cellstr(get(hObject, 'String'))));

checkToEnableOkButton(handles);

guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function sbjNotesInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sbjNotesInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

enableLineScrolling(hObject);

end

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Dialog box asking the user whether or not they wish to exit the program
exit = questdlg('Are you sure you want to quit?','Quit','Yes','No','No'); % TODO just cancel or is this just fine?
switch exit
    case 'Yes'
        %Clears variables in the case that they wish to exit the program
        handles.age = [];
        handles.gender = [];
        handles.ADDiagnosis = [];
        handles.causeOfDeath = '';
        handles.subjectNotes = '';
        handles.medicalHistory = '';
        handles.subjectId = '';
        handles.subjectNumber = [];
        handles.cancelValue = true;
        guidata(hObject, handles);
        uiresume(handles.NaturalSubjectMetadataEntry);
    case 'No'
end

end

% --- Executes on button press in OK.
function OK_Callback(hObject, eventdata, handles)
% hObject    handle to OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);
uiresume(handles.NaturalSubjectMetadataEntry);

end

% --- Executes when user attempts to close NaturalSubjectMetadataEntry.
function NaturalSubjectMetadataEntry_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to NaturalSubjectMetadataEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    handles.age = [];
    handles.gender = [];
    handles.ADDiagnosis = [];
    handles.causeOfDeath = '';
    handles.subjectNotes = '';
    handles.medicalHistory = '';
    handles.subjectId = '';
    handles.subjectNumber = [];
    handles.cancelValue = true;
    guidata(hObject, handles);
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    handles.age = [];
    handles.gender = [];
    handles.ADDiagnosis = [];
    handles.causeOfDeath = '';
    handles.subjectNotes = '';
    handles.medicalHistory = '';
    handles.subjectId = '';
    handles.subjectNumber = [];
    handles.cancelValue = true;
    guidata(hObject, handles);
    delete(hObject);
end
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


function subjectIdInput_Callback(hObject, eventdata, handles)
% hObject    handle to subjectIdInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of subjectIdInput as text
%        str2double(get(hObject,'String')) returns contents of subjectIdInput as a double

handles.subjectId = get(hObject, 'String');

checkToEnableOkButton(handles);

guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function subjectIdInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subjectIdInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function medicalHistoryInput_Callback(hObject, eventdata, handles)
% hObject    handle to medicalHistoryInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of medicalHistoryInput as text
%        str2double(get(hObject,'String')) returns contents of medicalHistoryInput as a double

handles.medicalHistory = strjoin(rot90(cellstr(get(hObject, 'String'))));

checkToEnableOkButton(handles);

guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function medicalHistoryInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to medicalHistoryInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

enableLineScrolling(hObject);

end

%% Local Functions

function checkToEnableOkButton(handles)

%This function will check to see if any of the input variables are empty,
%and if not it will enable the OK button

if ~isempty(handles.subjectNumber) && ~isempty(handles.subjectId) && ~isempty(handles.age) && ~isempty(handles.gender) && ~isempty(handles.ADDiagnosis) && ~isempty(handles.causeOfDeath)
    set(handles.OK, 'enable', 'on');
else
    set(handles.OK, 'enable', 'off');
end

end

