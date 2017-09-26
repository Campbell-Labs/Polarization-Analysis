classdef Slide
    %Slide
    %stores information about a slide of the artificial subject
    
    properties
        %set at initialization
        uuid
        dirName
        naviListboxLabel
        metadataHistory
        
        projectPath = '';
        toPath = '';
        toFilename = '';
        
        %set by metadata entry
        aliquotDate
        aliquotDoneBy
        stain
        slideMaterial
        slideNumber
        notes
        slideType = [];
        
        %locations list and index
        locations
        locationIndex = 0;
        
        %for use with select structures
        isSelected = [];
        selectStructureFields = [];
    end
    
    methods
        function slide = Slide(suggestedSlideNumber, existingSlideNumbers, toSamplePath, projectPath, importDir, userName, toFilename)
            [cancel, slide] = slide.enterMetadata(suggestedSlideNumber, existingSlideNumbers, importDir, userName);
            
            if ~cancel
                %set UUID
                slide.uuid = generateUUID();
                
                % set metadata history
                slide.metadataHistory = MetadataHistoryEntry(userName, Sample.empty);
                
                % set navigation listbox label
                slide.naviListboxLabel = slide.generateListboxLabel();
                
                % make directory/metadata file
                slide = slide.createDirectories(toSamplePath, projectPath);
                
                % set toPath
                slide.toPath = toSamplePath;
                
                % set toFilename
                slide.toFilename = toFilename;
                
                % save metadata
                saveToBackup = true;
                slide.saveMetadata(makePath(toSamplePath, slide.dirName), projectPath, saveToBackup);
            else
            slide = Slide.empty;
            end
        end
        
        function slide = editMetadata(slide, projectPath, toSamplePath, userName, dataFilename, existingSlideNumbers)
            [cancel, stain, slideMaterial, slideNumber, aliquotDate, aliquotDoneBy, notes] = SlideMetadataEntry([], existingSlideNumbers, '', userName, slide);
            
            if ~cancel
                slide = updateMetadataHistory(slide, userName);
                
                oldDirName = slide.dirName;
                oldFilenameSection = slide. generateFilenameSection();
                
                %Assigning values to Slide properties
                slide.stain = stain;
                slide.slideMaterial = slideMaterial;
                slide.slideNumber = slideNumber;
                slide.aliquotDate = aliquotDate;
                slide.aliquotDoneBy = aliquotDoneBy;
                slide.notes = notes;
                
                updateBackupFiles = updateBackupFilesQuestionGui();
                
                newDirName = slide.generateDirName();
                newFilenameSection = slide.generateFilenameSection();
                
                renameDirectory(toSamplePath, projectPath, oldDirName, newDirName, updateBackupFiles);
                renameFiles(toSamplePath, projectPath, dataFilename, oldFilenameSection, newFilenameSection, updateBackupFiles);
                
                slide.dirName = newDirName;
                slide.naviListboxLabel = slide.generateListboxLabel();
                
                slide = slide.updateFileSelectionEntries(makePath(projectPath, toSamplePath)); %incase files renamed
                
                slide.saveMetadata(makePath(toSamplePath, slide.dirName), projectPath, updateBackupFiles);
            end
        end
               
        
        function dirName = generateDirName(slide)
            dirSubtitle = slide.stain;
            
            dirName = createDirName(SlideNamingConventions.DIR_PREFIX, slide.slideNumber, dirSubtitle, SlideNamingConventions.DIR_NUM_DIGITS);
        end   
        
        
        function label = generateListboxLabel(slide) 
            subtitle = slide.stain;
            
            label = createNavigationListboxLabel(SlideNamingConventions.NAVI_LISTBOX_PREFIX, slide.slideNumber, subtitle);
        end
        
        
        function section = generateFilenameSection(slide)
            section = createFilenameSection(SlideNamingConventions.DATA_FILENAME_LABEL, num2str(slide.slideNumber));
        end
        
        function filename = getFilename(slide)
            filename = [slide.toFilename, slide.generateFilenameSection()];
        end  
        
        function toPath = getToPath(slide)
            toPath = makePath(slide.toPath, slide.dirName);
        end
        
        function toPath = getFullPath(slide)
            toPath = makePath(slide.projectPath, slide.getToPath());
        end
        
        function slide = updateFileSelectionEntries(slide, toPath)
            locations = slide.locations;
            
            toPath = makePath(toPath, slide.dirName);
            
            for i=1:length(locations)
                slide.locations{i} = locations{i}.updateFileSelectionEntries(toPath);
            end
        end
        
        function slide = loadObject(slide)            
            % load locations            
            [objects, objectIndex] = loadObjects(slide, LocationNamingConventions.METADATA_FILENAME);
            
            slide.locations = objects;
            slide.locationIndex = objectIndex;
            
        end
        
        function slide = importSlide(slide, toSlideProjectPath, slideImportPath, projectPath, dataFilename, userName, subjectType, sampleType)
            dirList = getAllFolders(slideImportPath);
            
            filenameSection = slide.generateFilenameSection();
            dataFilename = [dataFilename, filenameSection];
            
            for i=1:length(dirList)
                folderName = dirList{i};
                
                locationImportPath = makePath(slideImportPath, folderName);
                
                prompt = ['Select the location to which the data being imported from ', locationImportPath, ' belongs to.'];
                title = 'Select Location';
                choices = slide.getLocationChoices();
                
                [choice, cancel, createNew] = selectEntryOrCreateNew(prompt, title, choices);
                
                if ~cancel
                    if createNew
                        suggestedLocationNumber = getNumberFromFolderName(folderName);
                        
                        if isnan(suggestedLocationNumber)
                            suggestedLocationNumber = slide.nextLocationNumber();
                        end
                        
                        locationNumbers = slide.getLocationNumbers();
                        rejectSelectedLocation = false;
                        locationCoordsWithLabels = slide.generateLocationCoordsWithLabels(rejectSelectedLocation);
                        toFilename = slide.getFilename();
                        
                        location = Location(suggestedLocationNumber, locationNumbers, locationCoordsWithLabels, toQuarterProjectPath, projectPath, locationImportPath, userName, subjectType, sampleType, slide.slideType, toFilename); 
                    else
                        location = slide.getLocationFromChoice(choice);
                    end
                    
                    if ~isempty(location)
                        locationProjectPath = makePath(toSlideProjectPath, location.dirName);
                        
                        location = location.importLocation(locationProjectPath, locationImportPath, projectPath, dataFilename, userName, slide.locations);
                        
                        slide = slide.updateLocation(location);
                    end
                end
            end
        end
        
        function location = getLocationFromChoice(slide, choice)
            location = slide.locations{choice};
        end
        
        function locationChoices = getLocationChoices(slide)
            locations = slide.locations;
            numLocations = length(locations);
            
            locationChoices = cell(numLocations, 1);
            
            for i=1:numLocations
                locationChoices{i} = locations{i}.naviListboxLabel;
            end
        end
        
        function slide = updateLocation(slide, location)
            locations = slide.locations;
            numLocations = length(locations);
            updated = false;
            
            for i=1:numLocations
                if locations{i}.locationNumber == location.locationNumber
                    slide.locations{i} = location;
                    updated = true;
                    break;
                end
            end
            
            if ~updated
                slide.locations{numLocations + 1} = location;
                
                if slide.locationIndex == 0
                    slide.locationIndex = 1;
                end
            end   
        end
        
        function slide = updateSelectedLocation(slide, location)
            slide.locations{slide.locationIndex} = location;
        end
        
        function location = getLocationByNumber(slide, number)
            locations = slide.locations;
            
            location = Location.empty;
            
            for i=1:length(locations)
                if locations{i}.locationNumber == number
                    location = locations{i};
                    break;
                end
            end
        end
        
        function locationNumbers = getLocationNumbers(slide)
            locations = slide.locations;
            numLocations = length(locations);
            
            locationNumbers = zeros(numLocations, 1); % want this to be an matrix, not cell array
            
            for i=1:numLocations
                locationNumbers(i) = locations{i}.locationNumber;                
            end
        end 
        
        function nextNumber = nextLocationNumber(slide)
            locationNumbers = slide.getLocationNumbers();
            
            if isempty(locationNumbers)
                nextNumber = 1;
            else
                lastNumber = max(locationNumbers);
                nextNumber = lastNumber + 1;
            end
        end
        
        function [cancel, slide] = enterMetadata(slide, suggestedSlideNumber, existingSlideNumbers, importPath, userName)
            %Call to SlideMetadataEntry GUI
            [cancel, stain, slideMaterial, slideNumber, aliquotDate, aliquotDoneBy, notes] = SlideMetadataEntry(suggestedSlideNumber, existingSlideNumbers, importPath, userName);
            
            if ~cancel
                %Assigning values to Slide Properties
                slide.stain = stain;
                slide.slideMaterial = slideMaterial;
                slide.slideNumber = slideNumber;
                slide.aliquotDate = aliquotDate;
                slide.aliquotDoneBy = aliquotDoneBy;
                slide.notes = notes;
            end
            
        end
        
        function slide = createDirectories(slide, toSamplePath, projectPath)
             
            slideDirectory = slide.generateDirName();
            
            createBackup = true;
            
            createObjectDirectories(projectPath, toSamplePath, slideDirectory, createBackup);
                        
            slide.dirName = slideDirectory;
        end
        
        function [] = saveMetadata(slide, toSlidePath, projectPath, saveToBackup)
            saveObjectMetadata(slide, projectPath, toSlidePath, SlideNamingConventions.METADATA_FILENAME, saveToBackup);            
        end
        
        function slide = wipeoutMetadataFields(slide)
            slide.dirName = '';
            slide.locations = [];
            slide.toPath = '';
            slide.toFilename = '';
        end
        
        function location = getSelectedLocation(slide)
            location = [];
            
            if slide.locationIndex ~= 0
                location = slide.locations{slide.locationIndex};
            end
        end
        
        function handles = updateNavigationListboxes(slide, handles)
            numLocations = length(slide.locations);
            
            if numLocations == 0
                disableNavigationListboxes(handles, handles.locationSelect);
            else            
                locationOptions = cell(numLocations, 1);
                
                for i=1:numLocations
                    locationOptions{i} = slide.locations{i}.naviListboxLabel;
                end
                
                set(handles.locationSelect, 'String', locationOptions, 'Value', slide.locationIndex, 'Enable', 'on');
                
                handles = slide.getSelectedLocation().updateNavigationListboxes(handles);
            end
        end
        
        
        function handles = updateMetadataFields(slide, handles)
            location = slide.getSelectedLocation();
                        
            if isempty(location)
                disableMetadataFields(handles, handles.locationMetadata);
            else
                metadataString = location.getMetadataString();
                
                set(handles.locationMetadata, 'String', metadataString);
                
                handles = location.updateMetadataFields(handles);
            end
        end
        
        function metadataString = getMetadataString(slide)
            
            stainString = ['Stain: ', slide.stain];
            slideMaterialString = ['Slide Material: ', slide.slideMaterial];
            slideNumberString = ['Slide Number; ', num2str(slide.slideNumber)];
            aliquotDoneByString = ['Aliquot Done By: ', slide.aliquotDoneBy];
            aliquotDateString = ['Aliquot Date: ', displayDate(slide.aliquotDate)];
            notesString = ['Notes: ', formatMultiLineTextForDisplay(slide.notes)];
            metadataHistoryStrings = generateMetadataHistoryStrings(slide.metadataHistory);
            
            metadataString = ['Slide:', slideNumberString, stainString, slideMaterialString, aliquotDoneByString, aliquotDateString, notesString];
            metadataString = [metadataString, metadataHistoryStrings];
        end
            
        function slide = updateLocationIndex(slide, index)
            slide.locationIndex = index;
        end
        
        function slide = updateSessionIndex(slide, index)
            location = slide.getSelectedLocation();
            
            location = location.updateSessionIndex(index);
            
            slide = slide.updateLocation(location);
        end
        
        function slide = updateSubfolderIndex(slide, index)
            location = slide.getSelectedLocation();
            
            location = location.updateSubfolderIndex(index);
            
            slide = slide.updateLocation(location);
        end
        
        function slide = updateFileIndex(slide, index)
            location = slide.getSelectedLocation();
            
            location = location.updateFileIndex(index);
            
            slide = slide.updateLocation(location);
        end
        
        
        function fileSelection = getSelectedFile(slide)
            location = slide.getSelectedLocation();
            
            if ~isempty(location)
                fileSelection = location.getSelectedFile();
            else
                fileSelection = [];
            end
        end
        
        function slide = incrementFileIndex(slide, increment)            
            location = slide.getSelectedLocation();
            
            location = location.incrementFileIndex(increment);
            
            slide = slide.updateLocation(location);
        end
        
        function coordsWithLabels = generateLocationCoordsWithLabels(slide, rejectSelectedLocation)
            locations = slide.locations;
            
            selectedLocation = slide.getSelectedLocation();
            
            coordsWithLabels = {};
            counter = 1;
            
            for i=1:length(locations)
                location = locations{i};
                
                if (~rejectSelectedLocation || location.locationNumber ~= selectedLocation.locationNumber) && (~isempty(location.locationCoords))
                    coordsWithLabels{counter} = struct('coords', location.locationCoords, 'label', num2str(location.locationNumber));
                    
                    counter = counter + 1;
                end
            end
        end
        
        function slide = importLegacyData(slide, toSlideProjectPath, legacyImportPaths, displayImportPath, localProjectPath, dataFilename, userName, subjectType, sampleType)
            filenameSection = slide.generateFilenameSection();
            dataFilename = [dataFilename, filenameSection];
            
            prompt = ['Select the location to which the data being imported from ', displayImportPath, ' belongs to.'];
            title = 'Select Location';
            choices = slide.getLocationChoices();
            
            [choice, cancel, createNew] = selectEntryOrCreateNew(prompt, title, choices);
            
            if ~cancel
                if createNew
                    suggestedLocationNumber = slide.nextLocationNumber();
                    
                    locationNumbers = slide.getLocationNumbers();
                    rejectSelectedLocation = false;
                    locationCoordsWithLabels = slide.generateLocationCoordsWithLabels(rejectSelectedLocation);
                    toFilename = slide.getFilename();
                    location = Location(suggestedLocationNumber, locationNumbers, locationCoordsWithLabels, toSlideProjectPath, localProjectPath, displayImportPath, userName, subjectType, sampleType, slide.slideType, toFilename);
                else
                    location = slide.getLocationFromChoice(choice);
                end
                
                if ~isempty(location)
                    toLocationProjectPath = makePath(toSlideProjectPath, location.dirName);
                                        
                    location = location.importLegacyData(toLocationProjectPath, legacyImportPaths, localProjectPath, dataFilename, userName, slide.locations);
                    
                    slide = slide.updateLocation(location);
                end
            end
        end
        
        function slide = editSelectedLocationMetadata(slide, projectPath, toSlidePath, userName, dataFilename, sampleType, subjectType)
            location = slide.getSelectedLocation();
            
            if ~isempty(location)
                existingLocationNumbers = slide.getLocationNumbers();
                filenameSection = slide.generateFilenameSection();
                dataFilename = [dataFilename, filenameSection];
                
                rejectSelectedLocation = true;
                locationCoordsWithLabels = slide.generateLocationCoordsWithLabels(rejectSelectedLocation);
                
                location = location.editMetadata(projectPath, toSlidePath, userName, dataFilename, existingLocationNumbers, locationCoordsWithLabels, sampleType, subjectType, slide.slideType);
            
                slide = slide.updateSelectedLocation(location);
            end
        end
        
        
        function slide = editSelectedSessionMetadata(slide, projectPath, toSlidePath, userName, dataFilename)
            location = slide.getSelectedLocation();
            
            if ~isempty(location)
                toLocationPath = makePath(toSlidePath, location.dirName);
                filenameSection = slide.generateFilenameSection();
                dataFilename = [dataFilename, filenameSection];
                
                location = location.editSelectedSessionMetadata(projectPath, toLocationPath, userName, dataFilename);
            
                slide = slide.updateSelectedLocation(location);
            end
        end
        
        function slide = createNewLocation(slide, projectPath, toPath, userName, subjectType, sampleType)
            suggestedLocationNumber = slide.nextLocationNumber();
            existingLocationNumbers = slide.getLocationNumbers();
            
            rejectSelectedLocation = false;
            locationCoordsWithLabels = slide.generateLocationCoordsWithLabels(rejectSelectedLocation);
            
            toSlidePath = makePath(toPath, slide.dirName);
            slideType = slide.slideType;
            
            importDir = '';
            
            location = Location(suggestedLocationNumber, existingLocationNumbers, locationCoordsWithLabels, toSlidePath, projectPath, importDir, userName, subjectType, sampleType, slideType, slide.getFilename());
            
            if ~isempty(location)
                slide = slide.updateLocation(location);
            end
        end
        
        function slide = createNewSession(slide, projectPath, toPath, userName, sessionType)
            location = slide.getSelectedLocation();
            
            if ~isempty(location)
                toPath = makePath(toPath, slide.dirName);
                
                locations = slide.locations;
                
                location = location.createNewSession(projectPath, toPath, userName, sessionType, locations);
                
                slide = slide.updateLocation(location);
            end
        end
        
        function filenameSections = getFilenameSections(slide, indices)
            if isempty(indices)
                filenameSections = slide.generateFilenameSection();
            else
                index = indices(1);
                
                location = slide.locations{index};
                
                if length(indices) == 1
                    indices = [];
                else
                    indices = indices(2:length(indices));
                end
                
                filenameSections = [slide.generateFilenameSection(), location.getFilenameSections(indices)];
            end
        end    
        
        function slide = applySelection(slide, indices, isSelected, additionalFields)
            index = indices(1);
            
            len = length(indices);
            
            selectedObject = slide.locations{index};
            
            if len > 1
                indices = indices(2:len);
                
                selectedObject = selectedObject.applySelection(indices, isSelected, additionalFields);
            else
                selectedObject.isSelected = isSelected;
                selectedObject.selectStructureFields = additionalFields;
            end           
            
            slide.locations{index} = selectedObject;
        end
        
        % ************************************************
        % FUNCTIONS FOR SENSITIVITY AND SPECIFICITY MODULE
        % ************************************************
        
        function [dataSheetOutput, rowIndex, locationRowIndices] = placeSensitivityAndSpecificityData(slide, dataSheetOutput, rowIndex)
            colHeaders = getExcelColHeaders();
            
            locations = slide.locations;
            
            locationRowIndices = [];
            rowCounter = 1;
            
            for i=1:length(locations)
                location = locations{i};
                
                if ~isempty(location.isSelected)                        
                    % write data
                    dataSheetOutput{rowIndex, 1} = location.uuid;
                    dataSheetOutput{rowIndex, 2} = location.getFilename();
                        
                    if location.isSelected
                        microscopeSession = location.getMicroscopeSession();
                        rowIndexString = num2str(rowIndex);
                        
                        % add row index
                        locationRowIndices(rowCounter) = rowIndex;
                        rowCounter = rowCounter + 1;
                        
                        % write data
                        dataSheetOutput{rowIndex, 3} = ' '; % no AD positive value to give
                        dataSheetOutput{rowIndex, 4} = convertBoolToExcelBool(microscopeSession.fluoroSignature);
                        dataSheetOutput{rowIndex, 5} = convertBoolToExcelBool(microscopeSession.crossedSignature);
                        dataSheetOutput{rowIndex, 6} = ['=INT(AND(',    colHeaders{4},rowIndexString,',',       colHeaders{5},rowIndexString,'))'];
                        dataSheetOutput{rowIndex, 7} = ['=INT(AND(NOT(',colHeaders{4},rowIndexString,'),',      colHeaders{5},rowIndexString,'))'];
                        dataSheetOutput{rowIndex, 8} = ['=INT(AND(',    colHeaders{4},rowIndexString,',NOT(',   colHeaders{5},rowIndexString,')))'];
                        dataSheetOutput{rowIndex, 9} = ['=INT(AND(NOT(',colHeaders{4},rowIndexString,'),NOT(',  colHeaders{5},rowIndexString,')))'];
                    else
                        reason = location.selectStructureFields.exclusionReason;
                        
                        if isempty(reason)
                            reason = SensitivityAndSpecificityConstants.NO_REASON_TAG;
                        end
                        dataSheetOutput{rowIndex, 3} = [SensitivityAndSpecificityConstants.NOT_RUN_TAG, reason];
                    end
                        
                    % increment row index
                    rowIndex = rowIndex + 1;
                end
            end
        end
        
         % ******************************************
        % FUNCTIONS FOR POLARIZATION ANALYSIS MODULE
        % ******************************************
        
        function [hasValidSession, selectStructureForSlide] = createSelectStructure(slide, indices, sessionClass)
            locations = slide.locations;
            
            selectStructureForSlide = {};
            hasValidSession = false;
            
            for i=1:length(locations)
                newIndices = [indices, i];
                
                [newHasValidLocation, selectStructureForLocation] = locations{i}.createSelectStructure(newIndices, sessionClass);
                
                if newHasValidLocation
                    selectStructureForSlide = [selectStructureForSlide, selectStructureForLocation];
                    
                    hasValidSession = true;
                end
            end
            
            if hasValidSession
                switch sessionClass
                    case class(PolarizationAnalysisSession)
                        selectionEntry = PolarizationAnalysisModuleSelectionEntry(slide.naviListboxLabel, indices);
                    case class(SubsectionStatisticsAnalysisSession)
                        selectionEntry = SubsectionStatisticsModuleSelectionEntry(slide.naviListboxLabel, indices);
                    case class(SensitivityAndSpecificityAnalysisSession)
                        selectionEntry = SensitivityAndSpecificityModuleSelectionEntry(slide.naviListboxLabel, indices, slide);
                end
                
                selectStructureForSlide = [{selectionEntry}, selectStructureForSlide];
            else
                selectStructureForSlide = {};
            end
            
        end
        
        
        function [isValidated, toPath] = validateSession(slide, indices, toPath)
            location = slide.locations{indices(1)};
            
            newIndices = indices(2:length(indices));
            toPath = makePath(toPath, slide.dirName);
            
            [isValidated, toPath] = location.validateSession(newIndices, toPath);
        end
        
        function [slide, selectStructure] = runPolarizationAnalysis(slide, indices, defaultSession, projectPath, progressDisplayHandle, selectStructure, selectStructureIndex, toPath, fileName)
            location = slide.locations{indices(1)};
            
            newIndices = indices(2:length(indices));
            toPath = makePath(toPath, slide.dirName);
            fileName = [fileName, slide.generateFilenameSection];
            
            [location, selectStructure] = location.runPolarizationAnalysis(newIndices, defaultSession, projectPath, progressDisplayHandle, selectStructure, selectStructureIndex, toPath, fileName);
            
            slide = slide.updateLocation(location);
        end
        
        function session = getSelectedSession(slide)
            location = slide.getSelectedLocation();
            
            if isempty(location)            
                session = [];
            else
                session = location.getSelectedSession();
            end
        end
        
         % ******************************************
        % FUNCTIONS FOR SUBSECTION STATISTICS MODULE
        % ******************************************
        
        function [data, locationString, sessionString] = getPolarizationAnalysisData(slide, subsectionSession, toIndices, toPath, fileName)
            location = slide.locations{toIndices(1)};
            
            toPath = makePath(toPath, slide.dirName);
            fileName = [fileName, slide.generateFilenameSection];
            
            [data, locationString, sessionString] = location.getPolarizationAnalysisData(subsectionSession, toPath, fileName);
        end
        
        function mask = getFluoroMask(slide, subsectionSession, toIndices, toPath, fileName)
            location = slide.locations{toIndices(1)};
            
            toPath = makePath(toPath, slide.dirName);
            fileName = [fileName, slide.generateFilenameSection];
            
            mask = location.getFluoroMask(subsectionSession, toPath, fileName);
        end
        
    end
    
end