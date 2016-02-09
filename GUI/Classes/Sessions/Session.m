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
                
        rejected % T/F, will exclude data from being included in analysis
        rejectedReason % reason that this data was rejected (suspected poor imaging, out of focus
        rejectedBy
        
        metadataHistory
        
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
                
                handles = session.getSubfolderSelection().updateNavigationListboxes(handles);
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
        
        function fileSelection = getSelectedFile(session)
            subfolderSelection = session.getSubfolderSelection();
            
            if ~isempty(subfolderSelection)
                fileSelection = subfolderSelection.getFileSelection();
            else
                fileSelection = [];
            end
        end
        
        function session = incrementFileIndex(session, increment)            
            subfolderSelection = session.getSubfolderSelection();
            
            subfolderSelection = incrementFileIndex(subfolderSelection, increment);
            
            index = subfolderSelection.fileIndex;
            
            newIndex = index + increment;
            
            newIndex = (mod(newIndex-1, length(subfolderSelection.filesInDir))) + 1;
            
            subfolderSelection.fileIndex = newIndex;
            
            session = session.updateFileIndex(newIndex);
        end
        
        function [sessionDateString, sessionDoneByString, sessionNumberString, rejectedString, rejectedReasonString, rejectedByString, sessionNotesString] = getSessionMetadataString(session)
            
            sessionDateString = ['Date: ', session.sessionDate];
            sessionDoneByString = ['Done By: ', session.sessionDoneBy];
            sessionNumberString = ['Session Number: ', session.sessionNumber];
            rejectedString = ['Rejected: ' , session.rejected];
            rejectedReasonString = ['Rejected Reason: ', session.rejectedReason];
            rejectedByString = ['Rejected By: ', session.rejectedBy];
            sessionNotesString = ['Notes: ', session.notes];
        end
    end
    
end

