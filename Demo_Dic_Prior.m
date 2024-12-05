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
maxAtomNum = 10;
proposedResidual = 1e-5;

%%
for num = 1:iterate
   [sparseX, residual] = OMP(data, Dictionary, maxAtomNum, proposedResidual);% max num of atom: 6, proposed residual: 5, gamma: 5.25 
   sparseX(isnan(sparseX)) = 0;
   [Dictionary, sparseX] = ksvd(data, sparseX, Dictionary);
end

%% transfer vector to image
patchSize = 9;
patchDic = getPatchDic(Dictionary,patchSize);

%%
% abnormal fundus image loading
im_abnormal_path = './RGB_abnormal';
im_abnormal = fileloading3D(im_abnormal_path);
edge = imread('mask_out.bmp');
weight = getWeightTen(im_abnormal,patchDic,patchSize,edge);

%%

a = weight(:,:,10);
% a(edge_inner==0)=nan;
% max_a = max(a(:));
% min_a = min(a(:));
% min_a = 0.95;
% a = (a-min_a)/(max_a-min_a);
% a(isnan(a))=1;
% a(edge_inner==0)=1;
imshow(a);

%%
a(a>0.6)=0;
a = a/0.6;
imshow(a);
