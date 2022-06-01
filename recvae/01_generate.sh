#!/bin/bash

CONTAINER="${HOME}/Documents/git/generative3d/dev/singularity/gnina.sif"
LIGAN_ROOT="${HOME}/Documents/git/ligan-EVOTEC"

ROOT=${PWD}
OUTDIR="${ROOT}/generated"

mkdir -p ${OUTDIR}

for SYSTEM in "BRD4"
do
    for vf in 1.0
    do
        PREFIX="${SYSTEM}_vf${vf}"

        OUTFILE=${OUTDIR}/${PREFIX}.out
        git -C ${LIGAN_ROOT} log | head -n 1 | 2>&1 tee ${OUTFILE}

        singularity run --nv --app python ${CONTAINER} \
            ${LIGAN_ROOT}/generate.py \
            --data_model_file ${ROOT}/models/data_48_0.5_batch10.model \
            --gen_model_file ${ROOT}/models/_vlr-le13_48_0.5_4_3lS_32_2_512_e.model \
            --gen_weights_file ${ROOT}/weights/lessskip_crossdocked_increased_1.lowrmsd.0_gen_iter_1000000.caffemodel \
            --data_file ${ROOT}/data/${SYSTEM}rec.types \
            --data_root ${ROOT}/data/ \
            -o ${OUTDIR} \
            --out_prefix ${OUTDIR}/${PREFIX} \
            --verbose 1 \
            --n_samples 1000 \
            --var_factor ${vf} \
            -b lig -b lig_gen \
            --fit_atoms \
            --dkoes_simple_fit --dkoes_make_mol \
            --output_sdf \
            --gpu \
            2>&1 | tee -a ${OUTFILE}

        mv bad* ${OUTDIR}
    done
done