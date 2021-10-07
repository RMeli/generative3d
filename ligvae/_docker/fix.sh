#!/bin/bash

ROOT=/gen3d/ligvae/
OUTDIR=${ROOT}/generated/

# Name of *.typse file without extension
# Used in PREFIX as well
SYSTEM="CDK2lig"

for vf in 0.5 1.0 5.0
do

    PREFIX="${SYSTEM}_vf${vf}"

    for f in $(ls ${OUTDIR}/${PREFIX}*.gz)
    do
        gzip -df ${f}
    done

    for f in $(ls ${OUTDIR}/${PREFIX}*)
    do
       chmod a+x ${f}
    done
done
