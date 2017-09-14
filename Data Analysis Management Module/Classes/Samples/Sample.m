classdef Sample
    %Sample
    
    properties
        % set at initialization
        uuid
        dirName
        naviListboxLabel
        metadataHistory
        
        projectPath = ''
        toPath = ''
        toFilename = ''
        
        
        sampleNumber
        notes = '';
        
        
        % for use with select structures
        isSelected = [];
        selectStructureFields = [];
    end
    
    methods(Static)
        
        function sample = createSample(sampleType, sampleNumber, existingSampleNumbers, subSampleNumber, existingSubSampleNumbers, toSubjectPath, projectPath, importPath, userName, toFilename)
            
            if sampleType == SampleTypes.Eye
                sample = Eye(...
                    sampleNumber,...
                    existingSampleNumbers,...
                    subSampleNumber,...
                    existingSubSampleNumbers,...
                    toSubjectPath,...
                    projectPath,...
                    importPath,...
                    userName,...
                    toFilename);
                
            elseif sampleType == SampleTypes.CsfSample
                sample = CsfSample(...
                    sampleNumber,...
                    existingSampleNumbers,...
                    subSampleNumber,...
                    existingSubSampleNumbers,...
                    toSubjectPath,...
                    projectPath,...
                    importPath,...
                    userName,...
                    toFilename);
                
            elseif sampleType == SampleTypes.BrainSection
                sample = BrainSection(...
                    sampleNumber,...
                    existingSampleNumbers,...
                    subSampleNumber,...
                    existingSubSampleNumbers,...
                    toSubjectPath,...
                    projectPath,...
                    importPath,...
                    userName,...
                    toFilename);
            elseif sampleType == SampleTypes.ArtificialSample
                sample = ArtificialSample();
                
            else
                error('Invalid Sample type!');
            end                
        end
        
    end
    
    methods
        
        function sample = createDirectories(sample, toSubjectPath, projectPath)
            sampleDirectory = sample.generateDirName();
            
            createBackup = true;
            
            createObjectDirectories(projectPath, toSubjectPath, sampleDirectory, createBackup);
                        
            sample.dirName = sampleDirectory;
        end
        
        function [] = saveMetadata(sample, toSamplePath, projectPath, saveToBackup)
            saveObjectMetadata(sample, projectPath, toSamplePath, SampleNamingConventions.METADATA_FILENAME, saveToBackup);            
        end
        
        function [sampleNumberString, notesString] = getSampleMetadataString(sample)
            sampleNumberString = ['Sample Number: ', num2str(sample.sampleNumber)];
            notesString = ['Notes: ', formatMultiLineTextForDisplay(sample.notes)];
        end
            
        function filename = getFilename(sample)
            filename = [sample.toFilename, sample.generateFilenameSection()];
        end
        
        function toPath = getToPath(sample)
            toPath = makePath(sample.toPath, sample.dirName);
        end
        
        function toPath = getFullPath(sample)
            toPath = makePath(sample.projectPath, sample.getToPath());
        end
        
        function sampleType = getSampleType(sample)
            classString = class(sample);
            
            if isa(SampleTypes.Eye.sessionClass, classString)
                sampleType = SampleTypes.Eye;
            elseif isa(SampleTypes.CsfSample.sessionClass, classString)
                sampleType = SampleTypes.CsfSample;
            elseif isa(SampleTypes.BrainSection.sessionClass, classString)
                sampleType = SampleTypes.BrainSection;
            else
                error('Unknown Sample Type');
            end
        end
        
    end
    
end

