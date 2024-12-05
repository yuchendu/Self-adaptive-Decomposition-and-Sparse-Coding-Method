function [codebookNew, coefficientNew] = ksvd(data, coefficient, codebook,gamma)
% this function aims to regenerate the codebook using K-SVD algorithm
% input: data, sparse representation coefficient, codebook
% output: new codebook, new sparse representation coefficient

[rowData, colData] = size(data);
[rowDic, colDic] = size(codebook);
X = coefficient;
D = codebook;


for k = 1:colDic
    posChoice = [];
    E(:,:) = data - D * X + D(:,k) * X(k,:);
    for count = 1:colData
        if X(k,count) ~= 0
            posChoice = [posChoice count];
        end
    end
    if isempty(posChoice)
        continue;
    end
    Er = E(:,posChoice);
    Er(isnan(Er)) = 0;
    Er(isinf(Er)) = 0;
    [U,S,V] = svd(Er);
    D(:,k) = U(:,1);
    X(k,posChoice) = S(1,1) .* V(:,1)';
end
codebookNew = D;
coefficientNew = X;

end