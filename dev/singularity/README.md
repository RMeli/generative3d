# Singularity container

This directory contains the [Singularity container](https://sylabs.io/guides/3.7/user-guide/introduction.html#why-use-singularity), along with its [definition file](https://sylabs.io/guides/3.7/user-guide/definition_files.html), to run GNINA and/or its Python environment.

*Note:* The `debs` sub-folder contains the debian packages that are needed to build the container with cuDNN (v.7) enabled. Theses packages are included in this repo because a NVIDIA developer's account is needed to download them. Because of the required user's authentification, it is cumbersome to try to download them when building the container.

## Building the container

To build the container, you need administrative (root) access on your build system:

```shell
sudo singularity build gnina.sif gnina.def
```

*Note:* It takes 15-20 minutes to build the container image.

The building process ends with a simplistic test to make sure that Gnina and Python are both accessible.
It thus should end with the following lines:

```text
Testing Python installation...
RDKIT 2021.03.1 is installed
Openbabel 3.1.0 is installed
molgrid is installed
Caffe 1.0.0 is installed
Python installation is OK

Testing GNINA execution...
    1      -10.03       0.9903      7.446
GNINA succesfully tested
```

## Running the container

### GNINA

To use the container to run GNINA, the `--app gnina` option needs to specified. Here is an example:

```shell
singularity run --app gnina gnina.sif --help
```

This command should display GNINA's help menu.

### Python

To use the container to run Python, the `--app python` option needs to specified. Here is an example:

```shell
singularity run --app python gnina.sif myscript.py
```

This command should use the python interpreter from the container to run `myscript.py`.

*Note:* Without any arguments `singularity run --app python` will simply launch the python interpreter.

### GPU awareness

By default, singularity does not give access to the GPU(s) present on the host. the `--nv` option must be used to access the GPU(s).

Example with GNINA:

```shell
> singularity run --nv --app gnina gnina.sif -r /gnina-examples/rec.pdb -l /gnina-examples/lig.sdf --autobox_ligand /gnina-examples/lig.sdf --seed 2 --num_modes=5 --cnn crossdock_default2018
Running gnina with the following parameters: -r /gnina-examples/rec.pdb -l /gnina-examples/lig.sdf --autobox_ligand /gnina-examples/lig.sdf --seed 2 --num_modes=5 --cnn crossdock_default2018
              _
             (_)
   __ _ _ __  _ _ __   __ _
  / _` | '_ \| | '_ \ / _` |
 | (_| | | | | | | | | (_| |
  \__, |_| |_|_|_| |_|\__,_|
   __/ |
  |___/

gnina v1.0.1 HEAD:aa41230   Built Apr 19 2021.
gnina is based on smina and AutoDock Vina.
Please cite appropriately.

Commandline: gnina -r /gnina-examples/rec.pdb -l /gnina-examples/lig.sdf --autobox_ligand /gnina-examples/lig.sdf --seed 2 --num_modes=5 --cnn crossdock_default2018
Using random seed: 2

0%   10   20   30   40   50   60   70   80   90   100%
|----|----|----|----|----|----|----|----|----|----|
***************************************************

mode |  affinity  |    CNN     |   CNN
     | (kcal/mol) | pose score | affinity
-----+------------+------------+----------
    1      -10.03       0.9903      7.446
    2       -8.61       0.9685      7.098
    3       -8.22       0.9655      6.880
    4       -8.96       0.9121      6.715
    5       -7.09       0.7697      6.230

```

Example with Python:

```shell
> singularity run --nv --app python gnina.sif -c "import torch;print(torch.cuda.is_available());print(torch.cuda.device_count());print(torch.cuda.get_device_name())"
Running python with the following parameters: -c import torch;print(torch.cuda.is_available());print(torch.cuda.device_count());print(torch.cuda.get_device_name())
True
2
Tesla V100-SXM2-32GB
```
