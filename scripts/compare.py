"""
Load SDF and DX files for both AE and VAE models.
"""

from pymol import cmd

import numpy as np

import glob
import os


def color(namedx):
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


def compare(
    name,
    aeprefix,
    vaeprefix,
    blob="lig_gen",
    aepath="ligae/generated/",
    vaepath="ligvae/generated/",
    path="data/BRD4/sdf/",
    nsamples=5,
):
    """
    Compare AE and VAE inpout/generated densities and molecules.

    Parameters
    ----------
    name:
        ligand name
    aeprefix:
        AE prefix
    vaeprefix:
        VAE prefix
    blob:
        Caffe blob used to generate densities (lig or lig_gen)
    aepath:
        Path to AE files
    vaepath:
        Path to VAE files
    path:
        Path to original files
    n_samples:
        Number of VAE samples
    """

    cmd.reinitialize("everything")

    cmd.load(path + f"{name}.sdf", "SEED")

    xyz = cmd.get_coords("SEED", 0)
    c = np.mean(np.array(xyz), axis=0)

    # Load SDF files for AE
    cmd.load(aepath + aeprefix + f"_{name}_{blob}_fit.sdf", f"ATOMS-{blob}-AE")
    cmd.load(aepath + aeprefix + f"_{name}_{blob}_fit_add.sdf", f"BONDS-{blob}-AE")
    cmd.load(aepath + aeprefix + f"_{name}_{blob}_fit_uff.sdf", f"UFF-{blob}-AE")

    # Load SDF filed for VAE
    cmd.load(vaepath + vaeprefix + f"_{name}_{blob}_fit.sdf", f"ATOMS-{blob}-VAE")
    cmd.load(vaepath + vaeprefix + f"_{name}_{blob}_fit_add.sdf", f"BONDS-{blob}-VAE")
    cmd.load(vaepath + vaeprefix + f"_{name}_{blob}_fit_uff.sdf", f"UFF-{blob}-VAE")

    xyz = cmd.get_coords("SEED", 0)
    c = np.mean(np.array(xyz), axis=0)
    cmd.translate(list(-c), "SEED", state=0, camera=0)

    # Translate to origin
    for model in ["AE", "VAE"]:
        for o in [
            f"ATOMS-{blob}-{model}",
            f"BONDS-{blob}-{model}",
            f"UFF-{blob}-{model}",
        ]:
            cmd.translate(list(-c), o, state=0, camera=0)

    # Translate to origin
    # for o in ["SEED", "ATOMS", "BONDS", "UFF"]:
    #    cmd.translate(list(-c), o, state=0, camera=0)

    for s in [f"ATOMS-{blob}-AE", f"ATOMS-{blob}-VAE"]:
        cmd.show("sphere", s)
        cmd.set("sphere_scale", 0.25, s)

    cmd.set("stick_radius", 0.2, "SEED")

    # Load AE grids (only index 0)
    for f in glob.glob(aepath + aeprefix + f"_{name}_{blob}_fit_0_Ligand*.dx"):
        to_remove = aepath + aeprefix + f"_{name}_{blob}_fit_0_"
        namedx = f.replace(to_remove, "AE")

        cmd.load(f, namedx)
        cmd.isomesh("m" + namedx, namedx, 0.5)

        color(namedx)

    # Load VAE grids
    for s in range(nsamples):
        for f in glob.glob(vaepath + vaeprefix + f"_{name}_{blob}_fit_{s}_Ligand*.dx"):
            to_remove = vaepath + vaeprefix + f"_{name}_{blob}_fit_{s}_"
            namedx = f.replace(to_remove, "VAE")

            cmd.load(f, namedx)
            cmd.isomesh("m" + namedx, namedx, 0.5)

            color(namedx)


cmd.extend("compare", compare)

# vi:expandtab
