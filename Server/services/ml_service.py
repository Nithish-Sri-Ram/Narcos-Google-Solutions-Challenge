from typing import Dict, Any, Tuple, List
import uuid
import pandas as pd
import os
import json
from google import genai
from admet.scrape import automate_download
from binding_affinity.plapt import Plapt

def call_gemini_api(prompt: str) -> str:
    """
    Calls the Gemini API directly with the given prompt.
    Returns the LLM's response as a string.
    """
    try:
        api_key = os.environ.get("GEMINI_API_KEY")
        if not api_key:
            raise ValueError("Gemini API key is required as environment variable.")
            
        client = genai.Client(api_key=api_key)
        model = "gemini-2.0-flash"
        
        response = client.models.generate_content(
            model=model,
            contents=prompt
        )
        
        if response.text:
            return response.text
        else:
            return ""
    except Exception as e:
        print(f"Error calling Gemini API: {e}")
        return ""

def run_ml_model(parameters: Dict[str, Any]) -> str:
    """
    Runs the appropriate ML model based on the task specified in parameters.
    Returns a user-friendly explanation of the results.
    """
    task = parameters.get("task", "").lower()
    smiles_list = parameters.get("smiles", [])
    
    if not smiles_list:
        return "Error: No valid SMILES strings provided for prediction."
    
    if "@admet_prediction" in task:
        return run_admet_prediction(smiles_list)
    elif "@binding_affinity" in task:
        protein_sequence = parameters.get("protein_sequence", "")
        if not protein_sequence:
            return "Error: No protein sequence provided for binding affinity prediction."
        return run_binding_affinity_prediction(protein_sequence, smiles_list)
    else:
        return f"Unknown task: {task}"

def run_admet_prediction(smiles_list: list) -> str:
    """
    Runs ADMET prediction for the given SMILES strings and generates
    a user-friendly explanation of the results.
    """
    unique_id = str(uuid.uuid4())[:8]
    
    smiles = smiles_list[0] if smiles_list else ""
    
    try:
        df, _, _ = automate_download(unique_id, smiles)
        
        if df is None:
            return "Failed to generate ADMET predictions. Please try again later."
        
        predictions = extract_key_admet_predictions(df)
        
        return generate_admet_explanation(smiles, predictions)
    
    except Exception as e:
        return f"Error generating ADMET predictions: {str(e)}"

def run_binding_affinity_prediction(protein_sequence: str, smiles_list: List[str]) -> str:
    """
    Runs binding affinity prediction for the given protein sequence and SMILES strings
    and generates a user-friendly explanation of the results.
    """
    try:
        model = Plapt(use_tqdm=False)
        
        results = model.score_candidates(protein_sequence, smiles_list)
        
        if not results:
            return "Failed to generate binding affinity predictions. Please try again later."
        
        formatted_results = []
        for i, (smiles, result) in enumerate(zip(smiles_list, results)):
            formatted_results.append({
                "molecule": smiles,
                "neg_log10_affinity_M": result["neg_log10_affinity_M"],
                "affinity_uM": result["affinity_uM"]
            })
        
        return generate_binding_affinity_explanation(protein_sequence, formatted_results)
    
    except Exception as e:
        return f"Error generating binding affinity predictions: {str(e)}"

