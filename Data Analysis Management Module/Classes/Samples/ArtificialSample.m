classdef ArtificialSample < Sample
    % ArtificialSample
    % metadata for a sample coming from an ArtificialSubject
    
    properties 
        sampleId
        preppedBy
        preppedDate
        
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
        
         function sample = editMetadata(sample, projectPath, toSubjectPath, userName, dataFilename, existingSampleNumbers, existingCsfSampleNumbers)
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
                
                %Assigning values to Csf Sample Properties
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
            dirSubtitle = ''; % No subtitle for Artificial sample
            
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
            sample.slideIndex = objectIndex;   
        end
        
        function sample = updateFileSelectionEntries(eye, toPath)
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
                        
                        slide = slide.importSlide(slideProjectPath, slideImportPath, projectPath, dataFilename, userName, subjectType);
                        
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
                
                if sample.slideIndex == 0
                    sample.slideIndex = 1;
                end
            end            
        end
        
        function sample = updateSelectedQuarter(sample, slide)
            sample.slides{sample.slideIndex} = slide;
        end
        
        function sample = updateSelectedLocation(sample, location)
            slide = sample.slides{sample.slideIndex};
            
            slide = slide.updateSelectedLocation(location);
                        
            sample.slides{sample.slideIndex} = slide;
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
        
        
        
        
        
    end%%
    
end

