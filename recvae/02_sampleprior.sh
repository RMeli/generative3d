#!/bin/bash

. /root/miniconda3/etc/profile.d/conda.sh && conda activate myenv

export LIGAN_ROOT=/ligan/
export PYTHONPATH=${LIGAN_ROOT}:${PYTHONPATH}
export PYTHONPATH=${LIGAN_ROOT}/param_search/:${PYTHONPATH} # params.py

ROOT=/gen3d/recvae/
OUTDIR=${ROOT}/generated/

mkdir -p ${OUTDIR}

git -C ${LIGAN_ROOT} log | head -n 1 | 2>&1 tee ${OUTFILE}

for vf in 5.0 # 0.5 1.0
do

PREFIX="BRD4_vf${vf}_prior"

OUTFILE=${OUTDIR}${PREFIX}.out

python /ligan/generate.py \
    --data_model_file ${ROOT}/models/data_48_0.5_batch10.model \
    --gen_model_file ${ROOT}/models/_vlr-le13_48_0.5_4_3lS_32_2_512_e.model \
    --gen_weights_file ${ROOT}/weights/lessskip_crossdocked_increased_1.lowrmsd.0_gen_iter_1000000.caffemodel \
    --data_file ${ROOT}/data/BRD4prior.types \
    --data_root ${ROOT}/data/ \
    -o ${OUTDIR} \
    --out_prefix ${OUTDIR}${PREFIX} \
    --verbose 1 \
    --n_samples 1000 \
    --var_factor ${vf} \
    -b lig -b lig_gen \
    --fit_atoms \
    --dkoes_simple_fit --dkoes_make_mol \
    --gen_only \
    --prior \
    --output_sdf \
    --output_dx \
    --output_latent \
    --gpu \
    2>&1 | tee -a ${OUTFILE}

done

# Signle sample with no variance
vf=0.0
PREFIX="BRD4_vf${vf}_prior"
OUTFILE=${OUTDIR}${PREFIX}.out
python /ligan/generate.py \
    --data_model_file ${ROOT}/models/data_48_0.5_batch10.model \
    --gen_model_file ${ROOT}/models/_vlr-le13_48_0.5_4_3lS_32_2_512_e.model \
    --gen_weights_file ${ROOT}/weights/lessskip_crossdocked_increased_1.lowrmsd.0_gen_iter_1000000.caffemodel \
    --data_file ${ROOT}/data/BRD4prior.types \
    --data_root ${ROOT}/data/ \
    -o ${OUTDIR} \
    --out_prefix ${OUTDIR}${PREFIX} \
    --verbose 1 \
    --n_samples 1 \
    --var_factor ${vf} \
    -b lig -b lig_gen \
    --fit_atoms \
    --dkoes_simple_fit --dkoes_make_mol \
    --gen_only \
    --prior \
    --output_sdf \
    --output_dx \
    --output_latent \
    --gpu \
    2>&1 | tee -a ${OUTFILE}

for f in $(ls ${OUTDIR}*.gz)
do
    gzip -df ${f}
done

for f in $(ls ${OUTDIR})
do
   chmod a+rwx ${OUTDIR}/${f}
done

