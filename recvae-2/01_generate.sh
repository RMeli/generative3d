#!/bin/bash

CONTAINER="${HOME}/Documents/git/generative3d/dev/singularity/gnina.sif"
LIGAN_ROOT="${HOME}/Documents/git/liGAN"

git -C ${LIGAN_ROOT} log | head -n 1 | 2>&1 tee ${OUTFILE}

singularity run --nv \
    --env "GNINA_CMD='gnina'" \
    --app python ${CONTAINER} \
    ${LIGAN_ROOT}/generate.py BRD4.config \
    2>&1 | tee -a ${OUTFILE}
