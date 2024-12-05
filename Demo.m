% clear;
% clc;

% path_ab = '..\EvaluationMethod\110\110\Kaggle+MessidorLesionAlignCutRemVesNormColorRGB';
path_ab = '..\EvaluationMethod\193\193\(436-422)RemVesVesRGB(193)changename';
path_nor = '..\imageNormal';
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

%% weight information

%% Residual information
result = cell(5,10);
for ii = 1:1
for jj = 1:1
if jj==0
    continue;
end
% RPCA decomposition parameters
p = 0.50+0.00*(jj-1);
% if ii==1
%     p = 1.08+0.01*(jj-1);
% end
alpha = 1;
lambda = 0.055+0.0*(jj-1);

% dictionary parameters
dicSize = 5;
if ii==2
    if jj==1
        dicSize = 3;
    elseif jj==2
        dicSize = 5;
    elseif jj==3
        dicSize = 9;
    elseif jj==4
        dicSize = 13;
    elseif jj==5
        dicSize = 19;
    end
end
gamma = 0.2;
tau = 2;
T1 = 0.9;
if ii==3
    T1 = 0.75+0.05*(jj-1);
end

strDic = strcat('dictionary_50_',num2str(dicSize),'_gamma_',num2str(gamma),'.mat');
load(strDic);
% Residual = getResidual_fixSum(ImgCell_ab,dictionary,tau);
Residual = getResidual(ImgCell_ab,dictionary,tau);
weight = getWeight(Residual,dictionary,1,0.9);
weight = cat(3,weight,ones(size(weight,1),size(weight,2),length(ImgCell_nor)));
% weight = ones(size(weight));

if ii==4
    weight(:,:,end-99:end)=[];
    ImgCell(end-99:end)=[];
    ImgCell_nor(end-99:end)=[];
    ImgTensor(:,:,end-99:end)=[];
end

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
path_groundtruth = '..\groundtruth\193_org_num';
[auc,pr,FPR,SE,PPv] = AUC_PR(path_groundtruth,Output_E);
disp(['p__',num2str(p),...
    '__lambda_',num2str(lambda),...
    '__dicSize_',num2str(dicSize),...
    '__gamma_',num2str(gamma),...
    '__tau_',num2str(tau),...
    '__T1_',num2str(T1),...
    '__normalImgNum_',num2str(size(ImgCell_nor,2)),...
    '__AUC__',num2str(auc),'__AP_',num2str(pr)]);
store = ['p__',num2str(p),...
    '__lambda_',num2str(lambda),...
    '__dicSize_',num2str(dicSize),...
    '__gamma_',num2str(gamma),...
    '__tau_',num2str(tau),...
    '__T1_',num2str(T1),...
    '__normalImgNum_',num2str(size(ImgCell_nor,2)),...
    '__AUC__',num2str(auc),'__AP_',num2str(pr)];
result{ii,jj} = store;
%%
% save([store,'.mat'],'Output_A','Output_E','FPR','SE','PPv');
% save([store,'.mat'],'FPR','SE','PPv');
end
end
