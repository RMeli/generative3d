#!/bin/bash

# Optimise UFF-minimised ligands within binding site
# Get VINA and GNINA scores

CONTAINER="${HOME}/Documents/git/generative3d/dev/singularity/gnina.sif"

ROOT=$(pwd)
OUTDIR=${ROOT}/generated/
mkdir -p ${OUTDIR}


# Obtain Vina-minimised poses for posterior sampling
for SYSTEM in "BRD4"
do
    for vf in 1.0
    do
        datafile="${ROOT}/data/${SYSTEM}rec.types"

        PREFIX="${SYSTEM}_vf${vf}"

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
done

# Obtain Vina-minimised poses for sampling with scaffold
#   Variablility factor: 1.0 (only)
# for SYSTEM in "CDK2"
# do
#     datafile="${ROOT}/data/${SYSTEM}rec.types"

#     PREFIX="${SYSTEM}_vf1.0_scaffold"

#     while read line
#      do
#         #echo $line
#         rec=$(echo $line | cut -f3 -d " ")
#         lig=$(echo $line | cut -f4 -d " ")
#         lig=$(basename ${lig} .sdf)

            
#         ligfile="${OUTDIR}${PREFIX}_${lig}_lig_gen_fit_uff.sdf.gz"
#         recfile="${ROOT}/data/${rec}"

#         singularity run --nv --app gnina ${CONTAINER} \
#             -l ${ligfile} -r ${recfile} \
#             --autobox_ligand ${ligfile} --minimize --seed 42 \
#             -o ${OUTDIR}/${PREFIX}_${lig}_lig_gen_vina.sdf.gz \
#             2>&1 | tee -a ${OUTDIR}/${PREFIX}_${lig}_vina.out
#     done < ${datafile}
# done
