#!/bin/bash

CONTAINER="/site/tl/home/lcolliandre/work/AI/3d-cnn/gnina/containers/Singularity/gnina.sif"
export LIGAN_ROOT="/site/tl/home/lcolliandre/work/AI/3d-cnn/ligan"

ROOT=${PWD}
OUTDIR="/site/tl/home/lcolliandre/work/AI/3d-cnn/generated-results/"
SITE="/site/"

mkdir -p ${OUTDIR}

OUTFILE=${OUTDIR}test.out

git -C ${LIGAN_ROOT} log | head -n 1 | 2>&1 tee ${OUTFILE}
#git --exec-path=${LIGAN_ROOT} log | head -n 1 | 2>&1 tee ${OUTFILE}

singularity run --nv -B ${SITE}:${SITE} --app python ${CONTAINER} \
    ${LIGAN_ROOT}/generate.py \
    --data_model_file ${ROOT}/models/data_48_0.5-nomolcache.model \
    --gen_model_file ${ROOT}/models/ae.model \
    --gen_weights_file ${ROOT}/weights/ae_disc_x_0.molportFULL_rand_.0.0_gen_iter_100000.caffemodel \
    --data_file ${ROOT}/data/gentest.types \
    --data_root ${ROOT}/data/ \
    -o ${OUTDIR} \
    --out_prefix ${OUTDIR}test \
    -b lig -b lig_gen \
    --fit_atoms \
    --dkoes_simple_fit --dkoes_make_mol \
    --output_sdf \
    --gpu \
    2>&1 | tee -a ${OUTFILE}
