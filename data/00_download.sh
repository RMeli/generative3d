#!/bin/bash

# BRD4
wget https://github.com/MobleyLab/benchmarksets/archive/master.zip
unzip master.zip
rm master.zip
mv benchmarksets-master/input_files/BRD4 .
rm -r benchmarksets-master
rm -r BRD4/prmtop-coords

