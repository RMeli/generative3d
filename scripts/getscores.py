"""
Extract VINA and GNINA results from output SDF file
with optimized ligand poses
"""

from rdkit import Chem

import pandas as pd

from collections import defaultdict

import argparse as ap
import sys
import os

parser = ap.ArgumentParser(description="Extract GNINA results from SDF file")

parser.add_argument("mols", type=str, help="First SDF file")
parser.add_argument("-o", "--output", default=None, type=str, help="Output CSV file")
args = parser.parse_args()

Smols = Chem.SDMolSupplier(args.mols)

data = defaultdict(list)

for i, mol in enumerate(Smols):
    if mol is None:
        print(f"WARNING: Molecule {i} in {args.mols} could not be parsed!")
        continue

    n = mol.GetProp("_Name")
    vinascore = float(mol.GetProp("minimizedAffinity"))
    cnnscore = float(mol.GetProp("CNNscore"))
    cnnaffinity = float(mol.GetProp("CNNaffinity"))

    data["sample"].append(n)
    data["vinaaffinity"].append(vinascore)
    data["cnnaffinity"].append(cnnaffinity)
    data["cnnscore"].append(cnnscore)

if args.output is None:
    name = args.mols.replace("_vina.sdf", "")
    tag = "_scores.csv"

    outname = name + tag
else:
    outname = args.output

df = pd.DataFrame.from_dict(data)
df.to_csv(outname, index=False, float_format="%.5f")
