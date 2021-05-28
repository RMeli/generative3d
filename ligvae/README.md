# Ligand Variational AutoEncoder

## Scripts

For a description of how Docker and Singularity containers are used, see the `ligae` README file. Here we focus on how to use liGAN's `generative.py` script.

Scripts are run within the Docker container with the `run.sh` script (comment/uncomment lines accordingly, and specify the correct GPU tag).

### Sampling from Seed

liGAN allow to generate molecules by sampling the latent space of the variational autoencoder around a seed. This is used in `01_generate.sh` and `01_generate-bigsample.sh`.

```bash
python /ligan/generate.py \
	--data_model_file ${ROOT}/models/data_48_0.5-nomolcache.model \
        --gen_model_file ${ROOT}/models/gen_e_0.1_1.model \
        --gen_weights_file ${ROOT}/weights/gen_e_0.1_1_disc_x_10_0.molportFULL_rand_.0.0_gen_iter_100000.caffemodel \
        --data_file ${ROOT}/data/${SYSTEM}.types \
        --data_root ${ROOT}/data/ \
        -o ${OUTDIR} \
        --out_prefix ${OUTDIR}${PREFIX} \
        --n_samples 1000 \
        --var_factor ${vf} \
        -b lig -b lig_gen \
        --fit_atoms \
        --dkoes_simple_fit --dkoes_make_mol \
        --output_sdf \
        --gpu \
        2>&1 | tee -a ${OUTFILE}
```

