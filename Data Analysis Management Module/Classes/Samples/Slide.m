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
        
        %locations list and index
        locations
        locationIndex = 0;
        
        %for use with select structures
        isSelected = [];
        selectStructureFields = [];
    end
    
    methods
        function slide = Slide(suggestedSlideNumber, existingSlideNumbers, toSamplePath, projectPath, importDir, userName, toFilename)
            [cancel, slide] = slide.enterMetadata(suggestedSlideNumber, exisitingSlideNumbers, importDir, userName);
            
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
                slide.locations{i} = slide{i}.updateFileSelectionEntries(toPath);
            end
        end
        
        function slide = loadObject(slide)            
            % load locations            
            [objects, objectIndex] = loadObjects(slide, LocationNamingConventions.METADATA_FILENAME);
            
            slide.locations = objects;
            slide.locationIndex = objectIndex;
            
        end
        
        function slide = importSlide(slide, toSlideProjectPath, slideImportPath, projectPath, dataFilename, userName, subjectType, eyeType)
            dirList = getAllFolders(quarterImportPath);
            
            filenameSection = slide.generateFilenameSection();
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
                        
                        locationNumbers = quarter.getLocationNumbers();
                        rejectSelectedLocation = false;
                        locationCoordsWithLabels = quarter.generateLocationCoordsWithLabels(rejectSelectedLocation);
                        toFilename = quarter.getFilename();
                        
                        location = Location(suggestedLocationNumber, locationNumbers, locationCoordsWithLabels, toQuarterProjectPath, projectPath, locationImportPath, userName, subjectType, eyeType, quarter.quarterType, toFilename); 
                    else
                        location = quarter.getLocationFromChoice(choice);
                    end
                    
                    if ~isempty(location)
                        locationProjectPath = makePath(toQuarterProjectPath, location.dirName);
                        
                        location = location.importLocation(locationProjectPath, locationImportPath, projectPath, dataFilename, userName, quarter.locations);
                        
                        quarter = quarter.updateLocation(location);
                    end
                end
            end
        end
        
        
        
        
        
        
        
        
        
        
    end
    
end