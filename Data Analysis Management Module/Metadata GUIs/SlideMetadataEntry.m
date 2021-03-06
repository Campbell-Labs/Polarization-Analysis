function varargout = SlideMetadataEntry(varargin)
% SLIDEMETADATAENTRY MATLAB code for SlideMetadataEntry.fig
%      SLIDEMETADATAENTRY, by itself, creates a new SLIDEMETADATAENTRY or raises the existing
%      singleton*.
%
%      H = SLIDEMETADATAENTRY returns the handle to a new SLIDEMETADATAENTRY or the handle to
%      the existing singleton*.
%
%      SLIDEMETADATAENTRY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SLIDEMETADATAENTRY.M with the given input arguments.
%
%      SLIDEMETADATAENTRY('Property','Value',...) creates a new SLIDEMETADATAENTRY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SlideMetadataEntry_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SlideMetadataEntry_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SlideMetadataEntry

% Last Modified by GUIDE v2.5 19-Sep-2017 10:39:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SlideMetadataEntry_OpeningFcn, ...
                   'gui_OutputFcn',  @SlideMetadataEntry_OutputFcn, ...
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

% --- Executes just before SlideMetadataEntry is made visible.
function SlideMetadataEntry_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SlideMetadataEntry (see VARARGIN)

% Choose default command line output for SlideMetadataEntry
handles.output = hObject;

% ***************************************************************************************
% INPUT: (suggestedSlideNumber, existingSlideNumbers, importPath, userName, slide*)
%        *may be empty
% ***************************************************************************************


if isa(varargin{1}, 'numeric')
    handles.suggestedSlideNumber = num2str(varargin{1}); %Parameter name is 'suggestedSlideNumber' from Slide class function
else
    handles.suggestedSlideNumber = '';
end

handles.exisitingSlideNumbers = varargin{2};
handles.importPath = varargin{3};
handles.userName = varargin{4};


if length(varargin) > 4
    slide = varargin{5};
    
    set(handles.importPathDisplay, 'String', 'None');
    
    handles.stain = slide.stain;
    handles.slideMaterial = slide.slideMaterial;
    handles.aliquotDate = slide.aliquotDate;
    handles.aliquotDoneBy = slide.aliquotDoneBy;
    handles.slideNumber = slide.slideNumber;
    handles.notes = slide.notes;
    
    set(handles.stainInput, 'String', handles.stain);
    set(handles.slideMaterialInput, 'String', handles.slideMaterial);
    
    set(handles.slideNumberInput, 'String', num2str(handles.slideNumber));
    set(handles.aliquotDateDisplay, 'String', displayDate(handles.aliquotDate));
    set(handles.aliquotDoneByInput, 'String', handles.aliquotDoneBy);
    set(handles.slideNotesInput, 'String', handles.notes);
    
    set(handles.OK, 'Enable', 'on');
else
    %Defining the default input variables, awaiting user input
    handles.stain = SlideNamingConventions.DEFAULT_METADATA_GUI_STAIN;
    handles.slideMaterial = SlideNamingConventions.DEFAULT_METADATA_GUI_SLIDE_MATERIAL;
    handles.aliquotDate = [];
    handles.aliquotDoneBy = handles.userName;
    handles.slideNumber = str2double(handles.suggestedSlideNumber);
    handles.notes = '';
    
    %Setting default values for input boxes on GUI
    set(handles.importPathDisplay, 'String', handles.importPath);
    set(handles.slideNumberInput, 'String', handles.suggestedSlideNumber);
    set(handles.aliquotDoneByInput, 'String', handles.userName);
    set(handles.stainInput, 'String', SlideNamingConventions.DEFAULT_METADATA_GUI_STAIN);
    set(handles.slideMaterialInput, 'String', SlideNamingConventions.DEFAULT_METADATA_GUI_SLIDE_MATERIAL);
    
    set(handles.OK, 'Enable', 'off');
end

handles.cancel = false;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SlideMetadataEntry wait for user response (see UIRESUME)
uiwait(handles.slideMetadataEntry);
end

% --- Outputs from this function are returned to the command line.
function varargout = SlideMetadataEntry_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% *********************************************************************************************************************
% OUTPUT: [cancel, stain, slideMaterial, slideNumber, aliquotDate, aliquotDoneBy, notes]
% *********************************************************************************************************************

% Get default command line output from handles structure
varargout{1} = handles.cancel;
varargout{2} = handles.stain;
varargout{3} = handles.slideMaterial;
varargout{4} = handles.slideNumber;
varargout{5} = handles.aliquotDate;
varargout{6} = handles.aliquotDoneBy;
varargout{7} = handles.notes;

close(handles.slideMetadataEntry);
end


