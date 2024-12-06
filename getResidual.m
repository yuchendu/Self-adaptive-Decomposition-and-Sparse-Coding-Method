function Residual = getResidual(im_tensor,Dictionary,numAtoms)
kernel_norm = ones(1,1,3);
codebook = Dictionary;
dicSize = fix(sqrt(size(codebook,1)/3));
sumDic = sum(codebook);
codebook(:,sumDic==0) = [];
for i = 1:length(im_tensor)
    im = double(im_tensor{i});
    p_r = im2col(im(:,:,1),[dicSize,dicSize],'distinct');
    p_g = im2col(im(:,:,2),[dicSize,dicSize],'distinct');
    p_b = im2col(im(:,:,3),[dicSize,dicSize],'distinct');
    p = [p_r;p_g;p_b];
    
    [coef,~,~] = OMP(p,codebook,numAtoms,1,1);
    Resid = abs(codebook*coef-p);
    resid_r = Resid(1:size(p_r,1),:);
    resid_g = Resid(size(p_r,1)+1:2*size(p_r,1),:);
    resid_b = Resid(2*size(p_r,1)+1:end,:);
    
    ResiMat_r = col2im(resid_r,[dicSize,dicSize],size(im(:,:,1)),'distinct');
    ResiMat_g = col2im(resid_g,[dicSize,dicSize],size(im(:,:,1)),'distinct');
    ResiMat_b = col2im(resid_b,[dicSize,dicSize],size(im(:,:,1)),'distinct');
    
    ResiMat = cat(3,ResiMat_r,ResiMat_g,ResiMat_b);
    ResiMat_2 = ResiMat.*ResiMat;
    Resi_temp = sqrt(imfilter(ResiMat_2,kernel_norm,'corr',0,'same'));
    Residual(:,:,i) = sqrt(Resi_temp(:,:,2));
    
%     [coef,~,~] = OMP(p_g,codebook(dicSize*dicSize+1:2*dicSize*dicSize,:),numAtoms);
%     Resid = abs(codebook(dicSize*dicSize+1:2*dicSize*dicSize,:)*coef-p_g);
%     
%     ResiMat = col2im(Resid,[dicSize,dicSize],size(im(:,:,1)),'distinct');
%     
%     Residual(:,:,i) = ResiMat;
end

end