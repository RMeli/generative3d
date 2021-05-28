# Data

Directory for data files. It contains various data files, such as ligand/receptor maps, types files and PDB/SDF structures.

## Ligand and Receptor Maps

`lig_map` and `rec_map` conatin the list of atom types supported by the current models. They correspond to `smina` atom types.

Such files are needed in the definition of Caffe models, more precisely for the `MolGridData` layer in the data model.

## Types Files

The `*.types` files contain a series of ligand/receptor pairs to use as seed of the variational autoencoder (via `--data_file`). The first two columns usually represent the pose annotation (`0` or `1`) and the experimental binding affinity; here they are set to `1` and `0.0`, respectively. This is necessary since the `read_examples_from_data_file` function in `generate.py` assumes the receptor and ligand to be in columns 3 and 4:

```python
rec_file, lig_file = line.rstrip().split()[2:4]
```

This is legacy from [GNINA](https://github.com/gnina/gnina).

## Scripts

* `01_rdcheck.py`: script to check that the downloaded molecular data can be parsed by RDKit
* `02_optimize`: optimize ligands with RDKit's UFF so that they are similar to training set

## Datasets

### BRD4

[BRD4(1) benchmark set](https://github.com/MobleyLab/benchmarksets/tree/master/input_files/BRD4) for free energy calcularions.

Types files for BRD4:
* `BRD4.types`: contain BRD4 and 10 BRD4 inhibitors, to be used as seed for the auto-encoders
* `BRD4prior.types`: contain BRD4 and a single BRD4 inhibitor (which defines the binding site for prior sampling)
* `BRD4interpolation.types`: contain pairs of BRD4 inhibitors for interpolation between pairs

### CDK2

[D3R Challange CDK2 dataset](https://drugdesigndata.org/about/datasets `00_download.sh`: script to download some of the molecular data).

Types files for CDK2:
* `CDK2lig.types`: contain 6 CDK2 ligand/receptor pairs, to be used as seed for `ligvae`
* `CDK2rec.types`: contain 6 CDK2 ligand/receptor pairs, to be used as seed for `recvae`
* `CDK2prior.types`: contain a single CDK2 ligand/receptor pair (which defines the binding site for prior sampling)


