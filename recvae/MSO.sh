#!/bin/bash

SYSTEM="BRD4"
NSWARMS=5
NPARTICLES=100
NSTEPS=25
XLIM=3
VLIM=3
SF="cnn" # Scoring function

ROOT=${PWD}

if [ ${SYSTEM} == "BRD4" ]; then
  RECEPTOR=${ROOT}/data/BRD4/pdb/BRD4.pdb
elif [ ${SYSTEM} == "CDK2" ]; then
  RECEPTOR=${ROOT}/data/CDK2/data/4EK4.pdb
else
  echo "Unsupported system: ${SYSTEM}"
  exit
fi

if [ ${SF} == "cnn" ]; then
  CNNSCORE="rescore"
elif [ ${SF} == "vina" ]; then
  CNNSCORE="none"
else
  echo "Unsupported scoring function: ${SF}"
  exit
fi

# Output
OUTDIR="${ROOT}/generated"
PREFIX="${OUTDIR}/${SYSTEM}_mso_${SF}_ns${NSWARMS}_np${NPARTICLES}_it${NSTEPS}_xlim${XLIM}_vlim${VLIM}"
OUTFILE="${PREFIX}.out"

LIGAN_ROOT="${HOME}/Documents/git/ligan"

mkdir -p ${OUTDIR}

git -C ${LIGAN_ROOT} log | head -n 1 | 2>&1 tee ${OUTFILE}

# Install MSO code
pip install ${LIGAN_ROOT}/mso-code

#singularity run --nv --app python ${CONTAINER} \
time python ${LIGAN_ROOT}/MSO.py \
  --data_model_file ${ROOT}/models/data_48_0.5_batch10.model \
  --gen_model_file ${ROOT}/models/_vlr-le13_48_0.5_4_3lS_32_2_512_e.model \
  --gen_weights_file ${ROOT}/weights/lessskip_crossdocked_increased_1.lowrmsd.0_gen_iter_1000000.caffemodel \
  -r ${RECEPTOR} -l ${ROOT}/data/methyl_brd4.sdf \
  --n_swarms ${NSWARMS} --n_particles ${NPARTICLES} --iterations ${NSTEPS} \
  --v_min -${VLIM} --v_max ${VLIM} \
  --scores qed sa ${SF} \
  --out_prefix ${PREFIX} \
  --gpu \
  2>&1 | tee -a ${OUTFILE}

# Score best solution with GNINA
#singularity run --nv --app gnina ${CONTAINER} \
gnina \
  -r ${RECEPTOR} -l ${PREFIX}_best_uff.sdf \
  --autobox_ligand ${PREFIX}_best_uff.sdf \
  --minimize --seed 42 \
  --cnn_scoring ${CNNSCORE} \
  -o ${OUTDIR}${PREFIX}_GNINA_best.sdf \
  2>&1 | tee -a ${PREFIX}_GNINA_best.out

# Score history with GNINA
#singularity run --nv --app gnina ${CONTAINER} \
gnina \
  -r ${RECEPTOR} -l ${PREFIX}_history_uff.sdf \
  --autobox_ligand ${PREFIX}_history_uff.sdf \
  --minimize --seed 42 \
  --cnn_scoring ${CNNSCORE} \
  -o ${PREFIX}_GNINA_history.sdf \
  2>&1 | tee -a ${PREFIX}_GNINA_history.out

mv ${ROOT}/bad*.sdf ${ROOT}/bad*.pkl ${OUTDIR}
