# Datasets for AetherVision-Bench

## Download datasets

All six datasets require a manual/requested download (see their sections below). For ISPRS Potsdam and
UAVid, the preparation scripts then unzip and tile the data; for the remaining four they only verify the layout.

- ISPRS Potsdam: https://www.isprs.org/resources/datasets/benchmarks/UrbanSemLab/default.aspx (Potsdam)
- UAVid: https://uavid.nl (Download -> Semantic Labelling with Images Only)
- IndraEye: https://github.com/airl-iisc/IndraEye (dataset and download links: https://bit.ly/indraeye)
- CART: https://data.caltech.edu/records/cks6g-ps927 (labeled subset), code at
  https://github.com/aerorobotics/caltech-aerial-rgbt-dataset
- MSRS: https://github.com/Linfeng-Tang/MSRS
- MVSeg: https://jiwei0921.github.io/Multispectral-Video-Semantic-Segmentation/, baseline code at
  https://github.com/jiwei0921/MVSS-Baseline

You can place the downloaded files in the project root or unzip them directly in your dataset directory.

## Install environment

`pip install -e .` installs the packages required for dataset preparation. If you plan to evaluate
detectron2-based models (as used in the paper), see [setup_env.sh](setup_env.sh) for a reference
environment; `detectron2` is not required just to load the datasets.

## Dataset download and preparation

```sh
python -m aethervision.prepare_all_datasets --dataset_dir datasets

# check the preparation with
python -m aethervision.prepare_all_datasets --dataset_dir datasets --stats
```

ISPRS Potsdam and UAVid are tiled into non-overlapping 1024x1024 patches automatically. IndraEye, CART,
MSRS and MVSeg must be downloaded/requested manually and placed in the layout described below; the
preparation scripts for these four only verify that the layout is correct.

If you are using another dataset directory than `datasets`, export it as `DETECTRON2_DATASETS` before
evaluating (see `eval.sh`).

## Dataset overview

Note the different licenses of the datasets, and please cite the corresponding papers if you use them —
BibTeX is provided in [datasets.bib](datasets.bib).

