function handles = updateImageAxes(handles, imageSelection)
% updateImageAxes
% updates the image axes with the provided image selection

imageData = [];

if ~isempty(imageSelection)
    imagePath = imageSelection.toPath;
    
    imageData = openFile(imagePath);
    
    %%%%%%%%%% ERIK EDIT %%%%%%%%%%    
    if handles.AutoContrast == 1
        try
            if isempty(strfind(imagePath,'Hist')) && isempty(strfind(imagePath,'Data'))
                imagePath_mat = [imagePath(1:find(imagePath=='(',1,'last')),'Data).mat'];
                load(imagePath_mat), data = data(3:end-2,3:end-2);
                figure,imshow(data,[]),colorbar, title( imagePath( find(imagePath=='(',1,'last'):find(imagePath==')',1,'last') ) )
            end
        end
    end
    %%%%%%%%%% ERIK EDIT %%%%%%%%%% 
end


% update image axes

%%%%%%%%%% ERIK EDIT %%%%%%%%%%
if handles.AutoContrast == 1                
    handles.image = imshow(imageData, [], 'Parent', handles.imageAxes);     
else                                        
    handles.image = imshow(imageData, 'Parent', handles.imageAxes);         % leave only this line if you wish to delete the edit by Erik
end
%%%%%%%%%% ERIK EDIT %%%%%%%%%%

end