def extract_key_admet_predictions(df: pd.DataFrame) -> Dict[str, Any]:
    """
    Extracts key ADMET predictions from the dataframe.
    Returns a dictionary of important predictions.
    """
    predictions = {}
    
    # Basic properties
    predictions["Molecular_weight"] = df.iloc[0]['MW']
    predictions["Formula"] = df.iloc[0]['Formula']
    predictions["Num_H_donors"] = df.iloc[0]['#H-bond donors']
    predictions["Num_H_acceptors"] = df.iloc[0]['#H-bond acceptors']
    predictions["Num_Rotatable_bonds"] = df.iloc[0]['#Rotatable bonds']
    predictions["Fraction_Csp3"] = df.iloc[0]['Fraction Csp3']
    predictions["Num_Heavy_atoms"] = df.iloc[0]['#Heavy atoms']
    predictions["Num_Aromatic_heavy_atoms"] = df.iloc[0]['#Aromatic heavy atoms']
    
    # Physicochemical properties
    predictions["TPSA"] = df.iloc[0]['TPSA']
    predictions["MR"] = df.iloc[0]['MR']
    
    # Lipophilicity
    predictions["iLOGP"] = df.iloc[0]['iLOGP']
    predictions["XLOGP3"] = df.iloc[0]['XLOGP3']
    predictions["WLOGP"] = df.iloc[0]['WLOGP']
    predictions["MLOGP"] = df.iloc[0]['MLOGP']
    predictions["Silicos_IT_LogP"] = df.iloc[0]['Silicos-IT Log P']
    predictions["Consensus_LogP"] = df.iloc[0]['Consensus Log P']
    
    # Water Solubility
    predictions["ESOL_LogS"] = df.iloc[0]['ESOL Log S']
    predictions["ESOL_Solubility_mg_ml"] = df.iloc[0]['ESOL Solubility (mg/ml)']
    predictions["ESOL_Class"] = df.iloc[0]['ESOL Class']
    predictions["Ali_LogS"] = df.iloc[0]['Ali Log S']
    predictions["Ali_Solubility_mg_ml"] = df.iloc[0]['Ali Solubility (mg/ml)']
    predictions["Ali_Class"] = df.iloc[0]['Ali Class']
    predictions["Silicos_IT_LogSw"] = df.iloc[0]['Silicos-IT LogSw']
    predictions["Silicos_IT_Solubility_mg_ml"] = df.iloc[0]['Silicos-IT Solubility (mg/ml)']
    predictions["Silicos_IT_Class"] = df.iloc[0]['Silicos-IT class']
    
    # Pharmacokinetics
    predictions["GI_absorption"] = df.iloc[0]['GI absorption']
    predictions["BBB_permeant"] = df.iloc[0]['BBB permeant']
    predictions["Pgp_substrate"] = df.iloc[0]['Pgp substrate']
    predictions["CYP1A2_inhibitor"] = df.iloc[0]['CYP1A2 inhibitor']
    predictions["CYP2C19_inhibitor"] = df.iloc[0]['CYP2C19 inhibitor']
    predictions["CYP2C9_inhibitor"] = df.iloc[0]['CYP2C9 inhibitor']
    predictions["CYP2D6_inhibitor"] = df.iloc[0]['CYP2D6 inhibitor']
    predictions["CYP3A4_inhibitor"] = df.iloc[0]['CYP3A4 inhibitor']
    predictions["log_Kp"] = df.iloc[0]['log Kp (cm/s)']
    
    # Drug Likeness
    predictions["Lipinski_violations"] = df.iloc[0]['Lipinski #violations']
    predictions["Ghose_violations"] = df.iloc[0]['Ghose #violations']
    predictions["Veber_violations"] = df.iloc[0]['Veber #violations']
    predictions["Egan_violations"] = df.iloc[0]['Egan #violations']
    predictions["Muegge_violations"] = df.iloc[0]['Muegge #violations']
    predictions["Bioavailability_Score"] = df.iloc[0]['Bioavailability Score']
    
    # Medicinal Chemistry
    predictions["PAINS_alerts"] = df.iloc[0]['PAINS #alerts']
    predictions["Brenk_alerts"] = df.iloc[0]['Brenk #alerts']
    predictions["Leadlikeness_violations"] = df.iloc[0]['Leadlikeness #violations']
    predictions["Synthetic_Accessibility"] = df.iloc[0]['Synthetic Accessibility']
    
    return predictions

def generate_admet_explanation(smiles: str, predictions: Dict[str, Any]) -> str:
    """
    Uses LLM to generate a user-friendly explanation of ADMET predictions.
    """
    pred_text = "\n".join([f"{k}: {v}" for k, v in predictions.items()])
    
    prompt = f"""
    You are a pharmacology expert explaining ADMET predictions to a researcher.
    Below are the predictions for SMILES: {smiles}
    
    {pred_text}
    
    Please provide a concise yet comprehensive explanation of these results:
    1. Start with a brief overview of what ADMET properties were predicted
    2. Explain the important findings (highlight any potential issues), interpret the scores for given smile
    3. Interpret the Lipinski rule compliance and bioavailability score
    4. Mention any significant enzyme inhibition risks
    5. Provide overall assessment of the molecule's drug-likeness
    6. Keep it technical, concise and dense. Provide all important predicted values to the user
    
    """
    try:
        explanation = call_gemini_api(prompt)
        return explanation
    except Exception as e:
        print(f"Error generating explanation: {e}")
        return f"ADMET Predictions for {smiles}:\n\n{pred_text}"

def generate_binding_affinity_explanation(protein_sequence: str, predictions: List[Dict[str, Any]]) -> str:
    """
    Uses LLM to generate a user-friendly explanation of binding affinity predictions.
    """
    pred_text = ""
    for i, pred in enumerate(predictions):
        pred_text += f"Molecule {i+1} ({pred['molecule']}):\n"
        pred_text += f"- pKd (neg_log10_affinity_M): {pred['neg_log10_affinity_M']:.2f}\n"
        pred_text += f"- Affinity (µM): {pred['affinity_uM']:.4f}\n\n"
    
    display_protein = protein_sequence[:50] + "..." if len(protein_sequence) > 50 else protein_sequence
    
    prompt = f"""
    You are a computational chemist explaining protein-ligand binding affinity predictions to a researcher.
    Below are the predictions for protein: {display_protein}
    Against {len(predictions)} molecule(s):
    
    {pred_text}
    
    Please provide a concise yet comprehensive explanation of these results:
    1. Start with a brief overview of what binding affinity means (pKd and affinity in µM)
    2. Explain the results for each molecule (higher pKd values indicate stronger binding)
    3. Compare the molecules if there are multiple (which ones bind strongest/weakest)
    4. Provide context on what these affinity values typically mean in drug discovery:
       - pKd > 9: Very strong binding
       - pKd 7-9: Strong binding
       - pKd 5-7: Moderate binding
       - pKd < 5: Weak binding
    5. Offer a brief interpretation of what these results suggest for further research
    6. Keep it technical, concise and dense. Provide all important predicted values to the user
    """
    
    try:
        explanation = call_gemini_api(prompt)
        return f"Binding Affinity Predictions for Protein-Ligand Interactions:\n\n{explanation}"
    except Exception as e:
        print(f"Error generating explanation: {e}")
        return f"Binding Affinity Predictions:\n\n{pred_text}"