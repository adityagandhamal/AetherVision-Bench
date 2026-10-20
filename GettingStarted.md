# Getting Started with AetherVision-Bench

## Installation

Install the package and its dependencies:
```sh
pip install -e .
```

If you plan to evaluate detectron2-based models (as used in the paper), install detectron2 separately —
see [setup_env.sh](setup_env.sh) or https://detectron2.readthedocs.io/en/latest/tutorials/install.html.
`detectron2` is not required just to load the datasets.

## Prepare the datasets

See [DATASETS.md](DATASETS.md) for download links, licenses and expected directory layout. Once the raw
data is in place, run:
```sh
python -m aethervision.prepare_all_datasets --dataset_dir datasets
# check status with
python -m aethervision.prepare_all_datasets --dataset_dir datasets --stats
```

Export the dataset directory before evaluating:
```sh
export DETECTRON2_DATASETS=datasets
```

## Register the datasets

```python
import aethervision.datasets
```
This registers all 11 dataset/modality combinations (6 datasets, RGB + IR where available) to the
detectron2 `DatasetCatalog` (or the fallback catalog in `aethervision.utils.catalog` if detectron2 is not
installed).

Registered dataset names:
```
isprs_potsdam_sem_seg_test_rgb
isprs_potsdam_sem_seg_test_irrg
uavid_sem_seg_val
indraeye_sem_seg_test_rgb
indraeye_sem_seg_test_ir
cart_sem_seg_test_rgb
cart_sem_seg_test_ir
msrs_sem_seg_test_rgb
msrs_sem_seg_test_ir
mvseg_sem_seg_test_rgb
mvseg_sem_seg_test_ir
```
`indraeye_sem_seg_train_rgb` and `msrs_sem_seg_train_rgb` are also registered for the fine-tuning settings
below.

## Evaluation settings used in the paper

The paper evaluates four OVSS models (SAN, Zegformer, OVSeg, CAT-Seg, plus the `-L` (large) variants of
OVSeg and CAT-Seg) under three training regimes, each validated on all 6 benchmark datasets:

1. **COCO-Stuff-trained** — the standard zero-shot setting, using each model's official COCO-Stuff
   checkpoint.
2. **MSRS-trained** — fine-tuned on the ground-level MSRS training set (`msrs_sem_seg_train_rgb`).
3. **IndraEye-trained** — fine-tuned on the slant-angle IndraEye training set
   (`indraeye_sem_seg_train_rgb`).

Settings 2 and 3 introduce an additional challenge of limited training samples and test whether a model
fine-tuned on one viewpoint generalizes to the other two.

Run all three settings with [eval.sh](eval.sh). It is a template: copy it into your model's repository (where
`train_net.py`, configs and weights live), add `import aethervision.datasets` to `train_net.py`, and fill in
the `<...>` placeholders:
```sh
bash eval.sh
```

## Evaluating with your own model

For a custom detectron2-based model, an evaluation loop looks like:
```sh
export DETECTRON2_DATASETS=datasets
TEST_DATASETS="isprs_potsdam_sem_seg_test_rgb uavid_sem_seg_val indraeye_sem_seg_test_rgb indraeye_sem_seg_test_ir cart_sem_seg_test_rgb cart_sem_seg_test_ir msrs_sem_seg_test_rgb msrs_sem_seg_test_ir mvseg_sem_seg_test_rgb mvseg_sem_seg_test_ir"

for DATASET in $TEST_DATASETS
do
  python train_net.py --num-gpus 1 --eval-only --config-file <your_config>.yaml \
    DATASETS.TEST \(\"$DATASET\",\) MODEL.WEIGHTS <your_weights>.pth OUTPUT_DIR output/<model_name>/$DATASET
done

python aethervision/evaluation/aethervision_evaluation.py --model_outputs output/<model_name>
```

For code changes required to add a new model to the benchmark (registering datasets, swapping in the
evaluator), see [mess/GettingStarted.md](https://github.com/blumenstiel/MESS/blob/main/GettingStarted.md),
whose conventions this toolkit follows.

## Adding a new dataset

Use `aethervision/datasets/register_TEMPLATE.py` as a starting point, and add the corresponding
`prepare_datasets/prepare_<name>.py` script plus a section in [DATASETS.md](DATASETS.md).
