"""
Compute pairwise RMSD between molecules in two SDF files.

The files are iterated together and molecules need to have the same name.
"""

from rdkit import Chem

from spyrmsd import spyrmsd
from spyrmsd.optional import rdkit as rd

import pandas as pd

from collections import defaultdict

import argparse as ap
import sys
import os

parser = ap.ArgumentParser(
    description="Element-wise RMSD calculations between molecules in two SDF files."
)

parser.add_argument("mols1", type=str, help="First SDF file")
parser.add_argument("mols2", type=str, help="Second SDF file")
parser.add_argument("-m", "--minimize", action="store_true", help="Minimium RMSD")
parser.add_argument("-o", "--output", type=str, help="Output CSV file")
args = parser.parse_args()

mols1 = args.mols1
mols2 = args.mols2

Smols1 = Chem.SDMolSupplier(mols1)
Smols2 = Chem.SDMolSupplier(mols2)

data = defaultdict(list)

for i, (mol1, mol2) in enumerate(zip(Smols1, Smols2)):
    if mol1 is None:
        print(f"WARNING: Molecule {i} in {mols1} could not be parsed!")
        continue
    if mol2 is None:
        print(f"WARNING: Molecule {i} in {mols2} could not be parsed!")
        continue

    n1 = mol1.GetProp("_Name")
    n2 = mol2.GetProp("_Name")

    name = (
        os.path.basename(mols1).replace("_fit_add.sdf", "").replace("_fit_uff.sdf", "")
    )

    if n1 != n2:
        # Allow off-by-one problems
        if int(n1) < int(n2):
            while int(n1) != int(n2):
                mol1 = next(Smols1)
                n1 = mol1.GetProp("_Name")
            # assert mol1.GetProp("_Name") == n2
        elif int(n2) < int(n1):
            while int(n2) != int(n1):
                mol2 = next(Smols2)
                n2 = mol2.GetProp("_Name")
        else:
            raise RuntimeError(f"Different names {n1} and {n2}...")

    assert n1 == n2

    m1 = rd.to_molecule(mol1)
    m2 = rd.to_molecule(mol2)

    try:
        rmsd = spyrmsd.rmsdwrapper(m1, [m2], strip=True, minimize=args.minimize)
    except Exception as e:
        print(f"ERROR: Failed to computed RMSD between {n1} and {n2}.", e)

    data["rmsd"].append(rmsd[0])
    data["sample"].append(n1)

if args.output is None:
    name = mols1.replace("_fit_add.sdf", "").replace("_fit_uff.sdf", "")
    tag = "_RMSDmin.csv" if args.minimize else "_RMSD.csv"

    outname = name + tag
else:
    outname = args.output

df = pd.DataFrame.from_dict(data)
df.to_csv(outname, index=False, float_format="%.5f")
