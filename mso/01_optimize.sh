#!/bin/bash

CONTAINER="${HOME}/Documents/git/generative3d/dev/singularity/gnina.sif"
LIGAN_ROOT="${HOME}/Documents/git/liGAN-MSO"

singularity run --nv \
    --env "GNINA_CMD='gnina'" \
    --app python ${CONTAINER} \
    ${LIGAN_ROOT}/optimize.py BRD4.config
