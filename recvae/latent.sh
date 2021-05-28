#!/bin/bash

# Output latent space vector for original ligands

. /root/miniconda3/etc/profile.d/conda.sh && conda activate myenv

export LIGAN_ROOT=/ligan/
export PYTHONPATH=${LIGAN_ROOT}:${PYTHONPATH}
export PYTHONPATH=${LIGAN_ROOT}/param_search/:${PYTHONPATH} # params.py

ROOT=/gen3d/recvae/
OUTDIR=${ROOT}/generated/

mkdir -p ${OUTDIR}

git -C ${LIGAN_ROOT} log | head -n 1 | 2>&1 tee ${OUTFILE}

PREFIX="BRD4_latent"
OUTFILE=${OUTDIR}${PREFIX}.out

python /ligan/generate.py \
    --data_model_file ${ROOT}/models/data_48_0.5_batch10.model \
    --gen_model_file ${ROOT}/models/_vlr-le13_48_0.5_4_3lS_32_2_512_e.model \
    --gen_weights_file ${ROOT}/weights/lessskip_crossdocked_increased_1.lowrmsd.0_gen_iter_1000000.caffemodel \
    --data_file ${ROOT}/data/BRD4.types \
    --data_root ${ROOT}/data/ \
    -o ${OUTDIR} \
    --out_prefix ${OUTDIR}${PREFIX} \
    --verbose 1 \
    --n_samples 1 \
    --var_factor 0.0 \
    -b lig -b lig_gen \
    --fit_atoms \
    --dkoes_simple_fit --dkoes_make_mol \
    --output_sdf \
    --output_dx \
    --output_latent \
    --gpu \
    2>&1 | tee -a ${OUTFILE}

for f in $(ls ${OUTDIR}/${PREFIX}*.gz)
do
    gzip -df ${f}
done

for f in $(ls ${OUTDIR}/${PREFIX}*)
do
   chmod a+rwx ${f}
done

