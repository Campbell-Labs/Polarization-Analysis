classdef Subject
    %subject
    
    properties
        % set at initialization
        uuid
        dirName
        naviListboxLabel
        metadataHistory
        
        % set by metadata entry        
        subjectId % person ID, dog name        
        subjectNumber                
        notes
        
        % list of eyes and index
        samples
        sampleIndex = 0
    end
    
    
    methods
        
        function subject = Subject()
            % set UUID
            subject.uuid = generateUUID();
        end
        
        function dirName = generateDirName(subject)
            dirName = createDirName(SubjectNamingConventions.DIR_PREFIX, subject.subjectNumber, subject.subjectId, SubjectNamingConventions.DIR_NUM_DIGITS);
        end
        
        
        function label = generateListboxLabel(subject)
            label = createNavigationListboxLabel(SubjectNamingConventions.NAVI_LISTBOX_PREFIX, subject.subjectNumber, subject.subjectId);            
        end
        
        
        function section = generateFilenameSection(subject)
            section = createFilenameSection(SubjectNamingConventions.DATA_FILENAME_LABEL, num2str(subject.subjectNumber));
        end
        
        
        function subject = createDirectories(subject, toTrialPath, projectPath)
            subjectDirectory = subject.generateDirName();
            
            createObjectDirectories(projectPath, toTrialPath, subjectDirectory);
                        
            subject.dirName = subjectDirectory;
        end
        
        
        function [] = saveMetadata(subject, toSubjectPath, projectPath, saveToBackup)
            saveObjectMetadata(subject, projectPath, toSubjectPath, SubjectNamingConventions.METADATA_FILENAME, saveToBackup);            
        end
        
        
        function [subjectIdString, subjectNumberString, subjectNotesString] = getSubjectMetadataString(subject)            
            subjectIdString = ['Subject ID: ', subject.subjectId];
            subjectNumberString = ['Subject Number: ', num2str(subject.subjectNumber)];
            subjectNotesString = ['Notes: ', subject.notes];
        end
        
        
        function subject = importLegacyData(subject, toSubjectPath, legacySubjectImportPath, localProjectPath, dataFilename, userName, subjectType)
            % keep looping through importing locations for the subject
            counter = 1;
            
            while true
                
                if counter ~= 1
                    prompt = 'Would you like to import another location?';
                    title = 'Import Next Location';
                    yes = 'Yes';
                    no = 'No';
                    default = yes;
                    
                    response = questdlg(prompt, title, yes, no, default);
                    
                    if strcmp(response, no)
                        break;
                    end
                end
                
                [cancel, rawDataPath, registeredDataPath, positiveAreaPath, negativeAreaPath] = selectLegacyDataPaths(legacySubjectImportPath);
                
                % TODO: could add a path validation here
                
                if ~cancel && (~isempty(rawDataPath) || ~isempty(registeredDataPath) || ~isempty(positiveAreaPath) || ~isempty(negativeAreaPath))
                    paths = {rawDataPath, registeredDataPath, positiveAreaPath, negativeAreaPath};
                    
                    displayImportPath = ''; % we need a path to display to the user on the metadata entry GUIs just to remind them what's going on
                    
                    for i=1:length(paths)
                        if ~isempty(paths{i})
                            displayImportPath = paths{i};
                            break;
                        end
                    end
                    
                    legacyImportPaths = struct('rawDataPath', rawDataPath, 'registeredDataPath', registeredDataPath, 'positiveAreaPath', positiveAreaPath, 'negativeAreaPath', negativeAreaPath);
                    
                    subject = subject.importLegacyDataTypeSpecific(toSubjectPath, legacyImportPaths, displayImportPath, localProjectPath, dataFilename, userName, subjectType);
                end
                    
                counter = counter + 1;
            end
        end
        
        function subject = createNewSample(subject, toPath, projectPath, userName, sampleType)
            suggestedSampleNumber = subject.nextSampleNumber();
            suggestedSubSampleNumber = subject.nextSubSampleNumber(sampleType);
            
            existingSampleNumbers = subject.getSampleNumbers();
            existingSubSampleNumbers = subject.getSubSampleNumbers(sampleType);
            
            toPath = makePath(toPath, subject.dirName);
            importPath = '';
            
            sample = Sample.createSample(...
                sampleType,...
                suggestedSampleNumber,...
                existingSampleNumbers,...
                suggestedSubSampleNumber,...
                existingSubSampleNumbers,...
                toPath,...
                projectPath,...
                importPath,...
                userName);
            
            if ~isempty(sample)
                subject = subject.updateSample(sample);
            end
        end
        
        
    end
    
end

