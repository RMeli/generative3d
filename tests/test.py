import molgrid

from openbabel import pybel
from openbabel import openbabel as ob

import numpy as np

import torch

FILE = False

lig_map = molgrid.FileMappedGninaTyper("data/lig_map")
rec_map = molgrid.FileMappedGninaTyper("data/rec_map")

print("rec_map.num_types", rec_map.num_types())
print("lig_map.num_types", lig_map.num_types())

if FILE:
    exprovider = molgrid.ExampleProvider(
        rec_map,
        lig_map,
    )
    exprovider.populate("test.types")
    examples = exprovider.next_batch(1)

    ex = examples[0]
else:
    obmol = next(pybel.readfile("sdf", "data/BRD4/sdf/ligand-1_min.sdf")).OBMol
    obmol.AddHydrogens()

    obrec = next(pybel.readfile("pdb", "data/BRD4/pdb/BRD4.pdb")).OBMol
    obrec.AddHydrogens()

    ex = molgrid.Example()

    # Receptor coordinates are needed!
    # If the coordinate set is empty, then a grid of zeros is returned
    #ex.coord_sets.append(molgrid.CoordinateSet(obrec, rec_map))
    fakerec = pybel.readstring("smi", "C").OBMol
    ex.coord_sets.append(molgrid.CoordinateSet(fakerec, rec_map))
    #ex.coord_sets.append(molgrid.CoordinateSet(ob.OBMol(), rec_map))
    ex.coord_sets.append(molgrid.CoordinateSet(obmol, lig_map))

    ex.labels.append(0)

print(type(ex), len(ex.coord_sets), len(ex.labels))
print(len(ex.coord_sets[0].coords), len(ex.coord_sets[1].coords))

#print(np.array(ex.coord_sets[1].coords))

grid_maker = molgrid.GridMaker(0.5, 23.5)
grid_dims = grid_maker.grid_dimensions(rec_map.num_types() + lig_map.num_types())

print("grid_sims", grid_dims)

grid = torch.zeros(1, *grid_dims, dtype=torch.float32, device="cuda")

transform = molgrid.Transform(
    ex.coord_sets[1].center(),
    0.0, # Random translation
    False, # Random rotation
)

transform.forward(ex, ex)
grid_maker.forward(ex, grid[0]) # Select first batch

rec = grid[0,:rec_map.num_types(),...].cpu().numpy()
lig = grid[0,rec_map.num_types():,...].cpu().numpy()

print("rec.shape", rec.shape)
print("lig.shape", lig.shape)

assert not np.allclose(rec, 0.0)
assert not np.allclose(lig, 0.0)
