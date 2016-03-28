classdef NaturalSubject < Subject
    % NaturalSubject 
    % a NaturalSubject is a person or animal
    
    properties
        % set by metadata entry
        age %number (decimal please!)
        gender % GenderTypes
        ADDiagnosis % DiagnosisTypes
        causeOfDeath
        medicalHistory
    end
    
    methods
        function subject = NaturalSubject(subjectNumber, existingSubjectNumbers, toTrialPath, projectPath, importDir, userName)
            if nargin > 0
                [cancel, subject] = subject.enterMetadata(subjectNumber, existingSubjectNumbers, importDir, userName);
                
                if ~cancel
                    % set metadata history
                    subject.metadataHistory = MetadataHistoryEntry(userName, NaturalSubject.empty);
                    
                    % set navigation listbox label
                    subject.naviListboxLabel = subject.generateListboxLabel();
                    
                    % make directory/metadata file
                    subject = subject.createDirectories(toTrialPath, projectPath);
                    
                    % save metadata
                    saveToBackup = true;
                    subject.saveMetadata(makePath(toTrialPath, subject.dirName), projectPath, saveToBackup);
                else
                    subject = NaturalSubject.empty;
                end
            end
        end
        
        function subject = editMetadata(subject, projectPath, toTrialPath, userName, dataFilename, existingSubjectNumbers)
            [cancel, subjectNumber, subjectId, age, gender, ADDiagnosis, causeOfDeath, medicalHistory, notes] = NaturalSubjectMetadataEntry([], existingSubjectNumbers, userName, '', subject);
            
            if ~cancel
                subject = updateMetadataHistory(subject, userName);
                                
                oldDirName = subject.dirName;
                oldFilenameSection = subject.generateFilenameSection();
                
                %Assigning values to NaturalSubject Properties
                subject.subjectNumber = subjectNumber;
                subject.subjectId = subjectId;
                subject.age = age;
                subject.gender = gender;
                subject.ADDiagnosis = ADDiagnosis;
                subject.causeOfDeath = causeOfDeath;
                subject.medicalHistory = medicalHistory;
                subject.notes = notes;
                
                updateBackupFiles = updateBackupFilesQuestionGui();
                
                newDirName = subject.generateDirName();
                newFilenameSection = subject.generateFilenameSection();
                
                renameDirectory(toTrialPath, projectPath, oldDirName, newDirName, updateBackupFiles);
                renameFiles(toTrialPath, projectPath, dataFilename, oldFilenameSection, newFilenameSection, updateBackupFiles);
                
                subject.dirName = newDirName;
                subject.naviListboxLabel = subject.generateListboxLabel();
                
                subject = subject.updateFileSelectionEntries(makePath(projectPath, toTrialPath)); %incase files renamed
                
                subject.saveMetadata(makePath(toTrialPath, subject.dirName), projectPath, updateBackupFiles);
            end
        end
        
        
        function subject = updateFileSelectionEntries(subject, toPath)
            samples = subject.samples;
            
            toPath = makePath(toPath, subject.dirName);
            
            for i=1:length(samples)
                subject.samples{i} = samples{i}.updateFileSelectionEntries(toPath);
            end
        end
        
        
        function subject = loadSubject(subject, toSubjectPath, subjectDir)
            subjectPath = makePath(toSubjectPath, subjectDir);
            
            % load metadata
            vars = load(makePath(subjectPath, SubjectNamingConventions.METADATA_FILENAME), Constants.METADATA_VAR);
            subject = vars.metadata;
            
            % load dir name
            subject.dirName = subjectDir;
            
            % load eyes            
            sampleDirs = getMetadataFolders(subjectPath, SampleNamingConventions.METADATA_FILENAME);
            
            numSamples = length(sampleDirs);
            
            subject.samples = createEmptyCellArray(Sample.empty, numSamples);
            
            for i=1:numSamples
                subject.samples{i} = subject.samples{i}.loadGenericSample(subjectPath, sampleDirs{i});
            end
            
            if ~isempty(subject.samples)
                subject.sampleIndex = 1;
            end
        end
        
        function subject = importSubject(subject, toSubjectProjectPath, subjectImportPath, projectPath, dataFilename, userName, subjectType)
            dirList = getAllFolders(subjectImportPath);
            
            filenameSection = subject.generateFilenameSection();
            dataFilename = [dataFilename, filenameSection]; 
            
            for i=1:length(dirList)
                folderName = dirList{i};
                
                sampleImportPath = makePath(subjectImportPath, folderName);
                
                prompt = ['Select the sample to which the data being imported from ', sampleImportPath, ' belongs to.'];
                title = 'Select Sample';
                choices = subject.getSampleChoices();
                
                [choice, cancel, createNew] = selectEntryOrCreateNew(prompt, title, choices);
                
                if ~cancel
                    if createNew
                        [choices, choiceStrings] = choicesFromEnum('SampleTypes');
                        
                        [choice, ok] = listdlg('ListString', choiceStrings,...
                                               'SelectionMode', 'single',...
                                               'Name', 'Select Sample Type',...
                                               'PromptString', 'For the data being imported, please select the type of sample it is from:');
                        
                        if ok
                            sampleType = choices(choice);
                            
                            suggestedSampleNumber = subject.nextSampleNumber();
                            
                            suggestedSubSampleNumber = getNumberFromFolderName(folderName);
                            
                            if isnan(suggestedSubSampleNumber)
                                suggestedSubSampleNumber = subject.nextSubSampleNumber(sampleType);
                            end
                            
                            existingSampleNumbers = subject.getSampleNumbers();
                            existingSubSampleNumbers = subject.getSubSampleNumbers(sampleType);
                            
                            sample = Sample.createSample(sampleType,...
                                                         suggestedSampleNumber,...
                                                         existingSampleNumbers,...
                                                         suggestedSubSampleNumber,...
                                                         existingSubSampleNumbers,...
                                                         toSubjectProjectPath,...
                                                         projectPath,...
                                                         sampleImportPath,...
                                                         userName);
                        end                        
                    else
                        sample = subject.getSampleFromChoice(choice);
                    end
                    
                    if ~isempty(sample)
                        sampleProjectPath = makePath(toSubjectProjectPath, sample.dirName);
                        
                        sample = sample.importSample(sampleProjectPath, sampleImportPath, projectPath, dataFilename, userName, subjectType);
                        
                        subject = subject.updateSample(sample);
                    end
                end                
            end          
        end
        
        function sample = getSampleFromChoice(subject, choice)
            sample = subject.samples{choice};
        end
        
        function sampleChoices = getSampleChoices(subject)
            samples = subject.samples;
            numSamples = length(samples);
            
            sampleChoices = cell(numSamples, 1);
            
            for i=1:numSamples
                sampleChoices{i} = samples{i}.naviListboxLabel;
            end
        end
        
        function subject = updateEye(subject, eye)
            eyes = subject.eyes;
            numEyes = length(eyes);
            updated = false;
            
            for i=1:numEyes
                if eyes{i}.eyeNumber == eye.eyeNumber
                    subject.eyes{i} = eye;
                    updated = true;
                    break;
                end
            end
            
            if ~updated % add new eye
                subject.eyes{numEyes + 1} = eye;
                
                if subject.eyeIndex == 0
                    subject.eyeIndex = 1;
                end
            end            
        end
        
               
        function eye = getEyeByNumber(subject, number)
            eyes = subject.eyes;
            
            eye = Eye.empty;
            
            for i=1:length(eyes)
                if eyes{i}.eyeNumber == number
                    eye = eyes{i};
                    break;
                end
            end
        end
        
        function eyeNumbers = getEyeNumbers(subject)
            eyes = subject.eyes;
            numEyes = length(eyes);
            
            eyeNumbers = zeros(numEyes, 1); % want this to be an matrix, not cell array
            
            for i=1:numEyes
                eyeNumbers(i) = eyes{i}.eyeNumber;                
            end
        end
        
        function nextEyeNumber = nextEyeNumber(subject)
            eyeNumbers = subject.getEyeNumbers();
            
            if isempty(eyeNumbers)
                nextEyeNumber = 1;
            else
                lastEyeNumber = max(eyeNumbers);
                nextEyeNumber = lastEyeNumber + 1;
            end
        end
       
        function [cancel, subject] = enterMetadata(subject, subjectNumber, existingSubjectNumbers, importPath, userName)
            
            %Call to NaturalSubjectMetadataEntry GUI
            [cancel, subjectNumber, subjectId, age, gender, ADDiagnosis, causeOfDeath, medicalHistory, notes] = NaturalSubjectMetadataEntry(subjectNumber, existingSubjectNumbers, userName, importPath);
            
            if ~cancel
                %Assigning values to NaturalSubject Properties
                subject.subjectNumber = subjectNumber;
                subject.subjectId = subjectId;
                subject.age = age;
                subject.gender = gender;
                subject.ADDiagnosis = ADDiagnosis;
                subject.causeOfDeath = causeOfDeath;
                subject.medicalHistory = medicalHistory;
                subject.notes = notes;
            end
            
        end
        
        function subject = wipeoutMetadataFields(subject)
            subject.dirName = '';
            subject.samples = [];
        end
        
        function sample = getSelectedSample(subject)
            sample = [];
            
            if subject.sampleIndex ~= 0
                sample = subject.samples{subject.sampleIndex};
            end
        end
        
        function handles = updateNavigationListboxes(subject, handles)
            numSamples = length(subject.samples);
            
            if numSamples == 0
                disableNavigationListboxes(handles, handles.sampleSelect);
            else            
                sampleOptions = cell(numSamples, 1);
                
                for i=1:numSamples
                    sampleOptions{i} = subject.samples{i}.naviListboxLabel;
                end
                
                set(handles.sampleSelect, 'String', sampleOptions, 'Value', subject.sampleIndex, 'Enable', 'on');
                
                handles = subject.getSelectedSample().updateNavigationListboxes(handles);
            end
        end
        
        function handles = updateMetadataFields(subject, handles)
            sample = subject.getSelectedSample();
                        
            if isempty(sample)
                disableMetadataFields(handles, handles.sampleMetadata);
            else
                sampleMetadataString = sample.getMetadataString();
                                
                handles = sample.updateMetadataFields(handles, sampleMetadataString);
            end
        end
       
        function metadataString = getMetadataString(subject)
            
            [subjectIdString, subjectNumberString, subjectNotesString] = subject.getSubjectMetadataString();
            
            ageString = ['Age: ', num2str(subject.age)];
            genderString = ['Gender: ', displayType(subject.gender)];
            ADDiagnosisString = ['AD Diagnosis: ', displayType(subject.ADDiagnosis)];
            causeOfDeathString = ['Cause of Death: ', subject.causeOfDeath];
            medicalHistoryString = ['Medical History: ', subject.medicalHistory];
            metadataHistoryStrings = generateMetadataHistoryStrings(subject.metadataHistory);
            
            metadataString = {subjectIdString, subjectNumberString, ageString, genderString, ADDiagnosisString, causeOfDeathString, medicalHistoryString, subjectNotesString};
            metadataString = [metadataString, metadataHistoryStrings];
            
        end
        
        function subject = updateSampleIndex(subject, index)            
            subject.sampleIndex = index;
        end
        
        function subject = updateSubSampleIndex(subject, index)
            sample = subject.getSelectedSample();
            
            sample = sample.updateSubSampleIndex(index);
            
            subject = subject.updateSample(sample);
        end
        
        function subject = updateLocationIndex(subject, index)
            sample = subject.getSelectedSample();
            
            sample = sample.updateLocationIndex(index);
            
            subject = subject.updateSample(sample);
        end
        
        function subject = updateSessionIndex(subject, index)
            sample = subject.getSelectedSample();
            
            sample = sample.updateSessionIndex(index);
            
            subject = subject.updateSample(sample);
        end
        
        function subject = updateSubfolderIndex(subject, index)
            sample = subject.getSelectedSample();
            
            sample = sample.updateSubfolderIndex(index);
            
            subject = subject.updateSample(sample);
        end
        
        function subject = updateFileIndex(subject, index)
            sample = subject.getSelectedSample();
            
            sample = sample.updateFileIndex(index);
            
            subject = subject.updateSample(sample);
        end
        
        function fileSelection = getSelectedFile(subject)
            sample = subject.getSelectedSample();
            
            if ~isempty(sample)
                fileSelection = sample.getSelectedFile();
            else
                fileSelection = [];
            end
        end
        
        function subject = incrementFileIndex(subject, increment)            
            sample = subject.getSelectedSample();
            
            sample = sample.incrementFileIndex(increment);
            
            subject = subject.updateSample(sample);
        end
        
        
        function subject = importLegacyDataTypeSpecific(subject, toSubjectProjectPath, legacyImportPaths, displayImportPath, localProjectPath, dataFilename, userName, subjectType)
            filenameSection = subject.generateFilenameSection();
            dataFilename = [dataFilename, filenameSection];
            
            prompt = ['Select the eye to which the data being imported from ', displayImportPath, ' belongs to.'];
            title = 'Select Eye';
            choices = subject.getSampleChoices();
            
            [choice, cancel, createNew] = selectEntryOrCreateNew(prompt, title, choices);
            
            if ~cancel
                if createNew
                      sampleType = SampleTypes.Eye;
                      
                      suggestedSampleNumber = subject.nextSampleNumber();
                      suggestedSubSampleNumber = subject.nextSubSampleNumber(sampleType);
                      
                      existingSampleNumbers = subject.getSampleNumbers();
                      existingSubSampleNumbers = subject.getSubSampleNumbers(sampleType);
                      
                      sample = Sample.createSample(...
                          sampleType,...
                          suggestedSampleNumber,...
                          existingSampleNumbers,...
                          suggestedSubSampleNumber,...
                          existingSubSampleNumbers,...
                          toSubjectProjectPath,...
                          localProjectPath,...
                          displayImportPath,...
                          userName);
                else
                    sample = subject.getSampleFromChoice(choice);
                end
                
                if ~isempty(sample)
                    toEyeProjectPath = makePath(toSubjectProjectPath, sample.dirName);
                    
                    sample = sample.importLegacyData(toEyeProjectPath, legacyImportPaths, displayImportPath, localProjectPath, dataFilename, userName, subjectType);
                    
                    subject = subject.updateSample(sample);
                end
            end
        end
        
        
        function subject = editSelectedSampleMetadata(subject, projectPath, toSubjectPath, userName, dataFilename)
            sample = subject.getSelectedSample();
            
            if ~isempty(sample)
                existingSampleNumbers = subject.getSampleNumbers();
                
                sampleType = sample.getSampleType();
                
                existingSubSampleNumbers = subject.getSubSampleNumbers(sampleType);
                
                filenameSection = subject.generateFilenameSection();
                dataFilename = [dataFilename, filenameSection];
                
                sample = sample.editMetadata(projectPath, toSubjectPath, userName, dataFilename, existingSampleNumbers, existingSubSampleNumbers);
            
                subject = subject.updateSelectedSample(sample);
            end
        end
        
        function subject = editSelectedQuarterMetadata(subject, projectPath, toSubjectPath, userName, dataFilename)
            eye = subject.getSelectedSample();
            
            if ~isempty(eye)
                toEyePath = makePath(toSubjectPath, eye.dirName);
                filenameSection = subject.generateFilenameSection();
                dataFilename = [dataFilename, filenameSection];
                
                eye = eye.editSelectedQuarterMetadata(projectPath, toEyePath, userName, dataFilename);
            
                subject = subject.updateSelectedSample(eye);
            end
        end
        
        function subject = editSelectedLocationMetadata(subject, projectPath, toSubjectPath, userName, dataFilename, subjectType)
            sample = subject.getSelectedSample();
            
            if ~isempty(sample)
                toSamplePath = makePath(toSubjectPath, sample.dirName);
                filenameSection = subject.generateFilenameSection();
                dataFilename = [dataFilename, filenameSection];
                
                sample = sample.editSelectedLocationMetadata(projectPath, toSamplePath, userName, dataFilename, subjectType);
            
                subject = subject.updateSelectedSample(sample);
            end
        end
        
        function subject = editSelectedSessionMetadata(subject, projectPath, toSubjectPath, userName, dataFilename)
            sample = subject.getSelectedSample();
            
            if ~isempty(sample)
                toSamplePath = makePath(toSubjectPath, sample.dirName);
                filenameSection = subject.generateFilenameSection();
                dataFilename = [dataFilename, filenameSection];
                
                sample = sample.editSelectedSessionMetadata(projectPath, toSamplePath, userName, dataFilename);
            
                subject = subject.updateSelectedSample(sample);
            end
        end
        
    end
    
end
