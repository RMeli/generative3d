The `BRD4ob.pdb` file has been obtained by removing all hydrogen atoms from the `BRD4.pdb` file using
```bash
obabel -ipdb data/BRD4/pdb/BRD4.pdb -opdb -O data/BRD4/pdb/BRD4ob.pdb -d
```