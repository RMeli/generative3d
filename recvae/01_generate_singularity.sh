#!/bin/bash

CONTAINER="/site/tl/home/lcolliandre/work/AI/3d-cnn/gnina/containers/Singularity/gnina.sif"
export LIGAN_ROOT="/site/tl/home/lcolliandre/work/AI/3d-cnn/ligan"

ROOT=${PWD}
OUTDIR="/site/tl/home/lcolliandre/work/AI/3d-cnn/generated-results/"
SITE="/site/"

mkdir -p ${OUTDIR}

OUTFILE=${OUTDIR}test.out

# Name of *.typse file without extension
# Used in PREFIX as well
SYSTEM="CDK2rec"

git -C ${LIGAN_ROOT} log | head -n 1 | 2>&1 tee ${OUTFILE}
#git --exec-path=${LIGAN_ROOT} log | head -n 1 | 2>&1 tee ${OUTFILE}

for vf in 1.0
do
    PREFIX="${SYSTEM}_vf${vf}"
    OUTFILE=${OUTDIR}${PREFIX}_generated.out
    git -C ${LIGAN_ROOT} log | head -n 1 | 2>&1 tee ${OUTFILE}

    singularity run --nv -B ${SITE}:${SITE} --app python ${CONTAINER} \
        ${LIGAN_ROOT}/generate.py \
        --data_model_file ${ROOT}/models/data_48_0.5_batch10_singularity.model \
        --gen_model_file ${ROOT}/models/_vlr-le13_48_0.5_4_3lS_32_2_512_e.model \
        --gen_weights_file ${ROOT}/weights/lessskip_crossdocked_increased_1.lowrmsd.0_gen_iter_1000000.caffemodel \
        --data_file ${ROOT}/data/${SYSTEM}.types \
        --data_root ${ROOT}/data/ \
        -o ${OUTDIR} \
        --out_prefix ${OUTDIR}${PREFIX} \
        --verbose 1 \
        --n_samples 10 \
        --var_factor ${vf} \
        -b lig -b lig_gen \
        --fit_atoms \
        --dkoes_simple_fit --dkoes_make_mol \
        --output_sdf \
        --output_dx \
        --gpu \
        2>&1 | tee -a ${OUTFILE}

    for f in $(ls ${OUTDIR}/${PREFIX}*.gz)
    do
        gzip -df ${f}
    done

    for f in $(ls ${OUTDIR}/${PREFIX}*)
    do
       chmod a+x ${f}
    done
done