% --- Executes when user attempts to close slideMetadataEntry.
function slideMetadataEntry_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to slideMetadataEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    %Clears variables in the case that they wish to exit the program
    handles.cancel = true;
    handles.stain = '';
    handles.slideMaterial = '';
    handles.slideNumber = [];
    handles.aliquotDate = [];
    handles.aliquotDoneBy = '';
    handles.notes = '';
    guidata(hObject, handles);
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    %Clears variables in the case that they wish to exit the program
    handles.cancel = true;
    handles.stain = '';
    handles.slideMaterial = '';
    handles.slideNumber = [];
    handles.aliquotDate = [];
    handles.aliquotDoneBy = '';
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


function stainInput_Callback(hObject, eventdata, handles)
% hObject    handle to stainInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stainInput as text
%        str2double(get(hObject,'String')) returns contents of stainInput as a double

handles.stain = get(hObject, 'String');

checkToEnableOkButton(handles);

guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function stainInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stainInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function slideMaterialInput_Callback(hObject, eventdata, handles)
% hObject    handle to slideMaterialInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slideMaterialInput as text
%        str2double(get(hObject,'String')) returns contents of slideMaterialInput as a double

handles.slideMaterial = get(hObject, 'String');

checkToEnableOkButton(handles);

guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function slideMaterialInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slideMaterialInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function slideNumberInput_Callback(hObject, eventdata, handles)
% hObject    handle to slideNumberInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slideNumberInput as text
%        str2double(get(hObject,'String')) returns contents of slideNumberInput as a double

%Get value from input box
if isnan(str2double(get(hObject, 'String')))
    
    set(handles.slideNumberInput, 'String', '');
    handles.slideNumber = [];
    
    warndlg('Slide Number must be numerical.', 'Slide Number Error', 'modal'); 
    
else
    handles.slideNumber = str2double(get(hObject, 'String'));
end

checkToEnableOkButton(handles);

guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function slideNumberInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slideNumberInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function aliquotDateDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to aliquotDateDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of aliquotDateDisplay as text
%        str2double(get(hObject,'String')) returns contents of aliquotDateDisplay as a double
end

% --- Executes during object creation, after setting all properties.
function aliquotDateDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to aliquotDateDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function aliquotDoneByInput_Callback(hObject, eventdata, handles)
% hObject    handle to aliquotDoneByInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of aliquotDoneByInput as text
%        str2double(get(hObject,'String')) returns contents of aliquotDoneByInput as a double

handles.aliquotDoneBy = get(hObject, 'String');

checkToEnableOkButton(handles);

guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function aliquotDoneByInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to aliquotDoneByInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function slideNotesInput_Callback(hObject, eventdata, handles)
% hObject    handle to slideNotesInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slideNotesInput as text
%        str2double(get(hObject,'String')) returns contents of slideNotesInput as a double

%Get value from input box
handles.notes = strjoin(rot90(cellstr(get(hObject, 'String'))));

checkToEnableOkButton(handles);

guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function slideNotesInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slideNotesInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

enableLineScrolling(hObject);

end


% --- Executes on button press in aliquotDatePicker.
function aliquotDatePicker_Callback(hObject, eventdata, handles)
% hObject    handle to aliquotDatePicker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

justDate = false;

serialDate = guiDatePicker(now, justDate);

handles.aliquotDate = serialDate;

setDateInput(handles.aliquotDateDisplay, serialDate, justDate);

checkToEnableOkButton(handles);

guidata(hObject, handles);

end

% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Dialog box asking the user whether or not they wish to exit the program
exit = questdlg('Are you sure you want to quit?','Quit','Yes','No','No'); 
switch exit
    case 'Yes'
        %Clears variables in the case that they wish to exit the program
        handles.cancel = true;        
        
        handles.stain = '';
        handles.slideMaterial = '';
        handles.slideNumber = [];
        handles.aliquotDate = [];
        handles.aliquotDoneBy = '';
        handles.notes = '';
        guidata(hObject, handles);
        uiresume(handles.slideMetadataEntry);
    case 'No'
end

end

% --- Executes on button press in OK.
function OK_Callback(hObject, eventdata, handles)
% hObject    handle to OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);
uiresume(handles.slideMetadataEntry);

end

%% Local Functions

function checkToEnableOkButton(handles)

%This function will check to see if any of the input variables are empty,
%and if not it will enable the OK button

if ~isempty(handles.stain) && ~isempty(handles.slideMaterial) && ~isempty(handles.slideNumber) && ~isempty(handles.aliquotDate) && ~isempty(handles.aliquotDoneBy) 
    set(handles.OK, 'enable', 'on');
else
    set(handles.OK, 'enable', 'off');
end

end

