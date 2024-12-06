clear;
clc;

% normal fundus image loading
im_normal_path = './RGB_normal';
im_normal = fileloading3D(im_normal_path);

% 3D patch extraction
patchSize = 5;
data = [];
for i = 1:length(im_normal)
    im = double(im_normal{i});
    r = im2col(im(:,:,1),[patchSize,patchSize],'sliding');
    g = im2col(im(:,:,2),[patchSize,patchSize],'sliding');
    b = im2col(im(:,:,3),[patchSize,patchSize],'sliding');
    tempData = [r;g;b];
    data = [data,tempData];
end
data = data(:,randperm(size(data,2),2e4));

% normalization
for i = 1:size(data,2)
    norm_i = norm(data(:,i));
    if norm_i==0
        continue;
    end
    data(:,i) = data(:,i)/norm_i;
end

% SR training
dictionarySize = 50;
Dictionary = data(:,randperm(size(data,2),dictionarySize));

iterate = 100;
maxAtomNum = 6;
proposedResidual = 1e-5;
gamma = 0.2;

%%
for num = 1:iterate
   [sparseX, residual] = OMP(data, Dictionary, maxAtomNum, proposedResidual, gamma);
   sparseX(isnan(sparseX)) = 0;
   [Dictionary, sparseX] = ksvd(data, sparseX, Dictionary);
end

%% save dictionary
save(['dictionary_',num2str(dictionarySize),'_',num2str(patchSize),'_gamma_',num2str(gamma),'.mat']);

