classdef SlideNamingConventions
    %SlideNamingConventions
    
    properties (Constant)
        DIR_PREFIX = 'SL';
        DIR_NUM_DIGITS = 2;
        
        NAVI_LISTBOX_PREFIX = 'Slide';
        
        METADATA_FILENAME = 'slide_metadata.mat';
        
        DATA_FILENAME_LABEL = 'SL';
        
        %Metadata Defaults
        DEFAULT_METADATA_GUI_STAIN = 'Unstained';
        DEFAULT_METADATA_GUI_SLIDE_MATERIAL = 'Glass';
    end
    
    
end