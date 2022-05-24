#!/bin/bash/

# Compute RMSD between generated molecules and
#   - UFF minimised molecule
#   - Vina optimised molecle
# 
# ! Needs to run _after_ a01_score.sh which generates Vina poses

DATAROOT="generated"

# Compute RMSD for sampling with scaffold
#   Variablility factor: 1.0 (only)
for SYSTEM in "CDK2"
do
    datafile="data/${SYSTEM}rec.types"

    for vf in 5.0
    do
        PREFIX="${SYSTEM}_vf${vf}"

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
done

# Compute RMSD for sampling with scaffold
#   Variablility factor: 1.0 (only)
for SYSTEM in "CDK2"
do
    datafile="data/${SYSTEM}rec.types"

    PREFIX="${SYSTEM}_vf1.0_scaffold"

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
