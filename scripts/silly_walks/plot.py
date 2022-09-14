import pandas as pd

import seaborn as sns
from matplotlib import pyplot as plt

tag = "real"

df_BRD4 = pd.read_csv(f"silly_{tag}_BRD4.csv")
df_BRD4["system"] = "BRD4"

df_CDK2 = pd.read_csv(f"silly_{tag}_CDK2.csv")
df_CDK2["system"] = "CDK2"

df = pd.concat([df_BRD4, df_CDK2])

sns.displot(df, x="silly", hue="system")
plt.savefig(f"silly-{tag}.png")
