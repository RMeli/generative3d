import pandas as pd

df = pd.read_csv("CDK2.csv")

to_keep = [
    "Compound_ID",
    "SMILES",
    "Chemical Series",
    "Experimental Result, Average Value",
    "Experimental Result, Unit",
    "PDB ID",
]
df = df[to_keep]

to_rename = {
    "Compound_ID": "compound",
    "Chemical Series": "series",
    "Experimental Result, Average Value": "Kd",
    "Experimental Result, Unit": "unit",
    "PDB ID": "pdbid",
}
df.rename(columns=to_rename, inplace=True)

# Change 4FJK to 4FKJ
df.loc[df.pdbid == "4FJK", "pdbid"] = "4FKJ"

# Add ligand ID
ligid = {
    "3SW4": "18K",
    "3SW7": "19K",
    "4EK4": "1CK",
    "4EK5": "03K",
    "4EK6": "10K",
    "4EK8": "16K",
    "4FKG": "4CK",
    "4FKI": "09K",
    "4FKJ": "11K",
    "4FKO": "20K",
    "4FKP": "LS5",
    "4FKQ": "42K",
    "4FKR": "45K",
    "4FKS": "46K",
    "4FKT": "48K",
    "4FKU": "60K",
    "4FKV": "61K",
    "4FKW": "62K",
}
df.set_index("pdbid", drop=False, inplace=True)
df = df.join(pd.DataFrame().from_dict(ligid, orient="index", columns=["ligid"]))

# TODO: Add ligand chain?

# Drop systems with no connectivity
df.drop(index=["4EK6", "4EK8"], inplace=True)

df.to_csv("CDK2_clean.csv")
