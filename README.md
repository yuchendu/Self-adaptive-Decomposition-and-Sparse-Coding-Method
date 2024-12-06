# Self-adaptive Decomposition & Sparse Coding Method
This repository contains the description and the codes for the paper "Anomaly detection in fundus images by self-adaptive decomposition via local and color based sparse coding".
## Abstract
Anomaly detection in color fundus images is challenging due to the diversity of anomalies. The current studies detect anomalies from fundus images by learning their background images, however, ignoring the affluent characteristics of anomalies. In this paper, we propose a simultaneous modeling strategy in both sequential sparsity and local and color saliency property of anomalies are utilized for the multi-perspective anomaly modeling. In the meanwhile, the Schatten p-norm based metric is employed to better learn the heterogeneous background images, from where the anomalies are better discerned. Experiments and comparisons demonstrate the outperforming and effectiveness of the proposed method.
## Methodology
Two steps are enrolled in the proposed method. First, a dictionary is trained from color patches of normal fundus images. And a silency map is generated via sparse coding of a testing fundus image by this dictionary in an non-local manner. Second, the silency maps are acted as the weights of low-rank decomposition of test fundus images. Abnormalities could be detected with respect to the their color silency and the contextual silency from the image domain, as well as the sparsity property from the sequential domain.

![The flowchart of the proposed method](https://github.com/yuchendu/Self-adaptive-Decomposition-and-Sparse-Coding-Method/blob/main/assets/images/flowchart.jpg)

## Result
Here we illustrate the weight silency maps generated under different dictionaries conducted via different sizes of patches. The results are shown below:

![The silency maps](https://github.com/yuchendu/Self-adaptive-Decomposition-and-Sparse-Coding-Method/blob/main/assets/images/patchsize.jpg)

## Advantages and Limitations
The primary advantage of this study lies in the use of weights (saliency maps) to refine the decomposition of diverse lesions. These weights, which incorporate the color and contextual saliency of lesions, effectively compensate for the information loss that occurs with solo low-rank decomposition of a single channel. However, there are also some limitations. First, while the method compensates for the shortcomings of low-rank decomposition by addressing the inability to directly perform low-rank decomposition on multi-channel images, it does not resolve this issue at the foundational level of the decomposition method. Second, the method involves several steps, making it somewhat complex. Third, it requires the healthy images to exhibit a highly low-rank property.
