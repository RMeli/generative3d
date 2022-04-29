#!/bin/bash

# Compute baseline CNNscore and CNNaffinity

CONTAINER="${HOME}/Documents/git/generative3d/dev/singularity/gnina.sif"
ROOT=$(pwd)

rm tmp.out

echo "system,ligand,cnnscore,cnnaffinity" > baseline.csv

for SYSTEM in "BRD4" "CDK2"
do
    datafile="${ROOT}/data/${SYSTEM}rec.types"

    while read line
     do
        #echo $line
        rec=$(echo $line | cut -f3 -d " ")
        lig=$(echo $line | cut -f4 -d " ")
        ligname=$(basename ${lig} .sdf)
        
        ligfile="${ROOT}/data/${lig}"
        recfile="${ROOT}/data/${rec}"

        singularity run --nv --app gnina ${CONTAINER} \
            -l ${ligfile} -r ${recfile} \
            --autobox_ligand ${ligfile} --minimize --seed 42 \
            2>&1 | tee tmp.out

        cnnscore=$(grep "CNNscore" tmp.out | cut -f2 -d " ")
        cnnaffinity=$(grep "CNNaffinity" tmp.out | cut -f2 -d " ")

        echo "${SYSTEM},${ligname},${cnnscore},${cnnaffinity}" >> baseline.csv

        rm tmp.out
        
    done < ${datafile}
done
