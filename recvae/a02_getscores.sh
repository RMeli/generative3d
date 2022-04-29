#!/bin/bash/

# Use getscores.py script to extract Vina/GNINA scores from SDF files

ROOT=$(pwd)
OUTDIR=${ROOT}/generated/
mkdir -p ${OUTDIR}


#for PREFIX in "BRD4_vf1.0_big" "BRD4_vf0.5_big"
#do
#    for i in $(seq 1 10)
#    do
#        python ../scripts/getscores.py \
#            ${DATAROOT}/${PREFIX}_ligand-${i}_min_lig_gen_vina.sdf \
#            -o ${DATAROOT}/${PREFIX}_ligand-${i}_min_lig_gen_scores.csv
#    done
#done

#for PREFIX in "BRD4_vf0.0_prior" "BRD4_vf0.5_prior" "BRD4_vf1.0_prior"
#do
#    python ../scripts/getscores.py \
#        ${DATAROOT}/${PREFIX}_ligand-1_min_lig_gen_vina.sdf \
#        -o ${DATAROOT}/${PREFIX}_ligand-1_min_lig_gen_scores.csv
#done

# Obtain Vina-minimised scores for sampling with scaffold
#   Variablility factor: 1.0 (only)
for SYSTEM in "BRD4"
do
    datafile="${ROOT}/data/${SYSTEM}rec.types"

    # TYPO in CDK2: "scffold" instead of "scaffold"
    if [ "${SYSTEM}" == "CDK2" ]; then
        PREFIX="${SYSTEM}_vf1.0_scffold"
    else
        PREFIX="${SYSTEM}_vf1.0_scaffold"
    fi

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
