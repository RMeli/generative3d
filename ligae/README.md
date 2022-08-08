# Ligan Auto-Encoder

The ligand autoencoder model is not very interesting in itself, because of the drawbacks of autoencoders as generative models. The model is used here as a test platform for both Docker and Singularity.

## Docker

The script `test.sh` runs the `00_test_docker.sh` script within a Docker container:
```bash
#!/bin/bash

CONTAINER=gnina:commit

ROOT=/gen3d/ligae

HRID=/local/scratch/rmeli/
PATHgen3d=${HDIR}/Documents/git/evotec/generative3d/
PATHligan=${HDIR}/Documents/git/evotec/liGAN/

docker run --gpus device=0 -v ${PATHligan}:/ligan -v ${PATHgen3d}:/gen3d ${CONTAINER} ${ROOT}/00_test_docker.sh

```

`CONTAINER` is the name of the Docker container (with tag). `ROOT` represents the working directory within the Docker container, where the script `00_test_docker.sh` is located. `PATHgen3d` defines the path to the root of this repository, that is mapped to `/gen3d` within the Docker container (`-v ${PATHgen3d}:/gen3d`). `PATHligan` defines the path to the ligand code, that is mapped to `/ligan` within the container (`-v ${PATHligan}:/ligan`). The `--gpus` option allows to select where to run liGAN.

The `00_test_docker.sh` is the actual script that runs liGAN within the Docker container:
```bash
#!/bin/bash

. /root/miniconda3/etc/profile.d/conda.sh && conda activate myenv

export LIGAN_ROOT=/ligan/
export PYTHONPATH=${LIGAN_ROOT}:${PYTHONPATH}
export PYTHONPATH=${LIGAN_ROOT}/param_search/:${PYTHONPATH} # params.py

ROOT=/gen3d/ligae/
OUTDIR=${ROOT}/generated/

mkdir -p ${OUTDIR}

OUTFILE=${OUTDIR}test.out

git -C ${LIGAN_ROOT} log | head -n 1 | 2>&1 tee ${OUTFILE}

python /ligan/generate.py \
    --data_model_file ${ROOT}/models/data_48_0.5-nomolcache.model \
    --gen_model_file ${ROOT}/models/ae.model \
    --gen_weights_file ${ROOT}/weights/ae_disc_x_0.molportFULL_rand_.0.0_gen_iter_100000.caffemodel \
    --data_file ${ROOT}/data/gentest.types \
    --data_root ${ROOT}/data/ \
    -o ${OUTDIR} \
    --out_prefix ${OUTDIR}test \
    -b lig -b lig_gen \
    --fit_atoms \
    --dkoes_simple_fit --dkoes_make_mol \
    --output_sdf \
    --gpu \
    2>&1 | tee -a ${OUTFILE}

for f in $(ls ${OUTDIR}*.gz)
do
    gzip -df ${f}
done

chmod a+rwx ${OUTDIR}*

```

In the Docker container, Python is manages via `conda` and all liGAN Python dependencies are in the environment `myenv`. Therefore the environment needs to be activated within the container with
```bash
. /root/miniconda3/etc/profile.d/conda.sh && conda activate myenv
```

`LIGAN_ROOT` points to the liGAN code and `PYTHONPATH` is modified accordingly. `ROOT` represents the working directory. Since this scrip runs within the container, all paths are within the Docker container, taking into account the mapping defined in the `test.sh` script, when running the container.

