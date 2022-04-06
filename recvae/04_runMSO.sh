#!/bin/bash

CONTAINER="${HOME}/Documents/git/generative3d/dev/singularity/ligan.sif"

singularity exec --nv ${CONTAINER} ./MSO.sh