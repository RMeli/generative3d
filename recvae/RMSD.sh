#!/bin/bash/

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

for SYSTEM in "BRD4" #"CDK2rec"
do
    datafile="data/${SYSTEM}.types"
    for vf in 5.0 #1.0 5.0
    do
	PREFIX="${SYSTEM}_vf${vf}_big"
	while read line
 	do
	    #echo $line
            lig=$(echo $line | cut -f4 -d " ")
  	    lig=$(basename ${lig} .sdf)
	    
            python ../scripts/RMSD.py ${DATAROOT}/${PREFIX}_${lig}_lig_gen_fit_add.sdf ${DATAROOT}/${PREFIX}_${lig}_lig_gen_fit_uff.sdf \
                --minimize -o ${DATAROOT}/${PREFIX}_${lig}_lig_gen_RMSDuff.csv

            python ../scripts/RMSD.py ${DATAROOT}/${PREFIX}_${lig}_lig_gen_fit_add.sdf ${DATAROOT}/${PREFIX}_${lig}_lig_gen_vina.sdf \
		--minimize -o ${DATAROOT}/${PREFIX}_${lig}_lig_gen_RMSDvina.csv

        done < ${datafile}
    done
done
