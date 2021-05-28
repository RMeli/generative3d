# Receptor-Constrained Variational AutoEncoder

## Scripts

For a description of how Docker and Singularity containers are used, see the `ligae` README file. Here we focus on how to use liGAN's `generative.py` script.

Scripts are run within the Docker container with the `run.sh` script (comment/uncomment lines accordingly, and specify the correct GPU tag).

Alternatively, `01_generate_singularity.sh` shows how to run `generative.py` within the Singularity container.

### Sampling from Seed

liGAN allow to generate molecules by sampling the latent space of the variational autoencoder around a seed. This is used in `01_generate.sh` and `01_generate-bigsample.sh` (and `01_generate_singularity.sh`, with the Singularity container).
```bash
python /ligan/generate.py \
        --data_model_file ${ROOT}/models/data_48_0.5_batch10.model \
        --gen_model_file ${ROOT}/models/_vlr-le13_48_0.5_4_3lS_32_2_512_e.model \
        --gen_weights_file ${ROOT}/weights/lessskip_crossdocked_increased_1.lowrmsd.0_gen_iter_1000000.caffemodel \
        --data_file ${ROOT}/data/${SYSTEM}.types \
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
        --gpu \
        2>&1 | tee -a ${OUTFILE}
```

`--data_model_file` points to the data model file, which defines the Caffe layers used to parse molecular data and compute the atomic densities on a grid. `--gen_model_file` and `--gen_weights_file` allow to specify the VAE architecture and weights. `--data_file` contains the seeds for the generative model. The file format is the folowing:
```text
<POSE_ANNOTATION> <BINDING_AFFINITY> <RECEPTOR_FILE> <LIGAND_FILE>
```
For `recvae`, only the ligand and receptor files are actually used, but all fields are needed. The `*.types` file used for different `SYSTEM`s are available in the `generative3d/data` folder (symlinked to `ROOT`). `--data_root` specify the path to prepend to the receptor and ligand file paths defined in the `--data_file`. `-o` specify the output directory for all files created by `generative.py`, while `--out_prefix` specify the prefix to such files (which allow to identify different runs). `--n_samples` defines the number of samples for each entry in the `--data_file`. The `--var_factor` defines a multiplyer for the generated variance; a variance is given as output of the variational autoencoder and is multiplied by `--var_factor` before the sampling is performed. The parameter `--var_factor` allows to specify the size of the neighbourood of the seed molecule to be sampled; the model was trained with `--var_factor 1.0`. `-b` allow to specify the [Caffe blobs](https://caffe.berkeleyvision.org/tutorial/net_layer_blob.html) from which molecules are reconstructed; `lig` defines the original ligand density while `lig_gen` defines the generated density. `--fit_atoms` allows to fit atoms within the densities, while `--dkoes_simple_fit` and `--dkoes_make_mol` specify alternative way of fitting and reconstructing the molecule (which seem to give better results than the standard options). `--ouput_sdf` requires to output the generated molecules in SDF files; adding `--output_dx` allow to output the atomic densities as well (in `.dx` files).

_Note_: `--output_dx` significantly increases I/O operations, slowing down sampling considerably.

All parameters are described in [generate.py#L2265-L2323](https://github.com/mattragoza/liGAN/blob/baa4f3e5c72d559bc3a0749c70899cc14a89fbd7/generate.py#L2265-L2323)

### Sampling from Prior Distribution

Sampling from the propr distribution is performed in `02_sampleprior.sh`

```bash
python /ligan/generate.py \
    --data_model_file ${ROOT}/models/data_48_0.5_batch10.model \
    --gen_model_file ${ROOT}/models/_vlr-le13_48_0.5_4_3lS_32_2_512_e.model \
    --gen_weights_file ${ROOT}/weights/lessskip_crossdocked_increased_1.lowrmsd.0_gen_iter_1000000.caffemodel \
    --data_file ${ROOT}/data/BRD4prior.types \
    --data_root ${ROOT}/data/ \
    -o ${OUTDIR} \
    --out_prefix ${OUTDIR}${PREFIX} \
    --verbose 1 \
    --n_samples 1 \
    --var_factor ${vf} \
    -b lig -b lig_gen \
    --fit_atoms \
    --dkoes_simple_fit --dkoes_make_mol \
    --gen_only \
    --prior \
    --output_sdf \
    --output_dx \
    --output_latent \
    --gpu \
    2>&1 | tee -a ${OUTFILE}
```

`--prior` tells `generate.py` to ignore the seed molecules in `--data_file` and sample from the prior instead. `${SYSTEM}prior.types` contains a single line, since the seed molecules are ignored; specifying more lines would end up with `generate.py` producing more samples because of how sampling is implemented (see [ligan/generate.py main loop](https://github.com/mattragoza/liGAN/blob/baa4f3e5c72d559bc3a0749c70899cc14a89fbd7/generate.py#L1950-L1952)).

`--output_latent` allows to output the latent space vector (in a `.latent` file that can be found in the output directory). `--gen_only` specifies to output only thing obtained from the `lig_gen` Caffe blob.

### Latent Space Interpolation

Latent space interpolation is performed in `03_interpolation.sh`. 

```bash
    python /ligan/generate.py \
        --data_model_file ${ROOT}/models/data_48_0.5-bs30.model \
        --gen_model_file ${ROOT}/models/_vlr-le13_48_0.5_4_3lS_32_2_512_e-bs30.model \
        --gen_weights_file ${ROOT}/weights/lessskip_crossdocked_increased_1.lowrmsd.0_gen_iter_1000000.caffemodel \
        --data_file ${ROOT}/data/${SYSTEM}.types \
        --data_root ${ROOT}/data/ \
        -o ${OUTDIR} \
        --out_prefix ${OUTDIR}${PREFIX} \
        --verbose 1 \
        --n_samples 15 \
        --var_factor ${vf} \
        -b lig -b lig_gen \
        --fit_atoms \
        --dkoes_simple_fit --dkoes_make_mol \
        --output_sdf \
        --output_latent \
        --output_dx \
        --interpolate \
        --gen_only \
        --gpu \
        2>&1 | tee -a ${OUTFILE}

```

The latent space interpolation in liGAN (`--interpolate`) makes use of batches, therefore the `*.model` file needs to be manually modified in order to change the number of interpolation points. The data model `data_48_0.5-bs30-nomolcache.model` and the autoencoder `_vlr-le13_48_0.5_4_3lS_32_2_512_e-bs30.model` have been modified in order to use a batch size of `30` (about the maximum number of density grids that can fit in a GPU with 16GB of memory). The `${SYSTEM}interpolate.types` defines pais of ligands that are interpolated. `--n_samples` defines the number of samples for each side of the interpolation, so it needs to be helf the batch size. `--output_latent` allow to output the latent space vector (in `.latent` files, that simply contain the numerical values of the vector). The option `--gen_only` specifies to output only thing obtained from the `lig_gen` Caffe blob and nothing else.

_Note_: the maximum batch size that can be propagated is different from `ligvae` (~50) and `recvae` (~30) since the `recvae` model is bigger (it consists of two autoencoders, one of which encodes the receptor).

### Molecular Swarm Optimisation

The [Molecular Swarm Optimiser (MSO)](https://github.com/jrwnter/mso) has been adapted and incorporated into `liGAN` (on the `evotec-latent` branch) and can be run via the `MSO.py` script, used in `07_MSO_<SYSTEM>.sh`.

```bash
python ${LIGAN_ROOT}/MSO.py \
  --data_model_file ${ROOT}/models/data_48_0.5_batch10.model \
  --gen_model_file ${ROOT}/models/_vlr-le13_48_0.5_4_3lS_32_2_512_e.model \
  --gen_weights_file ${ROOT}/weights/lessskip_crossdocked_increased_1.lowrmsd.0_gen_iter_1000000.caffemodel \
  -r ${RECEPTOR} -l ${ROOT}/data/benzene_brd4.sdf \
  --n_swarms 5 --n_particles 200 --iterations 20 \
  --v_min -3.0 --v_max 3.0 \
  --scores qed sa cnn \
  --out_prefix ${OUTDIR}${PREFIX} \
  --gpu \
  2>&1 | tee -a ${OUTFILE}
```

`-r` and `-l` allow to specify the receptor for the conditional search and `-l` the starting ligand for swarm optimisation. `--n_swarms` insicates the number of independent swarms to use, `--n_particles` indicates the number of particles per swarm and `--iterations` insicates the number of iterations to perform. `--v_min` and `--v_max` are the minimum and maximum value for the uniform distribution used to sample the initial velocities.

`--scores` allow to select the scoring functions to optimise. Desirability functions are hard-coded for the time being and therefore need to be changed directly in the source code of `MSO.py`. `--scores cnn` allows to optimise GNINA CNN scoring function, while `--scores vina` allows to optimise AutoDock Vina scoring function.

## Analysis

### Docking Scores

For `recvae`, ligands are generated conditional to the receptor binding site. Therefore, it is interesting to see how well they dock to the receptor. The script `score.sh` performs docking with GNINA, which gives the AutoDock Vina score but also an additional score obtained with the CNN scoring function. The script `getscores.sh` allows to collect such scores into a single CSV file.

GNINA is described and evaluated in details in the following publications:

> **GNINA 1.0: Molecular docking with deep learning** A McNutt, P Francoeur, R Aggarwal, T Masuda, R Meli, M Ragoza, J Sunseri, DR Koes. ChemRxiv, 2021   
> [ChemRxiv](https://chemrxiv.org/articles/preprint/GNINA_1_0_Molecular_Docking_with_Deep_Learning/13578140)

> **Protein-Ligand Scoring with Convolutional Neural Networks** M Ragoza, J Hochuli, E Idrobo, J Sunseri, DR Koes. *J. Chem. Inf. Model*, 2017 
> [link](http://pubs.acs.org/doi/full/10.1021/acs.jcim.6b00740) [arXiv](https://arxiv.org/abs/1612.02751)  


### RMSD

The script `RMSD.sh` runs `../scripts/rmsd.py` in order to compute the RMSD between the atoms fitted to the density and the final UFF-minimised molecule.

### Analysis

The script `analysys.sh` runs `../scripts/analysis.py` in order to extract interesting and relevant data from `*.gen_metrics` output file and produce ploits of different quantities (QED, SA, ...). 

## Data

### Models and Weights

Models (`.model`) and pre-trained weights (`.caffemodel`) are kindly provided by Matt Ragoza and David Koes. 

Weights are not hosted on GitHub but could be retrieved on the University of Pittsburgh cluster at the following locations:
```
/net/pulsar/home/koes/dkoes/git/liGAN/tomohide/
```

#### Caffe Models

One of the major drawbacks of Caffe is that models are defined in an [external JSON-like file](https://caffe.berkeleyvision.org/tutorial/net_layer_blob.html), therefore network parameters such as `batch_size` are hardcoded in the model definition. The following models are 

### Molecular Caches

Molecular caches (`.molcache` or `.molcache2`) are monolithic files collecting the information contained in a series of `.gninatypes` files. `.gninatypes` binary files are files used by [GNINA](https://github.com/gnina/gnina) and [libmolgrid](https://github.com/gnina/libmolgrid) to represent molecules in a minimal format (only atom types and coordinates) in order to reduce I/O during training and inference.

The `.molcache2` files referenced in the `.model` files can be obtained from [http://bits.csb.pitt.edu/files/molcaches/](http://bits.csb.pitt.edu/files/molcaches/).

Given that we are testing our own systems, the `.molcache2` are removed from the `.model` files. The files `*-nomolcache.model` are custom version of the original models which do not require `.molcache2` inputs.
