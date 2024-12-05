function weight = getWeightTen(im_abnormal,patchDic,patchSize,edge)
kernel_norm = ones(patchSize,patchSize,3);
for i = 1:length(im_abnormal)
    im = double(im_abnormal{i});
    im_2 = im.*im;
    norm_patch = imfilter(im_2,kernel_norm,'corr',0,'same');
    norm_patch = sqrt(norm_patch(:,:,2));
    for j = 1:length(patchDic)
        weight_img = imfilter(im,patchDic{j},'corr',0,'same');
        weight_img = weight_img(:,:,2)./norm_patch;
        weight_ten(:,:,j) = abs(weight_img);
    end
    [weight(:,:,i),~] = max(weight_ten,[],3);
end
weight(isnan(weight)) = 0;

se = strel('disk',5,0);
edge_inner = imerode(edge,se);
for i = 1:size(weight,3)
    weight_i = weight(:,:,i);
    weight_i(edge_inner==0)=nan;
    max_a = max(weight_i(:));
    min_a = 0.95;
    weight_i = (weight_i-min_a)/(max_a-min_a);
    weight_i(isnan(weight_i))=1;
    weight_i(edge_inner==0)=1;
    weight(:,:,i) = weight_i;
end

end