#!/bin/bash

CONTAINER=gnina:commit

ROOT=/gen3d/recvae

HDIR=/local/scratch/rmeli
PATHgen3d=${HDIR}/Documents/git/evotec/generative3d/
PATHligan=${HDIR}/Documents/git/evotec/liGAN/

#docker run --gpus device=0 -v ${PATHligan}:/ligan -v ${PATHgen3d}:/gen3d ${CONTAINER} ${ROOT}/01_generate.sh
#docker run --gpus device=2 -v ${PATHligan}:/ligan -v ${PATHgen3d}:/gen3d ${CONTAINER} ${ROOT}/01_generate-bigsample.sh
#docker run --gpus all -v ${PATHligan}:/ligan -v ${PATHgen3d}:/gen3d ${CONTAINER} ${ROOT}/03_sampleprior.sh
#docker run --gpus device=1 -v ${PATHligan}:/ligan -v ${PATHgen3d}:/gen3d ${CONTAINER} ${ROOT}/score.sh
#docker run --gpus device=1 -v ${PATHligan}:/ligan -v ${PATHgen3d}:/gen3d ${CONTAINER} ${ROOT}/06_interpolation.sh
docker run --gpus device=2 -v ${PATHligan}:/ligan -v ${PATHgen3d}:/gen3d ${CONTAINER} ${ROOT}/07_MSO_BRD4.sh &
docker run --gpus device=3 -v ${PATHligan}:/ligan -v ${PATHgen3d}:/gen3d ${CONTAINER} ${ROOT}/07_MSO_CDK2.sh &
#docker run --gpus device=3 -v ${PATHligan}:/ligan -v ${PATHgen3d}:/gen3d ${CONTAINER} ${ROOT}/07_MSO_BRD4_vina.sh &
#docker run --gpus device=3 -v ${PATHligan}:/ligan -v ${PATHgen3d}:/gen3d ${CONTAINER} ${ROOT}/07_MSO_CDK2_vina.sh &
#docker run --gpus device=2 -v ${PATHligan}:/ligan -v ${PATHgen3d}:/gen3d ${CONTAINER} ${ROOT}/05_latent.sh