The options for `generate.py` are self-documented in the liGAN code (and discussed in the READMEs in `ligvae` and `recvae`): [generate.py#L2262-L2320](https://github.com/mattragoza/liGAN/blob/6f1d99702023c0a887daebdf4be5b40ad0875e07/generate.py#L2262-L2320).

The data model file, which defines the input layers of the generative model, contains paths to `lig_map` and `rec_map` that also need to be within the container:
```
    recmap: "gen3d/data/rec_map"
    ligmap: "gen3d/data/lig_map"
```

The data model file and the generative model file also hard-code other variables that occasionally needs to be changed manually (such as the batch size for interpolation; see READMEs in `ligvae` and `recvae` for more details).

`chmod a+rwx ${OUTDIR}*` is needed so that the user has permission to move or remove files outside of the container (where everything is owned by `root`).

## Singularity

In the Singularity container, Python is set up as an entry point and therefore there is no need to create a script that runs within the container, but liGAN's modules can be run directly.

```bash
#!/bin/bash

CONTAINER="/site/tl/home/lcolliandre/work/AI/3d-cnn/gnina.sif"
export LIGAN_ROOT="/site/tl/home/lcolliandre/work/AI/3d-cnn/ligan"

ROOT=${PWD}
OUTDIR="/site/tl/home/lcolliandre/work/AI/3d-cnn/generated-results/"
SITE="/site/"

mkdir -p ${OUTDIR}

OUTFILE=${OUTDIR}test.out

git -C ${LIGAN_ROOT} log | head -n 1 | 2>&1 tee ${OUTFILE}
#git --exec-path=${LIGAN_ROOT} log | head -n 1 | 2>&1 tee ${OUTFILE}

singularity run --nv -B ${SITE}:${SITE} --app python ${CONTAINER} \
    ${LIGAN_ROOT}/generate.py \
    --data_model_file ${ROOT}/models/data_48_0.5-nomolcache.model \
    --gen_model_file ${ROOT}/models/ae.model \
    --gen_weights_file ${ROOT}/weights/ae_disc_x_0.molportFULL_rand_.0.0_gen_iter_100000.caffemodel \
    --data_file ${ROOT}/data/gentest.types \
    --data_root ${ROOT}/data/ \
    -o ${OUTDIR} \
    --out_prefix ${OUTDIR}test \
    -b lig -b lig_gen \
    --fit_atoms \
    --dkoes_simple_fit --dkoes_make_mol \
    --output_sdf \
    --gpu \
    2>&1 | tee -a ${OUTFILE}
```

The `CONTAINER` variable points to the Singularity container (`.sif` image). `LIGAN_ROOT` is the path to the liGAN code and needs to be exported. As for the Docker container, `ROOT` defines the working directory. Bacause NFS folders are not mounted directly by Singularity, these needs to be mounted explicitly and mapped within the container `-B ${SITE}:${SITE}` (where `SITE`  defines the directory to be mounted).

liGAN modules (in this case `generate.py`) can be run within the singularity container as follows:
```
singularity run --nv -B ${SITE}:${SITE} --app python ${CONTAINER} \
    ${LIGAN_ROOT}/generate.py <OPTIONS>
```
where `--nv` makes GPUs available within the container and `--app python` defines the entry point of the cointainer (in this case, the `python` interpreter).

_Note_: to use the Singularity container, the variables `ligmap` and `recmap` in the data model file need to be changed accordingly (to point to the `generative3d/data` folder (which is also symlinked to `ROOT`.

## Data

### Models and Weights

Models (`.model` files) and pre-trained weights (`.caffemodel` files) are kindly provided by Matt Ragoza and David Koes, and are available in the `model` and `weights` folders.

Weights are not hosted on GitHub but could be retrieved on the University of Pittsburgh cluster at the following locations:
```text
# molgrid data model
/net/pulsar/home/koes/mtr22/gan/models/data_48_0.5.model

# autoencoder model and weights
/net/pulsar/home/koes/mtr22/gan/models/ae.model
/net/pulsar/home/koes/mtr22/gan/models/ae_disc_x_0.molportFULL_rand_.0.0_gen_iter_100000.caffemodel
```

The `data_48_0.5-nomolcache.model` is a modified version of `data_48_0.5.model` without molecular caches (not needed when testing our own systems in a limited number).

Other model variables, such as the `batch_size` are hard-coded in the `.model` files and need to be manually changed occasionally.

