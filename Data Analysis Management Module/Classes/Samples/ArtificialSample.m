classdef ArtificialSample < Sample
    % ArtificialSample
    % metadata for a sample coming from an ArtificialSubject
    
    properties 
        sampleId
        preppedBy
        preppedDate
        sampleType = [];
        
        incubationTime %hours in decimal
        incubationTemperature %degrees celcius in decimal
        
        %list of slides and index
        slides
        slidesIndex = 0;
        
    end
    
    methods
        
        function sample = ArtificialSample(sampleNumber, existingSampleNumbers, toSubjectPath, projectPath, importPath, userName, toFilename)
            if nargin > 0
                [cancel, sample] = sample.enterMetadata(sampleNumber, existingSampleNumbers, importPath, userName);
                
                if ~cancel
                    % set UUID
                    sample.uuid = generateUUID();
                    
                    % set navigation listbox label
                    sample.naviListboxLabel = sample.generateListboxLabel();
                    
                    % make directory/metadata file
                    sample = sample.createDirectories(toSubjectPath, projectPath);
                    
                    % set metadata history
                    sample.metadataHistory = MetadataHistoryEntry(userName, ArtificialSample.empty);
                    
                    % set toPath
                    sample.toPath = toSubjectPath;
                    
                    % set toFilename
                    sample.toFilename = toFilename;
                    
                    % save metadata
                    saveToBackup = true;
                    sample.saveMetadata(makePath(toSubjectPath, sample.dirName), projectPath, saveToBackup);
                else
                    sample = ArtificialSample.empty;
                end
            end
        end
        
        function [cancel, sample] = enterMetadata(sample, suggestedSampleNumber, existingSampleNumbers, importPath, userName)
            isEdit = false;
            
            %Call to ArtificialSampleMetadataEntry GUI
            [...
                cancel,...
                sampleId,...
                sampleNumber,...
                preppedBy,...
                preppedDate,...
                incubationTime,...
                incubationTemperature,...
                notes]...
                = ArtificialSampleMetadataEntry(suggestedSampleNumber, existingSampleNumbers, userName, importPath, isEdit);
            
            if ~cancel
                %Assigning values to Csf Sample Properties
                sample.sampleId = sampleId;
                sample.sampleNumber = sampleNumber;
                sample.preppedBy = preppedBy;
                sample.preppedDate = preppedDate;
                sample.incubationTime = incubationTime;
                sample.incubationTemperature = incubationTemperature;
                sample.notes = notes;
            end
         end
        
         function sample = editMetadata(sample, projectPath, toSubjectPath, userName, dataFilename, existingSampleNumbers)
            isEdit = true;
            importPath = '';
            
            [...
                cancel,...
                sampleId,...
                sampleNumber,...
                preppedBy,...
                preppedDate,...
                incubationTime,...
                incubationTemperature,...
                notes]...
                = ArtificialSampleMetadataEntry([], existingSampleNumbers, userName, importPath, isEdit, sample);
            
            if ~cancel
                sample = updateMetadataHistory(sample, userName);
                
                oldDirName = sample.dirName;
                oldFilenameSection = sample.generateFilenameSection();
                
                %Assigning values to Artificial Sample Properties
                sample.sampleId = sampleId;
                sample.sampleNumber = sampleNumber;
                sample.preppedBy = preppedBy;
                sample.preppedDate = preppedDate;
                sample.incubationTime = incubationTime;
                sample.incubationTemperature = incubationTemperature;
                sample.notes = notes;
                
                updateBackupFiles = updateBackupFilesQuestionGui();
                
                newDirName = sample.generateDirName();
                newFilenameSection = sample.generateFilenameSection();
                
                renameDirectory(toSubjectPath, projectPath, oldDirName, newDirName, updateBackupFiles);
                renameFiles(toSubjectPath, projectPath, dataFilename, oldFilenameSection, newFilenameSection, updateBackupFiles);
                
                sample.dirName = newDirName;
                sample.naviListboxLabel = sample.generateListboxLabel();
                
                %section = section.updateFileSelectionEntries(makePath(projectPath, toSubjectPath)); %incase files renamed - NOT NEEDED AT THIS TIME
                
                sample.saveMetadata(makePath(toSubjectPath, sample.dirName), projectPath, updateBackupFiles);
            end
         end
        
        function dirName = generateDirName(sample)
            dirSubtitle = sample.sampleId; 
            
            dirName = createDirName(ArtificialSampleNamingConventions.DIR_PREFIX, sample.sampleNumber, dirSubtitle, ArtificialSampleNamingConventions.DIR_NUM_DIGITS);
        end
        
        function label = generateListboxLabel(sample)
            subtitle = ''; % No subtitle for Artificial sample
            
            label = createNavigationListboxLabel(ArtificialSampleNamingConventions.NAVI_LISTBOX_PREFIX, sample.sampleNumber, subtitle);
        end
        
        function sample = generateFilenameSection(sample)
            sample = createFilenameSection(ArtificialSampleNamingConventions.DATA_FILENAME_LABEL, num2str(sample.sampleNumber));
        end
        
        function sample = loadObject(sample)
            % load slides
            [objects, objectIndex] = loadObjects(sample, SlideNamingConventions.METADATA_FILENAME);
            
            sample.slides = objects;
            sample.slidesIndex = objectIndex;   
        end
        
        function sample = updateFileSelectionEntries(sample, toPath)
            slides = sample.slides;
            
            toPath = makePath(toPath, sample.dirName);
            
            for i=1:length(slides)
                sample.slides{i} = slides{i}.updateFileSelectionEntries(toPath);
            end
        end
        
        function sample = importSample(sample, toSampleProjectPath, sampleImportPath, projectPath, dataFilename, userName, subjectType)  
            dirList = getAllFolders(sampleImportPath);
            
            filenameSection = sample.generateFilenameSection();
            dataFilename = [dataFilename, filenameSection];
            
            for i=1:length(dirList)
                folderName = dirList{i};
                
                slideImportPath = makePath(sampleImportPath, folderName);
                
                prompt = ['Select the slide to which the data being imported from ', slideImportPath, ' belongs to.'];
                title = 'Select Slide';
                choices = sample.getSlideChoices();
                
                [choice, cancel, createNew] = selectEntryOrCreateNew(prompt, title, choices);
                
                if ~cancel
                    if createNew
                        suggestedSlideNumber = sample.nextSlideNumber();
                        toFilename = sample.getFilename();
                        slide = Sample(suggestedSlideNumber, eye.getQuarterNumbers(), toEyeProjectPath, projectPath, quarterImportPath, userName, toFilename);
                    else
                        slide = sample.getSlideFromChoice(choice);
                    end
                    
                    if ~isempty(slide)
                        slideProjectPath = makePath(toSampleProjectPath, slide.dirName);
                        
                        slide = slide.importSlide(slideProjectPath, slideImportPath, projectPath, dataFilename, userName, subjectType, sample.sampleType);
                        
                        sample = sample.updateSlide(slide);
                    end
                end
            end
        end
        
        function slide = getSlideFromChoice(sample, choice)
            slide = sample.slides{choice};
        end
        
        function slideChoices = getSlideChoices(sample)
            slides = sample.slides;
            numSlides = length(slides);
            
            slideChoices = cell(numSlides, 1);
            
            for i=1:numSlides
                slideChoices{i} = slides{i}.naviListboxLabel;
            end
        end
        
        function sample = updateSlide(sample, slide)
            slides = sample.slides;
            numSlides = length(slides);
            updated = false;
            
            for i=1:numSlides
                if slides{i}.slideNumber == slide.slideNumber
                    sample.slides{i} = slide;
                    updated = true;
                    break;
                end
            end
            
            if ~updated
                sample.slides{numSlides + 1} = slide;
                
                if sample.slidesIndex == 0
                    sample.slidesIndex = 1;
                end
            end            
        end
        
        function sample = updateSelectedSlide(sample, slide)
            sample.slides{sample.slidesIndex} = slide;
        end
        
        function sample = updateSelectedLocation(sample, location)
            slide = sample.slides{sample.slidesIndex};
            
            slide = slide.updateSelectedLocation(location);
                        
            sample.slides{sample.slidesIndex} = slide;
        end
        
        function slide = getSlideByNumber(sample, number)
            slides = sample.slides;
            
            slide = Slide.empty;
            
            for i=1:length(slides)
                if slides{i}.slideNumber == number
                    slide = slides{i};
                    break;
                end
            end
        end
        
        function slideNumbers = getSlideNumbers(sample)
            slides = sample.slides;
            numSlides = length(slides);
            
            slideNumbers = zeros(numSlides, 1); % want this to be an matrix, not cell array
                        
            for i=1:numSlides
                slideNumbers(i) = slides{i}.slideNumber;                
            end
        end
        
        function nextNumber = nextSlideNumber(sample)
            slideNumbers = sample.getSlideNumbers();
            
            if isempty(slideNumbers)
                nextNumber = 1;
            else
                lastNumber = max(slideNumbers);
                nextNumber = lastNumber + 1;
            end
        end
        
        function subSampleNumber = getSubSampleNumber(sample)
            subSampleNumber = sample.sampleNumber;
        end
        
        function sample = wipeoutMetadataFields(sample)
            sample.dirName = '';
            sample.slides = [];            
            sample.toPath = '';
            sample.toFilename = '';
        end
        
        function slide = getSelectedSlide(sample)
            slide = [];
            
            if sample.slidesIndex ~= 0
                slide = sample.slides{sample.slidesIndex};
            end
        end
        
        function handles = updateNavigationListboxes(sample, handles)
            numSlides = length(sample.slides);
            
            if numSlides == 0
                disableNavigationListboxes(handles, handles.subSampleSelect);
            else            
                slideOptions = cell(numSlides, 1);
                
                for i=1:numSlides
                    slideOptions{i} = sample.slides{i}.naviListboxLabel;
                end
                
                set(handles.subSampleSelect, 'String', slideOptions, 'Value', sample.slidesIndex, 'Enable', 'on');
                
                handles = sample.getSelectedSlide().updateNavigationListboxes(handles);
            end
        end
        
        function handles = updateMetadataFields(sample, handles, sampleMetadataString)
            slide = sample.getSelectedSlide();
                        
            if isempty(slide)
                metadataString = sampleMetadataString;
                
                disableMetadataFields(handles, handles.locationMetadata);
            else
                slideMetadataString = slide.getMetadataString();
                
                metadataString = [sampleMetadataString, {' '}, slideMetadataString];
                
                handles = slide.updateMetadataFields(handles);
            end
            
            set(handles.sampleMetadata, 'String', metadataString);
        end 
        
        function metadataString = getMetadataString(sample)
            
            [sampleNumberString, notesString] = sample.getSampleMetadataString();
            
            sampleIdString = ['Sample ID: ', sample.sampleId];
            preppedByString = ['Prepared By: ', sample.preppedBy];
            preppedDateString = ['Date Prepared: ', displayDateAndTime(sample.preppedDate)];
            incubationTimeString = ['Incubation Time (hours): ', num2str(sample.incubationTime)];
            incubationTemperatureString = ['Incubation Temperature (°C): ', num2str(sample.incubationTemperature)];
        
            metadataString = ...
                ['Artificial Sample: ',...
                sampleNumberString,...
                sampleIdString,...
                preppedByString,...
                preppedDateString,...
                incubationTimeString,...
                incubationTemperatureString,...
                notesString];
            
            metadataHistoryStrings = generateMetadataHistoryStrings(sample.metadataHistory);
            metadataString = [metadataString, metadataHistoryStrings];
            
        end
        
        function sample = updateSubSampleIndex(sample, index)
            sample.slidesIndex = index;
        end
        
        function sample = updateLocationIndex(sample, index)
            slide = sample.getSelectedSlide();
            
            slide = slide.updateLocationIndex(index);
            
            sample = sample.updateSlide(slide);
        end
        
        function sample = updateSessionIndex(sample, index)
            slide = sample.getSelectedSlide();
            
            slide = slide.updateSessionIndex(index);
            
            sample = sample.updateSlide(slide);
        end
        
        function sample = updateSubfolderIndex(sample, index)
            slide = sample.getSelectedSlide();
            
            slide = slide.updateSubfolderIndex(index);
            
            sample = sample.updateSlide(slide);
        end
        
        function sample = updateFileIndex(sample, index)
            slide = sample.getSelectedSlide();
            
            slide = slide.updateFileIndex(index);
            
            sample = sample.updateSlide(slide);
        end
        
        function fileSelection = getSelectedFile(sample)
            slide = sample.getSelectedSlide();
            
            if ~isempty(slide)
                fileSelection = slide.getSelectedFile();
            else
                fileSelection = [];
            end
        end
        
        function sample = incrementFileIndex(sample, increment)            
            slide = sample.getSelectedSlide();
            
            slide = slide.incrementFileIndex(increment);
            
            sample = sample.updateSlide(slide);
        end
        
        function sample = importLegacyData(sample, toSampleProjectPath, legacyImportPaths, displayImportPath, localProjectPath, dataFilename, userName, subjectType)
            filenameSection = sample.generateFilenameSection();
            dataFilename = [dataFilename, filenameSection];
            
            prompt = ['Select the slide to which the data being imported from ', displayImportPath, ' belongs to.'];
            title = 'Select Slide';
            choices = sample.getSlideChoices();
            
            [choice, cancel, createNew] = selectEntryOrCreateNew(prompt, title, choices);
            
            if ~cancel
                if createNew
                    suggestedSlideNumber = sample.nextSlideNumber();
                    toFilename = sample.getFilename();
                    slide = Slide(suggestedSlideNumber, sample.getSlideNumbers(), toSampleProjectPath, localProjectPath, displayImportPath, userName, toFilename);
                else
                    slide = sample.getSlideFromChoice(choice);
                end
                
                if ~isempty(slide)
                    toSlideProjectPath = makePath(toSampleProjectPath, slide.dirName);
                    
                    slide = slide.importLegacyData(toSlideProjectPath, legacyImportPaths, displayImportPath, localProjectPath, dataFilename, userName, subjectType, sample.sampleType);
                    
                    sample = sample.updateSlide(slide);
                end
            end
        end
        
