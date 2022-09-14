"""
Load SDF and DX files for visualization in PyMol
"""

from pymol import cmd

import numpy as np

import glob
import os


def ligan(
    name,
    prefix,
    blob="lig_gen",
    # BRD4 on Linux system
    path="../data/BRD4/sdf/",
    # CDK2 through Windows system
    # path="..\\data\\CDK2\\data\\",
    # genpath="..\\..\\generated-results\\",
    genpath="generated-small/",
    recpath="../data/BRD4/pdb/BRD4.pdb",
    # recpath="..\\data\\CDK2\\data\\3SW4.pdb",
    nsamples=10,
):
    cmd.reinitialize("everything")

    cmd.load(path + f"{name}.sdf", "SEED")

    xyz = cmd.get_coords("SEED", 0)
    c = np.mean(np.array(xyz), axis=0)

    # Load SDF files
    cmd.load(genpath + prefix + f"_{name}_{blob}_fit.sdf.gz", f"ATOMS-{blob}")
    cmd.load(genpath + prefix + f"_{name}_{blob}_fit_add.sdf.gz", f"BONDS-{blob}")
    cmd.load(genpath + prefix + f"_{name}_{blob}_fit_uff.sdf.gz", f"UFF-{blob}")
    cmd.load(genpath + prefix + f"_{name}_{blob}_vina.sdf.gz", f"VINA-{blob}")

    # Load receptor
    cmd.load(recpath, "rec")

    # Translate to origin
    for o in ["SEED", "ATOMS", "BONDS", "UFF", "VINA", "rec"]:
        cmd.translate(list(-c), o, state=0, camera=0)

    cmd.show("sphere", "ATOMS")
    cmd.set("sphere_scale", 0.25, "ATOMS")
    cmd.set("stick_radius", 0.2, "SEED")

    for s in range(nsamples):
        for f in glob.glob(genpath + prefix + f"_{name}_{blob}_fit_{s}_Ligand*.dx"):
            to_remove = genpath + prefix + f"_{name}_{blob}_fit_{s}_"
            namedx = f.replace(to_remove, "")

            cmd.load(f, namedx)
            cmd.isomesh("m" + namedx, namedx, 0.5)

            if "Oxygen" in namedx:
                cmd.color("red", "m" + namedx)
            elif "Nitrogen" in namedx:
                cmd.color("blue", "m" + namedx)
            elif "Carbon" in namedx:
                if "Aromatic" in namedx:
                    cmd.color("grey", "m" + namedx)
                else:
                    cmd.color("white", "m" + namedx)
            else:
                cmd.color("purple", "m" + namedx)


cmd.extend("ligan", ligan)
