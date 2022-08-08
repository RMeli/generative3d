# Generative3D

Generative models for 3D structures. Based on [liGAN](https://github.com/mattragoza/liGAN).

In order to run the scripts contained in this repository, two additional repositories are needed:

* [liGAN](https://github.com/mattragoza/liGAN)
* [GNINA](https://github.com/gnina/gnina)

This README file provides a general overview of the repository and associated containers, code and files. Instructions on how to run liGAN in a container are provided in `ligae/README` while instructions on how to use liGAN generative models are provided in `ligvae/README` and `recvae/README`.

### Papers

[liGAN](https://github.com/mattragoza/liGAN) is described in the following conference papers:
* [Learning a Continuous Representation of 3DMolecular Structures with Deep Generative Models](https://arxiv.org/pdf/2010.08687.pdf)
* [Generating 3D Molecular Structures Conditional on aReceptor Binding Site with Deep Generative Models](https://arxiv.org/pdf/2010.14442.pdf)

### Code

The main [liGAN](https://github.com/mattragoza/liGAN) script to generate new molecules from pre-trained models is `liGAN/generate.py`. The different arguments for this scipt are [described within the code](https://github.com/mattragoza/liGAN/blob/6f235f2e998614c643f01361299d7560a1106c42/generate.py#L2262-L2320), and the arguments used are further described in `ligvae/README` and `recvae/README`.

## Containers

[liGAN](https://github.com/mattragoza/liGAN) requires [libmolgrid](https://github.com/gnina/libmolgrid) and [Caffe](https://caffe.berkeleyvision.org/) ([GNINA](https://github.com/gnina/gnina)'s fork of Caffe) to run, as well as [RDKit](https://github.com/rdkit/rdkit), [Open Babel](https://github.com/openbabel/openbabel), and [PyTorch](https://pytorch.org/).

Given the complex dependencies, [Docker](https://www.docker.com/) and [Singularity](https://sylabs.io/singularity/) containers are provided.

### Notes

* Originally, only the Docker container was available, therefore the scripts in `ligvae` and `recvae` are tailored to run within the Docker container. `ligae` contains both example scripts for Docker and Singularity.
* [liGAN](https://github.com/mattragoza/liGAN) use [Caffe](https://caffe.berkeleyvision.org/) as main deep learning backend. Some parts requiring automatic differentiation (such as fitting atoms to a generated density) are implemented in PyTorch, but the generative models are implemented in Caffe. 
* Caffe is [discontinued (maintenance-only)](https://github.com/BVLC/caffe/releases/tag/1.0). A PyTorch refactoring of `liGAN` is currently underway in the [`refactor` branch](https://github.com/mattragoza/liGAN/tree/refactor).
## GNINA Legacy

[liGAN](https://github.com/mattragoza/liGAN) uses [GNINA](https://github.com/gnina/gnina)'s fork of Caffe as main deep learning backend and [libmolgrid](https://github.com/gnina/libmolgrid), therefore some files and definitions come from [GNINA](https://github.com/gnina/gnina)'s legacy.

Caffe uses JSON-like files to define deep learning models and therefore some variables are hard-coded in such files and occasionally need to be changed.

### Molecular Caches

Caffe models used by [GNINA](https://github.com/gnina/gnina) and [liGAN](https://github.com/mattragoza/liGAN) contain `MolGridData` layers for molecular input and gridding, and often refer to molecular cache files (through paths hard-coded in variables `ligmolcache` and `recmolcache` variables). Molecular caches (with extension `.molcache` or `.molcache2`) are monolithic files collecting the information contained in a series of `.gninatypes` files. `.gninatypes` binary files are files used by [GNINA](https://github.com/gnina/gnina) and [libmolgrid](https://github.com/gnina/libmolgrid) to represent molecules in a minimal format (only atom types and coordinates) in order to reduce I/O during training and inference. `.gninatypes` files are computed during pre-processing and can be [combined together into molecular caches](https://github.com/gnina/scripts/blob/master/create_caches2.py).

The `.molcache2` files referenced in the `.model` files can be obtained from [http://bits.csb.pitt.edu/files/molcaches/](http://bits.csb.pitt.edu/files/molcaches/).

Molecular caches are only useful when training and testing with large dataset and are not useful when using pre-trained models on a small number of system. In order to avoid using molecular caches, the variables `recmolcache` and `ligmolcache` can be removed from the `.model` files. The files `*-nomolcache.model` are custom version of the original models which do not require `.molcache2` inputs.

### Custom Caffe Models

One of the major drawbacks of Caffe is that models are defined in an [external JSON-like file](https://caffe.berkeleyvision.org/tutorial/net_layer_blob.html), therefore network parameters such as `batch_size` are hardcoded in the model definition. The `*-nomolcache-bs*.model` files provide models with a different `batch_size` (useful for interpolation).

The `batch_size` is usually the first dimension of the tensors.

### Data Files

Input files containing the ligand (`ligvae`) and the ligand/receptor pair (`recvae`) to use as seed for the generative model have the following structure:
```
<POSE_ANNOTATION> <BINDING_AFFINITY> <RECEPTOR_FILE> <LIGAND_FILE>
```

Because of the way the `MolGridData` layer works and how liGAN is coded, all the fields are needed. The first two fields are never used, while the receptor field is used only for the `recvae` model.

## Conventions

### File Names

All file names are prepended by a `PREFIX` that uniquely identifies the run. The molecules obtained from the input ligand density (singe they are obtained from the `lig` blob) are denoted by `lig` while the molecules obtained from the output (generated) densities are denoted by `lig_gen` (since they are generated from the `lig_gen` blob). Files also have a `SUFFIX` that identify the procedure performed to obtain the ligand.

For example, SDF file names have the following structure:
```
<PREFIX>_<LIGAND_NAME>_lig_<SUFFIX>.sdf # Molecules from original (input) density
<PREFIX>_<LIGAND_NAME>_lig_gen_<SUFFIX>.sdf # Molecules from generated (output) density
```

The main `SUFFIX`es of interest (for both `lig` and `lig_gen` blobs) are the following:
* `_fit`: atoms fitted to the density (no bonds added)
* `_fit_add`: atoms fitted to the density and bonds added (full reconstructed molecule)
* `_fit_uff`: `_fit_add` molecule minimised with UFF

For the `lig` blob (`_lig_fit`, `_lig_fit_add`, `_lig_fit_uff`), atoms are fitted to the density obtained from the original ligand. For the `lig_gen` blob (`_lig_gen_fit, `_lig_gen_fit_add`, `_lig_gen_fit_uff`), atoms are fitted to the generated density.

For the `lig` blob there are other possible `SUFFIX`es:
* `_src`: original ligand (with bonds)
* ` ` (no `SUFFIX`): origina ligand without bond information
* `_add`: bonds re-added to the original ligand (``, no `SUFFIX`)
* `_uff`: UFF-minimised ligand


The different `SUFFIX`es correspond to different paths in [Learning a Continuous Representation of 3DMolecular Structures with Deep Generative Models - Figure 1](https://arxiv.org/pdf/2010.08687.pdf).

## Models

### Ligand Autoencoder

`ligae` contains models and weights defining the ligand autoencoder, as well as test scripts to run liGAN within the Docker and Singularity containers. Original models and weights were provided by David Koes.

### Ligand Variational Autoencoder

`ligvae` contains models and weights defining the ligand autoencoder, as well as scripts to run liGAN within the Docker container (generation, interpolation, prior sampling, MSO). Original models and weights were provided by David Koes.


### Receptor-Conditional Variational Autoencoder

`recvae` contains models and weights defining the receptor-conditional variational autoencoder, as well as scripts to run liGAN within the Docker container (generation, interpolation, prior sampling, MSO). Original models and weights were provided by David Koes.

