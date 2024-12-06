% clear;
% clc;

path_ab = '.\abnormal_fundus_dir';
path_nor = '..\normal_fundus_dir';
ImgTensor_ab = fileloading(path_ab,2);
ImgTensor_ab = double(ImgTensor_ab);
% ImgTensor_ab = 255-ImgTensor_ab;
ten_sz_3 = size(ImgTensor_ab,3);
ImgTensor_nor = fileloading(path_nor,2);
ImgTensor_nor = double(ImgTensor_nor);

num_ab = size(ImgTensor_ab,3);
ImgTensor = cat(3,ImgTensor_ab,ImgTensor_nor);
% ImgTensor = ImgTensor_ab;

[ImgCell_ab,fileIndex] = fileloading3D(path_ab);
[ImgCell_nor,fileNormalIndex] = fileloading3D(path_nor);
ImgCell = [ImgCell_ab,ImgCell_nor];


%% Residual information
% RPCA decomposition parameters
p = 0.50;
alpha = 1;
lambda = 0.055;

% dictionary parameters
dicSize = 5;
gamma = 0.2;
tau = 2;
T1 = 0.9;

strDic = strcat('dictionary_50_',num2str(dicSize),'_gamma_',num2str(gamma),'.mat');
load(strDic);
Residual = getResidual(ImgCell_ab,dictionary,tau);
weight = getWeight(Residual,dictionary,1,0.9);
weight = cat(3,weight,ones(size(weight,1),size(weight,2),length(ImgCell_nor)));

%%
%%%%%%%%%%%% parameters %%%%%%%%%%%%%
mask = imread('mask.bmp');
mask_ten = repmat(mask,1,1,size(weight,3));
weight(mask_ten==0) = max(weight(:));

Algorithm_iterMax = 45;
residual_E_mu = 1e-3;

% parameters setting for MoGRPCA_inexact
RPCA_Param.p = p;
RPCA_Param.alpha = alpha;
RPCA_Param.lambda = lambda;
RPCA_Param.num_ab = num_ab;

RPCA_Param.Algorithm_iterMax = Algorithm_iterMax;
RPCA_Param.residual_E_mu = residual_E_mu;
%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
[lr_model, r] = Schatten(ImgTensor,RPCA_Param,weight);
Output_A = lr_model.A(:,:,1:ten_sz_3);
Output_E = lr_model.E(:,:,1:ten_sz_3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
