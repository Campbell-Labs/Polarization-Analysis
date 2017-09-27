function [] = newSlide(hObject, eventdata, handles)
%newSlide

project = handles.localProject;

userName = handles.userName;
projectPath = handles.localPath;

project = project.createNewSlide(projectPath, userName);

handles.localProject = project;

handles = project.updateMetadataFields(handles);
handles = project.updateNavigationListboxes(handles);

guidata(hObject, handles);

end