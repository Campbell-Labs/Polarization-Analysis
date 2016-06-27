classdef SensitivityAndSpecificityAnalysisSession < DataProcessingSession
    % SensitivityAndSpecificityAnalysisSession
    % stores metadata for a sensitity and specificity
    
    properties
        analysisType = [];
    end
    
    methods
        function session = SensitivityAndSpecificityAnalysisSession(sessionNumber, dataProcessingSessionNumber, toLocationPath, projectPath, userName, notes, rejected, rejectedReason, rejectedBy, analysisType)
            if nargin > 0
                % set session numbers
                session.sessionNumber = sessionNumber;
                session.dataProcessingSessionNumber = dataProcessingSessionNumber;
                
                % set navigation listbox label
                session.naviListboxLabel = session.generateListboxLabel();
                
                % set metadata history
                session.metadataHistory = MetadataHistoryEntry(userName, SensitivityAndSpecificityAnalysisSession.empty);
                
                % set other fields
                session.uuid = generateUUID();
                session.sessionDate = now;
                session.sessionDoneBy = userName;
                session.notes = notes;
                session.rejected = rejected;
                session.rejectedReason = rejectedReason;
                session.rejectedBy = rejectedBy;
                
                session.comparisonType = comparisonType;
                
                session.linkedSessionNumbers = []; %distributed over multiple subjects, could uuids I suppose
                
                % make directory/metadata file
                session = session.createDirectories(toLocationPath, projectPath);
                
                % save metadata
                saveToBackup = false;
                session.saveMetadata(makePath(toLocationPath, session.dirName), projectPath, saveToBackup);
            end
        end
        
        
        function dirSubtitle = getDirSubtitle(session)
            dirSubtitle = [SensitivityAndSpecificityAnalysisNamingConventions.SESSION_DIR_SUBTITLE];
        end
        
        
        function bool = shouldCreateBackup(session)
            bool = false;
        end
        
        function metadataString = getMetadataString(session)
            
            [sessionDateString, sessionDoneByString, sessionNumberString, rejectedString, rejectedReasonString, rejectedByString, sessionNotesString, metadataHistoryStrings] = getSessionMetadataString(session);
            [dataProcessingSessionNumberString, linkedSessionsString] = session.getProcessingSessionMetadataString();
            
            analysisTypeString = ['Analysis Type: ', displayType(session.analysisType)];            
                        
            metadataString = {...
                sessionDateString,...
                sessionDoneByString,...
                sessionNumberString,...
                dataProcessingSessionNumberString,...
                linkedSessionsString,...
                analysisTypeString,...
                rejectedString,...
                rejectedReasonString,...
                rejectedByString,...
                sessionNotesString};
            
            metadataString = [metadataString, metadataHistoryStrings];
        end
    end
    
end
