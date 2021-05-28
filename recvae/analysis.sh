#!/bin/bash/

DATAROOT="generated"

for SYSTEM in "CDK2lig" "BRD4"
do
    datafile="data/${SYSTEM}.types"
    for vf in 1.0 5.0
    do
        if [ ${SYSTEM} = "CDK2lig" ]
	then
            # For CDK2lig the suffix BIG was missing...
	    PREFIX="${SYSTEM}_vf${vf}"
        else
	    PREFIX="${SYSTEM}_vf${vf}_big"     	
	fi

	python ../scripts/analysis.py generated/${PREFIX}*.gen_metrics -o plots --pdf --nomols
    done
done

