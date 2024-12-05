function Im = fileloading(path,layer)
if nargin < 2
    layer = 2;
end
if ~exist(path,'dir')
    error(disp('Invalid file path'));
end
files = dir(path);
lengthFiles = length(files);
Im = [];
layerIndex = 0;
for index = 1:lengthFiles
    if strcmp(files(index).name,'.') || strcmp(files(index).name,'..')
        continue;
    end
    layerIndex = layerIndex + 1;
    filepath = strcat(path,'\',files(index).name);
    tempIm = imread(filepath);
%     tempIm = rgb2lab(tempIm);
    greenIm = tempIm(:,:,layer);
%     vecIm = greenIm(:);
%     validIm = vecIm(vecMask);
%     meanIm = mean(validIm);
%     greenIm(~mask) = meanIm;
    Im(:,:,layerIndex) = greenIm;
end


end