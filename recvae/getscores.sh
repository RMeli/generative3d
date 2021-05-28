#!/bin/bash/

# Use getscores.py script to extract Vina/GNINA scores from SDF files

DATAROOT="generated"

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

for SYSTEM in "CDK2rec" "BRD4"
do
    datafile="data/${SYSTEM}.types"
    for vf in 1.0 5.0
    do
	PREFIX="${SYSTEM}_vf${vf}_big"
	while read line
 	do
	    #echo $line
            lig=$(echo $line | cut -f4 -d " ")
  	    lig=$(basename ${lig} .sdf)
	    
	    python ../scripts/getscores.py \
                ${DATAROOT}/${PREFIX}_${lig}_lig_gen_vina.sdf \
                -o ${DATAROOT}/${PREFIX}_${lig}_lig_gen_scores.csv
        done < ${datafile}
    done
done

