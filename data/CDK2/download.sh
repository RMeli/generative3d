#/bin/bash

fname="CDK2_clean.csv"

mkdir -p rawdata

for pdbid in $(tail -n +2 ${fname} | awk -F, '{print $NF}')
do
    echo $pdbid

    wget https://files.rcsb.org/download/${pdbid}.pdb
    grep ATOM ${pdbid}.pdb | grep -v REMARK > rawdata/${pdbid}.pdb
    rm ${pdbid}.pdb
done