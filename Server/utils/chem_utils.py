from rdkit import Chem

def validate_smiles(smiles: str) -> bool:
    """
    Validates a string as a SMILES representation using RDKit.
    Returns True if the string is a valid SMILES, False otherwise.
    """
    try:
        mol = Chem.MolFromSmiles(smiles)
        return mol is not None
    except:
        return False