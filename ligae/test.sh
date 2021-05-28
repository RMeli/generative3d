#!/bin/bash

CONTAINER=gnina:commit

ROOT=/gen3d/ligae

HDIR=/local/scratch/rmeli/
PATHgen3d=${HDIR}/Documents/git/evotec/generative3d/
PATHligan=${HDIR}/Documents/git/evotec/liGAN/

docker run --gpus device=0 -v ${PATHligan}:/ligan -v ${PATHgen3d}:/gen3d ${CONTAINER} ${ROOT}/00_test_docker.sh

