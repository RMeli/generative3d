"""
Extract and plot data from 'gen_metrics' files.
"""

import pandas as pd
import numpy as np

from rdkit import Chem
import rdkit.Chem.PandasTools as PandasTools

PandasTools.InstallPandasTools()

import seaborn as sns
from matplotlib import pyplot as plt

import argparse as ap
import os

blobs = ["lig", "lig_gen"]
suffixes = [
    "_fit_n_atoms",
    "_fit_type_diff",
    "_fit_RMSD",
    "_fit_add_rdkit_sim",
    "_fit_add_morgan_sim",
    "_fit_add_maccs_sim",
    "_fit_add_dE_min",
    "_fit_add_RMSD_min",
    "_fit_add_min_RMSD_ref",
    "_fit_add_QED",
]

columns = ["lig_name", "sample_idx", "lig_n_atoms"] + [
    b + s for s in suffixes for b in blobs
]

to_plot = [
    "_fit_type_diff",
    "_fit_add_rdkit_sim",
    "_fit_add_morgan_sim",
    "_fit_add_maccs_sim",
    "_fit_add_min_RMSD_ref",
    "_fit_add_QED",
]

parser = ap.ArgumentParser(description="Train affinity prediction model.")

parser.add_argument("datafiles", type=str, nargs="+", help="Path to data file(s)")
parser.add_argument(
    "--add", type=str, default=[], nargs="+", help="Additional columns to consider"
)
parser.add_argument("-o", "--output", type=str, default="", help="Output path")
parser.add_argument("--pdf", action="store_true", help="Output PDF files")
parser.add_argument(
    "--similarity", type=float, default=-1.0, help="Similarity threshold (Morgan FP)"
)
parser.add_argument(
    "--nomols", action="store_false", help="Do not output 2D depiction of molecules"
)

args = parser.parse_args()

columns += args.add

for f in args.datafiles:
    print(f">>> {f}")
    df = pd.read_csv(f, sep=" ")
    df["lig_name_idx"] = df["lig_name"] + " " + df.index.astype(str)
    print(df[columns], "\n")

    df = df[df["lig_gen_fit_add_rdkit_sim"] > args.similarity]

    prefix = os.path.splitext(os.path.basename(f))[0] + "_"

    for blob in blobs:
        for suffix in to_plot:
            # Column to plot
            y = blob + suffix

            plt.figure()

            ax = sns.boxplot(x="lig_name", y=y, data=df)
            ax = sns.swarmplot(x="lig_name", y=y, data=df, ax=ax)
            ax.tick_params(axis="x", labelrotation=45)

            plt.tight_layout()

            fnpath = os.path.join(args.output, prefix + y)
            for ext in [".png", ".pdf"] if args.pdf else [".png"]:
                plt.savefig(fnpath + ext)
            plt.close()

        if args.nomols:
            df[f"{blob}_mol"] = df.apply(
                lambda r: Chem.MolFromSmiles(r[f"{blob}_fit_add_SMILES"]), axis=1
            )
            img = PandasTools.FrameToGridImage(
                df, column=f"{blob}_mol", legendsCol="lig_name_idx", molsPerRow=25
            )
            # img.save(os.path.join(args.output, prefix + f"{blob}_molecules.svg"))
            img.save(os.path.join(args.output, prefix + f"{blob}_molecules.png"))

            for l in [f"{blob}_fit_add_morgan_sim", f"{blob}_fit_add_QED"]:
                img = PandasTools.FrameToGridImage(
                    df, column=f"{blob}_mol", legendsCol=l, molsPerRow=25
                )
                img.save(os.path.join(args.output, prefix + f"{l}_molecules.png"))
