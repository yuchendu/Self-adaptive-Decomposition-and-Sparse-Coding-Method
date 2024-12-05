function patchDic = getPatchDic(Dictionary,patchSize)
patchVolumn = patchSize*patchSize;

sumDic = sum(Dictionary);
Dictionary(:,sumDic==0)=[];

r = Dictionary(1:patchVolumn,:);
g = Dictionary(patchVolumn+1:patchVolumn*2,:);
b = Dictionary(patchVolumn*2+1:patchVolumn*3,:);
for i = 1:size(Dictionary,2)
    patch(:,:,1) = reshape(r(:,i),[patchSize,patchSize]);
    patch(:,:,2) = reshape(g(:,i),[patchSize,patchSize]);
    patch(:,:,3) = reshape(b(:,i),[patchSize,patchSize]);
    patchDic{i} = patch;
end
end