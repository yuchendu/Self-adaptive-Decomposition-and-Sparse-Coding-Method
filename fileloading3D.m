function [Im,files] = fileloading3D(path)
if nargin < 1
    error(disp('no input paremeter!'));
    return;
end
if ~exist(path,'dir')
    error(disp('Invalid file path'));
end
files = dir(path);
lengthFiles = length(files);
Im = [];
Index = 0;
for index = 1:lengthFiles
    if strcmp(files(index).name,'.') || strcmp(files(index).name,'..')
        continue;
    end
    Index = Index + 1;
    filepath = strcat(path,'\',files(index).name);
    tempIm = imread(filepath);
    Im{Index} = tempIm;
end
end