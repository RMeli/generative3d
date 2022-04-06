#!/bin/bash

# Optimise UFF-minimised ligands within binding site
# Get VINA and GNINA scores

. /root/miniconda3/etc/profile.d/conda.sh && conda activate myenv

ROOT=/gen3d/recvae/
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

for SYSTEM in "BRD4" #"CDK2rec"
do
    datafile="${ROOT}/data/${SYSTEM}.types"
    for vf in 5.0
    do
	PREFIX="${SYSTEM}_vf${vf}_big"
	while read line
 	do
	    #echo $line
            rec=$(echo $line | cut -f3 -d " ")
            lig=$(echo $line | cut -f4 -d " ")
  	    lig=$(basename ${lig} .sdf)
   	     
            ligfile=${OUTDIR}/${PREFIX}_${lig}_lig_gen_fit_uff.sdf
	    recfile=${ROOT}/data/${rec}

	    gnina -l ${ligfile} -r ${recfile} \
		--autobox_ligand ${ligfile} --minimize --seed 42 \
    		-o ${OUTDIR}/${PREFIX}_${lig}_lig_gen_vina.sdf \
    		2>&1 | tee -a ${OUTDIR}/${PREFIX}_${lig}_vina.out

            #echo $ligfile $recfile
        done < ${datafile}

        for f in $(ls ${OUTDIR}/${PREFIX}*.gz)
        do
            gzip -df ${f}
        done

        for f in $(ls ${OUTDIR}/${PREFIX}*)
        do
            chmod a+rwx ${f}
        done

    done
done

