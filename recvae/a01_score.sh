#!/bin/bash

# Optimise UFF-minimised ligands within binding site
# Get VINA and GNINA scores

CONTAINER="${HOME}/Documents/git/generative3d/dev/singularity/gnina.sif"

ROOT=$(pwd)
OUTDIR=${ROOT}/generated/
mkdir -p ${OUTDIR}

#receptor=${ROOT}/data/BRD4/pdb/BRD4.pdb

#for vf in 0.5 1.0
#do
#
#PREFIX="BRD4_vf${vf}_prior"
#
# ligand-1_min used to define the binding site (box center)
#ligand="${OUTDIR}/${PREFIX}_ligand-1_min_lig_gen_fit_uff.sdf"
#    
#gnina -l ${ligand} -r ${receptor} --autobox_ligand ${ligand} --minimize \
#    -o ${OUTDIR}/${PREFIX}_ligand-1_min_lig_gen_vina.sdf \
#    2>&1 | tee -a ${OUTDIR}/${PREFIX}_ligand-1_vina.out
#
#done

# Obtain Vina-minimised poses for sampling with scaffold
#   Variablility factor: 1.0 (only)
for SYSTEM in "BRD4" #"CDK2"
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
        rec=$(echo $line | cut -f3 -d " ")
        lig=$(echo $line | cut -f4 -d " ")
        lig=$(basename ${lig} .sdf)

            
        ligfile="${OUTDIR}${PREFIX}_${lig}_lig_gen_fit_uff.sdf.gz"
        recfile="${ROOT}/data/${rec}"

        singularity run --nv --app gnina ${CONTAINER} \
            -l ${ligfile} -r ${recfile} \
            --autobox_ligand ${ligfile} --minimize --seed 42 \
            -o ${OUTDIR}/${PREFIX}_${lig}_lig_gen_vina.sdf.gz \
            2>&1 | tee -a ${OUTDIR}/${PREFIX}_${lig}_vina.out
    done < ${datafile}
done