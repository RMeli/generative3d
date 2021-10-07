#!/bin/bash

CONTAINER=gnina:commit

ROOT=/gen3d/ligvae

HDIR=/local/scratch/rmeli
PATHgen3d=${HDIR}/Documents/git/evotec/generative3d/
PATHligan=${HDIR}/Documents/git/evotec/liGAN/

docker run --gpus device=0 -v ${PATHligan}:/ligan -v ${PATHgen3d}:/gen3d ${CONTAINER} ${ROOT}/01_generate.sh
#docker run --gpus device=2 -v ${PATHligan}:/ligan -v ${PATHgen3d}:/gen3d ${CONTAINER} ${ROOT}/01_generate-bigsample.sh
#docker run --gpus device=1 -v ${PATHligan}:/ligan -v ${PATHgen3d}:/gen3d ${CONTAINER} ${ROOT}/02_priorsampling.sh
#docker run --gpus device=1 -v ${PATHligan}:/ligan -v ${PATHgen3d}:/gen3d ${CONTAINER} ${ROOT}/03_interpolate.sh
#docker run --gpus device=0 -v ${PATHligan}:/ligan -v ${PATHgen3d}:/gen3d ${CONTAINER} ${ROOT}/04_MSO.sh
#docker run --gpus device=1 -v ${PATHligan}:/ligan -v ${PATHgen3d}:/gen3d ${CONTAINER} ${ROOT}/04_MSO_BRD4.sh


#docker run --gpus device=2 -v ${PATHligan}:/ligan -v ${PATHgen3d}:/gen3d ${CONTAINER} ${ROOT}/fix.sh

