#!/bin/bash

LIGAN_ROOT="${HOME}/Documents/git/ligan-EVOTEC"

ROOT=${PWD}
OUTDIR="${ROOT}/generated2"

mkdir -p ${OUTDIR}

SYSTEM="BRD4"
NSWARMS=5
NPARTICLES=100
NSTEPS=25
XLIM=3
VLIM=3
SF="cnn" # Scoring function

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

PREFIX="${OUTDIR}/${SYSTEM}_mso_${SF}_ns${NSWARMS}_np${NPARTICLES}_it${NSTEPS}_xlim${XLIM}_vlim${VLIM}"
OUTFILE="${PREFIX}.out"

# Install MSO code
pip install ${LIGAN_ROOT}/mso-code

for system in "BRD4" "CDK2"
do

    for vf in 1.0
    do

    PREFIX="${system}_vf${vf}_mso"

    OUTFILE=${OUTDIR}/${PREFIX}.out
    git -C ${LIGAN_ROOT} log | head -n 1 | 2>&1 tee ${OUTFILE}

    python \
        ${LIGAN_ROOT}/MSO.py \
        --data_model_file ${ROOT}/models/data_48_0.5-nomolcache.model \
        --gen_model_file ${ROOT}/models/gen_e_0.1_1.model \
        --gen_weights_file ${ROOT}/weights/gen_e_0.1_1_disc_x_10_0.molportFULL_rand_.0.0_gen_iter_100000.caffemodel \
        -r ${RECEPTOR} -l ${ROOT}/data/methyl_brd4.sdf \
        --n_swarms ${NSWARMS} --n_particles ${NPARTICLES} --iterations ${NSTEPS} \
        --v_min -${VLIM} --v_max ${VLIM} \
        --scores qed sa ${SF} \
        --out_prefix ${PREFIX} \
        --gpu \
        2>&1 | tee -a ${OUTFILE}

    mv bad* ${OUTDIR}

    done
done
