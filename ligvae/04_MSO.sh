#!/bin/bash

. /root/miniconda3/etc/profile.d/conda.sh && conda activate myenv

export LIGAN_ROOT=/ligan/
export PYTHONPATH=${LIGAN_ROOT}:${PYTHONPATH}
export PYTHONPATH=${LIGAN_ROOT}/param_search/:${PYTHONPATH} # params.py

ROOT=/gen3d/ligvae/
OUTDIR=${ROOT}/generated/

mkdir -p ${OUTDIR}

# Install MSO code within container
pip install ${LIGAN_ROOT}/mso-code

# Name of *.typse file without extension
# Used in PREFIX as well
SYSTEM="CDK2"

PREFIX="${SYSTEM}_mso"
OUTFILE="${OUTDIR}${PREFIX}_mso.out"
git -C ${LIGAN_ROOT} log | head -n 1 | 2>&1 tee ${OUTFILE}

python /ligan/MSO.py \
  --data_model_file ${ROOT}/models/data_48_0.5-nomolcache.model \
  --gen_model_file ${ROOT}/models/gen_e_0.1_1.model \
  --gen_weights_file ${ROOT}/weights/gen_e_0.1_1_disc_x_10_0.molportFULL_rand_.0.0_gen_iter_100000.caffemodel \
  -r ${ROOT}/data/CDK2/data/4EK4.pdb -l ${ROOT}/data/CDK2/data/4ek4_B_1CK_min.sdf \
  --n_swarms 1 --n_particles 100 --iterations 25 \
  --scores qed sa \
  --out_prefix ${OUTDIR}${PREFIX} \
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
