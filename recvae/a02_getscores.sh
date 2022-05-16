#!/bin/bash/

# Use getscores.py script to extract Vina/GNINA scores from SDF files

ROOT=$(pwd)
OUTDIR=${ROOT}/generated/
mkdir -p ${OUTDIR}

# Obtain Vina-minimised scores for sampling with scaffold
#   Variablility factor: 1.0 (only)
for SYSTEM in "CDK2"
do
    datafile="${ROOT}/data/${SYSTEM}rec.types"

    for vf in 1.0 5.0
    do
        PREFIX="${SYSTEM}_vf${vf}"

        while read line
        do
            #echo $line
            lig=$(echo $line | cut -f4 -d " ")
            lig=$(basename ${lig} .sdf)
            
            python ../scripts/getscores.py \
                    ${OUTDIR}/${PREFIX}_${lig}_lig_gen_vina.sdf.gz \
                    -o ${OUTDIR}/${PREFIX}_${lig}_lig_gen_scores.csv
        done < ${datafile}
    done
done

# Obtain Vina-minimised scores for sampling with scaffold
#   Variablility factor: 1.0 (only)
for SYSTEM in "CDK2"
do
    datafile="${ROOT}/data/${SYSTEM}rec.types"

    PREFIX="${SYSTEM}_vf1.0_scaffold"

    while read line
     do
        #echo $line
        lig=$(echo $line | cut -f4 -d " ")
        lig=$(basename ${lig} .sdf)
        
        python ../scripts/getscores.py \
                ${OUTDIR}/${PREFIX}_${lig}_lig_gen_vina.sdf.gz \
                -o ${OUTDIR}/${PREFIX}_${lig}_lig_gen_scores.csv
    done < ${datafile}
done
