"""
Geometry optimization with RDKit UFF force field.
"""

from rdkit import Chem
from rdkit.Chem import AllChem

import argparse
import os

parser = argparse.ArgumentParser(description="Geometry optimization using RDKit UFF")
parser.add_argument("files", type=str, nargs="+", help="SDF files")
args = parser.parse_args()

for f in args.files:
    fname, ext = os.path.splitext(f)
    print(f"Minimising molecules in {fname}... ")

    suppl = Chem.SDMolSupplier(f)

    w = Chem.SDWriter(fname + "_min" + ext)

    for idx, mol in enumerate(suppl):
        if mol is None:
            print(f"    FAIL Failed to parse conformation {idx} in {fname}")
            continue

        mol.UpdatePropertyCache()  # https://github.com/rdkit/rdkit/issues/1596

        mol_H = Chem.AddHs(mol, addCoords=True)

        ff = AllChem.UFFGetMoleculeForceField(mol_H, confId=0)
        ff.Initialize()

        Ei = ff.CalcEnergy()
        result = ff.Minimize(maxIts=100)
        Ef = ff.CalcEnergy()

        mol_min = Chem.RemoveHs(mol_H, sanitize=False)

        w.write(mol_min)

        print(f"    Ei = {Ei:.3f}\tEf = {Ef:.3f}\tdE = {Ef - Ei:.3f}")
