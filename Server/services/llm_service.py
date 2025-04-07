import json
from typing import Dict, Any, Tuple, Optional
import os
import time
from google import genai

from services.chat_session import ChatSession
from utils.chem_utils import validate_smiles
from services.ml_service import run_ml_model, call_gemini_api

class LLMService:
    def __init__(self, api_key=None):
        """Initialize the LLM service with Gemini API."""
        if api_key is None:
            api_key = os.environ.get("GEMINI_API_KEY")
            
        if not api_key:
            raise ValueError("Gemini API key is required. Set it as an environment variable or pass it to the constructor.")
            
        self.client = genai.Client(api_key=api_key)
        self.model = "gemini-2.0-flash"
        
    def call_llm_api(self, prompt: str) -> str:
        """
        Calls the Gemini API with the given prompt.
        Returns the LLM's response as a string.
        """
        try:
            response = self.client.models.generate_content(
                model=self.model,
                contents=prompt 
            )
            
            if response.text:
                return response.text
            else:
                return ""
        except Exception as e:
            print(f"Error calling Gemini API: {e}")
            return ""

    def extract_smiles_with_llm(self, user_message: str) -> Dict[str, str]:
        """
        Uses Gemini to extract SMILES strings from a user message.
        Returns a dictionary with a list of valid SMILES strings.
        """
        prompt = f"""
        From the following message, extract any SMILES representations of molecules.
        Return your answer as a JSON object with a list of SMILES strings in the format:
        {{
            "smiles": ["first_smiles_string", "second_smiles_string", ...]
        }}
        If no valid SMILES strings are found, return {{"smiles": []}}.
        
        User message: {user_message}
        """
        
        llm_response = self.call_llm_api(prompt)
        
        try:
            response_text = llm_response.strip()
            json_start = response_text.find('{')
            json_end = response_text.rfind('}') + 1
            
            if json_start >= 0 and json_end > json_start:
                json_str = response_text[json_start:json_end]
                result = json.loads(json_str)
                smiles_list = result.get("smiles", [])
            else:
                smiles_list = []
            
            valid_smiles = [smiles for smiles in smiles_list if validate_smiles(smiles)]
            
            return {"smiles": valid_smiles}
        except json.JSONDecodeError:
            print("Failed to parse JSON from LLM response")
            return {"smiles": []}
        except Exception as e:
            print(f"Error extracting SMILES: {e}")
            return {"smiles": []}

    def extract_protein_and_smiles_with_llm(self, user_message: str) -> Dict[str, Any]:
        """
        Uses Gemini to extract a protein sequence and SMILES string from a user message.
        Returns a dictionary with the protein sequence and a SMILES string.
        """
        prompt = f"""
        From the following message, extract:
        1. A protein sequence (amino acid sequence)
        2. A SMILES representation of a molecule

        Return your answer as a JSON object in the format:
        {{
            "protein_sequence": "extracted protein sequence",
            "smiles": "extracted smiles string"
        }}
        
        If no protein sequence is found, return {{"protein_sequence": ""}}.
        If no SMILES string is found, return {{"smiles": ""}}.
        
        User message: {user_message}
        """
        
        llm_response = self.call_llm_api(prompt)
        
        try:
            response_text = llm_response.strip()
            json_start = response_text.find('{')
            json_end = response_text.rfind('}') + 1
            
            if json_start >= 0 and json_end > json_start:
                json_str = response_text[json_start:json_end]
                result = json.loads(json_str)
                protein_sequence = result.get("protein_sequence", "")
                smiles = result.get("smiles", "")
            else:
                protein_sequence = ""
                smiles = ""
            
            if smiles and not validate_smiles(smiles):
                smiles = ""
            
            return {
                "protein_sequence": protein_sequence,
                "smiles": smiles
            }
        except json.JSONDecodeError:
            print("Failed to parse JSON from LLM response")
            return {"protein_sequence": "", "smiles": ""}
        except Exception as e:
            print(f"Error extracting protein and SMILES: {e}")
            return {"protein_sequence": "", "smiles": ""}

    def generate_llm_response(self, user_message: str, chat_history=None) -> str:
        """
        Generates a response using the LLM for general chat interactions.
        """
        if chat_history is None:
            chat_history = []
            
        system_prompt = """
        You are a helpful assistant for drug discovery researchers. 
        Provide informative and scientifically accurate responses about chemistry, 
        biochemistry, pharmacology, and related topics. 
        If you don't know the answer, say so rather than providing incorrect information.
        Always be concise.
        """
        
        prompt = system_prompt + "\n\n"
        
        for message in chat_history:
            if "role" in message and "content" in message:
                role = message["role"].capitalize()
                content = message["content"]
                prompt += f"{role}: {content}\n\n"
        
        prompt += f"User: {user_message}\n\nAssistant: "
        
        try:
            response = self.client.models.generate_content(
                model=self.model,
                contents=prompt
            )
            
            if response.text:
                return response.text
            else:
                return "I apologize, but I couldn't generate a response. Please try again."
        except Exception as e:
            print(f"Error generating response: {e}")
            return "I encountered an error while processing your request. Please try again."

