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
        
    end
    
end