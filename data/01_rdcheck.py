"""
Load all SDF files to see if there is any problem.
"""

from rdkit import Chem

import os

folders = ["BRD4/sdf", "CDK2/data"]

for folder in folders:
    for f in os.listdir(folder):
        _, ext = os.path.splitext(f)
        if ext == ".sdf":
            print(f"Checking {f} in {folder}... ", end="")

            failed = False
            suppl = Chem.SDMolSupplier(os.path.join(folder, f))
            for i, mol in enumerate(suppl):
                if mol is None:
                    print(f"\n   !!! Problems with {f} in {folder} (index {i})")
                    failed = True

            if not failed:
                print("OK")
