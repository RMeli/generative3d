#!/bin/bash

CONTAINER="${HOME}/Documents/git/generative3d/dev/singularity/gnina.sif"
LIGAN_ROOT="${HOME}/Documents/git/ligan-EVOTEC"

ROOT=${PWD}
OUTDIR="${ROOT}/generated"

mkdir -p ${OUTDIR}

PREFIX="test_vf1.0"

OUTFILE=${OUTDIR}/${PREFIX}.out
git -C ${LIGAN_ROOT} log | head -n 1 | 2>&1 tee ${OUTFILE}

singularity run --nv --app python ${CONTAINER} \
    ${LIGAN_ROOT}/generate.py \
    --data_model_file ${ROOT}/models/data_48_0.5-bs1-nomolcache.model \
    --gen_model_file ${ROOT}/models/gen_e_0.1_1-bs1.model \
    --gen_weights_file ${ROOT}/weights/gen_e_0.1_1_disc_x_10_0.molportFULL_rand_.0.0_gen_iter_100000.caffemodel \
    --data_file ${ROOT}/data/gentest.types \
    --data_root ${ROOT}/data/ \
    --out_prefix ${OUTDIR}/${PREFIX} \
    --verbose 0 \
    --n_samples 5 \
    --var_factor 1.0 \
    -b lig -b lig_gen \
    --fit_atoms \
    --dkoes_simple_fit --dkoes_make_mol \
    --output_sdf \
    --gpu \
    2>&1 | tee -a ${OUTFILE}

mv bad* ${OUTDIR}
