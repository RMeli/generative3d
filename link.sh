#!/bin/bash

# Create symlinks to data directory and useful scripts

wd=${PWD}

for dir in "ligae" "ligvae" "recvae"
do
    cd ${dir}

    # Create relative (soft) links
    ln -s ../data .
    ln -s ../scripts/ligan.py .
    ln -s ../scripts/analysis.py .

    cd ${wd}
done
