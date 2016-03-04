classdef LegacyRegistrationSession < DataProcessingSession
    % LegacyRegistrationSession
    % holds metadata for registration session for which the results were
    % directly imported into this application
    
    properties
        registrationType = []; % registrationType
        registrationParams = '';
    end
    
    methods
        function session = LegacyRegistrationSession(sessionNumber, dataProcessingSessionNumber, toLocationPath, projectPath, importDir, userName, sessionChoices, sessionNumbers, lastSession)
            if nargin > 0
                [cancel, session] = session.enterMetadata(importDir, userName, sessionChoices, sessionNumbers, lastSession);
                
                if ~cancel
                    % set session numbers
                    session.sessionNumber = sessionNumber;
                    session.dataProcessingSessionNumber = dataProcessingSessionNumber;
                    
                    % set navigation listbox label
                    session.naviListboxLabel = session.generateListboxLabel();
                    
                    % set metadata history
                    session.metadataHistory = {MetadataHistoryEntry(userName)};
                    
                    % make directory/metadata file
                    session = session.createDirectories(toLocationPath, projectPath);
                    
                    % save metadata
                    saveToBackup = true;
                    session.saveMetadata(makePath(toLocationPath, session.dirName), projectPath, saveToBackup);
                else
                    session = LegacyRegistrationSession.empty;
                end
            end
        end
        
        
        function session = editMetadata(session, projectPath, toLocationPath, userName, dataFilename, sessionChoices, sessionNumbers)
            [cancel, sessionDate, sessionDoneBy, notes, registrationType, registrationParams, rejected, rejectedReason, rejectedBy, selectedChoices] = LegacyRegistrationSessionMetadataEntry('', userName, sessionChoices, session, sessionNumbers);
            
            if ~cancel
                oldDirName = session.dirName;
                oldFilenameSection = session.generateFilenameSection();  
                
                %Assigning values to Legacy Registration Session Properties
                session.registrationType = registrationType;
                session.registrationParams = registrationParams;
                session.sessionDate = sessionDate;
                session.sessionDoneBy = sessionDoneBy;
                session.notes = notes;
                session.rejected = rejected;
                session.rejectedReason = rejectedReason;
                session.rejectedBy = rejectedBy;
                                
                session.linkedSessionNumbers = getSelectedSessionNumbers(sessionNumbers, selectedChoices);
                
                session = updateMetadataHistory(session, userName);
                
                updateBackupFiles = updateBackupFilesQuestionGui();
                
                newDirName = session.generateDirName();
                newFilenameSection = session.generateFilenameSection(); 
                
                renameDirectory(toLocationPath, projectPath, oldDirName, newDirName, updateBackupFiles);
                renameFiles(toLocationPath, projectPath, dataFilename, oldFilenameSection, newFilenameSection, updateBackupFiles);
                
                session.dirName = newDirName;
                session.naviListboxLabel = session.generateListboxLabel();
                
                session = session.updateFileSelectionEntries(makePath(projectPath, toLocationPath)); %incase files renamed
                
                session.saveMetadata(makePath(toLocationPath, session.dirName), projectPath, updateBackupFiles);
            end
        end
        
        
        function [cancel, session] = enterMetadata(session, importPath, userName, sessionChoices, sessionNumbers, lastSession)
            
            %Call to Legacy Registration Session Metadata Entry GUI
            [cancel,...
             sessionDate,...
             sessionDoneBy,...
             notes,...
             registrationType,...
             registrationParams,...
             rejected,...
             rejectedReason,...
             rejectedBy,...
             selectedChoices]...
             = LegacyRegistrationSessionMetadataEntry(importPath, userName, sessionChoices, lastSession);
            
            if ~cancel
                %Assigning values to Legacy Registration Session Properties
                session.registrationType = registrationType;
                session.registrationParams = registrationParams;
                session.sessionDate = sessionDate;
                session.sessionDoneBy = sessionDoneBy;
                session.notes = notes;
                session.rejected = rejected;
                session.rejectedReason = rejectedReason;
                session.rejectedBy = rejectedBy;
                                
                session.linkedSessionNumbers = getSelectedSessionNumbers(sessionNumbers, selectedChoices);
            end
        
        end
        
        
        function session = importSession(session, sessionProjectPath, importPath, projectPath, dataFilename)
            dataFilename = strcat(dataFilename, session.generateFilenameSection());
            
            filenameExtensions = {Constants.BMP_EXT};
            
            waitText = 'Importing session data. Please wait.';
            waitTitle = 'Importing Data';
            
            waitHandle = popupMessage(waitText, waitTitle);
                        
            
            suggestedDirectoryName = MicroscopeNamingConventions.MM_DIR.getSingularProjectTag();
            suggestedDirectoryTag = MicroscopeNamingConventions.MM_FILENAME_LABEL;
            
            namingConventions = MicroscopeNamingConventions.getMMNamingConventions();
                                                        
            extensionImportPaths = getExtensionImportPaths(importPath, filenameExtensions, 'Registration');
                
            [filenames, pathIndicesForFilenames] = getFilenamesForTagAssignment(extensionImportPaths);
            
            suggestedFilenameTags = createSuggestedFilenameTags(filenames, namingConventions);
            
            
            [cancel, newDir, directoryTag, filenameTags] = SelectProjectTags(importPath, filenames, suggestedDirectoryName, suggestedDirectoryTag, suggestedFilenameTags);
            
            
            if ~cancel
                filenameSection = createFilenameSection(directoryTag, '');
                
                % import the files
                dataFilename = strcat(dataFilename, filenameSection);
                
                importFiles(sessionProjectPath, extensionImportPaths, projectPath, dataFilename, filenames, pathIndicesForFilenames, filenameExtensions, filenameTags, newDir);
            end

            delete(waitHandle);     
            
        end
        
        
        function dirSubtitle = getDirSubtitle(session)
            dirSubtitle = [LegacyRegistrationNamingConventions.SESSION_DIR_SUBTITLE];
        end
        
               
        function metadataString = getMetadataString(session)
            
            [sessionDateString, sessionDoneByString, sessionNumberString, rejectedString, rejectedReasonString, rejectedByString, sessionNotesString, metadataHistoryStrings] = getSessionMetadataString(session);
            [dataProcessingSessionNumberString, linkedSessionsString] = session.getProcessingSessionMetadataString();
            
            registrationTypeString = ['Registration Type: ', session.registrationType.displayString];
            registrationParamsString = ['Registration Parameters: ' session.registrationParams];
            
            
            metadataString = {sessionDateString, sessionDoneByString, sessionNumberString, dataProcessingSessionNumberString, linkedSessionsString, registrationTypeString, registrationParamsString, rejectedString, rejectedReasonString, rejectedByString, sessionNotesString};
            metadataString = [metadataString, metadataHistoryStrings];
        end        
        
        
        function preppedSession = prepForAutofill(session)
            preppedSession = LegacyRegistrationSession;
            
            % these are the values to carry over
            preppedSession.sessionDate = session.sessionDate;
            preppedSession.sessionDoneBy = session.sessionDoneBy;
            preppedSession.registrationType = session.registrationType;
            preppedSession.linkedSessionNumbers = session.linkedSessionNumbers;
        end
        
    end
    
end