%         function sample = editSelectedSlideMetadata(sample, projectPath, toSamplePath, userName, dataFilename)
%             slide = sample.getSelectedSlide();
%             
%             if ~isempty(slide)
%                 existingSlideNumbers = sample.getSlideNumbers();
%                 filenameSection = sample.generateFilenameSection();
%                 dataFilename = [dataFilename, filenameSection];
%                 
%                 slide = slide.editMetadata(projectPath, toSamplePath, userName, dataFilename, existingSlideNumbers);
%             
%                 sample = sample.updateSelectedSlide(slide);
%             end
%         end
        
        function sample = editSelectedSubdivisionMetadata(sample, projectPath, toSamplePath, userName, dataFilename)
            slide = sample.getSelectedSlide();
            
            if ~isempty(slide)
                existingSlideNumbers = sample.getSlideNumbers();
                filenameSection = sample.generateFilenameSection();
                dataFilename = [dataFilename, filenameSection];
                
                slide = slide.editMetadata(projectPath, toSamplePath, userName, dataFilename, existingSlideNumbers);
            
                sample = sample.updateSelectedSlide(slide);
            end
        end
        
        function sample = editSelectedLocationMetadata(sample, projectPath, toSamplePath, userName, dataFilename, subjectType)
            slide = sample.getSelectedSlide();
            
            if ~isempty(slide)
                toSlidePath = makePath(toSamplePath, slide.dirName);
                filenameSection = sample.generateFilenameSection();
                dataFilename = [dataFilename, filenameSection];
                
                slide = slide.editSelectedLocationMetadata(projectPath, toSlidePath, userName, dataFilename, sample.sampleType, subjectType);
            
                sample = sample.updateSelectedSlide(slide);
            end
        end
        
        function sample = editSelectedSessionMetadata(sample, projectPath, toSamplePath, userName, dataFilename)
            slide = sample.getSelectedSlide();
            
            if ~isempty(slide)
                toSlidePath = makePath(toSamplePath, slide.dirName);
                filenameSection = sample.generateFilenameSection();
                dataFilename = [dataFilename, filenameSection];
                
                slide = slide.editSelectedSessionMetadata(projectPath, toSlidePath, userName, dataFilename);
            
                sample = sample.updateSelectedSlide(slide);
            end
        end
        
        function sample = createNewSlide(sample, projectPath, toPath, userName)
            suggestedSlideNumber = sample.nextSlideNumber();
            existingSlideNumbers = sample.getSlideNumbers();
            
            toSamplePath = makePath(toPath, sample.dirName);
            importDir = '';
            
            slide = Slide(suggestedSlideNumber, existingSlideNumbers, toSamplePath, projectPath, importDir, userName, sample.getFilename());
            
            if ~isempty(slide)
                sample = sample.updateSlide(slide);
            end
        end 
        
        function sample = createNewLocation(sample, projectPath, toPath, userName, subjectType)
            slide = sample.getSelectedSlide();
            
            if ~isempty(slide)
                toPath = makePath(toPath, sample.dirName);
                
                sampleType = sample.sampleType;
                
                slide = slide.createNewLocation(projectPath, toPath, userName, subjectType, sampleType);
                
                sample = sample.updateSlide(slide);
            end
        end
        
        function sample = createNewSession(sample, projectPath, toPath, userName, sessionType)
            slide = sample.getSelectedSlide();
            
            if ~isempty(slide)
                toPath = makePath(toPath, sample.dirName);
                
                slide = slide.createNewSession(projectPath, toPath, userName, sessionType);
                
                sample = sample.updateSlide(slide);
            end
        end
        
        function filenameSections = getFilenameSections(sample, indices)
            if isempty(indices)
                filenameSections = sample.generateFilenameSection();
            else
                index = indices(1);
                
                slide = sample.slides{index};
                
                if length(indices) == 1
                    indices = [];
                else
                    indices = indices(2:length(indices));
                end
                
                filenameSections = [sample.generateFilenameSection(), slide.getFilenameSections(indices)];
            end
        end
        
        function sample = applySelection(sample, indices, isSelected, additionalFields)
            index = indices(1);
            
            len = length(indices);
            
            selectedObject = sample.slides{index};
            
            if len > 1
                indices = indices(2:len);
                
                selectedObject = selectedObject.applySelection(indices, isSelected, additionalFields);
            else
                selectedObject.isSelected = isSelected;
                selectedObject.selectStructureFields = additionalFields;
            end           
            
            sample.slides{index} = selectedObject;
        end
        
        % ************************************************
        % FUNCTIONS FOR SENSITIVITY AND SPECIFICITY MODULE
        % ************************************************
        
        function [dataSheetOutput, rowIndex, allLocationRowIndices] = placeSensitivityAndSpecificityData(sample, dataSheetOutput, rowIndex)
            slides = sample.slides;
            
            allLocationRowIndices = [];
            
            for i=1:length(slides)
                slide = slides{i};
                
                if ~isempty(slide.isSelected)
                    % increase row index
                    slideRowIndex = rowIndex;
                    
                    rowIndex = rowIndex + 1;
                    
                    % place location
                    [dataSheetOutput, rowIndex, locationRowIndices] = slide.placeSensitivityAndSpecificityData(dataSheetOutput, rowIndex);
                    
                    allLocationRowIndices = [allLocationRowIndices, locationRowIndices];
                    
                    % write slide data
                                        
                    dataSheetOutput{quarterRowIndex,1} = slide.uuid;
                    dataSheetOutput{quarterRowIndex,2} = slide.getFilename();
                    
                    if slide.isSelected
                        % nothing to do
                        dataSheetOutput{quarterRowIndex,3} = ' '; %blank 
                    else
                        reason = slide.selectStructureFields.exclusionReason;
                        
                        if isempty(reason)
                            reason = SensitivityAndSpecificityConstants.NO_REASON_TAG;
                        end
                        
                        dataSheetOutput{slideRowIndex, 3} = [SensitivityAndSpecificityConstants.NOT_RUN_TAG, reason];
                    end
                    
                end
            end
        end
        
        % ******************************************
        % FUNCTIONS FOR POLARIZATION ANALYSIS MODULE
        % ******************************************
        
        function [hasValidSession, selectStructureForSample] = createSelectStructure(sample, indices, sessionClass)
            slides = sample.slides;
            
            selectStructureForSample = {};
            hasValidSession = false;
            
            for i=1:length(slides)
                newIndices = [indices, i];
                
                [newHasValidLocation, selectStructureForSlide] = slides{i}.createSelectStructure(newIndices, sessionClass);
                
                if newHasValidLocation
                    selectStructureForSample = [selectStructureForSample, selectStructureForSlide];
                    
                    hasValidSession = true;
                end
            end
            
            if hasValidSession
                switch sessionClass
                    case class(PolarizationAnalysisSession)
                        selectionEntry = PolarizationAnalysisModuleSelectionEntry(sample.naviListboxLabel, indices);
                    case class(SubsectionStatisticsAnalysisSession)
                        selectionEntry = SubsectionStatisticsModuleSelectionEntry(sample.naviListboxLabel, indices);
                    case class(SensitivityAndSpecificityAnalysisSession)
                        selectionEntry = SensitivityAndSpecificityModuleSelectionEntry(sample.naviListboxLabel, indices, sample);
                end
                
                selectStructureForSample = [{selectionEntry}, selectStructureForSample];
            else
                if strcmp(sessionClass, class(SensitivityAndSpecificityAnalysisSession)) % for sensitivity and specificity, even if no location, have unselected sample
                    selectionEntry = SensitivityAndSpecificityModuleSelectionEntry(sample.naviListboxLabel, indices, sample);
                    
                    selectionEntry.isSelected = false;
                    selectionEntry.exclusionReason = SensitivityAndSpecificityConstants.NO_DATA_REASON;
                    
                    selectStructureForSample = {selectionEntry};
                else
                    selectStructureForSample = {};
                end
            end
            
        end
        
        function [isValidated, toPath] = validateSession(sample, indices, toPath)
            slide = sample.slides{indices(1)};
            
            newIndices = indices(2:length(indices));
            toPath = makePath(toPath, sample.dirName);
            
            [isValidated, toPath] = slide.validateSession(newIndices, toPath);
        end
        
        function [sample, selectStructure] = runPolarizationAnalysis(sample, indices, defaultSession, projectPath, progressDisplayHandle, selectStructure, selectStructureIndex, toPath, fileName)
            slide = sample.slides{indices(1)};
            
            newIndices = indices(2:length(indices));
            toPath = makePath(toPath, sample.dirName);
            fileName = [fileName, sample.generateFilenameSection];
            
            [slide, selectStructure] = slide.runPolarizationAnalysis(newIndices, defaultSession, projectPath, progressDisplayHandle, selectStructure, selectStructureIndex, toPath, fileName);
            
            sample = sample.updateSlide(slide);
        end
        
        function [location, toLocationPath, toLocationFilename] = getSelectedLocation(sample)
            slide = sample.getSelectedSlide();
            
            if isempty(slide)            
                location = [];
            else
                location = slide.getSelectedLocation();
                
                toLocationPath = makePath(slide.dirName, location.dirName);
                toLocationFilename = [slide.generateFilenameSection, location.generateFilenameSection];
            end
        end
        
        function session = getSelectedSession(sample)
            slide = sample.getSelectedSlide();
            
            if isempty(slide)            
                session = [];
            else
                session = slide.getSelectedSession();
            end
        end
        
        % ******************************************
        % FUNCTIONS FOR SUBSECTION STATISTICS MODULE
        % ******************************************
        
        function [data, locationString, sessionString] = getPolarizationAnalysisData(sample, subsectionSession, toIndices, toPath, fileName)
            slide = sample.slides{toIndices(1)};
            
            newIndices = toIndices(2:length(toIndices));
            toPath = makePath(toPath, sample.dirName);
            fileName = [fileName, sample.generateFilenameSection];
            
            [data, locationString, sessionString] = slide.getPolarizationAnalysisData(subsectionSession, newIndices, toPath, fileName);
        end
        
        function mask = getFluoroMask(sample, subsectionSession, toIndices, toPath, fileName)
            slide = sample.slides{toIndices(1)};
            
            newIndices = toIndices(2:length(toIndices));
            toPath = makePath(toPath, sample.dirName);
            fileName = [fileName, sample.generateFilenameSection];
            
            mask = slide.getFluoroMask(subsectionSession, newIndices, toPath, fileName);
        end
        
        
    end
    
end

