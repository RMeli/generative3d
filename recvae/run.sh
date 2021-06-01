#!/bin/bash

CONTAINER="${HOME}/Documents/git/generative3d/dev/singularity/gnina.sif"

singularity exec --nv ${CONTAINER} ./04_MSO.sh