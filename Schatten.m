function [RPCA_model,residual]=Schatten(X,RPCA_param,W)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this file aims to build a matrix consists of tremendous amount of normal
% images and some of abnormal images. the lesion of ALL abnormal images 
% could be decomposed out at one time.
% before running this file, one should notice that the original input
% matrix has been centralized in advance. that means the single vectors of 
% svd represent the principle components.
% another property of this program is that once the mask exists, the masked
% components would be removed, thus, the dimension declined through this
% procedure.
% NOTICE: when one trys to recover the matrix, do not forget to add the
% mean value.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 1
    disp('input parameter required');
    return;
end

% transfer uint8 D to double D
X = double(X);

% remove the masked region, so that decline the dimension of rows
% try
%     subD = D(Mask_vec==1,:);
% catch ErrorInfo
%     disp(ErrorInfo);
%     disp(ErrorInfo.message);
% end


% parameter initialization
sz_X = size(X);
if nargin == 1
    RPCA_param.alpha = 1*0.8*sqrt(sz_X(1)*sz_X(2));
    RPCA_param.lambda = 1;
elseif nargin == 2
    RPCA_param.alpha = RPCA_param.alpha*sqrt(sz_X(1)*sz_X(2));
elseif nargin == 3
    RPCA_param.alpha = RPCA_param.alpha*sqrt(sz_X(1)*sz_X(2));
end

p = RPCA_param.p;

alpha = RPCA_param.alpha;
lambda = RPCA_param.lambda;
num_ab = RPCA_param.num_ab;

% MoG_param.pi_k = zeros(1,MoG_param.K);
% MoG_param.mu_k = zeros(1,MoG_param.K);
% MoG_param.sigma_2_k = zeros(1,MoG_param.K);
% MoG_param.kappa = zeros(sz_X(1),sz_X(2),sz_X(3),MoG_param.K);


% ALM initialization
D = double(tenmat(X,3)');
Y = D;% Y is the lagrangian operator
[U_init,S_init,V_init] = svd(Y,'econ');
SingularMax = S_init(1,1);
norm_inf = norm( Y(:), inf) / (lambda/alpha);
dual_norm = max(SingularMax, norm_inf);
Y = Y / dual_norm;

A = U_init(:,1)*S_init(1,1)*V_init(:,1)';% A is the low rank matrix
E = D - A;% E is the sparse matrix

nv_init = 5e3/SingularMax; % this one can be tuned, nv is the augment lagrangian operator
rho = 1.5;          % this one can be tuned

dnorm = norm(D, 'fro');

% transfer matrix to tensor
Y = matten(Y',sz_X,3);
A = matten(A',sz_X,3);
E = matten(E',sz_X,3);


% converge condition
Algorithm_iterMax = RPCA_param.Algorithm_iterMax;   
residual_E_mu = RPCA_param.residual_E_mu;


disp('*** Algorithm optimization started ***');
Algorithm_iter = 0;
Algorithm_converge = 0;
while ~Algorithm_converge
    tic;
    Algorithm_iter = Algorithm_iter+1;
    disp(['The ',num2str(Algorithm_iter),'th iteration has been starting']);
    
    % RPCA update
    disp(' * RPCA optimization started *');
    nv = min(nv_init, 1e6);
    % update A
    [U,S,V] = svd(double(tenmat(X-E+1/nv*Y,3)'),'econ');
    sigma = diag(S);
    Delta = schattenThreshold(sigma,p,alpha/nv);
%     Delta = diag(softThreshold(sigma,alpha/nv));
    A_new = U*Delta*V';
    A_new = double(matten(A_new',sz_X,3));
    
    % update E
    E_new = softThreshold(X(:,:,1:num_ab)-A_new(:,:,1:num_ab)+1/nv*Y(:,:,1:num_ab),lambda/nv*W(:,:,1:num_ab));
%     E_new = softThreshold(X(:,:,1:num_ab)-A_new(:,:,1:num_ab)+1/nv*Y(:,:,1:num_ab),lambda/nv);
    E_new = cat(3,E_new,zeros(sz_X(1),sz_X(2),sz_X(3)-num_ab));
    
    
    Y = Y + nv*(X-A_new-E_new);
    nv_init = rho*nv_init;
    
    % stop Criterion 
    error_recst = norm(tensor(X-A_new-E_new))/dnorm;
    error_converge = norm(tensor(A_new-A))/norm(tensor(A));
    
    residual = error_recst;
    
    t = toc;
    disp(['    reconstruction error: ',num2str(error_recst)]);
    disp(['    converge error: ',num2str(error_converge)]);
    disp(['  the ',num2str(Algorithm_iter),'th iteration finished, takes ',num2str(t)]);
    if error_recst<residual_E_mu...
            && error_converge<residual_E_mu
        disp('Algorithm has converged');
        RPCA_model.A = A_new;
        RPCA_model.E = E_new;
        RPCA_model.U = U;
        RPCA_model.S = Delta;
        RPCA_model.V = V;
        Algorithm_converge = true;
    else
        if Algorithm_iter >= Algorithm_iterMax
            disp('Maximum iteration time has reached');
            RPCA_model.A = A_new;
            RPCA_model.E = E_new;
            RPCA_model.U = U;
            RPCA_model.S = Delta;
            RPCA_model.V = V;
        	break;
        end
        A = A_new;E = E_new;
    end
end
end


function Delta = schattenThreshold(sigma,p,w)
% S_schattenThreshold[X] = argmin w*(X)^p + 1/2*(X-Y)^2
tau_p_w = (2.*w.*(1-p)).^(1/(2-p))+w.*p.*(2.*w.*(1-p)).^((p-1)/(2-p));
delta = abs(sigma);
for i = 1:20
    delta = abs(sigma)-w.*p.*(abs(delta)).^(p-1);
    if p==1
        break;
    end
end
Delta = sign(sigma).*delta;
Delta(abs(sigma)<tau_p_w) = 0;
%%%%%%%%%%%%%%%% PCA setting %%%%%%%%%%%%%%%%
% Delta(floor(length(Delta)*0.7):end) = 0;
Delta = diag(Delta);  
end

function S = softThreshold(Mat,nv)
% S_epsilon[X] = argmin mu*||X||_1 + 1/2*||X-Y||_fro2
% S_epsilon[X] = sgn(W) * max(|W|-mu,0)
MatThresh = abs(Mat)-nv;
MatThresh(MatThresh<0) = 0;
S = sign(Mat) .* MatThresh;
% rank
% diagS = diag(S);
% svp = length(find(diagS > 1/nv));
end