classdef Quarter
    % Quarter 
    % stores information about about a quarter of a retina
    
    properties
        % set at initialization
        dirName
        naviListboxLabel
        metadataHistory
        
        % set by metadata entry        
        mountingDate
        mountingDoneBy        
        stain
        slideMaterial        
        quarterType % one of [S,T,I,N] (superior, temporal, inferior, nasal, unknown]
        quarterNumber %1, 2, 3, 4 (used for imaging)
        quarterArbitrary % False if which quarter is which is truly known, true otherwise (choosing S,T,I,N is arbitrary, but consistent)
        notes
        
        % locations list and index
        locations
        locationIndex = 0
    end
    
    methods
        function quarter = Quarter(suggestedQuarterNumber, existingQuarterNumbers, toEyePath, projectPath, importDir, userName)
            [cancel, quarter] = quarter.enterMetadata(suggestedQuarterNumber, existingQuarterNumbers, importDir, userName);
            
            if ~cancel
                % set metadata history
                quarter.metadataHistory = {MetadataHistoryEntry(userName)};
                
                % set navigation listbox label
                subtitle = quarter.quarterType.displayString;
                quarter.naviListboxLabel = createNavigationListboxLabel(QuarterNamingConventions.NAVI_LISTBOX_PREFIX, quarter.quarterNumber, subtitle);
                
                % make directory/metadata file
                quarter = quarter.createDirectories(toEyePath, projectPath);
                
                % save metadata
                saveToBackup = true;
                quarter.saveMetadata(makePath(toEyePath, quarter.dirName), projectPath, saveToBackup);
            else
                quarter = Quarter.empty;
            end              
        end
        
        function quarter = loadQuarter(quarter, toQuarterPath, quarterDir)
            quarterPath = makePath(toQuarterPath, quarterDir);
            
            % load metadata            
            vars = load(makePath(quarterPath, QuarterNamingConventions.METADATA_FILENAME), Constants.METADATA_VAR);
            quarter = vars.metadata;
            
            % load dirName            
            quarter.dirName = quarterDir;
            
            % load locations            
            locationsDirs = getMetadataFolders(quarterPath, LocationNamingConventions.METADATA_FILENAME);
            
            numLocations = length(locationsDirs);
            
            quarter.locations = createEmptyCellArray(Location.empty, numLocations);
                        
            for i=1:numLocations
                quarter.locations{i} = quarter.locations{i}.loadLocation(quarterPath, locationsDirs{i});
            end
            
            if ~isempty(quarter.locations)
                quarter.locationIndex = 1;
            end
        end
        
        function quarter = importQuarter(quarter, toQuarterProjectPath, quarterImportPath, projectPath, dataFilename, userName, subjectType, eyeType)
            dirList = getAllFolders(quarterImportPath);
            
            filenameSection = createFilenameSection(QuarterNamingConventions.DATA_FILENAME_LABEL, num2str(quarter.quarterNumber));
            dataFilename = [dataFilename, filenameSection];
            
            for i=1:length(dirList)
                folderName = dirList{i};
                
                locationImportPath = makePath(quarterImportPath, folderName);
                
                prompt = ['Select the location to which the data being imported from ', locationImportPath, ' belongs to.'];
                title = 'Select Location';
                choices = quarter.getLocationChoices();
                
                [choice, cancel, createNew] = selectEntryOrCreateNew(prompt, title, choices);
                
                if ~cancel
                    if createNew
                        suggestedLocationNumber = getNumberFromFolderName(folderName);
                        
                        if isnan(suggestedLocationNumber)
                            suggestedLocationNumber = quarter.nextLocationNumber();
                        end
                        
                        location = Location(suggestedLocationNumber, quarter.getLocationNumbers(), toQuarterProjectPath, projectPath, locationImportPath, userName, subjectType, eyeType, quarter.quarterType); 
                    else
                        location = quarter.getLocationFromChoice(choice);
                    end
                    
                    if ~isempty(location)
                        locationProjectPath = makePath(toQuarterProjectPath, location.dirName);
                        
                        location = location.importLocation(locationProjectPath, locationImportPath, projectPath, dataFilename, userName);
                        
                        quarter = quarter.updateLocation(location);
                    end
                end
            end
        end

        function location = getLocationFromChoice(quarter, choice)
            location = quarter.locations{choice};
        end
        
        function locationChoices = getLocationChoices(quarter)
            locations = quarter.locations;
            numLocations = length(locations);
            
            locationChoices = cell(numLocations, 1);
            
            for i=1:numLocations
                locationChoices{i} = locations{i}.naviListboxLabel;
            end
        end
        
        function quarter = updateLocation(quarter, location)
            locations = quarter.locations;
            numLocations = length(locations);
            updated = false;
            
            for i=1:numLocations
                if locations{i}.locationNumber == location.locationNumber
                    quarter.locations{i} = location;
                    updated = true;
                    break;
                end
            end
            
            if ~updated
                quarter.locations{numLocations + 1} = location;
                
                if quarter.locationIndex == 0
                    quarter.locationIndex = 1;
                end
            end   
        end
        
        function quarter = updateSelectedLocation(quarter, location)
            quarter.locations{quarter.locationIndex} = location;
        end
        
        function location = getLocationByNumber(quarter, number)
            locations = quarter.locations;
            
            location = Location.empty;
            
            for i=1:length(locations)
                if locations{i}.locationNumber == number
                    location = locations{i};
                    break;
                end
            end
        end
        
        function locationNumbers = getLocationNumbers(quarter)
            locations = quarter.locations;
            numLocations = length(locations);
            
            locationNumbers = zeros(numLocations, 1); % want this to be an matrix, not cell array
            
            for i=1:numLocations
                locationNumbers(i) = locations{i}.locationNumber;                
            end
        end    
        
        function nextNumber = nextLocationNumber(quarter)
            locationNumbers = quarter.getLocationNumbers();
            
            if isempty(locationNumbers)
                nextNumber = 1;
            else
                lastNumber = max(locationNumbers);
                nextNumber = lastNumber + 1;
            end
        end
        
        function [cancel, quarter] = enterMetadata(quarter, suggestedQuarterNumber, existingQuarterNumbers, importPath, userName)
            %Call to QuarterMetadataEntry GUI
            [cancel, stain, slideMaterial, quarterType, quarterArbitrary, quarterNumber, mountingDate, mountingDoneBy, notes] = QuarterMetadataEntry(suggestedQuarterNumber, existingQuarterNumbers, importPath, userName);
            
            if ~cancel
                %Assigning values to Quarter Properties
                quarter.stain = stain;
                quarter.slideMaterial = slideMaterial;
                quarter.quarterType = quarterType;
                quarter.quarterArbitrary = quarterArbitrary;
                quarter.quarterNumber = quarterNumber;
                quarter.mountingDate = mountingDate;
                quarter.mountingDoneBy = mountingDoneBy;
                quarter.notes = notes;
            end
            
        end
        
        function quarter = createDirectories(quarter, toEyePath, projectPath)
            dirSubtitle = quarter.quarterType.displayString;
            
            quarterDirectory = createDirName(QuarterNamingConventions.DIR_PREFIX, quarter.quarterNumber, dirSubtitle, QuarterNamingConventions.DIR_NUM_DIGITS);
            
            createObjectDirectories(projectPath, toEyePath, quarterDirectory);
                        
            quarter.dirName = quarterDirectory;
        end
        
        function [] = saveMetadata(quarter, toQuarterPath, projectPath, saveToBackup)
            saveObjectMetadata(quarter, projectPath, toQuarterPath, QuarterNamingConventions.METADATA_FILENAME, saveToBackup);            
        end
        
        function quarter = wipeoutMetadataFields(quarter)
            quarter.dirName = '';
            quarter.locations = [];
        end
        
        function location = getSelectedLocation(quarter)
            location = [];
            
            if quarter.locationIndex ~= 0
                location = quarter.locations{quarter.locationIndex};
            end
        end
        
        function handles = updateNavigationListboxes(quarter, handles)
            numLocations = length(quarter.locations);
            
            if numLocations == 0
                disableNavigationListboxes(handles, handles.locationSelect);
            else            
                locationOptions = cell(numLocations, 1);
                
                for i=1:numLocations
                    locationOptions{i} = quarter.locations{i}.naviListboxLabel;
                end
                
                set(handles.locationSelect, 'String', locationOptions, 'Value', quarter.locationIndex, 'Enable', 'on');
                
                handles = quarter.getSelectedLocation().updateNavigationListboxes(handles);
            end
        end
        
        function handles = updateMetadataFields(quarter, handles)
            location = quarter.getSelectedLocation();
                        
            if isempty(location)
                disableMetadataFields(handles, handles.locationMetadata);
            else
                metadataString = location.getMetadataString();
                
                set(handles.locationMetadata, 'String', metadataString);
                
                handles = location.updateMetadataFields(handles);
            end
        end
       
        function metadataString = getMetadataString(quarter)
            
            mountingDateString = ['Mounting Date: ', displayDate(quarter.mountingDate)];
            mountingDoneByString = ['Mounting Done By: ', quarter.mountingDoneBy];
            stainString = ['Stain: ', quarter.stain];
            slideMaterialString = ['Slide Material: ', quarter.slideMaterial];
            quarterTypeString = ['Quarter Type: ', quarter.quarterType.displayString];
            quarterNumberString = ['Quarter number: ', num2str(quarter.quarterNumber)];
            quarterArbitraryString = ['Quarter Arbitrary: ', booleanToString(quarter.quarterArbitrary)];
            quarterNotesString = ['Notes: ', quarter.notes];
            metadataHistoryStrings = generateMetadataHistoryStrings(quarter.metadataHistory);
            
            metadataString = {'Quarter:', mountingDateString, mountingDoneByString, stainString, slideMaterialString, quarterTypeString, quarterNumberString, quarterArbitraryString, quarterNotesString};
            metadataString = [metadataString, metadataHistoryStrings];
        end
        
        function quarter = updateLocationIndex(quarter, index)
            quarter.locationIndex = index;
        end
        
        function quarter = updateSessionIndex(quarter, index)
            location = quarter.getSelectedLocation();
            
            location = location.updateSessionIndex(index);
            
            quarter = quarter.updateLocation(location);
        end
        
        function quarter = updateSubfolderIndex(quarter, index)
            location = quarter.getSelectedLocation();
            
            location = location.updateSubfolderIndex(index);
            
            quarter = quarter.updateLocation(location);
        end
        
        function quarter = updateFileIndex(quarter, index)
            location = quarter.getSelectedLocation();
            
            location = location.updateFileIndex(index);
            
            quarter = quarter.updateLocation(location);
        end
        
        function fileSelection = getSelectedFile(quarter)
            location = quarter.getSelectedLocation();
            
            if ~isempty(location)
                fileSelection = location.getSelectedFile();
            else
                fileSelection = [];
            end
        end
        
        function quarter = incrementFileIndex(quarter, increment)            
            location = quarter.getSelectedLocation();
            
            location = location.incrementFileIndex(increment);
            
            quarter = quarter.updateLocation(location);
        end
        
        function quarter = importLegacyData(quarter, toQuarterProjectPath, legacyImportPaths, displayImportPath, localProjectPath, dataFilename, userName, subjectType, eyeType)
            filenameSection = createFilenameSection(QuarterNamingConventions.DATA_FILENAME_LABEL, num2str(quarter.quarterNumber));
            dataFilename = [dataFilename, filenameSection];
            
            prompt = ['Select the location to which the data being imported from ', displayImportPath, ' belongs to.'];
            title = 'Select Location';
            choices = quarter.getLocationChoices();
            
            [choice, cancel, createNew] = selectEntryOrCreateNew(prompt, title, choices);
            
            if ~cancel
                if createNew
                    suggestedLocationNumber = quarter.nextLocationNumber();
                    
                    location = Location(suggestedLocationNumber, quarter.getLocationNumbers(), toQuarterProjectPath, localProjectPath, displayImportPath, userName, subjectType, eyeType, quarter.quarterType);
                else
                    location = quarter.getLocationFromChoice(choice);
                end
                
                if ~isempty(location)
                    toLocationProjectPath = makePath(toQuarterProjectPath, location.dirName);
                    
                    location = location.importLegacyData(toLocationProjectPath, legacyImportPaths, localProjectPath, dataFilename, userName);
                    
                    quarter = quarter.updateLocation(location);
                end
            end
        end
        
        
        function quarter = editSelectedLocationMetadata(quarter, projectPath, toQuarterPath, userName)
            location = quarter.getSelectedLocation();
            
            if ~isempty(quarter)                
                location = location.editMetadata(projectPath, toQuarterPath, userName);
            
                quarter = quarter.updateSelectedLocation(location);
            end
        end
        
        function quarter = editSelectedSessionMetadata(quarter, projectPath, toQuarterPath, userName)
            location = quarter.getSelectedLocation();
            
            if ~isempty(quarter)
                toLocationPath = makePath(toQuarterPath, location.dirName);
                
                location = location.editSelectedSessionMetadata(projectPath, toLocationPath, userName);
            
                quarter = quarter.updateSelectedLocation(location);
            end
        end
        
    end
    
end

