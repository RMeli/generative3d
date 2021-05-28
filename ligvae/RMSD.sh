#!/bin/bash/

DATAROOT="generated"

#for PREFIX in "BRD4_vf1.0_big" # "BRD4_vf5.0_big" "BRD4_vf0.5_big"
#do
#    for i in $(seq 1 10)
#    do
#        python RMSD.py ${DATAROOT}/${PREFIX}_ligand-${i}_min_lig_gen_fit_add.sdf ${DATAROOT}/${PREFIX}_ligand-${i}_min_lig_gen_fit_uff.sdf
#        python RMSD.py ${DATAROOT}/${PREFIX}_ligand-${i}_min_lig_gen_fit_add.sdf ${DATAROOT}/${PREFIX}_ligand-${i}_min_lig_gen_fit_uff.sdf --minimize
#    done
#done

for SYSTEM in "CDK2lig"
do
    datafile="data/${SYSTEM}.types"
    for vf in 1.0 5.0
    do
	PREFIX="${SYSTEM}_vf${vf}"
	while read line
 	do
	    #echo $line
            lig=$(echo $line | cut -f4 -d " ")
  	    lig=$(basename ${lig} .sdf)
	    
            python ../scripts/RMSD.py ${DATAROOT}/${PREFIX}_${lig}_lig_gen_fit_add.sdf ${DATAROOT}/${PREFIX}_${lig}_lig_gen_fit_uff.sdf
            python ../scripts/RMSD.py ${DATAROOT}/${PREFIX}_${lig}_lig_gen_fit_add.sdf ${DATAROOT}/${PREFIX}_${lig}_lig_gen_fit_uff.sdf --minimize

        done < ${datafile}
    done
done

