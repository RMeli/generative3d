# Scripts

Useful script for pre- and post-processing.

## `analysis.py`

The script `analysis.py` extract and analyse data from `*.gen_metrics` files. It produces different plots, especially box plots grouped by ligand.

## `getscores.py`

The script `getscores.py` allows to extract Vina and GNINA scores from the output SDF file obtained by minimising the ligand pose within the receptor.

## `ligan.py`

The script `ligan.py` allows to visualise SDF and DX files from `liGAN` using `pymol`.

To load the command in PyMol:
```bash
pymol ligand.py
```

To run the command in PyMol
```
ligan <LIGAND_NAME>, <RUN_PREFIX>{, <CAFFE_BLOB>, <PATH_TO_INPUT_DATA>, <PATH_TO_GENERATED_DATA>, <RECEPTOR_FILE>, <NUMBER_OF_SAMPLES>}  
```
where `<LIGAND_NAME>` is the name of the ligand (in the `*.types` file), `<RUN_PREFIX>` is the prefix identifying the run, `<CAFFE_BLOB>` is the Caffe blob from which the output files have been generated (usually `lig` for the original density and `lig_gen` for the generated density), `<PATH_TO_INPUT_DATA>` is the path to input data (in the `*.types` file), `<PATH_TO_GENERATED_DATA>` is the path to generated data, `<RECEPTOR_FILE>` is the receptor file (if present) and `<NUMBER_OF_SAMPLES>` is the number of generated samples.

## `rdopt.py`

Optimisation of input ligand (in SDF file) using RDKit's UFF. This is needed to prepare the ligands for the ligand-only model since the model has been trained on conformers obtained with RDKit, which are local minima of RDKit's UFF.

## `RMSD.py`

Compute pairwise RMSD (with symmetry corrections) between molecules in two distinct SDF files. The moleculecules are paired by index but need to have the same name (which in `liGAN` corresponds to the sample number).

