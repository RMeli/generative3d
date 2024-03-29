#!/bin/bash

. /root/miniconda3/etc/profile.d/conda.sh && conda activate myenv

export LIGAN_ROOT=/ligan/
export PYTHONPATH=${LIGAN_ROOT}:${PYTHONPATH}
export PYTHONPATH=${LIGAN_ROOT}/param_search/:${PYTHONPATH} # params.py

ROOT=/gen3d/ligvae/
OUTDIR=${ROOT}/generated/

mkdir -p ${OUTDIR}

# Name of *.typse file without extension
# Used in PREFIX as well
SYSTEM="CDK2lig"

for vf in 0.0
do

    PREFIX="${SYSTEM}_vf${vf}_SULFONYL"
    OUTFILE="${OUTDIR}${PREFIX}_generated.out"
    git -C ${LIGAN_ROOT} log | head -n 1 | 2>&1 tee ${OUTFILE}

    python /ligan/generate.py \
        --data_model_file ${ROOT}/models/data_48_0.5-nomolcache.model \
        --gen_model_file ${ROOT}/models/gen_e_0.1_1.model \
        --gen_weights_file ${ROOT}/weights/gen_e_0.1_1_disc_x_10_0.molportFULL_rand_.0.0_gen_iter_100000.caffemodel \
        -r CDK2/data/4FKP.pdb -l CDK2/data/4fkp_B_LS5_min.sdf \
        --data_root ${ROOT}/data/ \
        -o ${OUTDIR} \
        --out_prefix ${OUTDIR}${PREFIX} \
        --verbose 1 \
        --n_samples 10 \
        --var_factor ${vf} \
        -b lig -b lig_gen \
        --fit_atoms \
        --dkoes_simple_fit --dkoes_make_mol \
        --output_sdf \
        --output_dx \
        --gpu \
        2>&1 | tee -a ${OUTFILE}

    for f in $(ls ${OUTDIR}/${PREFIX}*.gz)
    do
        gzip -df ${f}
    done

    for f in $(ls ${OUTDIR}/${PREFIX}*)
    do
       chmod a+x ${f}
    done
done
