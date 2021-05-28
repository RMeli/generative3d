"""
Create PNG images with skeletal formulae from SDF files.
"""

import numpy as np

from rdkit import Chem
from rdkit.Chem import Draw, AllChem

import argparse as ap
import os

parser = ap.ArgumentParser(description="Show molecules from SDF files.")

parser.add_argument("sdffiles", type=str, nargs="+", help="Path to SDF file(s)")
parser.add_argument(
    "-o", "--output", type=str, default="molecules.png", help="Output path"
)

args = parser.parse_args()

names = []
mols = []
for f in args.sdffiles:
    sdfsupp = Chem.SDMolSupplier(f)
    mol = next(sdfsupp)  # Only first molecule
    AllChem.Compute2DCoords(mol)
    mols.append(mol)

    names.append(os.path.splitext(os.path.basename(f))[0])

img = Draw.MolsToGridImage(mols, molsPerRow=5, subImgSize=(500, 500), legends=names)
img.save(os.path.join(args.output))
