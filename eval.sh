#!/bin/bash
source ~/miniconda3/etc/profile.d/conda.sh
conda activate <env_name>

export DETECTRON2_DATASETS="datasets"
TEST_DATASETS="isprs_potsdam_sem_seg_test_rgb uavid_sem_seg_val indraeye_sem_seg_test_rgb indraeye_sem_seg_test_ir cart_sem_seg_test_rgb cart_sem_seg_test_ir msrs_sem_seg_test_rgb msrs_sem_seg_test_ir mvseg_sem_seg_test_rgb mvseg_sem_seg_test_ir"

# --- Setting 1: COCO-Stuff-trained (zero-shot) ---
for DATASET in $TEST_DATASETS
do
 python train_net.py --num-gpus 1 --eval-only --config-file configs/<coco_stuff_config>.yaml \
  DATASETS.TEST \(\"$DATASET\",\) MODEL.WEIGHTS weights/<model>_coco_stuff.pth \
  OUTPUT_DIR output/<model_name>_coco/$DATASET
done

# --- Setting 2: MSRS-trained (ground-level fine-tuning) ---
for DATASET in $TEST_DATASETS
do
 python train_net.py --num-gpus 1 --eval-only --config-file configs/<msrs_config>.yaml \
  DATASETS.TEST \(\"$DATASET\",\) MODEL.WEIGHTS weights/<model>_msrs.pth \
  OUTPUT_DIR output/<model_name>_msrs/$DATASET
done

# --- Setting 3: IndraEye-trained (slant-angle fine-tuning) ---
for DATASET in $TEST_DATASETS
do
 python train_net.py --num-gpus 1 --eval-only --config-file configs/<indraeye_config>.yaml \
  DATASETS.TEST \(\"$DATASET\",\) MODEL.WEIGHTS weights/<model>_indraeye.pth \
  OUTPUT_DIR output/<model_name>_indraeye/$DATASET
done

# Combine results
python aethervision/evaluation/aethervision_evaluation.py \
  --model_outputs output/<model_name>_coco output/<model_name>_msrs output/<model_name>_indraeye

# Run evaluation with:
# nohup bash eval.sh > eval.log &
# tail -f eval.log
