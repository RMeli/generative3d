#!/bin/bash

. /root/miniconda3/etc/profile.d/conda.sh && conda activate myenv

export LIGAN_ROOT=/ligan/
export PYTHONPATH=${LIGAN_ROOT}:${PYTHONPATH}
export PYTHONPATH=${LIGAN_ROOT}/param_search/:${PYTHONPATH} # params.py

ROOT=/gen3d/ligae/
OUTDIR=${ROOT}/generated/

mkdir -p ${OUTDIR}

OUTFILE=${OUTDIR}test.out

git -C ${LIGAN_ROOT} log | head -n 1 | 2>&1 tee ${OUTFILE}

python /ligan/generate.py \
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

for f in $(ls ${OUTDIR}*.gz)
do
    gzip -df ${f}
done

chmod a+rwx ${OUTDIR}*