`--data_model_file` points to the data model file, which defines the Caffe layers used to parse molecular data and compute the atomic densities on a grid. `--gen_model_file` and `--gen_weights_file` allow to specify the VAE architecture and weights. `--data_file` contains the seeds for the generative model. The file format is the folowing:
```text
<POSE_ANNOTATION> <BINDING_AFFINITY> <RECEPTOR_FILE> <LIGAND_FILE>
```
For `ligvae`, only the ligand file is actually used, but all fields are needed. The `*.types` file used for different `SYSTEM`s are available in the `generative3d/data` folder (symlinked to `ROOT`). `--data_root` specify the path to prepend to the receptor and ligand file paths defined in the `--data_file`. `-o` specify the output directory for all files created by `generative.py`, while `--out_prefix` specify the prefix to such files (which allow to identify different runs). `--n_samples` defines the number of samples for each entry in the `--data_file`. The `--var_factor` defines a multiplyer for the generated variance; a variance is given as output of the variational outoencoder and is multiplied by `--var_factor` before the sampling is performed. The parameter `--var_factor` sllows to specify the size of the neighbourood of the seed molecule to be samples; the model was trained with `--var_factor 1.0`. `-b` allow to specify the [Caffe blobs](https://caffe.berkeleyvision.org/tutorial/net_layer_blob.html) from which molecules are reconstructed; `lig` defines the original ligand density while `lig_gen` defines the generated density. `--fit_atoms` allows to fit atoms within the densities, while `--dkoes_simple_fit` and `--dkoes_make_mol` specify alternative way of fitting and reconstructing the molecule (which seem to give better results than the standard options). `--ouput_sdf` requires to output the generated molecules in SDF files; adding `--output_dx` allow to output the atomic densities as well (in `.dx` files).

All parameters are described in [generate.py#L2265-L2323](https://github.com/mattragoza/liGAN/blob/baa4f3e5c72d559bc3a0749c70899cc14a89fbd7/generate.py#L2265-L2323)

### Sampling from Prior Distribution

Sampling from the propr distribution is performed in `02_priorsampling.sh`

```bash
python /ligan/generate.py \
    --data_model_file ${ROOT}/models/data_48_0.5-nomolcache.model \
    --gen_model_file ${ROOT}/models/gen_e_0.1_1.model \
    --gen_weights_file ${ROOT}/weights/gen_e_0.1_1_disc_x_10_0.molportFULL_rand_.0.0_gen_iter_100000.caffemodel \
    --data_file ${ROOT}/data/${SYSTEM}prior.types \
    --data_root ${ROOT}/data/ \
    -o ${OUTDIR} \
    --out_prefix ${OUTDIR}${PREFIX} \
    --verbose 1 \
    --n_samples 1000 \
    --var_factor ${vf} \
    -b lig -b lig_gen \
    --fit_atoms \
    --dkoes_simple_fit --dkoes_make_mol \
    --output_sdf \
    --output_dx \
    --gpu \
    --prior \
    2>&1 | tee -a ${OUTFILE}
```

`--prior` tells `generate.py` to ignore the seed molecules in `--data_file` and sample from the prior instead. `${SYSTEM}prior.types` contains a single line, since the seed molecules are ignored; specifying more lines would end up with `generate.py` producing more samples because of how sampling is implemented (see [ligan/generate.py main loop](https://github.com/mattragoza/liGAN/blob/baa4f3e5c72d559bc3a0749c70899cc14a89fbd7/generate.py#L1950-L1952)).

### Latent Space Interpolation

Latent space interpolation is performed in `03_interpolation.sh`. 

```bash
python /ligan/generate.py \
    	--data_model_file ${ROOT}/models/data_48_0.5-bs50-nomolcache.model \
        --gen_model_file ${ROOT}/models/gen_e_0.1_1-bs50.model \
        --gen_weights_file ${ROOT}/weights/gen_e_0.1_1_disc_x_10_0.molportFULL_rand_.0.0_gen_iter_100000.caffemodel \
        --data_file ${ROOT}/data/${SYSTEM}interpolate.types \
        --data_root ${ROOT}/data/ \
        -o ${OUTDIR} \
        --out_prefix ${OUTDIR}${PREFIX} \
        --verbose 1 \
        --n_samples 25 \
        --var_factor ${vf} \
        -b lig -b lig_gen \
        --fit_atoms \
        --dkoes_simple_fit --dkoes_make_mol \
        --output_sdf \
        --output_dx \
        --output_latent \
        --interpolate \
        --gen_only \
        --gpu \
        2>&1 | tee -a ${OUTFILE}
```

The latent space interpolation in liGAN (`--interpolate`) makes use of batches, therefore the `*.model` file needs to be manually modified in order to change the number of interpolation points. The data model `data_48_0.5-bs50-nomolcache.model` and the autoencoder `gen_e_0.1_1-bs50.model` have been modified in order to use a batch size of `50` (about the maximum number of density grids that can fit in a GPU with 16GB of memory). The `${SYSTEM}interpolate.types` defines pais of ligands that are interpolated. `--n_samples` defines the number of samples for each side of the interpolation, so it needs to be helf the batch size. `--output_latent` allow to output the latent space vector (in `.latent` files, that simply contain the numerical values of the vector). The option `--gen_only` specifies to output only thing obtained from the `lig_gen` Caffe blob and nothing else.

## Analysis

### RMSD

The script `RMSD.sh` runs `../scripts/rmsd.py` in order to compute the RMSD between the atoms fitted to the density and the final UFF-minimised molecule.

### Analysis

The script `analysys.sh` runs `../scripts/analysis.py` in order to extract interesting and relevant data from `*.gen_metrics` output file and produce ploits of different quantities (QED, SA, ...). 

## Data

### Models and Weights

Models (`.model`) and pre-trained weights (`.caffemodel`) are kindly provided by Matt Ragoza and David Koes. 

Weights are not hosted on GitHub but could be retrieved on the University of Pittsburgh cluster at the following locations:
```
# molgrid data model
/net/pulsar/home/koes/mtr22/gan/models/data_48_0.5.model

# variational autoencoder model and weights
/net/pulsar/home/koes/mtr22/gan/models/gen_e_0.1_1.model
/net/pulsar/home/koes/mtr22/gan/weights/gen_e_0.1_1_disc_x_10_0.molportFULL_rand_.0.0_gen_iter_100000.caffemodel
```

#### Caffe Models

One of the major drawbacks of Caffe is that models are defined in an [external JSON-like file](https://caffe.berkeleyvision.org/tutorial/net_layer_blob.html), therefore network parameters such as `batch_size` are hardcoded in the model definition. The following models are 

### Molecular Caches

Molecular caches (`.molcache` or `.molcache2`) are monolithic files collecting the information contained in a series of `.gninatypes` files. `.gninatypes` binary files are files used by [GNINA](https://github.com/gnina/gnina) and [libmolgrid](https://github.com/gnina/libmolgrid) to represent molecules in a minimal format (only atom types and coordinates) in order to reduce I/O during training and inference.

The `.molcache2` files referenced in the `.model` files can be obtained from [http://bits.csb.pitt.edu/files/molcaches/](http://bits.csb.pitt.edu/files/molcaches/).

Given that we are testing our own systems, the `.molcache2` are removed from the `.model` files. The files `*-nomolcache.model` are custom version of the original models which do not require `.molcache2` inputs.
