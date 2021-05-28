# CDK2


For our evaluation, we used the the CSAR CDK2 Kinase dataset available on the [D3R website](https://drugdesigndata.org/about/datasets). The dataset contains active molecules and decoys. We downloaded the active molecules together with the associate protein structure from the PDB, while we discarded all inactive. 

Ligand CS12 (PDB ID 4FKL) was discarded because lacking of experimental binding affinity. Ligands CS2, CS5, CS13, CS14, CS15, CS17, CS244 and CS247 were discarded for lack of associated PDB ID. PDB ID 4FJK in the dataset did not correspond to CDK2, therefore the correct system (PDB ID 4FKJ) was downloaded instead.

The CDK2 inhibitors retained come from three different chemical series. In order to reduce the number of systems to test, we selected the first and last compound of each series.

The target structures are superimposed using ChimeraX alignment tool, and all solvent molecules as well as ions and crystallisation co-factors are removed.
