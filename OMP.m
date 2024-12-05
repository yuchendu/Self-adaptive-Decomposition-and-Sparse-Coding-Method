function [matr_coef, posAt, resid] = OMP(label, codebook, numValidAtom, proposedResidual, gamma)
% this function calculates the result of the K-SVD algorithm
% input: label Matrix, codebook, proposed iterate time, proposed stop
% condition related to residual, gamma
% output: coefficient Matrix, residual

[~, col] = size(label);
[rowDic, colDic] = size(codebook);
residual = label;
matr_coef = zeros(colDic, col);

n = fix(rowDic/3);
I = eye(rowDic);
Jn = ones(n);
In = zeros(n);
K = [Jn In In; In Jn In; In In Jn];
C = sqrt(rowDic);
posAt = zeros(numValidAtom,col);
resid = zeros(col,1);

if nargin == 3
    for j = 1:col
        
        At = zeros(rowDic, numValidAtom);% store the choosed column in D
        
        for i = 1:numValidAtom
            product = codebook' * residual(:, j);
            [~, pos] = max(abs(product));
            At(:, i) = codebook(:, pos);
            posAt(i,j) = pos;
            coefficient = (At(:,1:i)' * At(:,1:i))^(-1) * At(:,1:i)' * label(:,j); 
            projectionVec = At(:,1:i) * coefficient; 
            residual(:,j) = label(:,j) - projectionVec;
            resid(j) = norm(residual(:,j));
        end
        matr_coef(posAt(:,j),j) = coefficient;
    end
    
elseif nargin == 4
    for j = 1:col
         
        At = zeros(rowDic, numValidAtom);
         
        for i = 1:numValidAtom
            product = codebook' * (I+gamma/n*K) * residual(:, j);
            [~, pos] = max(abs(product));
            At(:, i) = codebook(:, pos);
            posAt(i,j) = pos;
            coefficient = (At(:,1:i)' * At(:,1:i))^(-1) * At(:,1:i)' * label(:,j); 
            projectionVec = At(:,1:i) * coefficient; 
            residual(:,j) = label(:,j) - projectionVec;
            resid(j) = norm(residual(:,j));
            if norm(residual(:,j)) <= (C * proposedResidual)
                break;
            end
        end
        if ~all(posAt(:,j))
            continue;
        end
        matr_coef(posAt(:,j),j) = coefficient;
     end

elseif nargin == 5
    
     for j = 1:col
         
        At = zeros(rowDic, numValidAtom);
         
        for i = 1:numValidAtom
            product = codebook' * (I + gamma/n * K)  * residual(:, j);
            [~, pos] = max(abs(product));
            At(:, i) = codebook(:, pos);
            posAt(i,j) = pos;
            coefficient = (At(:,1:i)' * At(:,1:i))^(-1) * At(:,1:i)' * label(:,j); 
            projectionVec = At(:,1:i) * coefficient; 
            residual(:,j) = label(:,j) - projectionVec;
            resid(j) = norm(residual(:,j));
            if norm(residual(:,j)) <= (C * proposedResidual)
                break;
            end
        end
        if ~all(posAt(:,j))
            continue;
        end
        matr_coef(posAt(:,j),j) = coefficient;
    end

end

end