Datasets:
1. [ISPRS Potsdam](#isprs-potsdam) — bird's-eye view
2. [UAVid](#uavid) — slant-angle
3. [IndraEye](#indraeye) — slant-angle, RGB + IR
4. [CART](#cart) — slant-angle, RGB + IR
5. [MSRS](#msrs) — ground-level, RGB + IR
6. [MVSeg](#mvseg) — ground-level, RGB + IR

### Custom datasets

Use `aethervision/datasets/register_TEMPLATE.py` and `aethervision/prepare_datasets/prepare_TEMPLATE.py`
(mirroring MESS's templates) as a starting point for adding a new dataset.

### ISPRS Potsdam

Registered names: `isprs_potsdam_sem_seg_test_rgb` (RGB), `isprs_potsdam_sem_seg_test_irrg` (IRRG)

Dataset page: https://www.isprs.org/resources/datasets/benchmarks/UrbanSemLab/default.aspx

Dataset provider: BSF Swissphoto (2012). ISPRS Potsdam dataset within the ISPRS Test Project on Urban
Classification, 3D Building Reconstruction and Semantic Labeling.

Licence: undefined; citation required, notice of BSF Swissphoto as dataset provider (upon personal request
to the challenge organizers).

Download and prepare:
```sh
python -m aethervision.prepare_datasets.prepare_isprs_potsdam
```
The original tiles are 6000x6000; the script creates non-overlapping 1024x1024 patches with zero-padding
(ignored during evaluation) for both the RGB and IRRG orthophotos.

### UAVid

Registered name: `uavid_sem_seg_val`

Dataset page: https://uavid.nl

Paper: Lyu, Y., Vosselman, G., Xia, G. S., Yilmaz, A., & Yang, M. Y. (2020). UAVid: A semantic segmentation
dataset for UAV imagery. ISPRS Journal of Photogrammetry and Remote Sensing, 165, 108-119.

Licence: [CC BY-NC-SA 4.0](https://uavid.nl/). Citation (attribution) required, non-commercial use only.

Download the validation set from the website and place it in the project or dataset folder, then run:
```sh
python -m aethervision.prepare_datasets.prepare_uavid
```
The original tiles are large; the script creates non-overlapping 1024x1024 patches with zero-padding
(ignored during evaluation).

### IndraEye

Registered names: `indraeye_sem_seg_train_rgb`, `indraeye_sem_seg_test_rgb`, `indraeye_sem_seg_test_ir`

Dataset page: https://sites.google.com/view/indraeye, code and download links:
https://github.com/airl-iisc/IndraEye

Paper: Sikdar, A., Gurunath, P., Udupa, S., Sundaram, S. (2025). SAGA: Semantic-aware gray color
augmentation for visible-to-thermal domain adaptation across multi-view drone and ground-based vision
systems. arXiv:2504.15728.

Licence: see the dataset repository for current terms; citation required.

Download and place the dataset as:
```
datasets/indraeye/eo/train/images          datasets/indraeye/eo/train/annotations
datasets/indraeye/eo/test/images_original   datasets/indraeye/eo/test/annotations
datasets/indraeye/ir/test/images           datasets/indraeye/ir/test/annotations
```
Images are jpg, annotations are single-channel png with class indices (`ignore_label=255`). Then run:
```sh
python -m aethervision.prepare_datasets.prepare_indraeye
```

### CART

Registered names: `cart_sem_seg_test_rgb` (RGB), `cart_sem_seg_test_ir` (8-bit thermal)

Dataset page: https://data.caltech.edu/records/cks6g-ps927 (labeled subset), code at
https://github.com/aerorobotics/caltech-aerial-rgbt-dataset

Paper: Lee, C., Anderson, M., Ranganathan, N., Zuo, X., Do, K., Gkioxari, G., Chung, S. J. (2024). Caltech
aerial RGB-thermal dataset in the wild. ECCV 2024.

Licence: see the dataset page for current terms; citation required.

Download the labeled subset and place the held-out split as:
```
datasets/CART/val/color         datasets/CART/val/thermal8       datasets/CART/val/annotations
```
Then run:
```sh
python -m aethervision.prepare_datasets.prepare_cart
```

### MSRS

Registered names: `msrs_sem_seg_train_rgb`, `msrs_sem_seg_test_rgb`, `msrs_sem_seg_test_ir`

Dataset page: https://github.com/Linfeng-Tang/MSRS

Paper: Tang, L., Yuan, J., Zhang, H., Jiang, X., Ma, J. (2022). PIAFusion: A progressive infrared and
visible image fusion network based on illumination aware. Information Fusion, 83, 79-92.

Licence: see the dataset repository for current terms; citation required.

Download and place the dataset as:
```
datasets/msrs/images/{train,test}                  datasets/msrs/ir/test
datasets/msrs/annotations_detectron2/{train,test}
```
Images are png, annotations are single-channel png with class indices (`ignore_label=255`). Then run:
```sh
python -m aethervision.prepare_datasets.prepare_msrs
```

### MVSeg

Registered names: `mvseg_sem_seg_test_rgb`, `mvseg_sem_seg_test_ir`

Dataset page: https://jiwei0921.github.io/Multispectral-Video-Semantic-Segmentation/, baseline code at
https://github.com/jiwei0921/MVSS-Baseline

Paper: Ji, W., Li, J., Bian, C., Zhou, Z., Zhao, J., Yuille, A. L., Cheng, L. (2023). Multispectral video
semantic segmentation: A benchmark dataset and baseline. CVPR 2023.

Licence: see the dataset page for current terms; citation required.

Download and place the dataset as:
```
datasets/MVSeg/rgb/test/images (*v.jpg)   datasets/MVSeg/ir/test/images (*i.jpg)   datasets/MVSeg/rgb/test/labels (*l.png)
```
The RGB and IR frames of a co-registered pair share one label map. Then run:
```sh
python -m aethervision.prepare_datasets.prepare_mvseg
```
