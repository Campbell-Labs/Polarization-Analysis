classdef Session
    %Session
    % holds metadata describing data collection or analysis for a given
    % location
    
    % a lot of classes inherit from this bad boy
    
    properties
        dirName
        
        sessionDate
        sessionDoneBy
           
        sessionNumber
        
        isDataCollectionSession
        
        subfolderIndex = 0
        
        fileSelectionEntries
        
        notes
    end
    
    methods
        function session = wipeoutMetadataFields(session)
            session.dirName = '';
            session.fileSelectionEntries = [];
        end
        
        function handles = updateNavigationListboxes(session, handles)
            subfolderSelections = session.getSubfolderSelections();
            
            if isempty(subfolderSelections)
                disableNavigationListboxes(handles, handles.subfolderSelect);
            else
                set(handles.subfolderSelect, 'String', subfolderSelections, 'Value', session.subfolderIndex, 'Enable', 'on');
                
                session.getSubfolderSelection().updateNavigationListboxes(handles);
            end            
        end
        
        function session = createFileSelectionEntries(session, toSessionPath)
            session.fileSelectionEntries = generateFileSelectionEntries({}, toSessionPath, session.dirName, 0);
        end
        
        function subfolderSelections = getSubfolderSelections(session)
            numEntries = length(session.fileSelectionEntries);
            
            subfolderSelections = cell(numEntries, 1);
            
            for i=1:numEntries
                subfolderSelections{i} = session.fileSelectionEntries{i}.selectionLabel;
            end
        end              
        
        function subfolderSelection = getSubfolderSelection(session)
            
            if session.subfolderIndex ~= 0
                subfolderSelection = session.fileSelectionEntries{session.subfolderIndex};
            else
                subfolderSelection = [];
            end
        end
                
        function session = updateSubfolderIndex(session, index)
            session.subfolderIndex = index;
        end
        
        function session = updateFileIndex(session, index)
            subfolderSelection = session.getSubfolderSelection();
            
            subfolderSelection = subfolderSelection.updateFileIndex(index);  
            
            session.fileSelectionEntries{session.subfolderIndex} = subfolderSelection;
        end
    end
    
end

