#!/bin/bash

CONTAINER="${HOME}/Documents/git/generative3d/dev/singularity/ligan.sif"
LIGAN_ROOT="${HOME}/Documents/git/ligan"

ROOT=${PWD}
OUTDIR="${ROOT}/generated"

mkdir -p ${OUTDIR}

git -C ${LIGAN_ROOT} log | head -n 1 | 2>&1 tee ${OUTFILE}

singularity run --nv --app python ${CONTAINER} \
    ${LIGAN_ROOT}/generate.py \
    --data_model_file ${ROOT}/models/data_48_0.5-nomolcache.model \
    --gen_model_file ${ROOT}/models/ae.model \
    --gen_weights_file ${ROOT}/weights/ae_disc_x_0.molportFULL_rand_.0.0_gen_iter_100000.caffemodel \
    --data_file ${ROOT}/data/gentest.types \
    --data_root ${ROOT}/data/ \
    -o ${OUTDIR} \
    --out_prefix ${OUTDIR}/test \
    -b lig -b lig_gen \
    --n_samples 1 \
    --fit_atoms \
    --dkoes_simple_fit --dkoes_make_mol \
    --output_sdf \
    --gpu \
    2>&1 | tee -a ${OUTDIR}/test.out
