from molecules import rd_mol_to_ob_mol

from rdkit import Chem
from rdkit.Chem import AllChem
from openbabel import pybel

rdmol = Chem.MolFromSmiles("c1ccccc1")
rdmol = Chem.AddHs(rdmol)
AllChem.EmbedMolecule(rdmol)

w = Chem.SDWriter('rdmol.sdf')
w.write(rdmol)
w.close()

obmol = rd_mol_to_ob_mol(rdmol)

pybel.Molecule(obmol).write("sdf", "obmol.sdf", overwrite=True)
