#!/bin/bash/

# Compute RMSD between generated molecules and
#   - UFF minimised molecule
#   - Vina optimised molecle
# 
# ! Needs to run _after_ a01_score.sh which generates Vina poses

DATAROOT="generated"

#for PREFIX in "BRD4_vf1.0_big" "BRD4_vf0.5_big"
#do
#    for i in $(seq 1 10)
#    do
#        python ../scripts/RMSD.py \
#            ${DATAROOT}/${PREFIX}_ligand-${i}_min_lig_gen_fit_add.sdf ${DATAROOT}/${PREFIX}_ligand-${i}_min_lig_gen_fit_uff.sdf \
#            --minimize -o ${DATAROOT}/${PREFIX}_ligand-${i}_min_lig_gen_RMSDuff.csv
#
#        python ../scripts/RMSD.py \
#            ${DATAROOT}/${PREFIX}_ligand-${i}_min_lig_gen_fit_add.sdf ${DATAROOT}/${PREFIX}_ligand-${i}_min_lig_gen_vina.sdf \
#            --minimize -o ${DATAROOT}/${PREFIX}_ligand-${i}_min_lig_gen_RMSDvina.csv
#    done
#done

# Compute RMSD for sampling with scaffold
#   Variablility factor: 1.0 (only)
for SYSTEM in "CDK2" #BRD4
do
    datafile="data/${SYSTEM}rec.types"

    # TYPO in CDK2: "scffold" instead of "scaffold"
    if [ "${SYSTEM}" == "CDK2" ]; then
        PREFIX="${SYSTEM}_vf1.0_scffold"
    else
        PREFIX="${SYSTEM}_vf1.0_scaffold"
    fi

    while read line
    do
        echo $line
        lig=$(echo $line | cut -f4 -d " ")
        lig=$(basename ${lig} .sdf)

        python ../scripts/RMSD.py ${DATAROOT}/${PREFIX}_${lig}_lig_gen_fit_add.sdf.gz ${DATAROOT}/${PREFIX}_${lig}_lig_gen_fit_uff.sdf.gz \
            --minimize -o ${DATAROOT}/${PREFIX}_${lig}_lig_gen_RMSDuff.csv

        python ../scripts/RMSD.py ${DATAROOT}/${PREFIX}_${lig}_lig_gen_fit_add.sdf.gz ${DATAROOT}/${PREFIX}_${lig}_lig_gen_vina.sdf.gz \
            --minimize -o ${DATAROOT}/${PREFIX}_${lig}_lig_gen_RMSDvina.csv

    done < ${datafile}
done
