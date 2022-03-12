#!/bin/bash

CONTAINER="${HOME}/Documents/git/generative3d/dev/singularity/gnina.sif"
LIGAN_ROOT="${HOME}/Documents/git/ligan"

ROOT=${PWD}
OUTDIR="${ROOT}/generated"

mkdir -p ${OUTDIR}

for system in "BRD4" "CDK2"
do

    for vf in 1.0
    do

    PREFIX="${system}_vf${vf}_prior"

    OUTFILE=${OUTDIR}/${PREFIX}prior.out
    git -C ${LIGAN_ROOT} log | head -n 1 | 2>&1 tee ${OUTFILE}

    singularity run --nv --app python ${CONTAINER} \
        ${LIGAN_ROOT}/generate.py \
        --data_model_file ${ROOT}/models/data_48_0.5-nomolcache.model \
        --gen_model_file ${ROOT}/models/gen_e_0.1_1.model \
        --gen_weights_file ${ROOT}/weights/gen_e_0.1_1_disc_x_10_0.molportFULL_rand_.0.0_gen_iter_100000.caffemodel \
        --data_file ${ROOT}/data/${system}prior.types \
        --data_root ${ROOT}/data/ \
        --out_prefix ${OUTDIR}/${PREFIX} \
        --verbose 1 \
        --n_samples 1000 \
        --var_factor ${vf} \
        -b lig -b lig_gen \
        --fit_atoms \
        --dkoes_simple_fit --dkoes_make_mol \
        --output_sdf \
        --gpu \
        --prior \
        2>&1 | tee -a ${OUTFILE}

    mv bad* ${OUTDIR}

    done
done