llm_service = None

def get_llm_service(api_key=None):
    """Get or create the LLM service instance."""
    global llm_service
    if llm_service is None:
        llm_service = LLMService(api_key)
    return llm_service

async def process_message(user_message: str, session: ChatSession, ml_button_clicked: bool = False) -> Tuple[str, Dict[str, Any]]:
    """
    Processes a user message and returns an appropriate response.
    Returns the response and any ML results (if applicable).
    """
    service = get_llm_service()
    
    if hasattr(session, 'add_message'):
        session.add_message({"role": "user", "content": user_message})
    
    ml_tasks = {
        "@admet_prediction": "ADMET Prediction",
        "@binding_affinity": "Binding Affinity Prediction",
    }
    
    detected_task = None
    for task_key in ml_tasks.keys():
        if task_key in user_message.lower():
            detected_task = task_key
            break
    
    if detected_task:
        if detected_task == "@binding_affinity":
            extracted_data = service.extract_protein_and_smiles_with_llm(user_message)
            protein_sequence = extracted_data.get("protein_sequence", "")
            smiles = extracted_data.get("smiles", "")
            
            if not protein_sequence:
                return "No protein sequence found. Please provide a valid protein sequence for binding affinity prediction.", {}
            
            if not smiles:
                return "No valid SMILES string found. Please provide a valid SMILES string for binding affinity prediction.", {}
            
            try:
                result = run_ml_model({
                    "task": detected_task,
                    "protein_sequence": protein_sequence,
                    "smiles": [smiles]
                })
                
                ml_response = {
                    "task": ml_tasks[detected_task],
                    "protein_sequence": protein_sequence,
                    "smiles": smiles,
                    "result": result,
                    "timestamp": time.time()
                }
                
                if hasattr(session, 'add_ml_result'):
                    session.add_ml_result(ml_response)
                
                response = f"{ml_tasks[detected_task]} Results:\n"
                response += f"Protein: {protein_sequence[:30]}...\n" if len(protein_sequence) > 30 else f"Protein: {protein_sequence}\n"
                response += f"SMILES: {smiles}\n"
                response += f"Prediction: {result}"
            except Exception as e:
                response = f"Error running {ml_tasks[detected_task]} model: {str(e)}"
        else:
            extracted_data = service.extract_smiles_with_llm(user_message)
            smiles_list = extracted_data.get("smiles", [])
            
            if not smiles_list:
                return "No valid SMILES strings found. Please provide valid SMILES strings.", {}
            
            try:
                result = run_ml_model({
                    "task": detected_task,
                    "smiles": smiles_list
                })
                
                ml_response = {
                    "task": ml_tasks[detected_task],
                    "smiles": smiles_list,
                    "result": result,
                    "timestamp": time.time()
                }
                
                if hasattr(session, 'add_ml_result'):
                    session.add_ml_result(ml_response)
                
                response = f"{ml_tasks[detected_task]} Results:\n"
                response += f"SMILES: {', '.join(smiles_list)}\n"
                response += f"Prediction: {result}"
            except Exception as e:
                response = f"Error running {ml_tasks[detected_task]} model: {str(e)}"
    else:
        chat_history = session.get_chat_history() if hasattr(session, 'get_chat_history') else []
        breakpoint()
        response = service.generate_llm_response(user_message, chat_history)
    
    if hasattr(session, 'add_message'):
        session.add_message({"role": "assistant", "content": response})
    
    return response, {}


async def generate_chat_summary(messages: list) -> dict:
    """
    Generate an article summary based on chat messages.
    
    Args:
        messages: List of chat messages with role and content
    
    Returns:
        Dictionary containing article title and content
    """
    chat_content = ""
    for msg in messages:
        role = "User" if msg.role == "user" else "Assistant"
        chat_content += f"{role}: {msg.content}\n\n"
    
    prompt = f"""
    Based on the following conversation about drug discovery, generate a medium-length article that 
    summarizes the key points and insights. The article should be well-structured, informative, and 
    suitable for publication on a scientific blog or newsletter.
    
    CONVERSATION:
    {chat_content}
    
    Please generate:
    1. An engaging title for the article (prefixed with "TITLE: ")
    2. A comprehensive article that covers the main topics discussed, key insights, and conclusions
    
    Make sure the article is factually accurate, cites any specific molecules or methods mentioned in the 
    conversation, and maintains a professional tone suitable for a scientific audience.
    """
    
    response = call_gemini_api(prompt)
    
    try:
        title_marker = "TITLE: "
        title_start = response.find(title_marker)
        
        if title_start >= 0:
            title_start += len(title_marker)
            title_end = response.find("\n", title_start)
            if title_end < 0:
                title_end = len(response)
            
            title = response[title_start:title_end].strip()
            
            content = response[title_end:].strip()
        else:
            title = "Article Summary of Drug Discovery Conversation"
            content = response
        
        return {
            "title": title,
            "content": content
        }
    except Exception as e:
        print(f"Error processing article response: {e}")
        return {
            "title": "Article Summary (Error Occurred)",
            "content": "An error occurred while generating the article. Please try again."
        }