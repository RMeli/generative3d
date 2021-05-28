#!/bin/bash

. /root/miniconda3/etc/profile.d/conda.sh && conda activate myenv

export LIGAN_ROOT=/ligan/
export PYTHONPATH=${LIGAN_ROOT}:${PYTHONPATH}
export PYTHONPATH=${LIGAN_ROOT}/param_search/:${PYTHONPATH} # params.py

ROOT=/gen3d/recvae/
OUTDIR=${ROOT}/generated/

mkdir -p ${OUTDIR}

# Install MSO code within container
pip install ${LIGAN_ROOT}/mso-code

# Name of *.typse file without extension
# Used in PREFIX as well
SYSTEM="BRD4"

PREFIX="${SYSTEM}_mso_sa_vina_big"
OUTFILE="${OUTDIR}${PREFIX}_mso.out"
git -C ${LIGAN_ROOT} log | head -n 1 | 2>&1 tee ${OUTFILE}

RECEPTOR=${ROOT}/data/BRD4/pdb/BRD4.pdb

python ${LIGAN_ROOT}/MSO.py \
  --data_model_file ${ROOT}/models/data_48_0.5_batch10.model \
  --gen_model_file ${ROOT}/models/_vlr-le13_48_0.5_4_3lS_32_2_512_e.model \
  --gen_weights_file ${ROOT}/weights/lessskip_crossdocked_increased_1.lowrmsd.0_gen_iter_1000000.caffemodel \
  -r ${RECEPTOR} -l ${ROOT}/data/benzene_brd4.sdf \
  --n_swarms 5 --n_particles 50 --iterations 20 \
  --scores qed sa vina \
  --out_prefix ${OUTDIR}${PREFIX} \
  --gpu \
  2>&1 | tee -a ${OUTFILE}

gnina \
  -r ${RECEPTOR} -l ${OUTDIR}${PREFIX}_best_uff.sdf \
  --autobox_ligand ${OUTDIR}${PREFIX}_best_uff.sdf \
  --minimize --seed 42 \
  --cnn_scoring none \
  -o ${OUTDIR}${PREFIX}_GNINA_best.sdf \
  2>&1 | tee -a ${OUTDIR}${PREFIX}_GNINA_best.out

gnina \
  -r ${RECEPTOR} -l ${OUTDIR}${PREFIX}_history_uff.sdf \
  --autobox_ligand ${OUTDIR}${PREFIX}_history_uff.sdf \
  --minimize --seed 42 \
  --cnn_scoring none \
  -o ${OUTDIR}${PREFIX}_GNINA_history.sdf \
  2>&1 | tee -a ${OUTDIR}${PREFIX}_GNINA_history.out

for f in $(ls ${OUTDIR}/${PREFIX}*.gz)
do
    gzip -df ${f}
done

for f in $(ls ${OUTDIR}/${PREFIX}*)
do
    chmod a+x ${f}
done
